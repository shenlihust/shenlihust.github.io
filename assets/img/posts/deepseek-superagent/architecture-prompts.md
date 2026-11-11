# 总体架构图生成记录

日期：2026-11-11。方式：内置 image_gen，先生成，再针对路由和回复路径做一次定向编辑。

最终文件：architecture-imagegen-v2.png。已检查中文、Host 边界、消息方向、测试仓库与产物名称。其余四张正文配图保持 Excalidraw。

## 初始提示词

Use case: infographic-diagram. Create an original publication-quality Chinese technical architecture infographic for a blog about our actual DeepSeek Super-agent prototype experiment. Landscape 3:2, high resolution, generous readable Chinese text. Rich information architecture with clear labeled modules, subtle dimensional icons (message envelopes, event tray, decision switch, terminal, file tree, database cylinder, shipping tray), restrained shadows, white/light ice-blue background, navy typography, blue inputs, violet AI sessions, amber decisions, teal delivery. No people, robots, desks, plants, mascots, official logos, watermark or 知其所以. Original editorial composition, not a generic office illustration. Technical correctness and Chinese legibility are paramount.

Title: “Super-agent：从群消息到代码交付”
Subtitle: “本地 DSH 桌面端 · 飞书测试群 · 单个 GitHub 仓库”
Use a large clearly marked rounded boundary “DSH Host · 插件与会话运行于本机”, with EXTERNAL SOURCES outside to LEFT, AI SESSION REGION upper inside, durable state along BOTTOM inside, DELIVERY REGION lower LEFT inside, external repository to RIGHT. This is an accurate schematic, not product screenshot.

LEFT external sources in two compact stacked cards:
“飞书群” / “任务请求 · 后续确认”
“GitHub” / “通知 · 评论 · PR 状态”
Both arrows converge into input module inside Host:
“消息接入” / “飞书：实时事件 + 历史补收” / “GitHub：后台轮询” / “标准化 · 去重”
Input arrow goes to central purple “Router Session” with small branching decision icon, text “理解意图 · 判断归属 · 协调交付”.
Below Router include three short decision labels on its outgoing routing branch: “新建任务 / 关联旧任务 / 忽略”. NEW and ATTACH paths lead rightward to “Worker Session”; IGNORE ends at small gray endpoint, no further flow.
Worker module on upper right within Host: “Worker Session” / “独立上下文 + 工作目录” / “读仓库 · 修改文件 · 执行验证”. Beneath worker a clearly attached task dossier icon and label “Ticket” / “授权范围 · 状态 · 待确认问题”.
Between Router and Worker TWO well-separated directional arrows: upper solid arrow Router → Worker labeled “任务与后续输入”; lower dashed arrow Worker → Router labeled “orchestrator_report”. Avoid any other arrow leaving Worker toward the delivery region.

External repository RIGHT of Host with folder and git branch icons, labeled “superagent-playground”. ONLY Worker connects to repository, arrow label “修改 · 验证 · 创建 PR”. Beneath repo show two files in file-tree form: “docs/superagent-test.md” and “README.md”. Small badge “人工审查与合并”.

Delivery region BELOW Router but to LEFT, FAR from Worker:
Router downward arrow labeled “orchestrator_reply” goes to teal “Outbox” / “待发送 → 发送回执”.
Outbox arrow LEFT exits Host toward external message result card “飞书原话题” / “实施计划 · 待确认问题 · PR 结果”.
CRITICAL: Do not draw ANY arrow from Worker to Outbox or to Feishu. Worker reports to Router; Router requests replies. Do not use a generic left-to-right chain that accidentally links Worker and Outbox.

BOTTOM inside Host a wide low storage strip with cylinder and record icons:
“SQLite 持久化状态”
“Trigger 消息 · Thread 关联 · Ticket 任务 · Outbox 发送状态”.
Thin neutral dotted NON-ARROW connectors associate storage with Router and Ticket only, no extra flow arrows.
Bottom footer, outside Host: “Router / Worker 是会话角色，不是各自独立的进程”
A tiny explanatory caption near message input says “示例：先给计划，确认后再修改”.
Keep all module titles large; concise text only as specified. Ensure actual network and runtime boundaries are unambiguous. Do not claim cloud scheduling, permanent specialist workers, automatic merging or perfect memory.

## 最终编辑提示词

Edit this infographic precisely. Preserve its overall composition, title, source cards, Host boundary, database band, external repository and file names, color palette, typography and module details. Fix ONLY the routing/reply area beneath Router.

REMOVE the whole orange branching connector and orange arrow toward Worker, REMOVE the three separate pill nodes 新建任务 / 关联旧任务 / 忽略 and the gray 结束 node, REMOVE the dotted line from 关联旧任务 to SQLite.
Replace those decision nodes with ONE small free-floating text annotation underneath Router, offset to its RIGHT at center of the open space, two lines: “路由选择” then “新建 / 关联 / 忽略”. This is an annotation, NOT a flow node. It has NO arrows.
Make a single uninterrupted purple arrow go DIRECTLY from bottom LEFT edge of the Router rectangle to top of Outbox rectangle, through the open area beneath Router. Put “orchestrator_reply” alongside this purple arrow, clearly legible, without crossing any annotation. This arrow MUST originate at Router itself, never at the text annotation.
Keep the existing top horizontal Router → Worker arrow labeled 任务与后续输入. Keep existing dashed Worker → Router arrow labeled orchestrator_report. Keep Worker → external repository arrow. Keep Worker-Ticket connection. There must be NO Worker → Outbox arrow. Outbox → 飞书原话题 unchanged.
The output should be a polished technically accurate editorial architecture infographic. Do not introduce new modules, decorative people, robots, watermark, branding, or extra arrows. All other content unchanged.
