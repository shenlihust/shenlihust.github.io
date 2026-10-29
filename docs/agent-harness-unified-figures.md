# Agent Harness 统一配图记录

最新调整：封面恢复原 `hero.png` 机器人工作台插画；第六节改用 `context-memory.png`，补全长期记忆的检索、受控写入与更新失效路径。其余正文图保持统一信息图风格。

本次内置 imagegen 编辑提示词要点：以 context-unified.png 为风格参考，上方为当前材料→上下文组装→本轮上下文→模型；下方分别展示会话与任务状态、长期记忆（跨任务）。前者加载任务状态，后者按需检索至上下文组装。长期记忆包含用户偏好、项目知识、已验证经验；任务新经验经筛选与确认写入，保留来源与适用范围，并支持更新、纠正、失效。结论：存储不等于上下文，检索并筛选后模型才能使用。已目视核对生成图。

2026-10-29：正文 11 个主章节各一张图，另有统一封面。全部使用内置 GPT imagegen；保留旧图资源，不再引用旧手绘图。架构总览沿用 architecture.png，其余使用 *-unified.png。所有图为原创教学示意。

## 公共风格提示词

```text
Create an original Chinese technical infographic, landscape 3:2, 1536x1024. Match visual style of supplied reference ONLY: white background, navy large heading, pastel blue teal purple orange bordered cards, polished vector-like icons, crisp large Chinese sans serif, generous whitespace, precise arrows. Do not reuse reference content or layout. Avoid tiny text, decorative fake diagrams, crossed arrows. Technical correctness is essential.
```

风格参考：assets/img/posts/agent-harness/architecture.png。参考只用于颜色、字体层次与图标风格。

## 各图提示词

### position

标题：模型、Harness 与环境

三方分工图。左侧用户请求“查找项目的启动方式”；中央蓝色 Harness 卡片含“准备上下文”“调用模型”“执行工具”“记录结果”；上方紫色模型卡片“决定下一步：读取 README”；右侧橙色环境卡片“README.md / 文件系统”。箭头 Harness→模型标注请求，模型→Harness标注行动建议，Harness→环境标注读取，环境→Harness标注文件内容。底部结论“模型提出行动，Harness 让行动发生”。

### loop

标题：Agent 循环：下一步由状态决定

清楚的四步闭环：准备上下文→调用模型→处理响应→执行工具→工具结果回到准备上下文。处理响应有两个额外分支：需要信息→等待用户→收到回复后回到准备上下文；结束候选→验证→通过则完成，未通过回到准备上下文。底部独立控制条“取消信号 / 轮数上限 / 时间预算”。使用简洁文字，不交叉箭头。

### adapter

标题：模型接入：统一请求与响应

两行反向流程。第一行：内部输入（消息、工具定义、输出预算）→请求适配（角色映射、能力检查）→模型服务 A / B。第二行：模型流式响应→事件组装（拼接参数、关联调用 ID）→内部事件（文本 / 工具请求 / 结束 / 错误）。底部示例三步“收到参数片段”→“组装完整请求”→“交给执行循环”，注释“参数未完整，不执行工具”。

### tools

标题：工具执行：请求如何变成结果

主流程左至右：请求 read_file（path: README.md）→工具注册表（定位实现）→参数与权限校验→文件读取→结构化结果（状态 / 内容 / 调用 ID）。下方两条并列机制：长命令“启动→任务 ID→查询输出→退出码”；失败分类“文件不存在：调整路径”“暂时不可用：有限重试”“写入结果未知：先核对”。底部“工具描述供模型选择，执行实现负责实际操作”。

### context

标题：上下文：从全部材料到本轮输入

左边材料堆：用户目标、项目规则、历史消息、工具日志、参考文档。中间漏斗或筛选工作台“相关性筛选→去重与压缩→保留来源”。右边整齐输入堆栈“规则与目标 / 当前任务状态 / 相关代码片段 / 最近工具结果”，箭头到模型。底部独立存储区“完整历史与产物保存在外部”，双向细箭头标注“按需读取 / 保存引用”。角落示例“长日志：保留错误摘要与文件位置”。

### permissions

标题：权限与沙箱：两道不同的边界

左右两个大面板。左“动作授权：这次能不能做？”输入编辑 README 请求→策略判断，分成允许 / 拒绝 / 等待确认三个分支，只有允许指向右。等待确认在左内部返回策略判断。右“执行隔离：最多能访问哪里？”容器边界内“项目目录 可读写”“临时目录”；边界外“个人文件”“未授权网络”带阻断标记。底部对照“批准动作 ≠ 开放全部资源”“进入沙箱 ≠ 获得业务授权”。

### orchestration

标题：任务编排：分工、依赖与汇总

具体场景“评估项目升级影响”。顶层主 Agent“拆分问题 / 分配资源”；向下并行三分支“依赖检查：版本与兼容性”“代码检查：受影响接口”“测试检查：覆盖与缺口”。每个节点都有“独立上下文 / 只读工具”小标签。三个分支向下汇总到“主 Agent 核对证据”，再到“升级建议与待确认项”。侧边调度栏“并发上限 / 超时 / 取消 / 结果引用”。底部“可独立的工作并行，有依赖的步骤等待”。

### extensions

标题：扩展机制：不同能力接到不同位置

中心 Harness 内三横排接入点“上下文组装”“工具注册与执行”“生命周期事件”。左上 Skill 文件夹标注“SKILL.md / 参考材料”，箭头仅到上下文组装。左中 MCP 服务标注“工具 / 资源”，箭头到工具注册与执行，资源可按需读取。左下 Hooks 标注“调用前检查 / 调用后记录”，箭头到生命周期事件。顶部客户端通过 ACP 双向连接 Harness 入口。底部“Skill 教怎么做；工具提供动作；Hook 接入流程；ACP 连接客户端”。

### state

标题：状态、观测与评估：三种不同用途

三个并列可视面板，不要串行箭头。蓝色“恢复工作”含时间线“运行→检查点→中断→核对现场→继续”；紫色“解释过程”含 trace 树“任务→模型调用→工具调用”，标签“耗时 / 错误 / 产物引用”；绿色“判断效果”上方“本次产物→验收→修订或交付”，下方“代表性任务集→版本对比”，指标“成功率 / 成本 / 人工介入”。底部“检查点用于恢复，Trace 用于诊断，评估用于比较”。

### journey

标题：一次任务如何流经 Harness

用编号的两行蛇形清晰流程讲一个独立短例“任务：说明项目怎样启动”。1 用户提出问题→2 上下文加载项目规则→3 模型请求读取 README→4 权限检查通过→5 工具返回启动说明→6 模型发现缺少环境配置→7 再读取配置文档→8 汇总启动步骤与来源。第6到7标注“新信息驱动下一轮”。底部贯穿带“每轮记录请求、结果与任务状态”。注明“教学示例：只读资料，不启动服务”。

### cover-unified

标题：Agent Harness

Editorial cover same polished white/light blue infographic style as reference, landscape 3:2. Large navy title Agent Harness, subtitle 大模型之外的运行系统. Central blue execution hub with surrounding elegant icons for model purple brain, context blue documents, tools teal wrench, permissions orange shield, memory database and orchestration tree. Sparse text only title subtitle and three bottom labels 上下文 / 行动 / 反馈. No robot or sketch. This is conceptual cover not detailed architecture.

## 核对与精修

逐图目视检查中文、流程方向和职责边界。修正用户请求绕过 Harness 的连线；整理循环返回路径并补充结束候选入口；将模型适配中的能力差异、结束事件和参数措辞校准；将恢复图中绝对保证的表述改为恢复前核对外部状态。图注补充省略步骤和示例范围。图片生成不代表运行过所示任务。
