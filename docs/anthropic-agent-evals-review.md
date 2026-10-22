# Agent 评估解析：内容与配图核对

核对日期：2026-10-22。原文：[Anthropic — Demystifying evals for AI agents](https://www.anthropic.com/research/demystifying-evals-for-ai-agents)。

## 本轮发现与修改

- 上一版四类 Agent 只有一张简表；现已分别增加编码、对话、研究、计算机操作的方法、原创案例及相关一手资料链接。
- 上一版落地顺序是自拟流程；现已增加原文编号 0—8 的九步索引，并逐项对应本文案例的交付物。
- 增加初期任务规模的适用边界、全失败排查、历史状态泄漏、有效替代路径、评分版本变化等说明。
- 增加六种观测方式的职责与局限比较。

## 配图覆盖

原文正文有 5 张内容插图，讲解单轮与多轮评估、评估组成、多次尝试指标、评估建设流程、多种观测方法的互补。本站没有复制原图，图解按原创报表案例重新组织，因此不逐张对应原图布局。

| 本文图解 | 讲解作用 |
| --- | --- |
| evidence-flow | 区分过程与产物、体现评分依据；单轮与多轮差异另在正文说明 |
| trial-rules | 同一尝试序列下，至少一次成功与全部成功的不同判断 |
| eval-roadmap | 任务契约、可重跑实验、长期维护的交付物闭环；完整九步见正文表格 |
| agent-methods | 四类 Agent 采用不同证据结构 |
| feedback-layers | 离线检查与线上信号如何推动任务修订 |

所有图均为手工编写的 Excalidraw，源文件在 `assets/diagrams/anthropic-agent-evals/`，PNG 在 `assets/img/posts/anthropic-agent-evals/`。示例数据与概率计算不作为模型实测成绩。

本文保留必要原文引用，重点是方法分析与原创案例；没有逐一重述原文的客户故事、历史排行榜成绩、全部示例配置及附录工具介绍。
