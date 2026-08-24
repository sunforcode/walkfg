## Why

Flutter Web 当前会在首屏前加载远程 CanvasKit，并串行执行多项互不依赖的基础初始化。远程渲染资源不可达时页面会永久停留在 HTML 加载提示，即使资源可达，串行初始化与缺少针对 Flutter 产物的缓存策略也会放大冷启动和重复访问耗时。

## What Changes

- Flutter Web 构建产物包含 CanvasKit，并从应用同源地址加载，不依赖 Google CDN。
- 应用在 Flutter 第一帧后并行执行互不依赖的基础初始化，仅保留存在依赖关系的网络与登录态恢复顺序。
- 真实服务模式不预加载 Mock JSON；Mock 模式继续在进入应用前准备所需数据。
- Nginx 对 Flutter Web 入口文件禁用缓存，对可复用的 JS、WASM、字体和图片资源启用压缩与长期缓存。
- 增加构建、启动状态和缓存响应头验证，避免发布后重新出现永久加载或重复下载大体积资源。

## Capabilities

### New Capabilities
- `web-startup-performance`: 规定 Flutter Web 渲染资源来源、启动初始化边界以及静态资源缓存行为。

### Modified Capabilities

无。

## Impact

影响 Flutter 子项目的启动入口、启动测试和 Web 构建流水线，以及承载 `/app/` 的 Nginx 配置。不会修改后端 API、DTO、业务数据或跨端协议；发布时 Web 产物会增加本地 CanvasKit 文件，但客户端不再依赖 Google CDN。
