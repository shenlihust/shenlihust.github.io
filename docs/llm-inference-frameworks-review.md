# 推理框架文章核对记录

核对日期：2026-10-26。

文章：`_posts/2026-10-26-llm-inference-frameworks.md`。用户已授权更新到线上，本文已转为正式文章；实际 GitHub Pages 部署结果以对应提交的 Actions 记录为准。

## 写作定位与来源覆盖

文章标题按用户反馈调整为《一次 LLM 请求背后：理解大模型推理框架》，去掉面向特定职业的措辞；头图同步调整副标题。用户要求吸收推荐文章、讲清概念、扩展网上材料并多配图。正文用故障排查 Agent 串起请求处理，以应用开发的观测、设计与验收为落点。

推荐文章为阿里云《AI Agent Handbook》的《深入浅出推理框架》。页面未见具名作者与明确发布日期，正文如实说明，不猜测。原文内容按以下范围吸收：

| 原文主题 | 正文处理 |
| --- | --- |
| 模型、训练、推理、Harness 与服务关系 | 开篇分层；区分 inference 和 reasoning，避免把推理引擎与网关混为一层 |
| 基础术语与指标 | Token、模板、两阶段、KV、MoE、TTFT / TPOT、吞吐和 Goodput 分别解释 |
| 开源框架生态 | 保留引擎、本地运行工具、集群编排的阅读地图；没有抄录星标、厂商性能或发布时间线 |
| 一个请求的工作过程 | 模板与分词、调度、执行、缓存、采样、输出解析与流式返回 |
| 服务端优化 | 分页、FlashAttention、连续批处理、分块 Prefill、抢占、量化、并行、PD 分离、投机解码 |
| 使用人群与应用关联 | 重点覆盖 API 应用团队与自部署团队；未展开云厂商经营、客户故事及 RL rollout |

未使用原文中 DeepInfer 等最新发布叙述作为文章论据，未复述未经独立核对的价格比例或性能倍数。明确未展开多模态编码、底层算子实现与完整行业历史。

补充资料均为一手来源；正文有 22 个去重后的外部 URL，包含参考入口，不等于 22 份独立实测：

- Hugging Face：Chat templates、How caching works。
- vLLM：Automatic Prefix Caching、Optimization and Tuning；核对缓存主要减少 Prefill、V1 抢占采用 RECOMPUTE、分块 Prefill 和并行策略。
- SGLang：结构化输出、确定性推理、量化官方文档；RadixAttention 对照 SGLang 原始论文。
- 原始研究：PagedAttention（2309.06180）、SGLang（2312.07104）、FlashAttention（2205.14135）、Speculative Decoding（2211.17192）、DistServe（2401.09670）；Orca 使用 USENIX OSDI 2022 页面。
- NVIDIA：NIM 推理指标文档；对齐 TTFT 的客户端口径与流式空事件问题。
- 项目官方仓库：TensorRT-LLM、llama.cpp、Ollama、Dynamo、llm-d；仅描述职责，不做性能排名。

## 关键事实与限制

- 只将 Prefill / Decode 经验用于本文限定的自回归 Transformer 路径；计算瓶颈保留批次、模型结构、硬件和通信条件。
- Prefill 的预测分布可以产生首 Token，监控实现可能另行划分阶段。
- KV 缓存保存中间状态，不是答案；前缀复用不消除全注意力 Decode 的历史访问。
- 前缀缓存命中取决于实际序列、块边界、缓存存续、路由、配置与服务隔离，不承诺请求相似就命中。
- KV 估算限定为全注意力、各层 KV 形状一致的常见模型；GQA / MQA 使用 KV 头数；MLA、滑动窗口、混合结构另算。
- 算术例：2 × 32 × 8 × 128 × 2 = 131072 字节，即 128 KiB / Token；8192 Token 为 1 GiB；16 条独立序列为 16 GiB。未冒充模型实测。
- TTFT 不等于 Prefill；首个底层 Token 不等于首个可见正文；流事件不等于 Token。
- TPOT 公式要求 N > 1 且 Token 数和时间范围一致；吞吐注明计数与 SLO 约束。
- 结构化输出约束格式，不保证事实、业务参数与权限正确。
- 低温度不保证跨批次、硬件和版本逐字确定；投机解码保持分布有算法前提，不引用通用加速倍数。
- PD 分离按计算阶段切资源，需要 KV 传输，不是 PP 的模型层划分。
- Agent 串行耗时与并行关键路径分开，避免将 E2E 与内含的阶段耗时重复相加。
- 实验章节明确为待实施方案，没有调用模型做 GPU benchmark，也没有推断云服务内部指标。

## 配图与技能取舍

正文技术图按仓库规范使用 `excalidraw-diagram`，沿用其色板与清晰直线。图中英文 Token 与块表是教学示意，中文已渲染核对。用户随后明确要求用 imagegen 增加文章头图，并要求加入中文文案：通过内置 `image_gen` 生成横幅概念插画，以机械装置隐喻输入、调度、计算、缓存和输出，配色呼应正文；加入与文章对应的中文主副标题后，再微调底部留白。它不作为实际硬件结构图或技术证据。当前头图保存在 `assets/img/posts/llm-inference-frameworks/hero-v2.png`，副标题为“理解大模型推理框架”；无字首版与原文案版本仍保留，完整提示词见 `docs/llm-inference-frameworks-hero-prompt.md`。

| 文件标识 | 图解意图 |
| --- | --- |
| request-journey | 职责分层与一条请求的流向，执行与 KV 双向交互 |
| prefill-decode | 已知输入的位置并行与未知输出的串行依赖 |
| kv-cache-pages | 两条逻辑序列映射到非连续物理块，共享块 4 |
| continuous-batching | 固定批次的空槽与迭代边界补入新请求 |
| prefix-cache | 稳定公共前缀与开头动态内容的差异 |
| latency-metrics | 请求发出、首内容、末内容和响应结束的边界 |
| pd-disaggregation | 同实例执行与跨资源池 KV 传输 |
| agent-critical-path | 模型与工具交替执行、任务时间与请求内部时间 |

8 份 `.excalidraw` 源文件在 `assets/diagrams/llm-inference-frameworks/`，8 张 PNG 在 `assets/img/posts/llm-inference-frameworks/`，约 3.5 MiB。每张都经过渲染并查看，输入 Token 位置标签从空格排版改为独立文本后重新渲染查看。正文含中文替代文本与原创图注。

## 验证记录

- Homebrew Ruby 3.4 下开发构建及最终 `JEKYLL_ENV=production bundle exec jekyll build --drafts --destination /tmp/agent-tech-blog-inference-preview` 均成功。
- 加入中文头图后，生产模式草稿构建再次通过；最终 HTML-Proofer 内部检查通过：32 个 HTML 文件，194 个内部链接、7 个文件中的锚点检查；关闭外链批量检查。
- 专项检查通过：8 个图片引用存在；8 份 JSON 可解析，元素 ID 唯一、绑定引用有效；Markdown 代码围栏成对、无行尾空白；KV 算术通过。
- 文章 HTML 的 56 个 ID 无重复、25 个本页锚点有效。
- IAB 1280 × 720 桌面抽查标题、正文和请求旅程图；390 × 844 手机抽查代码、正文、图注及灯箱。手机页面 `scrollWidth` 与 `clientWidth` 均为 390，无整页横向溢出；代码块保留自身滚动。大图在手机宽度下文字较小，需放大阅读。
- 分类与标签页面确认文章收录于“原理与架构”和“LLM”，均可返回草稿。预览使用 4173 端口的独立静态目录，不改动已有预览配置。手机视口覆盖已经重置。

限制：浏览器为抽查，没有逐段、逐浏览器验证；未视为已执行全部实验或外链状态测试。本文已从 `_drafts` 移入 `_posts`，发布时需通过不含 `--drafts` 的生产构建。

中文头图追加验证：1672 × 941 PNG 已保存项目目录；生成 HTML 中恰好一个头图引用，中文替代文本正确。浏览器刷新预览后，确认文章顶部展示带中文主副标题的插画，主体和底部支脚无裁切。

发布前验证：转入 `_posts` 后，执行不带 `--drafts` 的生产构建，输出目录 `/tmp/agent-tech-blog-inference-release`，构建成功。HTML-Proofer 检查 32 个 HTML 文件、194 个内部链接及 7 个文件的锚点，通过。正式文章输出存在，引用中文头图与 8 张正文图，9 个图片文件全部存在；旧草稿路径已移除。发布目标核对为 `origin` 的 `shenlihust/shenlihust.github.io` 仓库、`main` 分支与 GitHub Pages workflow。
