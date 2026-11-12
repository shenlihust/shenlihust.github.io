# Super-agent 概念关系图

- 生成方式：内置 image_gen，未使用 CLI/API fallback。
- 发布图片：concepts-imagegen.png
- 日期：2026-11-12
- 说明：U、话题内补充和恢复执行是教学示例；连线不是完整运行时流程。

## 完整生成提示词

后续局部修订（内置 image_gen，两轮）：移除上半部交叉连线的双拱桥，让 B → T 的上升线连续，A → U 的下降线在交叉处留出背景色断口；不增加交点，保持 A–T、A–U、B–T 三条关系及原有文字布局。第二轮明确只补齐上升线中间的断口。最终采用 exec-6780d549-699e-459c-ae6b-1308c7095cc8.png。

Use case: infographic-diagram
Asset type: Chinese technical blog concept diagram, polished original editorial infographic.
Create a rich but precise diagram about DeepSeek Super-agent, landscape 3:2, white/light blue background, navy typography, restrained blue/teal/purple/orange accents, subtle dimensional document stacks, message bubbles and session panels. Beautiful professional technical illustration, NOT a character illustration. Large readable Chinese text, generous spacing, no logos or watermarks, never write 知其所以.

Title: “Super-agent：从消息到任务，再到执行”
Subtitle: “Trigger · Thread · Ticket · Assignment · Worker”

Use two clear horizontal sections. Upper section labeled “消息与任务：多对多关联”.
Left column shows Thread A as a blue grouping container labeled “Thread A · 飞书话题”, containing two distinct orange message objects:
“Trigger 1：新增测试说明”
“Trigger 2：话题内补充要求”
Below it a smaller blue grouping labeled “Thread B · 独立群消息”, containing one orange message object:
“Trigger 3：确认，按计划执行”
Small legend near messages: “Trigger：一次消息或事件”.
Right column shows two task document cards, Ticket T on top labeled “Ticket T · 新增测试说明” and “目标 · 授权 · 状态”, and Ticket U below labeled “Ticket U · 另一项工作”.
Draw exactly three plain association lines: Thread A to Ticket T, Thread A to Ticket U, Thread B to Ticket T. No line from B to U. Use bridge at crossings, no junction dot. Central label “Thread ↔ Ticket：多对多”. Small annotation beneath: “B 经 Router 判断，关联到已有任务 T”.
Thread container grouping must clearly communicate messages belong to discussion threads. Do not imply that one message must create a task.

Lower section labeled “展开 Ticket T：执行记录变化，会话身份不变”.
Draw Ticket T as green task document at left. A bold purple association connects it directly to one single large purple Worker Session panel at right. Label this association “1 : 1（主会话）”. Worker panel text “Worker Session” and “worker-<ticketId>” and “承载模型上下文与工具执行”.
Below the Ticket T, branch down to an execution-history timeline with two items “Assignment 1 · 首次执行” followed by “Assignment 2 · 恢复执行”. Label the branch “1 : N · 执行安排”. A fine connector from each assignment to the SAME Worker panel, with label “复用同一会话”. Timeline note “等待确认不必新建；任务结束后恢复可新增执行记录”.
Do NOT draw multiple Workers for Ticket T. Do NOT suggest Assignment is a model turn or a separate agent.

Bottom compact footer with two short lines:
“任务结束：停止执行，不因此删除 Worker 会话”
“多 Worker 收到消息 ≠ 都应执行；接收确认去重 ≠ 独占处理权”
Small final annotation “关系示意：U 与恢复执行为教学示例”.
Keep exact concept names and Chinese wording correct. All arrows or connectors must land cleanly at intended objects. Richness comes from meaningful grouping, document/message symbols, clear relationship cardinality, and execution timeline, not decorative people.
