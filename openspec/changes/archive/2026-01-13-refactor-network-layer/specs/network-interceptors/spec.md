## MODIFIED Requirements

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

## REMOVED Requirements

_无移除的要求_

<!-- 移除了 retry_interceptor.dart 中重复的 RetryConfig 类，现统一使用 app_config.dart 中的定义 -->
