# network-client Specification

## Purpose
HTTP 客户端核心能力，提供统一的网络请求管理，包括请求发送、配置管理、生命周期控制。

**技术栈**: Dio HTTP Client  
**设计模式**: 单例模式
## Requirements
### Requirement: HTTP 请求方法支持
ApiClient SHALL 提供完整的 HTTP 方法支持：

| 方法 | 用途 |
|------|------|
| `GET` | 获取资源 |
| `POST` | 创建资源 |
| `PUT` | 完整更新资源 |
| `PATCH` | 部分更新资源 |
| `DELETE` | 删除资源 |

每个请求方法 SHALL 支持以下参数：
- `path`: 请求路径（必需）
- `queryParameters`: 查询参数（可选）
- `data`: 请求体数据（可选，仅 POST/PUT/PATCH/DELETE）
- `options`: Dio Options 配置（可选）
- `cancelToken`: 取消令牌（可选）

#### Scenario: 发送 GET 请求
- **WHEN** 调用 `apiClient.get('/routes')`
- **THEN** 发送 GET 请求到 `{baseUrl}/routes`
- **AND** 返回 `Response<T>` 对象

#### Scenario: 发送带参数的 POST 请求
- **WHEN** 调用 `apiClient.post('/login', data: {'username': 'test'})`
- **THEN** 发送 POST 请求，body 为 JSON 格式
- **AND** Content-Type 为 `application/json`

---

### Requirement: 文件上传支持
ApiClient SHALL 提供文件上传能力：

- 支持 `FormData` 格式上传
- 支持上传进度回调 `onSendProgress`
- 支持多文件上传

#### Scenario: 上传 GPX 文件
- **WHEN** 调用 `apiClient.upload('/upload/gpx', formData)`
- **THEN** 以 `multipart/form-data` 格式发送请求
- **AND** 通过 `onSendProgress` 回调报告上传进度

---

### Requirement: 文件下载支持
ApiClient SHALL 提供文件下载能力：

- 支持下载到指定路径
- 支持下载进度回调 `onReceiveProgress`
- 支持断点续传（通过 `lengthHeader` 参数）
- 支持下载失败时自动删除不完整文件

#### Scenario: 下载离线地图
- **WHEN** 调用 `apiClient.download(url, savePath)`
- **THEN** 将文件保存到 `savePath`
- **AND** 通过 `onReceiveProgress` 回调报告下载进度

---

### Requirement: 基础配置管理
ApiClient SHALL 支持基础配置：

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| `baseUrl` | 从 AppConfig 获取 | 基础 URL |
| `connectTimeout` | 15000ms | 连接超时 |
| `receiveTimeout` | 15000ms | 接收超时 |
| `sendTimeout` | 15000ms | 发送超时 |
| `headers` | 见下表 | 默认请求头 |

默认请求头：
- `Content-Type`: `application/json`
- `Accept`: `application/json`
- `User-Agent`: `Walk-App/{version}`

#### Scenario: 初始化客户端
- **WHEN** 调用 `apiClient.initialize(baseUrl: 'https://api.example.com')`
- **THEN** 设置基础 URL 和默认配置
- **AND** 添加拦截器链

#### Scenario: 动态更新 baseUrl
- **WHEN** 调用 `apiClient.updateBaseUrl('https://new-api.example.com')`
- **THEN** 后续请求使用新的 baseUrl

---

### Requirement: 认证 Token 管理
ApiClient SHALL 提供认证 Token 管理：

- `setAuthToken(token)`: 设置 Bearer Token
- `clearAuthToken()`: 清除认证 Token

#### Scenario: 设置认证 Token
- **WHEN** 调用 `apiClient.setAuthToken('jwt_token_xxx')`
- **THEN** 后续请求头包含 `Authorization: Bearer jwt_token_xxx`

#### Scenario: 清除认证 Token
- **WHEN** 调用 `apiClient.clearAuthToken()`
- **THEN** 后续请求不包含 Authorization 头

---

### Requirement: 单例模式
ApiClient SHALL 使用单例模式，确保全局唯一实例：

- 通过 `ApiClient.instance` 获取实例
- 私有构造函数防止外部实例化

#### Scenario: 获取单例实例
- **WHEN** 多次调用 `ApiClient.instance`
- **THEN** 返回同一个实例

---

### Requirement: 网络管理器
NetworkManager SHALL 提供网络层统一管理：

- 初始化网络层（结合 AppConfig）
- 网络状态检查（健康检查）
- 获取网络配置信息

#### Scenario: 初始化网络层
- **WHEN** 调用 `NetworkManager.instance.initialize()`
- **THEN** 从 AppConfig 读取配置
- **AND** 初始化 ApiClient
- **AND** 添加环境特定的请求头

#### Scenario: 检查网络状态
- **WHEN** 调用 `networkManager.checkNetworkStatus()`
- **THEN** 发送健康检查请求到 `/api/system/health`
- **AND** 返回 `true` 表示网络可用，`false` 表示不可用

---

### Requirement: 环境配置
AppConfig SHALL 提供环境配置管理：

| 环境 | 说明 |
|------|------|
| `development` | 开发环境，默认启用 Mock 和日志 |
| `staging` | 测试环境 |
| `production` | 生产环境，禁用日志 |

配置项包括：
- `baseUrl`: 基础 URL（**从环境变量读取，不硬编码默认值**）
- `useMockServices`: 是否使用 Mock 服务
- `enableLogging`: 是否启用日志
- `timeoutConfig`: 超时配置
- `retryConfig`: 重试配置（**统一使用 AppConfig 中的定义**）

`_getDefaultBaseUrl()` 方法 SHALL 根据环境变量正确返回对应环境的 URL：
- `development`: 从 `DEV_BASE_URL` 环境变量读取，默认 `http://localhost:8080`
- `staging`: 从 `STAGING_BASE_URL` 环境变量读取
- `production`: 从 `PROD_BASE_URL` 环境变量读取

#### Scenario: 开发环境初始化
- **WHEN** 环境变量 `ENV=development`
- **THEN** 从 `DEV_BASE_URL` 读取 baseUrl
- **AND** 默认启用 Mock 服务
- **AND** 默认启用日志

#### Scenario: 生产环境初始化
- **WHEN** 环境变量 `ENV=production`
- **THEN** 从 `PROD_BASE_URL` 读取 baseUrl
- **AND** 禁用 Mock 服务
- **AND** 禁用日志

#### Scenario: baseUrl 不被硬编码覆盖
- **WHEN** 调用 `_getDefaultBaseUrl()`
- **THEN** 根据 `_environment` 变量执行对应的 switch 分支
- **AND** 不存在提前 return 的硬编码值

