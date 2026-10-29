# Agent Harness 配图记录

当前版本：正文十一张统一风格信息图及封面，见 [统一配图与提示词记录](agent-harness-unified-figures.md)。以下保留此前版本的设计历史，当前引用以正文为准。

文章：`_posts/2026-10-21-agent-harness.md`

配图资源位于 `assets/img/posts/agent-harness/`：封面 `hero.png`，以及八组 PNG / Excalidraw 文件。所有图按正文主题命名，不使用独立数字编号。

2026-10-29 架构版正文使用封面和四张关系图：`subsystems`、`model-adapter`、`permissions-sandbox`、`skill-mcp-acp`，分别对应整体架构、模型接入、权限隔离和扩展机制。原稿中的工具循环、编辑冲突、会话交接与验证闭环图保留为资源，不再嵌入正文；正文以模块职责和协作关系为主线。

封面使用内置 image_gen 工具生成，未使用 CLI。用户提供的图仅用于理解手绘科普风格，未复制其布局或署名。流程图使用 Excalidraw，采用技能定义的颜色，蓝色表示主流程、紫色表示模型、绿色表示成功、红色表示受阻或失败。

## 封面最终提示词

```text
Use case: illustration-story
Asset type: 中文技术博客横版封面，主题 Agent Harness。
Primary request: 原创手绘科普插画，白色纸面背景，蓝色马克笔轮廓，淡蓝淡紫淡绿水彩填充，圆润可爱的机器人与工具，类似中文工程科普手帐。画面中心是一位小机器人坐在工作台前，工作台和包围它的开放式工具架代表 Harness；左侧有用户交来的任务纸张，右侧是完成的文件和绿色验收对勾。工具架上有文件夹、终端窗口、记事本、秒表和小盾牌；蓝色箭头把任务、机器人工作台、交付物连接起来，小绿色弧线表达检查反馈。机器人应是视觉焦点。构图宽屏 16:9，简洁留白，适合文章顶部。
Text (verbatim): 顶部大标题 "Agent Harness"；下方中文副标题 "让模型有环境、有工具、有反馈"；仅这两处文字，其他图标无文字。
Constraints: 不是精确架构图，不复制任何参考图的布局、署名或品牌；不要水印，不要密集标签，不要照片或3D，线条略有手绘不规则但精致，文字清楚。
```

## 图形设计

<details>
<summary>架构图首次生成提示词</summary>

```text
Use case: infographic-diagram. Create an original high-resolution Chinese technical blog architecture infographic, landscape 3:2, white background, beautifully typeset crisp Chinese sans-serif, navy headings, restrained blue/teal/orange/purple accents, polished small vector-style icons, meticulous spacing. NOT a sketch. Do not copy any existing diagram. Title "Agent Harness 架构"; subtitle "围绕模型，组织上下文、行动与反馈".
Design an original layered architecture with a large central pale-blue rounded boundary labeled "Harness · 运行与控制系统". Above boundary, two separate external entities: left "用户 / 客户端" with person/chat icon, right "大模型 LLM" with neural icon. Model must be OUTSIDE harness boundary. User connects to core loop; model connects bidirectionally to model adapter.
Within boundary: main horizontal execution pipeline of four substantial cards with numbered headers and concise content:
"④ 上下文与记忆" / "任务目标 · 历史 · 检索" / "筛选、压缩、按需加载";
"① Agent 循环" / "推进 · 等待 · 停止" / "管理每轮执行状态";
"② 模型接入" / "请求适配 · 流式解析" / "统一响应与能力差异";
"③ 工具与动作" / "参数校验 · 调度执行" / "文件 · 终端 · 浏览器 · API".
Relationships must be technically explicit: context -> loop -> model adapter -> external LLM; external LLM -> adapter -> loop. Loop -> tools via a clearly labeled orange small gate "⑤ 权限检查" placed on the route below main row. Tools -> context via a distinct blue bottom return arrow labeled "执行结果 → 下一轮上下文". Route arrows neatly, no crossing text.
Under main pipeline, two supporting side-by-side cards: "⑥ 任务编排" / "计划与依赖 · 子任务委派 · 结果汇总"; "⑦ 扩展机制" / "Skills · MCP · Hooks / Middleware". Subtle thin connectors to core modules; no confusing serial chain.
Bottom within boundary one full-width slim band: "贯穿全程：会话与状态持久化  ·  Trace 与指标  ·  验证与评估".
Outside boundary on right a distinct orange-tinted tall environment card labeled "执行环境", with folder, container and cloud icons and three lines "本地进程", "容器 / 沙箱", "远程服务". Tools connect to it with bidirectional arrow. Small caption "隔离文件、网络与凭据". The permission gate and environment isolation jointly correspond to module ⑤; no suggestion sandbox is approval.
Bottom page small footnote "职责划分示意，非固定部署拓扑；模型提供决策，Harness 组织执行。"
Keep readable text large, avoid excessive tiny labels. Make architecture coherent and attractive as an editorial information graphic. All specified Chinese text accurate. No watermark, no fake logos, no extra prose.
```

</details>

2026-10-29 总览图重绘为 `architecture.png`，替换正文中的 `subsystems.png`。使用内置 GPT imagegen，原创分层布局，不复刻用户参考图。模型位于 Harness 边界外，通过适配层交互；执行循环经权限检查调用工具，结果回流上下文。生成后修正了模型连线与绕过权限的多余箭头，并目视检查中文和数据流。旧源图保留。

最终提示词设计：白底、横向 3:2 中文技术信息图；上方用户与模型，中央 Harness 边界内为上下文、循环、模型接入、工具四个主模块；橙色权限门位于循环至工具路径；工具结果回流上下文；下方编排和扩展，底部持久化、Trace、验证评估；右侧独立执行环境。精修要求：模型只连接模型接入，删除适配器到工具的直连，反馈箭头从工具指向上下文。完整首次生成提示词见下文。

- `subsystems`：七项职责围绕执行循环协作，参考论文 §2.3；不是微服务部署图，模型本身不属于 Harness。
- 工具循环：上层呈现上下文、模型与执行器，底部反馈箭头闭合循环；具体工具请求与结果为教学示例。
- `edit-conflict`：时间轴展示读取 v1、外部写入 v2、拒绝过期补丁与重新读取，强调版本检查和写入要在受保护操作内完成。
- 跨会话交接：初始化、持久化材料、后续会话形成交接路径；文件名参考 Anthropic autonomous-coding README。
- 验证闭环：修改产物进入验收，通过后交付，失败返回修复，缺少条件时保持受阻状态。
- `skill-mcp-acp`：ACP 连接客户端与 Agent，Skill 从侧边注入工作方法，MCP client 连接 server；依据 Agent Skills、ACP v1 Prompt Turn 和 MCP 官方文档。不是三层串行栈。
- `model-adapter`：多种响应格式汇入适配层，转换为内部事件；例子不对应特定厂商。
- `permissions-sandbox`：授权决策与受限执行环境分别表达两个边界，不把沙箱等同于授权。

所有流程图都需要导出 PNG 并目视核验文字、箭头和布局。图中示例不代表实测日志。
