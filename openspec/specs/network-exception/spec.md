# network-exception Specification

## Purpose
统一的网络异常体系，提供类型化的异常处理、错误转换和用户友好的错误消息。

## Requirements

### Requirement: 异常基类 (ApiException)
ApiException SHALL 作为所有 API 异常的基类：

| 属性 | 类型 | 说明 |
|------|------|------|
| `message` | String | 用户友好的错误消息 |
| `code` | String? | 错误代码 |
| `statusCode` | int? | HTTP 状态码 |
| `originalException` | dynamic | 原始异常对象 |

#### Scenario: 异常包含完整信息
- **WHEN** 创建 `ApiException`
- **THEN** 包含消息、代码、状态码和原始异常

---

### Requirement: 异常类型体系
系统 SHALL 提供以下异常类型：

| 异常类型 | 用途 | 典型触发场景 |
|----------|------|--------------|
| `NetworkException` | 网络连接异常 | 无网络、DNS 失败 |
| `TimeoutException` | 超时异常 | 连接/发送/接收超时 |
| `ServerException` | 服务器异常 | HTTP 5xx |
| `ClientException` | 客户端异常 | HTTP 4xx (除特定外) |
| `AuthException` | 认证异常 | HTTP 401 |
| `PermissionException` | 权限异常 | HTTP 403 |
| `NotFoundException` | 资源不存在 | HTTP 404 |
| `ValidationException` | 参数验证异常 | HTTP 422 |
| `BusinessException` | 业务逻辑异常 | 业务规则校验失败 |
| `CancelException` | 请求取消 | 用户取消请求 |
| `UnknownException` | 未知异常 | 其他未分类错误 |

#### Scenario: 网络异常
- **WHEN** 网络不可用
- **THEN** 抛出 `NetworkException`
- **AND** `message` 为 `'网络连接失败，请检查网络设置'`

#### Scenario: 认证异常
- **WHEN** 收到 HTTP 401
- **THEN** 抛出 `AuthException`
- **AND** `message` 为 `'未授权，请重新登录'`

---

### Requirement: 验证异常详情 (ValidationException)
ValidationException SHALL 包含字段级错误详情：

| 属性 | 类型 | 说明 |
|------|------|------|
| `errors` | Map<String, List<String>>? | 字段名 → 错误消息列表 |

#### Scenario: 表单验证错误
- **WHEN** API 返回字段验证错误
- **THEN** `ValidationException.errors` 包含每个字段的错误列表

```dart
// 示例
{
  'email': ['邮箱格式不正确'],
  'password': ['密码长度至少8位', '密码必须包含数字']
}
```

---

### Requirement: 异常工厂 (ApiExceptionFactory)
ApiExceptionFactory SHALL 提供异常转换方法：

**`fromDioException(DioException)`**：
| DioExceptionType | 转换结果 |
|------------------|----------|
| `connectionTimeout` | `TimeoutException` |
| `sendTimeout` | `TimeoutException` |
| `receiveTimeout` | `TimeoutException` |
| `connectionError` | `NetworkException` |
| `badResponse` | 根据状态码转换 |
| `cancel` | `CancelException` |
| `badCertificate` | `NetworkException` (SSL错误) |
| `unknown` | `UnknownException` |

**HTTP 状态码转换**：
| 状态码 | 转换结果 |
|--------|----------|
| 400 | `ClientException` |
| 401 | `AuthException` |
| 403 | `PermissionException` |
| 404 | `NotFoundException` |
| 422 | `ValidationException` |
| 429 | `ClientException` |
| 5xx | `ServerException` |

**`fromException(Exception)`**：
- 如果是 `DioException`，调用 `fromDioException`
- 如果是 `ApiException`，直接返回
- 否则包装为 `UnknownException`

#### Scenario: 转换 Dio 超时异常
- **WHEN** 调用 `ApiExceptionFactory.fromDioException(connectTimeoutError)`
- **THEN** 返回 `TimeoutException`
- **AND** `message` 为 `'连接超时，请检查网络'`

#### Scenario: 转换 HTTP 404
- **WHEN** 调用 `ApiExceptionFactory.fromDioException(notFoundError)`
- **THEN** 返回 `NotFoundException`
- **AND** 从响应体解析 `message`

---

### Requirement: 异常处理工具 (ExceptionHandler)
ExceptionHandler SHALL 提供异常处理辅助方法：

| 方法 | 返回值 | 说明 |
|------|--------|------|
| `getErrorMessage(error)` | String | 获取用户友好错误消息 |
| `isNetworkError(error)` | bool | 判断是否网络错误 |
| `isAuthError(error)` | bool | 判断是否认证错误 |
| `isPermissionError(error)` | bool | 判断是否权限错误 |
| `isServerError(error)` | bool | 判断是否服务器错误 |
| `shouldRetry(error)` | bool | 判断是否应该重试 |

**重试判断规则**：
- `NetworkException` → 应该重试
- `TimeoutException` → 应该重试
- `ServerException` → 应该重试
- `AuthException` → 不应重试
- `ClientException` → 不应重试

#### Scenario: 获取用户友好消息
- **WHEN** 调用 `ExceptionHandler.getErrorMessage(networkError)`
- **THEN** 返回 `'网络连接失败，请检查网络设置'`

#### Scenario: 判断是否需要重试
- **WHEN** 调用 `ExceptionHandler.shouldRetry(timeoutError)`
- **THEN** 返回 `true`

#### Scenario: 判断认证错误
- **WHEN** 调用 `ExceptionHandler.isAuthError(error401)`
- **THEN** 返回 `true`

---

### Requirement: 默认错误消息
各异常类型 SHALL 提供默认的中文错误消息：

| 场景 | 默认消息 |
|------|----------|
| 连接超时 | 连接超时，请检查网络 |
| 发送超时 | 发送超时，请重试 |
| 接收超时 | 响应超时，请重试 |
| 网络错误 | 网络连接失败，请检查网络设置 |
| SSL 错误 | SSL证书验证失败 |
| 请求取消 | 请求已取消 |
| 未授权 | 未授权，请重新登录 |
| 禁止访问 | 权限不足 |
| 资源不存在 | 请求的资源不存在 |
| 参数验证失败 | 请求参数验证失败 |
| 请求过于频繁 | 请求过于频繁，请稍后再试 |
| 服务器错误 | 服务器错误，请稍后再试 |
| 未知错误 | 发生未知错误，请稍后重试 |

#### Scenario: 使用默认消息
- **WHEN** API 响应不包含 `message` 字段
- **THEN** 使用对应状态码的默认消息
