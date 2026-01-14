## MODIFIED Requirements

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
