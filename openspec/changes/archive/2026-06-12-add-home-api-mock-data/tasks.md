# Implementation Tasks

## 1. 创建MockInterceptor
- [x] 1.1 创建 `lib/core/network/interceptors/mock_interceptor.dart` 文件
- [x] 1.2 实现 `MockInterceptor` 类，继承 `Interceptor`
- [x] 1.3 实现 `onRequest` 方法，检查 `AppConfig.useMockServices`
- [x] 1.4 实现路径匹配逻辑，识别需要Mock的API端点
- [x] 1.5 实现Mock数据生成方法

## 2. 为首页API添加Mock数据
- [x] 2.1 实现用户信息Mock数据 (`_mockUserProfile`)
- [x] 2.2 实现天气信息Mock数据 (`_mockWeather`)
- [x] 2.3 实现规划行程Mock数据 (`_mockPlannedTrips`)
- [x] 2.4 实现推荐路线Mock数据 (`_mockRoutes`)
- [x] 2.5 实现徒步攻略Mock数据 (`_mockGuides`)

## 3. 集成MockInterceptor到ApiClient
- [x] 3.1 修改 `lib/core/network/api_client.dart`
- [x] 3.2 在 `_addInterceptors()` 方法中添加 `MockInterceptor`
- [x] 3.3 确保 `MockInterceptor` 在其他拦截器之前执行
- [x] 3.4 添加日志输出，标识Mock数据的使用

## 4. 测试验证
- [x] 4.1 设置 `useMockServices = true`，验证首页加载Mock数据
- [x] 4.2 验证用户信息卡片显示正确
- [x] 4.3 验证天气信息显示正确
- [x] 4.4 验证规划行程列表显示正确
- [x] 4.5 验证推荐路线列表显示正确
- [x] 4.6 验证徒步攻略列表显示正确
- [x] 4.7 设置 `useMockServices = false`，验证仍能正常调用真实API
- [x] 4.8 验证Mock拦截器不影响其他API请求

## 5. 文档更新
- [x] 5.1 在网络层README中添加MockInterceptor使用说明
- [x] 5.2 添加如何添加新Mock数据的指南
- [x] 5.3 更新开发环境配置文档

## 验证标准
每个任务完成后需要满足：
- 代码遵循项目Dart编码规范 ✅
- 添加必要的注释说明 ✅
- 确保不影响现有功能 ✅
- Mock数据格式符合后端API响应标准 ✅

## 实施总结

### 已完成的工作
1. **创建MockInterceptor拦截器**
   - 实现了完整的Mock拦截器类，包含路径匹配和数据返回逻辑
   - 支持5个首页API的Mock数据：用户信息、天气、规划行程、推荐路线、徒步攻略
   - 实现了200-500ms的网络延迟模拟，提供更真实的测试体验

2. **集成到ApiClient**
   - 将MockInterceptor作为第一个拦截器注册到ApiClient
   - 确保Mock模式启用时能绕过其他拦截器直接返回数据
   - 添加了清晰的日志输出，便于开发调试

3. **测试验证**
   - 创建了完整的单元测试套件（7个测试用例）
   - 所有测试用例全部通过 ✅
   - 验证了Mock数据的格式符合后端API响应标准
   - 验证了延迟模拟功能正常工作
   - 验证了未匹配的API会正常发送到网络

### 技术亮点
- **零侵入性**：Service层代码无需修改，完全通过拦截器实现
- **统一管理**：所有Mock数据集中在MockInterceptor中，便于维护
- **配置驱动**：通过AppConfig.useMockServices开关控制，灵活切换
- **符合规范**：Mock数据结构完全遵循后端API响应格式
- **开发友好**：提供清晰的日志输出和合理的延迟模拟

### 验证结果
```
✅ Mock用户信息API应返回mock数据
✅ Mock天气信息API应返回mock数据
✅ Mock规划行程API应返回mock数据
✅ Mock推荐路线API应返回mock数据
✅ Mock徒步攻略API应返回mock数据
✅ 未匹配的API应正常发送
✅ Mock数据包含合理的延迟
```

所有功能已完整实现并通过测试验证！
