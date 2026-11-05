# 智能体评估案例文章核对记录

核对日期：2026-11-05。文章：`_posts/2026-11-05-agent-benchmark-case-studies.md`。

## 范围与证据

- 原创案例解析，分类为工程实践；保留此前解析版与全文翻译。
- Terminal-Bench：固定 `2fd12b88aafdd04a52c298e3940bcb189f9766d6`，核对 regex-log 的 instruction、task 配置、测试和评分脚本。区分任务集、运行器、智能体框架、模型；oracle 不代表模型能力。
- τ 系列：固定 `033bf082f48e4a3c6a1256208e93cf2ce9c3bb6f`，核对航空任务 1、电信漫游任务及 evaluation 文档。航空任务的 NL_ASSERTION 不在 reward_basis；电信任务以 ENV_ASSERTION 计分。论文名称与仓库版本不混用。
- SWE-bench Verified：读取官方数据集 astropy__astropy-12907，核对基础提交、问题、参考补丁及测试列表；FAIL_TO_PASS 2 项、PASS_TO_PASS 13 项。不将参考补丁当成被测智能体输入。
- WebArena：固定 `dce04686a56253aefba7b18a4fa0937cf1dc987b`，任务 580 通过 program_html 检查保存的字段。
- OSWorld：固定 `8903ebeb0efdf74331bd7dc37ed91ccbbff22317`，核对 Chrome 任务 030eeff7-b492-4218-b312-701ec99ee0cc 及配置读取器。
- BrowseComp：核对官方介绍、论文和公开评分提示词。论文定位案例标明为公开构题示例；未把它声称为实际运行记录。当前公开代码的解析实现需另行测试，文章不提供未经运行验证的复现保证。
- 未覆盖所有基准与排行榜，不引用当前模型排名。重心是任务如何执行及验收，而不是基准穷举。

## 图解与验证

- 原创 Excalidraw 图解释 regex.txt 与测试共同产生 reward；保留可编辑源文件，已渲染并查看 PNG，无文字遮挡。
- 生产模式 Jekyll 构建通过。
- HTMLProofer `--disable-external` 通过：38 个 HTML 文件，277 个站内链接；外部链接未批量探活。
- Playwright 实际打开文章，检查 1440×1000 桌面与 390×844 手机首屏；手机 document scrollWidth 为 390，配图加载成功。
- 点击工程实践分类，确认新文章收录。
- 宽表格沿用主题的局部横向滚动，不造成整页溢出。
- 未运行完整基准、模型试验或文中的 Harbor 命令；正文已明确说明。
- 未提交、推送或部署；保留原有两张 agent-harness 未跟踪图片。

## 介绍与仓库入口补充

- 为 Terminal-Bench、τ-bench、τ²-bench、SWE-bench、WebArena、OSWorld、BrowseComp 补充定位、任务范围、交互方式和适用边界，保留具体案例。
- 新增官方 GitHub 表格，区分初代 τ-bench 与后续仓库，并补充 Harbor 和 Verified 数据集入口。
- 在线核对官方仓库、τ²-bench 论文、BrowseComp 官方介绍和 Verified 数据集；不将公开评测资源等同于全部依赖免费或开源。
- 补充后重新构建成功，HTMLProofer 检查 38 个 HTML 文件、283 个站内链接通过；生成页面中确认表格有 7 个仓库链接。
- 本次为正文与表格补充，未重复桌面和手机截图验收；上面的视觉检查记录对应初稿。
