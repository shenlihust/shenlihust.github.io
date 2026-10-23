# Codex 一轮任务：来源与校对记录

核对日期：2026-10-22。文章为源码解读与教学示例，未运行文中的 CSV 修复任务。

## 来源与版本

- Michael Bolin，2026-01-23：[Unrolling the Codex agent loop](https://openai.com/index/unrolling-the-codex-agent-loop/)。仅采用循环与 Turn 的基本概念；初始输入构建、上下文窗口与性能留待后续篇目，不做全文逐段翻译。
- Celia Chen，2026-02-04：[Unlocking the Codex harness: how we built the App Server](https://openai.com/index/unlocking-the-codex-harness/)。用于请求与持续事件的边界；部署和协议取舍延续第一篇，不重复展开。
- 实现统一固定在 `openai/codex` 提交 `d138398cef7d49e46fe33f1d0ddbd2ca0ed16aa4`。读取该提交的原始源码，未用当前 main 替换历史实现。

## 关键论断核对

| 论断 | 快照中的证据 |
| --- | --- |
| 请求可启动或引导当前任务 | `app-server/src/request_processors/turn_processor.rs`，`turn_start_inner` 调用 `start_or_steer_turn`，分辨 Started / Steered / NotSubmitted |
| 请求回复不是最终结果 | 同文件返回 InProgress，items 为空且 items_view 为 NotLoaded |
| 普通任务准备期间已经可见 | `core/src/tasks/regular.rs` 先发 TurnStarted，再准备并进入 run_turn |
| 工具可能在模型流结束前启动 | `core/src/stream_events_utils.rs` 的 handle_output_item_done 及立即分派注释；同步 post-model hook 是例外 |
| 工具输出进入历史 | `core/src/session/turn.rs` 的 drain_in_flight 使用 record_annotated_conversation_items |
| 模型完成不等于整轮结束 | ResponseEvent::Completed 返回 SamplingRequestResult；流处理后仍可等待工具；外层结合 pending input 判断 |
| 没有工具调用也不保证停止 | end_turn == Some(false)、待处理输入、Stop hooks 可要求继续 |
| 终态不保证业务成功 | `core/src/tasks/mod.rs` 的 on_task_finished 可构造携带 error 的 TurnComplete，或 TurnAborted |

图中 `read_export` / `call_demo_1` 是明确标注的教学名称。没有将 core 事件名冒充 JSON-RPC 方法名。没有承诺中断回滚、所有后台进程结束或每轮固定模型调用次数。

## 配图覆盖

1. hero：宽幅封面，避免主题裁剪技术图正文。
2. turn-boundaries：Turn 包含多次模型调用与工具反馈。
3. request-handoff：请求回复与持续事件分离。
4. loop-sequence：模型流完成时工具可能仍在执行。
5. tool-feedback：调用与输出由 call_id 关联，进入后续输入。
6. stop-decision：继续条件、停止钩子与任务层收尾。

全部保留 Excalidraw 源文件；每张图已渲染并查看。修正了初稿的多余画布宽度、工具流箭头和结束判断图的箭头落点。

## 本地验证

- `JEKYLL_ENV=production bundle exec jekyll build` 成功。
- `bundle exec htmlproofer _site --disable-external` 成功：22 个文件、139 个站内链接，并检查 5 个文件中的锚点。外链没有纳入该命令。
- Chrome 已检查桌面首屏、400 像素手机视口的封面与正文换行。没有进行全部设备或所有页面位置的兼容性测试。
- 生成后的 Codex 标签页与原理与架构分类页均收录新文章。
- 6 张 PNG 与 6 个可编辑源文件齐全，图片与下载链接纳入站内检查。
- 只完成本地写作与预览，没有提交、推送或部署。
