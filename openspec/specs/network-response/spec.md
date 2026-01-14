# network-response Specification

## Purpose
统一的 API 响应模型，提供标准化的响应结构、分页信息、状态码管理。

**序列化**: json_serializable 代码生成

## Requirements

### Requirement: 统一响应模型 (ApiResponse)
ApiResponse<T> SHALL 封装所有 API 响应的通用结构：

| 字段 | 类型 | JSON Key | 说明 |
|------|------|----------|------|
| `code` | int | `code` | 响应状态码 |
| `message` | String | `message` | 响应消息 |
| `data` | T? | `data` | 响应数据（泛型） |
| `pagination` | PaginationInfo? | `pagination` | 分页信息 |
| `timestamp` | int? | `timestamp` | 时间戳 |
| `requestId` | String? | `request_id` | 请求追踪 ID |

**计算属性**：
- `isSuccess`: `code >= 200 && code < 300`
- `isFailure`: `!isSuccess`

#### Scenario: 解析成功响应
- **WHEN** API 返回 `{"code": 200, "message": "Success", "data": {...}}`
- **THEN** `ApiResponse.fromJson()` 解析成功
- **AND** `isSuccess` 返回 `true`

#### Scenario: 创建成功响应
- **WHEN** 调用 `ApiResponse.success(data: routeModel)`
- **THEN** 返回 `code: 200, message: 'Success'` 的响应对象

#### Scenario: 创建错误响应
- **WHEN** 调用 `ApiResponse.error(message: '服务器错误', code: 500)`
- **THEN** 返回对应的错误响应对象

---

### Requirement: 分页信息模型 (PaginationInfo)
PaginationInfo SHALL 提供分页元数据：

| 字段 | 类型 | JSON Key | 说明 |
|------|------|----------|------|
| `currentPage` | int | `current_page` | 当前页码 |
| `perPage` | int | `per_page` | 每页数量 |
| `total` | int | `total` | 总数量 |
| `totalPages` | int | `total_pages` | 总页数 |
| `hasNext` | bool | `has_next` | 是否有下一页 |
| `hasPrev` | bool | `has_prev` | 是否有上一页 |

#### Scenario: 解析分页信息
- **WHEN** API 返回包含 `pagination` 字段的响应
- **THEN** `PaginationInfo.fromJson()` 解析分页信息

#### Scenario: 判断是否有更多数据
- **WHEN** `hasNext` 为 `true`
- **THEN** 可以请求下一页数据

---

### Requirement: 列表响应模型 (ListResponse)
ListResponse<T> SHALL 专门处理列表数据响应：

| 字段 | 类型 | JSON Key | 说明 |
|------|------|----------|------|
| `items` | List<T> | `items` | 列表数据 |
| `pagination` | PaginationInfo? | `pagination` | 分页信息 |

#### Scenario: 解析列表响应
- **WHEN** API 返回 `{"items": [...], "pagination": {...}}`
- **THEN** `ListResponse.fromJson()` 解析列表和分页信息

---

### Requirement: API 错误详情模型 (ApiErrorDetail)
ApiErrorDetail SHALL 封装错误详情：

| 字段 | 类型 | JSON Key | 说明 |
|------|------|----------|------|
| `errorCode` | String | `error_code` | 错误代码 |
| `errorMessage` | String | `error_message` | 错误消息 |
| `field` | String? | `field` | 错误字段（表单验证） |
| `details` | Map<String, dynamic>? | `details` | 错误详情 |

#### Scenario: 解析验证错误
- **WHEN** API 返回字段验证错误
- **THEN** `ApiErrorDetail` 包含错误字段名和消息

---

### Requirement: HTTP 状态码常量 (ApiStatusCode)
ApiStatusCode SHALL 提供 HTTP 状态码常量和辅助方法：

**成功状态码**：
| 常量 | 值 | 说明 |
|------|-----|------|
| `success` | 200 | 请求成功 |
| `created` | 201 | 创建成功 |
| `accepted` | 202 | 请求已接受 |
| `noContent` | 204 | 无内容 |

**客户端错误状态码**：
| 常量 | 值 | 说明 |
|------|-----|------|
| `badRequest` | 400 | 请求参数错误 |
| `unauthorized` | 401 | 未授权 |
| `forbidden` | 403 | 禁止访问 |
| `notFound` | 404 | 资源不存在 |
| `methodNotAllowed` | 405 | 方法不允许 |
| `conflict` | 409 | 资源冲突 |
| `unprocessableEntity` | 422 | 验证失败 |
| `tooManyRequests` | 429 | 请求过于频繁 |

**服务器错误状态码**：
| 常量 | 值 | 说明 |
|------|-----|------|
| `internalServerError` | 500 | 服务器内部错误 |
| `badGateway` | 502 | 网关错误 |
| `serviceUnavailable` | 503 | 服务不可用 |
| `gatewayTimeout` | 504 | 网关超时 |

**辅助方法**：
- `isSuccess(code)`: 判断是否成功 (2xx)
- `isClientError(code)`: 判断是否客户端错误 (4xx)
- `isServerError(code)`: 判断是否服务器错误 (5xx)
- `getDescription(code)`: 获取状态码中文描述

#### Scenario: 判断状态码类型
- **WHEN** 调用 `ApiStatusCode.isClientError(404)`
- **THEN** 返回 `true`

#### Scenario: 获取状态码描述
- **WHEN** 调用 `ApiStatusCode.getDescription(401)`
- **THEN** 返回 `'未授权'`

---

### Requirement: JSON 序列化规范
响应模型 SHALL 遵循以下序列化规范：

- 使用 `@JsonSerializable` 注解
- 泛型类型使用 `genericArgumentFactories: true`
- JSON 字段使用 snake_case，Dart 属性使用 camelCase
- 通过 `@JsonKey(name: 'json_field')` 进行映射

#### Scenario: 泛型响应解析
- **WHEN** 解析 `ApiResponse<RouteModel>`
- **THEN** 提供 `fromJsonT` 函数用于解析泛型数据

```dart
ApiResponse<RouteModel>.fromJson(
  json,
  (data) => RouteModel.fromJson(data as Map<String, dynamic>),
);
```
