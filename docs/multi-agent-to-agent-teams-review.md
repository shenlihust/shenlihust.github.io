# Multi-Agent 与 Agent Teams 初稿核对记录

核对日期：2026-10-23。

文章：`_posts/2026-10-23-multi-agent-to-agent-teams.md`。用户已授权将本次博客改动全部发布，文章已从草稿转为正式文章。

## 覆盖与事实边界

- 解释工作流、执行型 Agent 与多 Agent 的关系；不把多次模型调用都视为自主 Agent。
- 用控制权、执行结构、通信、状态、协作策略与部署边界组织讨论，注明这是本文分析框架。
- 覆盖流水线 / SOP、Router、并行分解、Supervisor、分层团队、Handoff、Peer-to-Peer / Swarm、Blackboard / 事件驱动。
- 单独解释评审、辩论、投票和 MoA，区分输出聚合与模型内部 MoE。
- Agent Teams 产品行为依据 Claude Code 官方文档；保留核对日期，说明实验性状态与具名 subagent 也能发消息这一版本细节。
- 区分 Claude Code Agent Teams 产品与编译器研究原型；后者没有中央编排 Agent，采用容器、Git 副本与任务文件协调。
- 任务协议、租约代次、幂等、上下文证据与集成验收属于原创案例设计，不表述为框架内置保证。
- 使用 MAST 论文 v3 的研究范围，不将样本结果扩展为所有系统的失败率。
- 未运行模型评测；实验章节明确是待实施设计，未编造准确率、成本或加速比。
- 参考资料共 11 份，链接在相应论述附近和文末提供；资料检索跨 2026-10-22、2026-10-23 两轮，产品文档在 23 日再次核对。

## 图解修订结果

首版只放了三张 Mermaid 图，未遵循项目的 Excalidraw 配图偏好，对长文知识点的图解覆盖也不足。根据用户反馈重做为九张原创中文 Excalidraw 图，使用技能色板、清晰直线、统一字号和留白。每张图同时交付 PNG 与可编辑源文件。

| 文件标识 | 图解要解释的问题 | 采用的结构 |
| --- | --- | --- |
| control-topologies | 中心化、分层、对等协作如何分配控制权 | 三种不同的网络拓扑 |
| parallel-dependencies | 为什么增加成员不等于等比例加速 | 并行泳道与共同验收点 |
| call-vs-handoff | 子任务返回与控制权交接有什么区别 | 两组时序与不同的最终响应者 |
| collaboration-strategies | 评审、辩论和 MoA 分别怎么改进候选 | 反馈环、多方交换、分层汇合 |
| team-coordination | 负责人、成员消息、共享任务怎样配合 | 负责人树、横向协作与任务记录 |
| task-lifecycle | 执行者做完为何不能直接算成功 | 状态迁移与验收门槛 |
| context-evidence | 私有上下文如何转成可追溯的共享信息 | 原始轨迹到证据包再到独立验收 |
| protocol-boundaries | MCP 与 A2A 的连接边界是什么 | 本地工具接入与跨服务委派 |
| evaluation-design | 怎样区分协作收益和额外预算收益 | 同源输入、四组对照、统一验收 |

所有案例都沿用正文的权限功能；图内字段和状态属于教学协议，不冒充产品内部 API。九张图均已渲染并逐张查看，已修正状态机返工路径重叠，以及交接图中专家接管前后的时间线表达。

## 已执行验证

- 使用 Homebrew Ruby 3.4，执行 `bundle exec jekyll build --drafts --destination /tmp/agent-tech-blog-multi-agent-preview`，成功。
- 执行 `bundle exec htmlproofer /tmp/agent-tech-blog-multi-agent-preview --disable-external`，26 个 HTML 文件检查通过；输出包括 190 个内部链接及 6 个文件的内部锚点检查。
- 单独解析文章 HTML：无重复 ID、无失效的本页静态锚点。
- Markdown 围栏成对，无行尾空白；无可执行模型示例，YAML 任务契约明确标为示意。
- 九份 Excalidraw JSON 均通过解析、元素 ID 唯一性与引用检查；正文的九个 PNG 链接均存在，已移除全部 Mermaid 图块及配置。按用户要求，正文不再逐图提供源文件下载说明；可编辑源文件仍保留在仓库中。
- 九张 PNG 均逐张查看；修正后的状态机与交接图再次渲染查看。网站 1280 × 900 桌面视口抽查团队协调图，确认灯箱可正常展示。
- 390 × 844 手机视口抽查正文与团队协调图灯箱；正文正常换行，页面 `scrollWidth` 与 `clientWidth` 均为 390。图示适配屏幕宽度，密集文字仍建议放大查看。检查后已恢复默认视口。

## 验证限制与后续

- 手机检查为抽查，未逐段截屏或覆盖所有浏览器。
- HTML-Proofer 关闭了外链检查；一手资料通过网页读取核对，不宣称批量 HTTP 链接测试已完成。
- 本文是综述式原创初稿，未对各框架做安装、运行或性能排名。
- 本地预览使用独立端口 4173，未改动项目现有预览配置。

重新预览草稿可使用：

```sh
PATH=/opt/homebrew/opt/ruby@3.4/bin:$PATH bundle exec jekyll serve --drafts --host 127.0.0.1 --port 4173
```

如果独立静态预览仍占用 4173，可另选空闲端口。
