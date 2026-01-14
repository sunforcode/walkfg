# Change: 优化 Home 页面网络请求

## Why
当前 Home 页面在初始化时串行执行 4 个独立的数据请求（用户天气、规划行程、推荐路线、徒步攻略），导致页面加载缓慢。此外，业务代码中混杂了数据来源的处理逻辑（Mock vs API），违背了 Service 层的设计原则。

## What Changes
- 将串行请求改为并行请求，使用 `Future.wait` 同时发起所有独立请求
- 简化业务代码，移除对 Mock 数据的感知，仅调用 Service 方法
- 建立统一的错误处理规范，单个请求失败不影响其他数据展示
- 优化用户体验，支持局部数据加载和错误展示

## Impact
- Affected specs: `service-layer`
- Affected code: 
  - `lib/ui/page/home/home_screen.dart` - 主要修改
  - `lib/ui/page/home/widgets/*.dart` - Widget 错误处理适配
- Performance: 预计页面加载时间减少 60%+（从串行改为并行）
- Breaking: 无破坏性变更
