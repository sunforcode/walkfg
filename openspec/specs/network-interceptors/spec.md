# network-interceptors Specification

## Purpose
网络拦截器链，提供请求/响应的统一处理能力，包括认证、重试、日志、错误处理。

**执行顺序**: Auth → Retry → Logging → Error
## Requirements
### Requirement: 拦截器链架构
拦截器 SHALL 按固定顺序执行：

| 顺序 | 拦截器 | 职责 |
|------|--------|------|
| 1 | AuthInterceptor | 请求前添加认证 Token |
| 2 | RetryInterceptor | 失败时自动重试 |
| 3 | LoggingInterceptor | 记录请求/响应日志（仅开发环境） |
| 4 | ErrorInterceptor | 统一错误处理和转换 |

#### Scenario: 拦截器执行顺序
- **WHEN** 发送请求
- **THEN** 请求依次经过 Auth → Retry → Logging → Error 拦截器
- **AND** 响应按逆序经过拦截器

---

### Requirement: 认证拦截器 (AuthInterceptor)
AuthInterceptor SHALL 自动管理认证 Token：

**请求拦截**：
- 从本地存储读取 Token
- 自动添加 `Authorization: Bearer {token}` 头

**错误拦截**：
- 检测 401 状态码
- 自动刷新 Token
- 使用新 Token 重发原请求

**静态方法**：
- `saveAuthTokens(token, refreshToken)`: 保存 Token
- `clearAuthTokens()`: 清除 Token
- `isLoggedIn()`: 检查登录状态
- `getCurrentToken()`: 获取当前 Token

#### Scenario: 自动添加 Token
- **WHEN** 发送请求且本地存储有 Token
- **THEN** 请求头自动包含 `Authorization: Bearer {token}`

#### Scenario: Token 过期自动刷新
- **WHEN** 收到 401 响应
- **THEN** 使用 refreshToken 请求新 Token
- **AND** 保存新 Token
- **AND** 使用新 Token 重发原请求

#### Scenario: 刷新失败清除 Token
- **WHEN** Token 刷新失败
- **THEN** 清除本地存储的 Token
- **AND** 返回原始 401 错误

---

### Requirement: 重试拦截器 (RetryInterceptor)
RetryInterceptor SHALL 在特定错误时自动重试：

**可重试的错误类型**：
- 连接超时 (`connectionTimeout`)
- 发送超时 (`sendTimeout`)
- 接收超时 (`receiveTimeout`)
- 连接错误 (`connectionError`)
- 服务器错误 (HTTP 5xx)

**不重试的错误类型**：
- 请求取消
- SSL 证书错误
- 客户端错误 (HTTP 4xx)

**重试配置**：
- **SHALL 使用 `lib/core/config/app_config.dart` 中定义的 `RetryConfig`**
- **SHALL NOT 在拦截器文件中重复定义 `RetryConfig` 类**

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `maxRetries` | 3 | 最大重试次数 |
| `retryDelay` | 1000ms | 初始重试延迟 |
| `enableExponentialBackoff` | true | 启用指数退避 |
| `maxDelay` | 10000ms | 最大延迟时间 |

**重试实现**：
- **SHALL 使用原有的 `ApiClient.instance.dio` 实例进行重试**
- **SHALL NOT 创建新的 Dio 实例（会丢失拦截器配置）**

#### Scenario: 网络超时重试
- **WHEN** 请求超时
- **THEN** 使用原 Dio 实例重发请求
- **AND** 保持完整的拦截器链

#### Scenario: 重试保持拦截器配置
- **WHEN** 进行重试请求
- **THEN** 使用 `ApiClient.instance.dio.fetch(requestOptions)` 发送
- **AND** 认证拦截器、日志拦截器等正常工作

---

### Requirement: 智能重试拦截器 (SmartRetryInterceptor)
SmartRetryInterceptor SHALL 根据错误类型使用不同的重试策略：

**配置引用**：
- **SHALL 使用 `lib/core/config/app_config.dart` 中定义的 `RetryConfig`**

**重试实现**：
- **SHALL 使用原有的 Dio 实例进行重试**
- **SHALL NOT 创建新的 Dio 实例**

#### Scenario: 智能重试保持拦截器配置
- **WHEN** 进行智能重试
- **THEN** 使用原 Dio 实例发送请求
- **AND** 所有拦截器正常工作

### Requirement: 日志拦截器 (LoggingInterceptor)
LoggingInterceptor SHALL 记录请求和响应信息：

**仅在 `kDebugMode` 下启用**

**配置参数**：
| 参数 | 默认值 | 说明 |
|------|--------|------|
| `enableDetailedLog` | true | 启用详细日志 |
| `logRequestBody` | true | 记录请求体 |
| `logResponseBody` | true | 记录响应体 |
| `maxLogLength` | 1000 | 最大日志长度 |

**敏感信息保护**：
以下 Header 的值 SHALL 被隐藏：
- `authorization`
- `token`
- `password`
- `secret`
- `key`

#### Scenario: 记录请求日志
- **WHEN** 发送请求
- **THEN** 打印请求方法、URL、Headers、Body
- **AND** 敏感信息显示为 `[HIDDEN]`

#### Scenario: 记录响应日志
- **WHEN** 收到响应
- **THEN** 打印状态码、Headers、Body、耗时

#### Scenario: 生产环境不记录日志
- **WHEN** 非 `kDebugMode`
- **THEN** 不输出任何日志

---

### Requirement: 简化日志拦截器 (SimpleLoggingInterceptor)
SimpleLoggingInterceptor SHALL 提供简化的日志输出：

- 请求：`🚀 {METHOD} {URL}`
- 成功：`✅ {STATUS} {METHOD} {URL}`
- 错误：`❌ {STATUS} {METHOD} {URL}`

#### Scenario: 简化日志输出
- **WHEN** 请求成功
- **THEN** 输出 `✅ 200 GET https://api.example.com/routes`

---

### Requirement: 错误处理拦截器 (ErrorInterceptor)
ErrorInterceptor SHALL 统一处理错误：

**错误拦截**：
- 将 `DioException` 转换为 `ApiException`
- 记录详细错误信息（仅调试模式）

**响应拦截**：
- 检查业务状态码（即使 HTTP 200）
- 如果 `code` 不等于 200 或 0，抛出 `BusinessException`

#### Scenario: 转换 Dio 异常
- **WHEN** 发生 DioException
- **THEN** 转换为对应的 ApiException 类型
- **AND** 保留原始错误信息

#### Scenario: 检测业务错误
- **WHEN** HTTP 200 但响应 `code: 500`
- **THEN** 抛出 `BusinessException`
- **AND** 消息为响应中的 `message` 字段

