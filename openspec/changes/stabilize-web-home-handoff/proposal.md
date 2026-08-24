## Why

当前 Web 冷启动连续暴露 HTML 空首页、Flutter 空首页和已选路线首页，既产生尺寸跳变，也错误地向已有路线的用户传达“还没有行程”。需要将启动等待与业务空态分离，确保首次可见业务页面就是最终首页状态。

## What Changes

- 将 HTML 首屏改为中性品牌启动画面，不展示“找路线”或“还没有行程”等业务状态。
- 在 HTML 中静态声明移动端 viewport，确保 Flutter 接管前后的尺寸基准一致。
- Flutter 在启动和首次首页数据解析期间不渲染业务空态，由静态启动画面持续覆盖。
- 首次路线恢复只产生一次首页数据加载，避免重复请求和竞态。
- 仅在确认没有已选路线后展示 `EmptyHome`；已有路线时直接展示 `RouteHome`。

## Capabilities

### New Capabilities
- `stable-home-handoff`: 定义 Web 启动画面与最终首页状态之间无错误业务中间态的交接行为。

### Modified Capabilities
- `web-startup-performance`: 补充移动端 viewport 与静态启动画面的稳定尺寸要求。

## Impact

影响 Flutter 首页状态管理、当前路线恢复监听、Web 入口 HTML，以及首页启动回归测试。不修改后端 API、DTO 或跨端共享数据契约。
