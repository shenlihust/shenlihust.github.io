# Super-agent 全文配图替换

生成方式：内置 image_gen；浅底蓝紫技术信息图。保留现有 architecture-imagegen-v2.png 和 concepts-imagegen.png，替换四张流程图。日期：2026-11-12。

## routing-imagegen.png

```text
Use case: infographic-diagram. Create an original polished Chinese technical-blog infographic, landscape 3:2, white and very pale blue background, navy typography, blue section ribbons, teal success accents, purple model/session accents, orange message accents. Subtle layered panels and restrained soft depth, professional editorial composition, rich meaningful message/document/database icons, crisp large readable simplified Chinese text. NO people, no generic robot artwork, no logos, no watermarks, never write 知其所以. All connectors clean, no ambiguous crossings. Explain actual mechanics, avoid invented claims. Content below is the full specification.
Title “听到消息，不等于接下任务”
Subtitle “同类只读请求，在配置调整前后的不同去向”
Top orange message bubble: “请查看仓库有哪些文件，不修改、不提交代码。”
Two clearly separated comparison lanes, NOT an automatic sequence from old to new:
Left lane labeled “调整前 · 本次实测”. Show blue policy list “Copy fixes：文案修正” / “Visual fixes：局部视觉修复”; note “不覆盖仓库只读查询”. Arrow to purple Router decision card “候选卡片直接判断：忽略”. Arrow to gray empty workspace icon “未创建 Ticket / Worker”.
Right lane labeled “调整后 · 再次发送”. Blue settings panel “新增：测试仓库只读查询” and “Eval：observe → auto”. Arrow to purple model card “模型理解规则与请求”. Arrow to blue gate “代码检查规则、证据与模式”. Arrow to teal task/session pair “接受 → 创建 Ticket 与 Worker”.
A bottom responsibility strip: “模型：判断语义是否匹配” and “代码：检查参数、规则与执行条件”.
Bottom notes exactly: “observe：记录判断，不自动执行推断请求” / “默认两条规则原本开启；测试中后来关闭”
Ensure first attempt is direct ignore from candidate, NOT imply observe was sole reason of ignore, NOT every request always complete Eval. Beautiful balanced before/after visual comparison.
```

## lifecycle-imagegen.png

```text
Use case: infographic-diagram. Create an original polished Chinese technical-blog infographic, landscape 3:2, white and very pale blue background, navy typography, blue section ribbons, teal success accents, purple model/session accents, orange message accents. Subtle layered panels and restrained soft depth, professional editorial composition, rich meaningful message/document/database icons, crisp large readable simplified Chinese text. NO people, no generic robot artwork, no logos, no watermarks, never write 知其所以. All connectors clean, no ambiguous crossings. Explain actual mechanics, avoid invented claims. Content below is the full specification.
Title “一条任务，跨过计划、确认与交付”
Subtitle “飞书发起 → 原 Worker 接续 → 人工合并 · 2026-11-11 北京时间”
Main visual a clean five-stage horizontal timeline, ample width:
“14:57 发起任务” message card “新增测试说明 + README 链接”
“14:58–14:59 给出计划” purple card “先等确认，不改文件”
“14:59 独立确认” orange bubble “确认，按计划执行。”
“15:00–15:01 创建 PR” teal branch/document card “PR #1 · 待人工审阅”
“15:45 人工合并” human-check icon without illustrated person “随后程序通知飞书”
Below timeline, enlarge the confirmation step into a precise three-part detail: evidence card “无 root_id / parent_id” / “related_tickets 为空” → purple Router card “结合此前等待通知” / “orchestrator_route：attach” → purple Worker card “原 Ticket · 原 Assignment” / “原 Worker Session 继续执行”.
Use a single clear line or bracket from confirmation stage down to detail, no crowded crossings.
Below detail small file-output group “docs/superagent-test.md” + “README.md”.
Bottom two concise boundaries “等待确认：Turn 结束，任务仍在” / “ready 不必结束 Ticket；本次 PR 合并后收尾”
Footer “本次成功关联依赖上下文；不代表任意一句‘确认’都无歧义”
Do not imply second assignment created by confirmation. Do not imply merge used model or autonomous merge. PR creation preceded merge.
```

## delivery-imagegen.png

```text
Use case: infographic-diagram. Create an original polished Chinese technical-blog infographic, landscape 3:2, white and very pale blue background, navy typography, blue section ribbons, teal success accents, purple model/session accents, orange message accents. Subtle layered panels and restrained soft depth, professional editorial composition, rich meaningful message/document/database icons, crisp large readable simplified Chinese text. NO people, no generic robot artwork, no logos, no watermarks, never write 知其所以. All connectors clean, no ambiguous crossings. Explain actual mechanics, avoid invented claims. Content below is the full specification.
Title “Worker 做完了，飞书为什么还没收到？”
Subtitle “内部汇报与外部交付，是两条不同的责任链”
Main upper flow left to right with 4 large clearly distinguished modules:
Purple “Worker” icon document tools; connector labeled “orchestrator_report” to purple “Router”; connector labeled “orchestrator_reply” to blue database/outgoing tray “Outbox”; connector labeled “发送并记录状态” to teal message panel “飞书原话题”.
Below Worker annotation “报告状态与结果”; below Router “决定对外回复”; below Outbox “排队、发送、重试”; below Feishu “核验实际送达”.
Place a focused red dashed bracket on Router-to-Outbox link labeled “首次排查：缺少对外发送调用”. Do not mark transport as failed or imply outbox already had message.
Below a comparison panel on left “不能只看报告” with quotation “报告写了‘已回复’” and small note “日志不支持这个完成声明”.
Right evidence panel “要看交付证据” with checklist “是否调用回复工具” / “Outbox 是否 sent” / “是否送达正确话题”.
Bottom subtle yellow lesson strip “明确交付职责的提示词配置后，补发并验证后续自动回复”
Footer “这是配置纠偏；不能据此断言已修复官方源码缺陷”
Do not show orchestrator_ack as final result, don't imply Worker report directly sends Feishu final response. Beautiful visual flow with output message mockup saying “查询结果：README.md …” and internal report mockup visually distinct.
```

## context-imagegen.png

```text
Use case: infographic-diagram. Create an original polished Chinese technical-blog infographic, landscape 3:2, white and very pale blue background, navy typography, blue section ribbons, teal success accents, purple model/session accents, orange message accents. Subtle layered panels and restrained soft depth, professional editorial composition, rich meaningful message/document/database icons, crisp large readable simplified Chinese text. NO people, no generic robot artwork, no logos, no watermarks, never write 知其所以. All connectors clean, no ambiguous crossings. Explain actual mechanics, avoid invented claims. Content below is the full specification.
Title “上下文会压缩，任务状态仍可查询”
Subtitle “Router 的会话摘要，与持久化任务记录，是两条信息通道”
Composition: two horizontal lanes converging into ONE Router Session at far right, clearly labeled information routes, avoid implying automatic database load.
Upper lane purple header “通道一 · 会话上下文（启用压缩插件时）”. Show document stack “较早历史” → compact summary document “结构化摘要” + adjacent smaller stack “保留的最近原文” → right Router. Small callout “按上下文压力触发；可先裁剪工具结果”.
Below upper lane show four summary content chips “用户意图” “约束” “当前工作” “未完成事项”.
Lower lane blue header “通道二 · 独立任务状态”. Cylinder “SQLite” containing “ticket” and small task record card “标题 / 状态” “assignments[].report” “attention.question”. Arrow toward Router explicitly labeled “Router 主动调用 orchestrator_read”; put readable code capsule '{"resource":"tickets"}' above this arrow and “分页列表 → 任务详情” below. The arrow represents read result into Router and label makes active querying clear.
Router panel at right: “Router Session” and “结合摘要与查询结果判断”. No third memory magic brain or automatic full history.
Footer two amber facts “摘要不保证保留每个待确认任务” / “数据可查，不代表模型每次都会查询”
Small bottom annotation “机制示意，不代表本次实测已触发上下文压缩”
Rich but legible library/document storage metaphor, no assertion that persistent records are compressed or deleted. Keep only needed text.
```
