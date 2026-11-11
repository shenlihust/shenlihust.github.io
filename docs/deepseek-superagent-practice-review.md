# Super-agent 实践文章图文核对

核对日期：2026-11-11。文章：`_posts/2026-11-11-deepseek-superagent-practice.md`。

## 本轮依据

- 本地 Super-agent HEAD：`8c32a9dc5d72c033816c6a8110b37f40cf94fba4`。
- 本地 DSH HEAD：`fcc0ad4621`。桌面安装包与源码检出版本不作等同。
- 以只读方式检查本机 `orchestrator.sqlite` 的表结构、三项测试任务、相关 Trigger、Decision 与 assignment 报告；没有修改配置或运行状态。
- Router 工具轨迹与候选卡片结论沿用本次前序排查记录；数据库里的路由结果不单独证明模型当时读过哪些上下文。

## 核实结果

| 核对项 | 依据与结论 |
| --- | --- |
| 实践日期 | 三项任务均创建于 2026-11-11；北京时间与正文一致 |
| 第一次只读请求 | 11:31:35 收到，11:32:37 决策为 ignore，理由为不匹配 Copy fixes / Visual fixes；属于卡片直接忽略 |
| 第二次只读请求 | 11:34:30 收到，11:34:41 接受，记录为 inferred、auto，命中 trial-readonly |
| 默认规则 | src/policy.ts 的 DEFAULT_RULES 中 copy、visual 均 enabled=true |
| 原任务与确认 | 14:57:51 发起；14:59:51 确认；确认 Trigger 没有 rootId、parentId，决策记录 routed 到原任务 |
| 文档产物 | assignment 报告列出 docs/superagent-test.md 和 README.md 两个文件、PR #1、验证内容及无 CI 检查项 |
| ready 与结束 | src/core/assignments.ts：ready 仅在无需继续跟踪时结束 Ticket；绑定 PR 的任务继续追踪 |
| 合并收尾 | 数据库记录 merged 时间 15:45:27、updatedAt 15:47:18；src/app/runtime.ts 中 ticket.ended 触发固定通知 |
| 只读结果未回复 | 原报告包含“已用 reply_to_trigger_id 回复原飞书会话”；此声明不是发送回执。正文仅将缺少发送调用写成已核实断点，不将模型原因写成确定性结论 |
| 飞书补收 | feishu-loops.ts：首次建立当前游标；随后按起止时间分页；poll.ts 回退 5 秒；14 天不是统一历史回看上限 |
| GitHub 轮询 | github.ts：轮询后等待 max(GitHub 要求间隔, 配置间隔)；不是固定每分钟调用一次模型 |
| 工具参数 | src/app/tools/tool.ts：orchestrator_read 使用 resource 字段，已改成 JSON 参数示例 |
| 压缩能力 | DSH docs/subsystems/compaction.zh.md：压缩是可选能力，摘要提供者可先调用可选裁剪服务 |
| 桌面关闭 | apps/desktop/src/main.ts：主窗口 close 被处理为隐藏；完整退出进入 Host 关闭流程 |

## 修改与图文对应

1. 总览图保留已认可的 imagegen 版本。图注明确这是新请求主路径；正文补充已有任务消息直达 Worker、终态通知由代码发送两条例外。解释本地 Host 不等于本地模型推理。
2. 图 2 与接单章节：区分接收、评估、接受；补充候选卡片可直接忽略。新增规则、切换 auto 均属本次定制，不作为官方默认。
3. 图 3 与任务章节：强调原 Worker 继续执行，并将合并节点补为 Ticket 结束；不把 ready 报告与终态混同。
4. 图 4 与故障章节：已验证的是缺少发送调用；配置纠偏与后续成功不等于已经证明并修复了官方确定性代码缺陷。
5. 图 5 与压缩章节：增加“启用压缩插件”的前提，保留“未观察到测试 Router 压缩”的历史检查范围。
6. 删去“此前讨论的额外小节”这类对外部读者无意义的会话背景；减少确认歧义的重复结论；统一图号、空行、图片发布目录。

## 范围与限制

- 主图为架构概览，不是每条来源事件都必须经过的完整状态机。
- 图中节选消息不是完整日志或产品截图。
- 自定义规则正文与提示词是模型约束，不被描述为 GitHub 权限或命令级硬拦截。
- 只读检查不重跑自动化任务，不补发消息，不合并 PR。
- 已渲染并目视核对修改后的三张 Excalidraw 图，中文、连线与图文含义一致；保留其源文件。

## 最终验证

- Jekyll production build 通过。
- HTML-Proofer 内部链接检查通过：51 个 HTML 文件、342 个内部链接；本轮未跑外部链接可用性扫描。
- 浏览器 1440 px 与 390 px 宽度下五张正文图全部加载，页面无横向溢出，图号顺序为 1–5，更新后的压缩前提与图注已出现在页面。
- 图片在窄屏按比例完整缩放，密集文字仍可用页面原有图片放大查看；没有添加横向滚动容器。
- 文章图片引用、Excalidraw JSON 可解析性、元素 ID 唯一性及 git diff 空白检查通过。
- 未提交、推送或部署；保留其他文章与写作指南的既有改动。
