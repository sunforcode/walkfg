## 1. Flutter 启动优化

- [x] 1.1 为并行基础初始化和依赖顺序补充启动测试
- [x] 1.2 并行执行环境、日期格式与 Hive 初始化
- [x] 1.3 保持网络客户端先于登录态恢复，并在真实服务模式跳过 Mock JSON 预加载

## 2. Web 资源交付

- [x] 2.1 使用本地 CanvasKit 构建 Flutter Web 产物
- [x] 2.2 为 `/app/` 下的入口文件和可复用静态资源配置不同缓存策略
- [x] 2.3 将 WebAssembly 纳入压缩响应类型

## 3. 验证

- [x] 3.1 严格校验 OpenSpec 变更
- [x] 3.2 运行 Flutter 启动测试和静态检查
- [x] 3.3 构建 Release Web 并确认 CanvasKit 同源加载与缓存配置有效
