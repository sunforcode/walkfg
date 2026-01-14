# api-endpoints Specification

## Purpose
API 端点配置管理，提供统一的 URL 路径定义、参数构建和版本管理，支持 RESTful API 的端点组织和路由配置。

## Requirements
### Requirement: API 版本管理
ApiEndpoints SHALL 提供版本化的 API 路径：

| 常量 | 值 | 说明 |
|------|-----|------|
| `apiVersion` | `'v1'` | API 版本号 |
| `apiPrefix` | `'/walkbg/api/v1'` | API 路径前缀 |

#### Scenario: 使用版本化路径
- **WHEN** 访问路线 API
- **THEN** 完整路径为 `/walkbg/api/v1/routes`

---

### Requirement: 路线相关端点 (Routes)
ApiEndpoints SHALL 提供路线相关的 API 端点：

| 端点 | 类型 | 路径 | 说明 |
|------|------|------|------|
| `routes` | 常量 | `/routes` | 路线列表 |
| `routeDetail(id)` | 方法 | `/routes/{id}` | 路线详情 |
| `searchRoutes` | 常量 | `/routes/search` | 搜索路线 |
| `popularRoutes` | 常量 | `/routes/popular` | 热门路线 |
| `seasonalRoutes` | 常量 | `/routes/seasonal` | 季节性路线 |
| `newRoutes` | 常量 | `/routes/new` | 新晋路线 |
| `weekendRoutes` | 常量 | `/routes/weekend` | 周末路线 |
| `recommendedRoutes` | 常量 | `/routes/recommended` | 推荐路线 |
| `routesByRegion(region)` | 方法 | `/routes/region/{region}` | 按地区 |
| `routesByDifficulty(difficulty)` | 方法 | `/routes/difficulty/{difficulty}` | 按难度 |
| `routesByDuration` | 常量 | `/routes/duration` | 按时长 |
| `routeRatings(id)` | 方法 | `/routes/{id}/ratings` | 路线评分 |
| `routeTags(id)` | 方法 | `/routes/{id}/tags` | 路线标签 |
| `routeWaypoints(id)` | 方法 | `/routes/{id}/waypoints` | 路线关键点 |
| `relatedRoutes(id)` | 方法 | `/routes/{id}/related` | 相关路线 |
| `routeComments(id)` | 方法 | `/routes/{id}/comments` | 路线评论 |

#### Scenario: 获取路线详情端点
- **WHEN** 调用 `ApiEndpoints.routeDetail('route_123')`
- **THEN** 返回 `/walkbg/api/v1/routes/route_123`

---

### Requirement: 收藏相关端点 (Favorites)
ApiEndpoints SHALL 提供收藏相关的 API 端点：

| 端点 | 类型 | 路径 | 说明 |
|------|------|------|------|
| `favoriteRoutes` | 常量 | `/favorites/routes` | 收藏列表 |
| `favoriteRoute(id)` | 方法 | `/favorites/routes/{id}` | 收藏/取消收藏 |
| `checkFavorite(id)` | 方法 | `/favorites/routes/{id}/check` | 检查收藏状态 |

#### Scenario: 检查收藏状态端点
- **WHEN** 调用 `ApiEndpoints.checkFavorite('route_123')`
- **THEN** 返回 `/walkbg/api/v1/favorites/routes/route_123/check`

---

### Requirement: 行程相关端点 (Trips)
ApiEndpoints SHALL 提供行程相关的 API 端点：

| 端点 | 类型 | 路径 | 说明 |
|------|------|------|------|
| `trips` | 常量 | `/trips` | 行程列表 |
| `tripDetail(id)` | 方法 | `/trips/{id}` | 行程详情 |
| `createTrip` | 常量 | `/trips` | 创建行程 |
| `updateTrip(id)` | 方法 | `/trips/{id}` | 更新行程 |
| `deleteTrip(id)` | 方法 | `/trips/{id}` | 删除行程 |
| `plannedTrips` | 常量 | `/trips/planned` | 计划中行程 |
| `completedTrips` | 常量 | `/trips/completed` | 已完成行程 |
| `ongoingTrips` | 常量 | `/trips/ongoing` | 进行中行程 |

#### Scenario: 获取行程详情端点
- **WHEN** 调用 `ApiEndpoints.tripDetail('trip_123')`
- **THEN** 返回 `/walkbg/api/v1/trips/trip_123`

---

### Requirement: 行程计划端点 (Trip Plans)
ApiEndpoints SHALL 提供行程计划相关的 API 端点：

| 端点 | 类型 | 路径 | 说明 |
|------|------|------|------|
| `tripPlans` | 常量 | `/trip-plans` | 计划列表 |
| `tripPlanDetail(id)` | 方法 | `/trip-plans/{id}` | 计划详情 |
| `createTripPlan` | 常量 | `/trip-plans` | 创建计划 |
| `updateTripPlan(id)` | 方法 | `/trip-plans/{id}` | 更新计划 |
| `deleteTripPlan(id)` | 方法 | `/trip-plans/{id}` | 删除计划 |

#### Scenario: 获取行程计划详情
- **WHEN** 调用 `ApiEndpoints.tripPlanDetail('plan_123')`
- **THEN** 返回 `/walkbg/api/v1/trip-plans/plan_123`

---

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

### Requirement: 认证相关端点 (Auth)
ApiEndpoints SHALL 提供认证相关的 API 端点：

| 端点 | 类型 | 路径 | 说明 |
|------|------|------|------|
| `login` | 常量 | `/auth/login` | 登录 |
| `register` | 常量 | `/auth/register` | 注册 |
| `logout` | 常量 | `/auth/logout` | 登出 |
| `refreshToken` | 常量 | `/auth/refresh` | 刷新 Token |
| `forgotPassword` | 常量 | `/auth/forgot-password` | 忘记密码 |
| `resetPassword` | 常量 | `/auth/reset-password` | 重置密码 |

#### Scenario: 登录端点
- **WHEN** 调用 `ApiEndpoints.login`
- **THEN** 返回 `/walkbg/api/v1/auth/login`

---

### Requirement: 天气相关端点 (Weather)
ApiEndpoints SHALL 提供天气相关的 API 端点：

| 端点 | 类型 | 路径 | 说明 |
|------|------|------|------|
| `weather` | 常量 | `/weather` | 天气信息 |
| `weatherForecast` | 常量 | `/weather/forecast` | 天气预报 |
| `markerPointWeather(id)` | 方法 | `/weather/marker-point/{id}` | 标记点天气 |

#### Scenario: 获取天气端点
- **WHEN** 调用 `ApiEndpoints.weather`
- **THEN** 返回 `/walkbg/api/v1/weather`

---

### Requirement: 装备相关端点 (Equipment)
ApiEndpoints SHALL 提供装备相关的 API 端点：

| 端点 | 类型 | 路径 | 说明 |
|------|------|------|------|
| `equipment` | 常量 | `/equipment` | 装备列表 |
| `equipmentDetail(id)` | 方法 | `/equipment/{id}` | 装备详情 |
| `equipmentCategories` | 常量 | `/equipment/categories` | 装备分类 |
| `recommendedEquipment` | 常量 | `/equipment/recommended` | 推荐装备 |
| `userEquipmentList` | 常量 | `/user/equipment-list` | 用户装备清单 |

#### Scenario: 获取装备详情端点
- **WHEN** 调用 `ApiEndpoints.equipmentDetail('equip_123')`
- **THEN** 返回 `/walkbg/api/v1/equipment/equip_123`

---

### Requirement: 攻略相关端点 (Guides)
ApiEndpoints SHALL 提供攻略相关的 API 端点：

| 端点 | 类型 | 路径 | 说明 |
|------|------|------|------|
| `guides` | 常量 | `/guides` | 攻略列表 |
| `guideDetail(id)` | 方法 | `/guides/{id}` | 攻略详情 |
| `guideCategories` | 常量 | `/guides/categories` | 攻略分类 |
| `popularGuides` | 常量 | `/guides/popular` | 热门攻略 |

#### Scenario: 获取攻略详情端点
- **WHEN** 调用 `ApiEndpoints.guideDetail('guide_123')`
- **THEN** 返回 `/walkbg/api/v1/guides/guide_123`

---

### Requirement: 搜索相关端点 (Search)
ApiEndpoints SHALL 提供搜索相关的 API 端点：

| 端点 | 类型 | 路径 | 说明 |
|------|------|------|------|
| `globalSearch` | 常量 | `/search` | 全局搜索 |
| `searchHistory` | 常量 | `/search/history` | 搜索历史 |
| `popularSearches` | 常量 | `/search/popular` | 热门搜索 |

#### Scenario: 全局搜索端点
- **WHEN** 调用 `ApiEndpoints.globalSearch`
- **THEN** 返回 `/walkbg/api/v1/search`

---

### Requirement: 文件上传端点 (Upload)
ApiEndpoints SHALL 提供文件上传相关的 API 端点：

| 端点 | 类型 | 路径 | 说明 |
|------|------|------|------|
| `uploadImage` | 常量 | `/upload/image` | 上传图片 |
| `uploadGpx` | 常量 | `/upload/gpx` | 上传 GPX |
| `uploadAvatar` | 常量 | `/upload/avatar` | 上传头像 |

#### Scenario: 上传图片端点
- **WHEN** 调用 `ApiEndpoints.uploadImage`
- **THEN** 返回 `/walkbg/api/v1/upload/image`

---

### Requirement: 系统相关端点 (System)
ApiEndpoints SHALL 提供系统相关的 API 端点：

| 端点 | 类型 | 路径 | 说明 |
|------|------|------|------|
| `versionCheck` | 常量 | `/system/version` | 版本检查 |
| `systemConfig` | 常量 | `/system/config` | 系统配置 |
| `feedback` | 常量 | `/system/feedback` | 反馈 |

#### Scenario: 版本检查端点
- **WHEN** 调用 `ApiEndpoints.versionCheck`
- **THEN** 返回 `/walkbg/api/v1/system/version`

---

### Requirement: URL 构建工具方法
ApiEndpoints SHALL 提供 URL 构建辅助方法：

**`buildUrl(endpoint, queryParams)`**：
- 将查询参数附加到端点 URL
- 参数值自动转换为字符串

**`buildPaginatedUrl(endpoint, {page, limit, additionalParams})`**：
- 构建分页 URL
- 默认 `page: 1`, `limit: 20`

#### Scenario: 构建带参数的 URL
- **WHEN** 调用 `ApiEndpoints.buildUrl('/routes', {'season': 'summer', 'limit': 10})`
- **THEN** 返回 `/routes?season=summer&limit=10`

#### Scenario: 构建分页 URL
- **WHEN** 调用 `ApiEndpoints.buildPaginatedUrl('/routes', page: 2, limit: 20)`
- **THEN** 返回 `/routes?page=2&limit=20`

---

### Requirement: 端点命名规范
ApiEndpoints SHALL 遵循以下命名规范：

- 列表端点：使用复数名词 (如 `routes`, `trips`)
- 详情端点：使用 `{resource}Detail(id)` 方法 (如 `routeDetail(id)`)
- 创建端点：使用 `create{Resource}` (如 `createTrip`)
- 更新端点：使用 `update{Resource}(id)` (如 `updateTrip(id)`)
- 删除端点：使用 `delete{Resource}(id)` (如 `deleteTrip(id)`)
- 子资源端点：使用 `{parent}{Child}(id)` (如 `routeComments(id)`)

#### Scenario: 端点命名一致性
- **WHEN** 需要获取路线评论
- **THEN** 使用 `ApiEndpoints.routeComments(routeId)`
- **AND** 返回 `/walkbg/api/v1/routes/{routeId}/comments`

