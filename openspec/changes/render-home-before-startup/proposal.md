## Why

首页是应用的第一交互界面，但当前仍由通用加载页等待基础设施初始化，Web 引擎启动前还同步加载未使用的第三方地图脚本。用户需要先看到并操作首页壳层，路线、天气、地图、认证等数据随后异步补齐。

## What Changes

- Flutter 第一帧直接渲染首页，不等待网络、缓存和登录态恢复完成。
- 首页基础初始化未完成时展示现有空态首页壳层，不展示通用加载指示器。
- 首页数据在基础初始化完成后异步加载，避免未初始化的网络调用。
- 删除 Web 入口中未使用的 MapLibre CDN 脚本、样式和检测逻辑。
- Web HTML 启动占位改为与空态首页一致的轻量静态壳层。
- 主 JS 允许浏览器保存并重新验证，避免每次刷新完整下载。

## Capabilities

### New Capabilities
- `home-first-render`: 规定首页壳层先于非必要基础设施和业务数据完成渲染。

### Modified Capabilities
- `web-startup-performance`: 调整 Web 启动占位和入口资源缓存行为。

## Impact

影响 Flutter 首页启动参数、启动入口、Web HTML 壳层、启动测试和 Nginx `/app/` 缓存规则。不改变后端接口、业务数据模型或导航契约。
