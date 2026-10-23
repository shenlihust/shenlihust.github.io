---
title: "Codex 架构（二）：一轮任务怎样运行，又在什么时候结束？"
description: "沿一次 CSV 导出修复，追踪 turn/start、模型响应、工具回填与任务收尾，区分请求被接收、一次推理结束和整轮任务结束。"
date: 2026-10-22 20:30:00 +0800
categories: [原理与架构]
tags: [Codex, Agent, Harness, Rust, 源码解读]
toc: true
image:
  path: /assets/img/posts/codex-one-turn/hero.png
  alt: "一轮 Codex 任务中的模型、工具反馈循环与任务终态"
---

在[第一篇架构地图](/posts/codex-architecture/)中，我们把 Codex 拆成客户端、App Server、core 和工具执行层。这次沿着同一个例子往下走：

> CSV 导出少了 `customer_id` 一列，请定位原因、修复，并运行相关测试。

用户只发了一条消息，界面却可能先显示“查看导出逻辑”，再出现读文件、修改代码、运行测试，最后才给出总结。中间发生了几次模型调用？命令还在执行时，模型响应能不能已经结束？用户此时补充“不要改接口”，会不会必然另起一轮？

理解这些现象，需要先分清三个边界：**请求被接收、一次模型响应结束、整轮任务结束。它们不是同一个时刻。**

本文结合两篇官方工程文章展开：Michael Bolin 于 **2026 年 1 月 23 日**发布的 [Unrolling the Codex agent loop][loop-blog]，以及 Celia Chen 于 **2026 年 2 月 4 日**发布的 [Unlocking the Codex harness: how we built the App Server][server-blog]。前者提供循环的基本模型，后者解释客户端怎样驱动和观察这个循环。

具体实现沿用第一篇的固定提交 [`d138398cef7d`][snapshot]，资料核对日期为 2026 年 10 月 22 日。下文关于函数、分支与事件的判断以这一源码快照为准，不把年初文章中的简化流程当成所有版本的完整实现。CSV 修复过程和图中的调用次数均为教学示例，没有实际运行该修复任务。

## 1. 一轮任务里面，可以有很多次推理

先约定本文使用的三个词。

| 层次 | 表示什么 | 示例 |
| --- | --- | --- |
| Thread | 可以持续多轮的会话 | 一直讨论这个项目的导出功能 |
| Turn | 运行时管理的一轮工作 | 处理“定位、修复并测试”这次请求 |
| 模型调用 | 向模型提交输入，消费一次响应 | 读完源码以后，让模型判断修改位置 |

官方循环文章给出的基本关系是：用户输入进入模型；模型可以提出工具调用；运行时执行工具，把结果带回后续模型输入；如此往复，最终把控制权交还用户。[原文][loop-blog]用这条主线解释了为什么一次 Turn 可以跨越多次推理。

对于 CSV 示例，可以设想这样的过程：第一次模型调用提出查看导出代码；工具返回文件内容。第二次调用根据代码提出修改并验证；工具返回修改结果和测试输出。第三次调用整理结果并回答用户。真实执行可能拆成更多次，也可能把几个工具调用放在同一次响应中。

![一条 Turn 时间线覆盖三次模型调用，工具结果分别进入下一次调用；模型响应结束点位于整轮结束点之前](/assets/img/posts/codex-one-turn/turn-boundaries.png)
_原创示意：时间线表达包含关系，不代表实际耗时。第三次调用只是为了说明循环，没有“每轮固定调用三次”的规则。_

这里最容易误读的是界面上的文字。“我先检查一下导出函数”是一条进展消息，不足以证明这一轮已经结束。即便某次模型流已经收完，运行时也可能仍在等工具，或者准备下一次推理。

因此，观察 Codex 不能只看“有没有文本输出”，还要看输出属于哪个层次、后面是否有工作尚未完成。

## 2. `turn/start` 返回的是什么？

先限定场景：Thread 已经存在，当前没有正在运行的任务，客户端提交这次修复请求。初始化、建会话和恢复历史的细节留在本篇主线之外。

当前源码的请求入口位于 [`request_processors/turn_processor.rs`][turn-processor]。`turn_start_inner` 处理输入和本轮设置，随后调用 `thread.start_or_steer_turn(...)`。这里有两个值得停下来看的细节。

第一，提交结果区分 `Started`、`Steered` 和 `NotSubmitted`。在我们设定的空闲场景下，重点是新任务开始；但函数名已经提醒我们，实际入口还处理把输入送入正在进行的任务。不能机械地把“用户又发了一条消息”理解成“一定创建新 Turn”。

第二，正常返回的 `TurnStartResponse` 中，Turn 的状态是 `InProgress`。源码在这里还把 `items` 初始化为空，并标记 `items_view: NotLoaded`。这个返回值不是装着全部执行结果的完成报告，也不能用空数组判断“这一轮没有工作记录”。

![客户端提交 turn/start 后先获得 InProgress 的 Turn，core 继续运行并通过事件向客户端报告进展](/assets/img/posts/codex-one-turn/request-handoff.png)
_原创交接图：箭头区分请求回复和持续事件。图中只展示空闲 Thread 启动普通任务的主线，不规定异步回复与首个通知到达客户端的绝对先后顺序。_

再往里看，core 的 [`session/handlers.rs`][handlers]处理 `Op::TurnInput`，交给 [`session/turn_input.rs`][turn-input]判断怎样接纳输入。在启动普通任务的分支中，它创建 `RegularTask`。

`RegularTask` 并不等到模型吐出第一个字才宣告开始。[`tasks/regular.rs`][regular]先发送 `TurnStarted`，再做后续准备并进入 `run_turn`。源码注释给出的理由很具体：启动准备进行时，任务也应该已经可见、可以被中断。

从客户端角度看，这形成了清楚的职责分工：请求回复告诉它运行时接纳了什么；后续事件告诉它执行到了哪里。官方 App Server 文章把这种“一次请求产生多次更新”的模式作为界面集成的重要基础。[来源][server-blog]

## 3. `run_turn` 才是这轮工作的外层循环

进入 [`session/turn.rs`][turn]后，不要立刻陷入所有配置和错误分支。先抓住两层调用关系：

- `run_turn` 管整轮工作：准备下一步输入，调用模型，检查是否继续。
- `run_sampling_request` 及其下层 `try_run_sampling_request` 管模型请求和响应消费，并协调这一步产生的工具工作。

一次模型调用之前，core 要准备模型能够消费的上下文。它不只是把用户的最后一句话原样转发出去，还会使用会话历史、指令和工具相关信息。本文只保留这个入口；输入项怎样排列、技能怎样进入上下文、缓存怎样命中，会在后续文章单独拆开。

模型响应回来以后，core 消费的也不只是一个完整字符串。在响应处理分支中，可以看到 `ResponseEvent::OutputTextDelta`、输出项完成事件和 `ResponseEvent::Completed` 等不同信号。文字可以逐段显示；一个输出项完成后可以被识别为工具调用；整个响应结束后，还要汇总本次调用的状态。

![core 在模型响应中接收文本和工具调用，工具结果写入会话后形成下一次模型输入，客户端接收过程事件](/assets/img/posts/codex-one-turn/loop-sequence.png)
_原创时序图：中间的往返发生在同一 Turn 内。为便于阅读，只画一个工具调用；具体工具可能并发、等待审批或返回后台进程信息。_

这个拆分解释了一种常见现象：模型已经说出“接下来运行测试”，但测试仍在执行。模型负责提出下一步工作；工具由运行时调度。两者有各自的生命周期，进展文字不会替代工具执行结果。

阅读源码时，我更愿意把 `run_turn` 理解成“推进工作的控制循环”。模型响应是它的一项输入，工具结果和新增用户输入也是。这样比较容易理解为什么系统需要在模型外面维护任务状态，而不能把整轮逻辑藏在一次 API 调用里。

## 4. 工具结果怎样回到下一次推理？

关键连接点在 [`stream_events_utils.rs`][stream-utils] 的 `handle_output_item_done`。

当一个输出项完成时，代码先调用 `ToolRouter::build_tool_call`，判断它是否可以解释为工具调用。对于正常识别的调用，主线是：记录模型提出的调用，交给 `ToolCallRuntime`，保存对应 future，并把 `needs_follow_up` 设为 `true`。

这里记录“模型提出了什么”很重要。比如模型请求查看导出代码，随后工具返回文件内容。这两者需要在历史中对应起来，后续模型才能知道输出来自哪个请求。对于函数工具，`call_id` 就是这种关联的一部分。

![工具调用与工具输出用同一个 call_id 关联，两者一起进入会话历史，再作为下一次模型输入的依据](/assets/img/posts/codex-one-turn/tool-feedback.png)
_原创数据流图：`read_export` 和 `call_demo_1` 是教学用名称，不是仓库提供的工具接口。这里演示函数调用项的对应关系，未列出真实协议的完整字段。_

工具并不一定等到整个模型响应结束才开始。上述函数中的注释明确说明，通常 `handle_tool_call` 会立即分派；启用同步 post-model hook 的路径则会延后分派。因此，把实现画成“完整收完模型响应，再依次执行所有工具”并不准确。

不过，能够较早启动，也不等于可以忽略结果。`try_run_sampling_request` 在流处理结束后检查尚未完成的工具 future；如果还有，就调用 `drain_in_flight`。该函数等待结果，并把返回项通过 `record_annotated_conversation_items` 写入会话。随后外层循环才能基于更新后的历史继续。[源码][turn]

还要区分两种“结束”：工具调用返回了，不一定意味着它启动的操作系统进程已经退出。某些执行工具可以返回仍在运行的会话信息，后续需要继续读取。这里等待的是本次工具调用的返回结果，不能据此推出“所有后台命令都已完成”。

回到 CSV 示例，修改工具返回“补丁已应用”之后，模型才有依据知道写入是否成功；测试工具返回输出之后，模型才有依据判断验证结果。模型在调用前预测“应该通过”，与调用后获得“测试通过”的证据，是两件不同的事。

## 5. 谁决定继续，谁决定结束？

官方循环图用“继续调用工具，直到给出回答”建立直觉。落到这个代码快照，停止条件更细。

首先，本次采样结果包含 `needs_follow_up`。工具调用处理会把它设为真；响应完成分支收到 `end_turn == Some(false)` 时，也会要求继续。这已经说明，后续推理并不只由“有没有工具调用”这一项决定。[源码][turn]

其次，`run_turn` 还要检查队列里有没有待处理输入。它的关键合并逻辑是：

```rust
let needs_follow_up = model_needs_follow_up || has_pending_input;
```

这行代码把两个来源放在一起：模型这一步要求继续，或者运行时还有输入要处理。比如用户在任务进行中补充“只补 CSV 列，不要调整接口”，如果这条输入被接纳到当前 Turn，它就可能成为后续推理的依据，而不是等原任务全部结束才有机会生效。

再次，即使暂时没有后续工作，代码还会运行 Stop hooks。对普通任务而言，如果 hook 阻止停止，并提供了可加入上下文的继续信息，代码会记录该信息并 `continue`。上下文管理、预算和错误分支也会影响实际走向；本文没有把这些控制逻辑简化成“模型说完一句话就立即退出”。

![一次模型响应完成后，先汇合工具结果，再检查后续工作和停止钩子；继续路径回到下一次推理，正常退出路径进入任务收尾](/assets/img/posts/codex-one-turn/stop-decision.png)
_原创控制流图：这是普通任务的主线摘要，省略压缩、预算和专用内部任务分支。中断与错误可以发生在多个等待点，不必排到图中最后一步才处理。_

最后，外层循环返回之后，还有任务层收尾。[`tasks/mod.rs`][tasks] 的 `on_task_finished` 处理运行结果、时间与统计等信息，构造 `TurnComplete` 或 `TurnAborted`，再清理对应活动状态。

有一个细节尤其值得注意：`TurnComplete` 本身可以携带 `error`。因此，名字里的 Complete 表示走到了终态，不足以单独证明修复成功。阅读客户端结果时，仍然要区分成功完成、失败和中断；源码中的 core 事件名也不应直接当成客户端 JSON-RPC 方法名。

由此可以得到三个不同的判断：

| 观察到的信号 | 能说明什么 | 不能据此断言什么 |
| --- | --- | --- |
| `TurnStartResponse`，状态为 `InProgress` | 输入已进入某个正在进行的 Turn | 修复已经结束 |
| `ResponseEvent::Completed` | 这次模型响应已经结束 | 工具都返回了、后面没有推理 |
| 任务层发出终态事件 | 这一轮进入收尾与终态报告 | 业务目标必然达成、测试必然通过 |

对使用者来说，最有价值的验收仍然是具体产物：列是否补上，相关测试是否运行，结果是什么，有哪些未完成事项。运行时终态解决的是控制权和生命周期问题，业务成功还需要证据。

## 6. 中断为什么也是循环的一部分？

如果用户点了停止，系统不能只在界面上隐藏“正在执行”。源码把取消信号传入模型和工具相关路径，并在任务层处理被中断的结果；任务收尾可以发出 `TurnAborted`。[相关入口][tasks]

这说明中断是运行时控制，不是给模型再追加一句“请停止”。它也解释了前面 `RegularTask` 为什么要在准备阶段就发送 `TurnStarted`：任务只要进入工作状态，就需要被界面看见和管理。

但中断不等于事务回滚。假如 CSV 文件的修改已经写入，接着用户在测试过程中点了停止，单凭这条取消路径不能推出修改会被撤销。要确认留下了什么，仍然需要查看工作区差异和执行结果。

同样，审批等待也不等于任务结束。某个工具需要用户决定时，执行可以暂时停在等待点；客户端提供决定后，运行时再推进。权限和沙箱怎样约束具体工具，会在后续专篇展开。

## 7. 沿着执行路径读源码

如果准备继续阅读，可以按照这条路线，而不必从最大的文件第一行开始：

| 想回答的问题 | 阅读入口 | 重点 |
| --- | --- | --- |
| 请求接纳以后返回什么？ | [`turn_start_inner`][turn-processor] | Started / Steered，以及 InProgress 响应 |
| 输入怎样变成普通任务？ | [`session/turn_input.rs`][turn-input]、[`RegularTask`][regular] | 启动分支、TurnStarted、run_turn |
| 为什么还会再调用模型？ | [`session/turn.rs`][turn] | SamplingRequestResult、待处理输入、Stop hooks |
| 工具结果怎样进入后续输入？ | [`handle_output_item_done`][stream-utils]、[`drain_in_flight`][turn] | 记录调用、分派、收集返回项 |
| 哪一层宣布整轮终态？ | [`on_task_finished`][tasks] | TurnComplete / TurnAborted、error、活动状态清理 |

这一轮任务的关键，不是循环里调用了多少次模型，而是**谁持有当前状态，谁把执行结果变成下一步依据，谁负责最终交还控制权**。在这份实现中，这些职责由 core 的循环与任务管理共同承担；App Server 把它们转换成客户端可以使用的交互契约。

下一篇继续拆最靠近模型的那个入口：每次推理之前，Codex 到底把哪些指令、历史、工具定义和环境信息放进输入，以及这些内容为什么不能简单理解成一段系统提示词。

## 资料与范围

- [Unrolling the Codex agent loop][loop-blog]：本文借用其循环概念；原文关于初始 prompt、Responses API 输入及性能的细节留待后续篇目。
- [Unlocking the Codex harness: how we built the App Server][server-blog]：用于理解请求、通知与 core 的边界；部署形态和协议选择已在系列第一篇展开。
- [openai/codex 固定源码快照][snapshot]：本文实现分析的依据。本文未实测并发调度、故障恢复或取消时延，也不覆盖所有特性开关组合。
- 配图均为原创手绘示意。

[loop-blog]: https://openai.com/index/unrolling-the-codex-agent-loop/
[server-blog]: https://openai.com/index/unlocking-the-codex-harness/
[snapshot]: https://github.com/openai/codex/tree/d138398cef7d49e46fe33f1d0ddbd2ca0ed16aa4
[turn-processor]: https://github.com/openai/codex/blob/d138398cef7d49e46fe33f1d0ddbd2ca0ed16aa4/codex-rs/app-server/src/request_processors/turn_processor.rs#L525
[handlers]: https://github.com/openai/codex/blob/d138398cef7d49e46fe33f1d0ddbd2ca0ed16aa4/codex-rs/core/src/session/handlers.rs#L568
[turn-input]: https://github.com/openai/codex/blob/d138398cef7d49e46fe33f1d0ddbd2ca0ed16aa4/codex-rs/core/src/session/turn_input.rs#L231
[regular]: https://github.com/openai/codex/blob/d138398cef7d49e46fe33f1d0ddbd2ca0ed16aa4/codex-rs/core/src/tasks/regular.rs#L49
[turn]: https://github.com/openai/codex/blob/d138398cef7d49e46fe33f1d0ddbd2ca0ed16aa4/codex-rs/core/src/session/turn.rs
[stream-utils]: https://github.com/openai/codex/blob/d138398cef7d49e46fe33f1d0ddbd2ca0ed16aa4/codex-rs/core/src/stream_events_utils.rs#L316
[tasks]: https://github.com/openai/codex/blob/d138398cef7d49e46fe33f1d0ddbd2ca0ed16aa4/codex-rs/core/src/tasks/mod.rs#L645
