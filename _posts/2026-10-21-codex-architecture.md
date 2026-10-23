---
title: "Codex 架构（一）：从 TUI、App Server 到 Agent 运行时"
description: "沿一次代码修复请求，拆解 Codex 的客户端、协议、核心循环、工具执行与状态边界，理解一套 Harness 如何支撑多种产品界面。"
date: 2026-10-21 21:00:00 +0800
categories: [原理与架构]
tags: [Codex, Agent, Harness, Rust, 源码解读]
toc: true
image:
  path: /assets/img/posts/codex-architecture/hero.png
  alt: "终端、桌面窗口和编辑器连接同一套 Agent 工作台的手绘概念图"
---

上一篇[《Agent Harness：让大模型把事情做完的那层工程》](/posts/agent-harness/)讨论了一个问题：模型能够提出修改方案，系统还要补上哪些能力，才能把修改落实并留下证据？

Codex 是观察这些能力如何落地的一个具体样本。你可以在终端里输入 `codex`，在桌面端管理多个任务，也可以把它接入自己的应用。表面上是不同界面，底下都要处理模型调用、工具执行、权限、历史与中断。

这篇作为 **Codex 系列的第一篇**，先建立架构地图。仍然沿用“修复 CSV 导出缺少一列”的例子：从用户按下发送开始，依次看请求怎样进入运行时、工具怎样执行、进展怎样回到界面，以及哪些状态能在下次继续使用。

本文基于 2026 年 10 月 21 日查阅的官方资料，以及 `openai/codex` 的固定提交 [`d138398cef7d`](https://github.com/openai/codex/tree/d138398cef7d49e46fe33f1d0ddbd2ca0ed16aa4)。文中的源码链接均指向该快照，不代表某个已发布桌面客户端内置的版本。桌面端按闭源产品边界讨论，只引用官方公开的集成方式；本文没有审计它的内部代码。图中省略了非主线能力，示例不是实际运行日志。

## 1. 先把 Codex 的几个名字拆开

“Codex”可能指产品，也可能指其中的开源运行时。如果直接把它画成一个大盒子，后面很容易把界面、协议和模型混在一起。

| 名称 | 主要负责什么 | 本文的观察入口 |
| --- | --- | --- |
| Codex CLI | 命令行入口，选择交互、批处理或服务等运行方式 | `codex-rs/cli/` |
| TUI | 终端中的输入、快捷键、历史与进度呈现 | `codex-rs/tui/` |
| Codex App Server | 把会话操作、事件和审批暴露给客户端 | `codex-rs/app-server/` |
| Codex core | 运行会话，协调模型、上下文、工具和状态 | `codex-rs/core/` |
| 桌面端、IDE 扩展 | 面向人的产品界面与工作流 | 官方产品与集成说明 |
| 模型服务 | 接收模型输入，返回文本或工具调用等输出 | core 的模型客户端及提供方接口 |

这里有两个容易误解的地方。

**CLI 和 TUI 不是同义词。** CLI 是命令行程序这个入口；不带子命令时可以进入交互式 TUI，也可以通过 `codex exec` 执行非交互任务，或通过 `codex app-server` 启动协议服务。不能把整个 `codex` 二进制只理解成终端聊天窗口。对应分发逻辑可从 [`cli/src/main.rs`][cli] 阅读。

**App Server 不是模型推理服务器。** 它向客户端暴露的是 Codex 的工作能力，例如开始会话、提交一轮任务、返回文件变化、请求审批。模型推理发生在另一侧：core 根据配置调用模型服务。两边即使都采用流式通信，也属于不同接口。

开源范围也需要说准确：官方[开源组件列表][oss]列出了 CLI、SDK、App Server 等组件，并明确 IDE 扩展和 Codex cloud 并未开源。桌面产品能使用开源 Harness，不意味着桌面 UI、云端控制面或模型权重都包含在 `openai/codex` 仓库里。

## 2. 一套 Harness，怎样接到不同界面上？

先看部署形态，再看内部模块。**逻辑上的客户端与服务端，不一定对应两个操作系统进程。**

![TUI 通过进程内客户端复用 App Server，桌面集成跨进程使用 stdio，远程客户端经网络连接服务](/assets/img/posts/codex-architecture/surfaces.png){: width="4480" height="3486" }
_部署形态图：上方是当前代码中的进程内路径，中间是官方公开的本地客户端集成方式，下方是远程连接模式。逻辑职责相近，进程与网络边界不同。_

### TUI：协议统一以后，仍然可以留在同一个进程

当前快照的 [`app-server-client/README.md`][inproc]明确写出，这个共享客户端用于 `codex-tui` 和 `codex-exec`，负责启动进程内 App Server、连接内存通道以及管理关闭流程。

它的内部传输使用 `ClientRequest`、`ClientNotification` 和 `InProcessServerEvent` 等类型，不要求每条消息都先转成 JSON 文本再解析回来。不过响应仍保留 App Server 的结果信封语义。这样，客户端复用了相同的请求和事件契约，又不必为了本地调用额外创建服务进程。

TUI 的 [`app_server_session.rs`][tui-session]还把请求细节封装在会话门面里。例如提交一轮输入时，构造的是 `ClientRequest::TurnStart`。终端输入框不需要亲自编排模型调用和工具执行。

这也是阅读资料时要注意版本的地方：2026 年 2 月的官方[App Server 工程文章][app-server-blog]还在描述 TUI 从直接使用 Rust core 类型向 App Server 迁移的计划。当前代码已经出现共享的进程内客户端，不能继续照搬“所有 TUI 都直接调用 core”，也不能据此推断“现在的 TUI 一定另起子进程”。

### 桌面端：界面与运行时之间有真实的进程边界

上述官方工程文章公开的本地集成方式是：桌面端或 IDE 客户端携带平台对应的 Codex 二进制，启动长时间运行的 App Server 子进程，经双向 stdio 交换消息。客户端随产品打包经过验证的版本，不必跟着仓库 `main` 同步变化。

这里能确认的是集成边界。它不能证明桌面端内部的全部模块怎样划分，也不能把某份逆向分析中的私有 IPC 名称当成稳定接口。本文因此把桌面端画到 App Server 边界为止。

### 远程：把运行时放到工作区附近

官方[App Server 文档][app-server-docs]还提供远程 TUI 连接方式：客户端留在一台机器，App Server 运行在另一台机器。当前文档将 WebSocket 传输标为实验性、不受支持；这条路径适合理解架构，不能直接当作生产服务承诺。

我的理解是，这三种形态真正统一的是“怎样驱动一个 Agent 会话”。一旦请求和事件不再依赖某个 UI 的内部对象，同一套执行能力就更容易被桌面、终端和其他产品复用。

## 3. App Server 暴露的不是一串聊天文本

如果界面只能收到“正在处理……”和最终回答，就很难准确展示命令、文件变化、审批和中断。Codex 用 **Thread、Turn、Item** 来组织这些信息。

![一个 Thread 包含多次 Turn，每次 Turn 又包含用户输入、命令、文件变化和 Agent 消息等 Item](/assets/img/posts/codex-architecture/thread-model.png){: width="4480" height="3504" }
_会话结构图：嵌套关系表达数据归属；Item 的事件表达生命周期。模型调用次数不等于 Turn 数量。_

**Thread 是一段会话。** “修复导出功能”可以在同一个 Thread 中讨论多轮。它是产品协议概念，不是 Rust 的操作系统线程，也不代表一个独立进程。

**Turn 是一次输入所触发的一段 Agent 工作。** 你说“先定位原因”，算一轮；之后说“修改并跑测试”，可以再开始一轮。每轮内部可能反复调用模型和工具，不能把一次模型 API 请求等同于一个 Turn。

**Item 是具有类型的一项输入或输出。** 例如 `userMessage`、`agentMessage`、`commandExecution`、`fileChange`、`mcpToolCall`。界面可以把命令呈现成执行卡片，把修改呈现成 diff，而不是从普通文本中猜测发生了什么。

协议定义可以从 [`app-server-protocol`][protocol] 查看。当前 [`TurnStatus`][turn-types]包含 `inProgress`、`completed`、`interrupted` 和 `failed`。这个区别对客户端很重要：收到 `turn/completed` 通知表示这一轮进入终态，仍然要读取状态字段，不能单凭方法名就显示“修复成功”。即使状态是 `completed`，也不自动证明测试覆盖充分或业务问题已经消失。

一个值得保留的设计经验是：**协议里的“执行结束”，应该与产品里的“验收通过”分别表达。** 上一篇讲的验收约定，在真实 Harness 中仍需要任务自身提供。

## 4. 一次请求怎样变成持续更新的界面？

现在让用户输入：“补上 CSV 的 currency 列，并验证导出结果。”

在跨进程的 App Server 接口上，客户端先完成连接初始化，然后开始或恢复 Thread，再提交 `turn/start`。它必须持续读取事件，而不是发送请求之后只等一个最终字符串。

![客户端与 App Server 双向交换请求、响应和通知，工具审批是服务端主动发出的请求](/assets/img/posts/codex-architecture/turn-sequence.png){: width="4480" height="4206" }
_协议时序图：示意一轮可能出现的事件；审批按配置发生，图中省略了部分响应字段和其他通知，不代表每轮固定出现这些消息。_

当前协议沿用 JSON-RPC 的请求、响应与通知形状，但线上消息省略 `"jsonrpc":"2.0"` 字段。默认 stdio 使用一行一条 JSON；**JSON-RPC 描述消息规则，stdio 描述传输方式，它们不是同一层。**

下面是阅读协议时可以对照的简化消息。`thr_demo` 是占位 ID，实际应使用服务端返回值；它们不是一段可直接粘贴运行的完整客户端。

```json
{"id":1,"method":"initialize","params":{"clientInfo":{"name":"architecture_demo","version":"0.1.0"}}}
{"method":"initialized","params":{}}
{"id":2,"method":"thread/start","params":{}}
{"id":3,"method":"turn/start","params":{"threadId":"thr_demo","input":[{"type":"text","text":"补上 currency 列，并验证导出结果"}]}}
```

客户端应先等待初始化成功，再推进后续请求；拿到 Thread ID 后才能提交这一轮。更完整的参数、能力协商与实验字段应以当前版本的 schema 为准。官方提供 `codex app-server generate-ts --out ./schemas` 和 `generate-json-schema` 导出对应版本的类型。[协议入口][protocol]

这条通道有三种消息，客户端必须区别处理：

| 消息 | 识别方式 | 客户端需要做什么 |
| --- | --- | --- |
| 自己发起请求的响应 | 通过 `id` 对应此前请求，包含 `result` 或 `error` | 完成对应的等待操作 |
| 服务端通知 | 有 `method`，没有请求 `id` | 根据 Thread、Turn、Item ID 更新界面 |
| 服务端发起的请求 | 有 `method` 和 `id`，例如审批 | 展示交互，并用同一个 `id` 回传决定 |

其中第三种最容易被写错。`item/commandExecution/requestApproval` 不是一条“打印到日志就算处理”的通知，它要求客户端回应。若客户端只支持单向“发任务、收文本”，用户可能看起来一直在等待，服务端其实正在等待一个永远不会到达的决定。[请求与通知定义][protocol]

对文本流也是一样：`item/agentMessage/delta` 用来增量显示；`item/completed` 用来收束这一项；`turn/completed` 用来收束这一轮。我的客户端实现会围绕 ID 维护状态，而不是把所有事件无差别追加到一个字符串里。因为一轮可能同时包含文字、工具进展和等待输入，只有字符串无法表达这些关系。

## 5. core 才是把工作往前推进的地方

App Server 接收请求并把运行进展转换为客户端事件；具体该给模型哪些信息、怎样接住工具调用、怎样继续下一步，则进入 core 的运行逻辑。

![上下文进入模型调用，工具请求经过执行侧处理后把结果送回历史，循环中同步产生面向客户端的事件](/assets/img/posts/codex-architecture/runtime-loop.png){: width="4540" height="3516" }
_核心循环图：按职责归纳，不是逐函数调用图。文本输出、工具调用、取消和失败会形成不同分支。_

在本文快照里，core 的 [`lib.rs`][core-root]已经能看出这些职责的聚合：`session`、模型 `client`、`context_manager`、`tools`、`sandboxing`、`skills`、`mcp`、`thread_manager` 等模块共同支撑工作。目录不是部署服务清单；很多模块都在同一运行时里协作。

从导出任务看，可以把主线理解成四步：

1. **形成这一轮可用的上下文。** 用户要求、项目说明、会话历史、可用工具及新读到的代码，不是天然就完整地摆在模型面前，运行时需要组织它们。
2. **调用模型并消费响应。** 输出可能是面向用户的内容，也可能是工具调用。这里的流式结果与 App Server 发给 UI 的事件是两套接口，不能直接画成同一条流。
3. **把工具请求交给执行侧。** 具体工具解析参数、处理策略和执行环境，返回真实输出或失败信息。模型说“运行测试”并不等于测试已经运行。
4. **把新结果加入后续决策。** 模型看到缺失字段、补丁结果和测试输出后，再决定下一步。循环要能处理中断和错误，不能只写“有工具就永远继续”。

这段主线与官方 [Unrolling the Codex agent loop][loop-blog]介绍的模型—工具反馈循环一致。当前源码已经持续拆分演进，想继续读实现，可以从 [`core/src/session/`][session-dir]进入，而不要依赖旧教程中某个大文件永远存在。

我最看重这里的职责划分：界面不负责解释模型的工具协议，模型也不负责落实文件权限。**每个边界都把不适合交给下一层猜测的信息，转换成明确的数据或动作。** 这比“外面包了一个 while 循环”更接近 Harness 的工程价值。

## 6. 关掉界面以后，究竟留下了什么？

“历史还在”“任务还在运行”和“文件已经修改”是三件不同的事。

![界面投影、内存运行状态、持久化会话与工作区文件分别保存不同信息，恢复会话不会自动撤销外部操作](/assets/img/posts/codex-architecture/persistence.png){: width="4560" height="3548" }
_状态边界图：能恢复会话，不等于能恢复一个已经消失的进程；记录进度，也不等于能回滚所有副作用。_

**界面状态**包括当前选中的 Thread、展开的命令卡片、尚未提交的输入等。**运行状态**包括进行中的一轮工作、待处理事件、等待中的审批和工具进程。**持久化状态**让系统能够重新找到会话与历史。**工作区状态**则是磁盘上的实际文件和 Git 改动。

这些状态彼此关联，但不能相互替代。当前源码的 [`ThreadManager`][thread-manager]承担会话管理；[`core/src/rollout.rs`][rollout]接入 `codex-rollout` 的记录能力；[`codex-state`][state]提供 SQLite 状态能力。存储实现仍在演进，不能把“某个 JSONL 文件”描述成所有功能唯一的数据源，也不应让第三方客户端直接修改这些内部文件。

客户端集成优先使用 `thread/read`、历史分页、`thread/resume` 等接口。读取历史和恢复一个可继续执行的会话是不同动作；协议还区分已持久化的会话与当前已加载到内存的会话。[Thread 接口][thread-types]

对于断连，我会分别问两个问题：

- **只是客户端断开，还是执行进程也退出了？** 远端服务仍存活与本机进程整体结束，恢复条件不同。不能承诺“关闭任何 Codex 窗口都能继续跑”。
- **恢复时，记录和外部现场是否一致？** 测试进程可能已经结束，文件可能又被人改过，远程操作也可能已经成功。恢复历史不等于可以无条件重放所有工具调用。

这正是长任务系统的难点：要把“系统知道什么”与“外部发生了什么”重新对齐。会话恢复解决了交接的一部分，工具副作用仍需要各自的执行与核对机制。

## 7. 审批、沙箱和外部工具，边界放在哪里？

导出任务中，允许查看代码、允许修改项目文件、允许运行测试，可能对应不同权限条件。它们不能被一句“用户让我修复”全部替代。

![动作请求先经过权限决策，获准后由受约束的执行环境运行；外部 MCP 服务还需要自己的授权与资源限制](/assets/img/posts/codex-architecture/security.png){: width="4480" height="3420" }
_执行边界图：审批决定是否允许，隔离机制约束能够访问什么。外部服务的权限不能由本地沙箱代替。_

审批是控制流程：根据策略，动作可能直接执行、被拒绝，或需要把请求交给客户端。沙箱是执行约束：工具进程实际能读写哪些资源、能否访问网络，应由对应机制落实。官方[安全文档][security-docs]也将审批与沙箱作为不同维度说明。

从 [`core/README.md`][core-readme]能看到平台差异：macOS 使用 Seatbelt 相关机制；Linux 存在 bubblewrap 与兼容的 Landlock 路径；Windows 使用相应的受限执行后端。具体选择受版本、配置和平台能力影响，所以不宜画成“所有工具统一放进 Docker”。

工具也未必都在本机执行。Codex 连接一个远程 MCP 服务后，那个服务对数据库、工单或其他系统的访问，依赖服务自身的身份和授权。我的集成设计会同时检查本地执行限制和远程工具权限，而不是看到 Codex 开启沙箱，就认为每个外部动作也被它隔离了。

另一个需要坚持的边界是：项目说明和 Skill 是上下文的一部分，不能因内容里写着“请执行”就自动获得运行时权限。工作方法可以指导动作，授权仍应由可信配置与执行侧决定。

## 8. App Server、MCP、Skill、SDK 分别接在哪？

上一篇已经区分过这些概念。放回 Codex，可以更清楚地看到各自接入的位置。

![客户端通过 App Server 驱动会话，Skill 提供工作方法，MCP 接入外部工具，TypeScript SDK 封装非交互 CLI](/assets/img/posts/codex-architecture/integrations.png){: width="4500" height="3484" }
_接入关系图：不同接口服务不同方向。图中的 TypeScript SDK 指固定快照下的 `sdk/typescript`，不概括所有语言 SDK 的未来实现。_

**App Server 面向客户端。** 你要做自己的任务界面，希望展示历史、流式进度、文件变化和审批，主要关心这个边界。

**MCP 面向工具与资源接入。** Codex 可以作为 MCP 客户端使用外部能力；另一个方向上，`codex mcp-server` 可以让其他 Agent 把 Codex 当成工具调用。两者方向相反，不能用一个“MCP Server”盒子把它们合并。

**Skill 提供工作方法和配套材料。** 例如把“检查导出字段、空值和列顺序”的经验封装起来，供运行时按需要纳入上下文或使用配套资源。它和 MCP 可以配合，但没有“所有 Skill 都必须通过 MCP 执行”的要求。

**SDK 要看具体实现。** 当前快照的 [TypeScript SDK][sdk]封装 CLI，通过标准输入输出交换 JSONL 事件，向使用者提供 `startThread()`、`run()`、`runStreamed()` 等接口。不要因为它和 App Server 都传 JSON，就把两者的事件名称、协议或 API 覆盖范围当成完全一致。

如果让我给一个内部系统接入 Codex，我会先根据交互需求选择入口：

| 目标 | 我会优先考察的入口 | 需要自己补齐什么 |
| --- | --- | --- |
| 脚本里跑一次任务，留结果与日志 | `codex exec` | 输入约束、退出结果处理、产物验收 |
| 在 TypeScript 工作流里编排多轮调用 | 对应版本的 SDK | 业务状态与错误处理 |
| 做持续会话、审批和 diff 界面 | App Server | 客户端状态机、请求分发、断连恢复 |
| 给 Codex 增加组织内部的操作能力 | MCP 或其他已支持工具接口 | 服务端身份、资源范围与副作用控制 |

这个选择与官方 [Codex as a platform][platform-blog]给出的集成方向一致。我的取舍是：能用较窄接口解决的批处理任务，就先不要承担完整交互客户端的复杂度；但需要审批与持续状态时，也不要把一串日志勉强包装成会话系统。

## 9. 接下来怎样读源码，才不会迷失在目录里？

我会按请求经过的边界阅读，而不是从仓库根目录逐个打开文件。

![从 CLI 入口和 TUI 会话门面开始，沿协议与 App Server 进入 core，再分别阅读工具执行和状态持久化](/assets/img/posts/codex-architecture/reading-map.png){: width="4500" height="3540" }
_源码阅读路线：路径对应本文固定提交；连线表达推荐阅读顺序与职责联系，不表示每个文件都直接调用下一个文件。_

| 阅读顺序 | 源码入口 | 带着什么问题看 |
| --- | --- | --- |
| 1 | [`cli/src/main.rs`][cli] | 一个二进制怎样选择 TUI、exec 和 App Server？ |
| 2 | [`tui/src/app_server_session.rs`][tui-session]、[`app-server-client`][inproc] | 界面如何提交 typed request，如何隔离连接细节？ |
| 3 | [`app-server-protocol`][protocol] | 请求、通知、审批和状态到底长什么样？ |
| 4 | [`app-server/src/message_processor.rs`][processor] | 连接请求怎样进入服务端处理层？ |
| 5 | [`core/src/thread_manager.rs`][thread-manager]、[`core/src/session/`][session-dir] | 会话怎样创建与恢复，一轮工作怎样推进？ |
| 6 | [`core/src/tools/`][tools-dir]、[`core/src/rollout.rs`][rollout]、[`state/src/lib.rs`][state] | 动作怎样落地，历史与状态怎样留下来？ |

源码最值得借鉴的，不只是使用了哪些 crate，而是为什么要保留这些边界。

第一，**产品界面与 Agent 运行机制分开演进**，能让同一套执行能力服务多种交互方式；代价是协议兼容、版本协同和客户端状态处理。

第二，**把执行过程做成有类型、有 ID、有生命周期的事件**，界面才有机会正确表达运行、等待、中断和失败；代价是事件顺序、最终状态与历史恢复都要认真设计。

第三，**把会话状态、进程生命周期和工作区副作用分开考虑**，才能讨论真实的恢复能力，而不是只做一个“加载聊天记录”按钮。

这也是我把 Codex 视为 Harness 实现来学习的原因：它展示了模型周边的工程如何逐渐形成可复用的运行时和产品接口。后面的系列文章可以继续沿这张地图展开：先追一轮任务的执行，再读上下文与压缩、工具和权限、历史恢复，最后做一个最小 App Server 客户端，把这些边界实际连接起来。

## 资料与图源

以下资料分别用于理解设计背景、核对接口和定位实现。官方工程文章反映其发表时的设计；实现细节以本文固定源码快照为准。本文未运行完整 Codex 测试套件，也不包含性能对比结论。

- [OpenAI：Unrolling the Codex agent loop][loop-blog]（2026-01-23）：模型与工具循环的设计背景。
- [OpenAI：Unlocking the Codex harness][app-server-blog]（2026-02-04）：App Server 的起源、客户端集成和历史演进。
- [OpenAI Developers：Codex as a platform][platform-blog]：在自己的产品中使用开放 Harness 的集成思路。
- [官方 App Server 文档][app-server-docs]、[安全文档][security-docs]、[开源范围][oss]：当前公开接口与产品边界。
- [openai/codex 固定提交](https://github.com/openai/codex/tree/d138398cef7d49e46fe33f1d0ddbd2ca0ed16aa4)：上文源码入口均来自该快照；仓库采用 Apache-2.0 许可证。

封面为 AI 生成的原创概念插画；正文八张图为本文依据公开资料绘制的手绘风格示意图，不是官方架构原图或闭源客户端内部截图。

[cli]: https://github.com/openai/codex/blob/d138398cef7d49e46fe33f1d0ddbd2ca0ed16aa4/codex-rs/cli/src/main.rs
[inproc]: https://github.com/openai/codex/blob/d138398cef7d49e46fe33f1d0ddbd2ca0ed16aa4/codex-rs/app-server-client/README.md
[tui-session]: https://github.com/openai/codex/blob/d138398cef7d49e46fe33f1d0ddbd2ca0ed16aa4/codex-rs/tui/src/app_server_session.rs
[protocol]: https://github.com/openai/codex/blob/d138398cef7d49e46fe33f1d0ddbd2ca0ed16aa4/codex-rs/app-server-protocol/src/protocol/common.rs
[turn-types]: https://github.com/openai/codex/blob/d138398cef7d49e46fe33f1d0ddbd2ca0ed16aa4/codex-rs/app-server-protocol/src/protocol/v2/turn.rs
[thread-types]: https://github.com/openai/codex/blob/d138398cef7d49e46fe33f1d0ddbd2ca0ed16aa4/codex-rs/app-server-protocol/src/protocol/v2/thread.rs
[core-root]: https://github.com/openai/codex/blob/d138398cef7d49e46fe33f1d0ddbd2ca0ed16aa4/codex-rs/core/src/lib.rs
[core-readme]: https://github.com/openai/codex/blob/d138398cef7d49e46fe33f1d0ddbd2ca0ed16aa4/codex-rs/core/README.md
[session-dir]: https://github.com/openai/codex/tree/d138398cef7d49e46fe33f1d0ddbd2ca0ed16aa4/codex-rs/core/src/session
[thread-manager]: https://github.com/openai/codex/blob/d138398cef7d49e46fe33f1d0ddbd2ca0ed16aa4/codex-rs/core/src/thread_manager.rs
[rollout]: https://github.com/openai/codex/blob/d138398cef7d49e46fe33f1d0ddbd2ca0ed16aa4/codex-rs/core/src/rollout.rs
[state]: https://github.com/openai/codex/blob/d138398cef7d49e46fe33f1d0ddbd2ca0ed16aa4/codex-rs/state/src/lib.rs
[sdk]: https://github.com/openai/codex/blob/d138398cef7d49e46fe33f1d0ddbd2ca0ed16aa4/sdk/typescript/README.md
[processor]: https://github.com/openai/codex/blob/d138398cef7d49e46fe33f1d0ddbd2ca0ed16aa4/codex-rs/app-server/src/message_processor.rs
[tools-dir]: https://github.com/openai/codex/tree/d138398cef7d49e46fe33f1d0ddbd2ca0ed16aa4/codex-rs/core/src/tools
[loop-blog]: https://openai.com/index/unrolling-the-codex-agent-loop/
[app-server-blog]: https://openai.com/index/unlocking-the-codex-harness/
[platform-blog]: https://developers.openai.com/blog/codex-as-a-platform
[app-server-docs]: https://learn.chatgpt.com/docs/app-server
[security-docs]: https://learn.chatgpt.com/docs/security
[oss]: https://learn.chatgpt.com/docs/open-source
