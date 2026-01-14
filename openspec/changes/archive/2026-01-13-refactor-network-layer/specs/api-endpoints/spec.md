## Purpose

本变更修改 api-endpoints 规范，移除用户端点中的硬编码用户ID，改为通过 Authorization Token 识别用户身份。

## MODIFIED Requirements

### Requirement: 用户相关端点 (User)
ApiEndpoints SHALL 提供用户相关的 API 端点：

| 端点 | 类型 | 路径 | 说明 |
|------|------|------|------|
| `userProfile` | 常量 | `/user/profile` | **当前用户信息（不含硬编码ID）** |
| `updateUserProfile` | 常量 | `/user/profile` | 更新用户信息 |
| `userStats` | 常量 | `/user/stats` | 用户统计 |
| `userPreferences` | 常量 | `/user/preferences` | 用户偏好 |

**变更说明**：
- `userProfile` **SHALL NOT 包含硬编码的用户ID**
- 用户身份通过请求头中的 Authorization Token 识别
- 路径固定为 `$apiPrefix/user/profile`

#### Scenario: 获取当前用户信息
- **WHEN** 调用 `ApiEndpoints.userProfile`
- **THEN** 返回 `/walkbg/api/v1/user/profile`
- **AND** 不包含任何硬编码的用户ID

#### Scenario: 用户身份识别
- **WHEN** 访问 `userProfile` 端点
- **THEN** 后端通过 `Authorization: Bearer {token}` 头识别用户
- **AND** 返回该 Token 对应用户的信息
