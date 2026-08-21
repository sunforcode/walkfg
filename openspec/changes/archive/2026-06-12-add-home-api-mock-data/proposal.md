# Change: 为首页API增加Mock数据支持

## Why
当前项目已经具备`useMockServices`配置开关和部分Service层的Mock数据实现，但是在网络层（ApiClient/拦截器）缺少统一的Mock拦截逻辑。这导致：

1. **开发体验不佳**：前端开发依赖后端API，后端未实现时无法进行首页开发
2. **测试困难**：无法在没有后端服务的情况下测试首页功能
3. **Mock实现不统一**：部分Service使用JSON文件，部分直接调用API，缺乏统一的Mock策略

首页是用户进入应用的第一个页面，包含5个关键API（用户信息、天气、规划行程、推荐路线、徒步攻略）。为这些API提供Mock数据支持可以：
- 使前端开发完全独立于后端进度
- 提供可预测的测试数据
- 在网络层统一管理Mock逻辑，不侵入Service层代码

## What Changes
- 创建 `MockInterceptor` 拦截器，在网络请求层面提供Mock数据支持
- 在 `ApiClient` 中集成 `MockInterceptor`，作为第一个拦截器执行
- 为首页5个API提供符合后端响应格式的Mock数据：
  - `GET /walkbg/api/v1/user/profile` - 用户信息
  - `GET /walkbg/api/v1/weather` - 天气信息
  - `GET /walkbg/api/v1/trips/planned` - 规划行程列表
  - `GET /walkbg/api/v1/routes` - 推荐路线列表
  - `GET /walkbg/api/v1/guides` - 徒步攻略列表
- 当 `AppConfig.useMockServices = true` 时，拦截器返回Mock数据
- 当 `AppConfig.useMockServices = false` 时，请求正常发送到后端

## Impact
- **Affected specs**: 
  - `network-interceptors` - 新增MockInterceptor要求
  
- **Affected code**: 
  - `lib/core/network/interceptors/mock_interceptor.dart` - 新建文件
  - `lib/core/network/api_client.dart` - 修改拦截器注册逻辑
  
- **Breaking changes**: 无
  - 现有代码无需修改
  - 完全向后兼容
  - 通过配置开关控制行为

- **Dependencies**: 
  - 依赖现有的 `AppConfig.useMockServices` 配置
  - 依赖 Dio 拦截器机制
  
- **Testing impact**:
  - 可以在无后端环境下测试首页功能
  - 提供稳定的测试数据
  
- **Documentation**: 
  - 需要在网络层README中说明Mock拦截器的使用方式
