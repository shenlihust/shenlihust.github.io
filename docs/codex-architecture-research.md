# Codex 架构文章：资料核对与配图说明

对应文章：`_posts/2026-10-21-codex-architecture.md`。

核对日期：2026-10-21。源码快照：`openai/codex@d138398cef7d49e46fe33f1d0ddbd2ca0ed16aa4`，提交时间为 2026-10-21 12:39:12 UTC。源码从 GitHub 固定提交读取，没有运行或编译完整 Codex 仓库。

## 证据层级

- 设计背景：OpenAI 的 `Unrolling the Codex agent loop` 与 `Unlocking the Codex harness` 工程文章。
- 当前公开契约：官方 App Server、安全、开源组件文档。原 `developers.openai.com/codex/...` 部分地址已重定向到 `learn.chatgpt.com/docs/...`，正文使用最终页面地址。
- 当前实现边界：固定提交下的 `cli/src/main.rs`、`tui/src/app_server_session.rs`、`app-server-client/README.md`、`app-server-protocol/src/protocol/common.rs` 与 `v2/turn.rs`、`v2/thread.rs`，以及 core、rollout、state 相关入口。
- 集成选择：官方 `Codex as a platform` 与固定提交下的 TypeScript SDK README。
- 桌面端：只使用官方公开集成方式；不把第三方逆向材料作为闭源模块或稳定接口的依据。

## 特别核对的易错点

1. CLI 是入口，TUI 是交互界面。App Server 不是模型推理服务。
2. 2026-02-04 工程文章中的 TUI 迁移计划不能代表当前实现；当前 `app-server-client` README 明确服务 TUI/exec 的进程内运行时。
3. 进程内路径使用 typed channels，仍保留 App Server 语义；不是所有客户端都通过子进程 stdio 连接。
4. 当前 App Server 文档将 WebSocket 标为实验性、不受支持，文章不作生产可用承诺。
5. `item/commandExecution/requestApproval` 是反向请求，必须有匹配请求 ID 的响应；不应只作为通知处理。
6. `TurnStatus` 的 wire 值包括 `completed`、`interrupted`、`failed`、`inProgress`。协议终态不等同于业务验收通过。
7. 新快照已拆分 core 的会话实现；不继续链接并不存在的旧 `core/src/codex.rs` 路径。
8. 存储使用了 rollout 和 state 等组件，文章不声称 JSONL 是所有状态唯一真源。
9. TypeScript SDK 的说明只针对本文快照的 `sdk/typescript`；不泛化到其他语言 SDK。
10. 本文不会将本地沙箱解释为远程 MCP 服务的授权机制。

## 配图

资源目录：`assets/img/posts/codex-architecture/`。封面为 AI 生成的手绘水彩概念插画；八张正文图为本文绘制的 Excalidraw 示意图，保留可编辑源文件并导出 PNG。使用与 Harness 文章一致的白底、蓝紫绿配色、中文等宽风格文字和轻微手绘笔触。

| 文件 | 要解释的关系 | 主要证据 |
| --- | --- | --- |
| `hero.png` | 多个界面共用 Agent 工作能力 | 概念插画，不作拓扑证据 |
| `surfaces` | 进程内、跨进程、跨机器的区别 | app-server-client README、官方工程文章和 App Server 文档 |
| `thread-model` | Thread / Turn / Item 的嵌套与生命周期 | protocol/common.rs、v2/turn.rs |
| `turn-sequence` | 双向协议与审批等待 | 官方协议、common.rs |
| `runtime-loop` | 上下文、模型、工具结果的反馈关系 | agent loop 工程文章、core/lib.rs |
| `persistence` | UI、内存、持久化和工作区状态的区别 | thread_manager.rs、rollout.rs、state/lib.rs；恢复边界为工程分析 |
| `security` | 动作授权与资源隔离的区别 | 安全文档、core README |
| `integrations` | App Server、MCP、Skill、SDK 接入方向 | 官方平台文章、SDK README、core 模块入口 |
| `reading-map` | 按请求边界展开后续源码阅读 | 固定快照的已核对路径 |

正文图的连线按职责、协议示意或阅读顺序表达，不冒充完整逐函数调用图。没有复制官方图，也没有展示私有桌面端模块。
