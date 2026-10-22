# 知其所以

基于 [Chirpy](https://github.com/cotes2020/jekyll-theme-chirpy) 的中文博客，由 shenli 记录 AI 技术学习、开源项目分析与技术文章阅读中的理解和思考。

## 本地运行

需要 Ruby 3.4。本机环境已安装，可在 Finder 中双击 `preview.command`，或执行：

```sh
./preview.command
```

该入口自动选择本机 Homebrew Ruby 3.4、检查依赖并启动预览，无需修改系统 Ruby。也可手动运行：

```sh
bundle install
bundle exec jekyll serve --host 127.0.0.1
```

预览：http://127.0.0.1:4000

开发模式自动禁用 PWA 离线缓存，并发送 `Cache-Control: no-store`，修改文章后刷新原地址即可看到更新。已打开过旧版预览的浏览器会在检查 Service Worker 更新后自动清理本站的 `chirpy-*` 缓存；首次迁移可能需要再刷新一次。修改 `_config.yml` 或 `_plugins/` 后需重启本地预览。

正式构建使用 `JEKYLL_ENV=production`（部署工作流已配置），仍保留主题原有的 PWA 缓存行为。

## 内容与配置

- `_posts/`：已发布文章。
- `_drafts/`：草稿。
- `_tabs/about.md`：关于本站。
- `_config.yml`：名称、简介、语言、站点地址。
- `assets/img/`：头像与文章图片。
- [写作指南](docs/写作指南.md)：新增文章、检查、部署和样式修改方法。

预设 GitHub Pages 地址为 `https://shenlihust.github.io`，需完成仓库上传与 Pages 启用后才会生效。

模板来自 [Chirpy Starter](https://github.com/cotes2020/chirpy-starter)，保留其 MIT 许可证。当前保留原版主题布局，自定义内容与主题实现分离。
