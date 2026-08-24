## Context

Flutter Web 冷启动包含引擎资源加载和 Dart 应用初始化两个阶段。当前构建默认从 Google CDN 获取 CanvasKit，在目标网络环境中可能不可达；Flutter 第一帧因此无法产生，HTML 占位页持续显示。第一帧产生后，应用又串行执行环境配置、日期数据、Hive、网络客户端和登录态恢复，扩大了进入正式页面前的等待。

生产部署由 `walkadmin-react/nginx.conf` 的 `/app/` location 承载 Flutter 静态文件，Flutter 构建产物通过 CI 同步到挂载目录。优化必须兼顾构建、运行时初始化与静态资源响应头。

## Goals / Non-Goals

**Goals:**

- 消除客户端启动对 Google CanvasKit CDN 的依赖。
- 尽早产生 Flutter 第一帧，并缩短 Flutter 加载页停留时间。
- 对不可变的大体积资源启用压缩和长期缓存，对入口文件保持禁用缓存。
- 保留初始化失败提示与重试能力。

**Non-Goals:**

- 不更换 Flutter Web 技术栈或改写为 DOM 前端。
- 不修改业务接口、登录协议或首页数据加载行为。
- 不引入新的缓存服务、Service Worker 定制或第三方 CDN。

## Decisions

CanvasKit 使用 Flutter 官方 `--no-web-resources-cdn` 构建选项随产物部署。相比继续配置已失效的 HTML renderer，此方案与当前 Flutter 版本一致，且能在目标网络环境中稳定启动。代价是部署产物体积增加，但浏览器可长期缓存这些文件。

基础初始化按依赖关系分组。环境文件加载、日期格式和 Hive 初始化互不依赖，可并行执行；应用配置依赖环境加载结果，网络客户端依赖应用配置，登录态恢复依赖网络客户端。Mock JSON 只在 Mock 模式下执行，真实服务模式不承担该启动成本。

Nginx 保持 `/app/index.html` 等入口协调文件不缓存，为 `/app/` 下可复用的 CanvasKit、字体与图片设置一周公共缓存，并把 `application/wasm` 纳入 gzip 类型。Flutter 生成文件名并非全部带内容哈希，因此不使用 immutable 或一年缓存，避免 Flutter 升级后长期命中旧资源。

## Risks / Trade-offs

- 本地 CanvasKit 增加部署体积 → 通过压缩和浏览器长期缓存降低重复传输成本。
- 初始化并行后异常顺序不再固定 → `Future.wait` 仍将任一失败传递给现有错误页，重试重新执行可重复步骤。
- 过度缓存入口文件可能造成新旧版本不一致 → `index.html`、`flutter_bootstrap.js`、`main.dart.js` 和版本清单不使用 immutable。
- 修改共享 Nginx 会影响 Admin 与 Flutter → 新规则限定在 `/app/` 路径，不改变 Admin 根路径和后端代理。

## Migration Plan

先合并启动初始化和构建参数，再发布包含本地 CanvasKit 的新 Web 产物，最后重新构建或重载 Nginx 配置。验证 `/app/index.html` 不缓存、CanvasKit 从 `/app/canvaskit/` 加载且具有压缩和长期缓存响应头。回滚时恢复旧 Nginx 配置和上一版 Flutter Web 产物即可。

## Open Questions

无。
