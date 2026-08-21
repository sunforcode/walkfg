# network-interceptors Specification

## Purpose
网络拦截器链，提供请求/响应的统一处理能力，包括认证、重试、日志、错误处理。

**执行顺序**: Auth → Retry → Logging → Error
## Requirements
### Requirement: 拦截器链架构
拦截器 SHALL 按固定顺序执行：

| 顺序 | 拦截器 | 职责 |
|------|--------|------|
| 1 | **MockInterceptor** | **返回Mock数据（仅Mock模式）** |
| 2 | AuthInterceptor | 请求前添加认证 Token |
| 3 | RetryInterceptor | 失败时自动重试 |
| 4 | LoggingInterceptor | 记录请求/响应日志（仅开发环境） |
| 5 | ErrorInterceptor | 统一错误处理和转换 |

**变更说明**：在拦截器链最前面添加 `MockInterceptor`，确保Mock数据可以绕过所有其他拦截器直接返回。

#### Scenario: Mock拦截器优先执行
- **WHEN** 发送请求且Mock模式启用
- **THEN** MockInterceptor 首先执行
- **AND** 如果返回Mock数据，后续拦截器不再执行
- **AND** 如果未匹配Mock，请求依次经过 Auth → Retry → Logging → Error 拦截器

#### Scenario: Mock模式关闭时执行顺序不变
- **WHEN** Mock模式关闭
- **THEN** 请求依次经过 Mock(放行) → Auth → Retry → Logging → Error 拦截器
- **AND** 响应按逆序经过拦截器

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

### Requirement: Mock拦截器 (MockInterceptor)
MockInterceptor SHALL 在开发/测试环境提供Mock数据支持：

**职责**：
- 在请求发送前拦截，根据 `AppConfig.useMockServices` 配置决定是否返回Mock数据
- 匹配API端点路径，返回对应的Mock响应数据
- 模拟网络延迟，提供更真实的测试体验

**执行时机**：
- **SHALL 作为第一个拦截器执行**（在 AuthInterceptor 之前）
- **SHALL 仅在 `onRequest` 阶段拦截**

**Mock数据格式**：
- **SHALL 遵循后端API响应规范**：统一的 `ApiResponse` 结构
- **SHALL 包含完整的业务数据字段**

**配置依赖**：
- **SHALL 读取 `AppConfig.instance.useMockServices` 判断是否启用**
- 当 `useMockServices = false` 时，SHALL 放行所有请求

**支持的Mock API端点**：
- `GET /walkbg/api/v1/user/profile` - 用户信息
- `GET /walkbg/api/v1/weather` - 天气信息  
- `GET /walkbg/api/v1/trips/planned` - 规划行程列表
- `GET /walkbg/api/v1/routes` - 路线列表（热门路线）
- `GET /walkbg/api/v1/guides` - 徒步攻略列表

**日志输出**：
- **SHALL 在返回Mock数据时输出日志**，标识使用的是Mock数据
- 日志格式：`MockInterceptor: Returning mock data for {path}`

#### Scenario: Mock模式启用时返回Mock数据
- **WHEN** `AppConfig.useMockServices = true`
- **AND** 请求路径匹配Mock端点（如 `/user/profile`）
- **THEN** 直接返回Mock数据，不发起网络请求
- **AND** 响应状态码为 200
- **AND** 响应数据符合后端API格式

#### Scenario: Mock模式关闭时放行请求
- **WHEN** `AppConfig.useMockServices = false`
- **THEN** 所有请求正常发送到网络
- **AND** 不影响其他拦截器的执行

#### Scenario: 未匹配到Mock端点时放行
- **WHEN** `AppConfig.useMockServices = true`
- **AND** 请求路径不在Mock端点列表中
- **THEN** 请求正常发送到网络
- **AND** 后续拦截器正常处理

#### Scenario: Mock数据包含模拟延迟
- **WHEN** 返回Mock数据
- **THEN** SHALL 模拟 200-500ms 的网络延迟
- **AND** 提供更接近真实网络的体验

#### Scenario: 用户信息Mock数据
- **WHEN** 请求 `GET /walkbg/api/v1/user/profile`
- **AND** Mock模式启用
- **THEN** 返回符合 `UserModel` 结构的用户数据：
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": "mock_user_001",
    "username": "hiker_zhang",
    "nickname": "张三",
    "avatar_url": "https://picsum.photos/200",
    "completed_routes": 12,
    "equipment_lists": 3,
    "favorite_routes": 8,
    "created_at": 1640000000000,
    "updated_at": 1705200000000
  }
}
```

#### Scenario: 天气信息Mock数据
- **WHEN** 请求 `GET /walkbg/api/v1/weather`
- **AND** Mock模式启用
- **THEN** 返回符合 `WeatherModel` 结构的天气数据：
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "city": "北京",
    "condition": "晴朗",
    "suitability": true,
    "temperature": 22.5,
    "wind_speed": 12.0,
    "humidity": 45.0,
    "visibility": 10.0,
    "uv_index": 5,
    "pressure": 1013.0,
    "sunrise_time": 1705200000000,
    "sunset_time": 1705240000000
  }
}
```

#### Scenario: 规划行程Mock数据
- **WHEN** 请求 `GET /walkbg/api/v1/trips/planned`
- **AND** Mock模式启用
- **THEN** 返回符合 `TripModel` 结构的分页行程列表：
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "content": [
      {
        "id": "trip_001",
        "name": "鳌太穿越",
        "description": "秦岭主脊穿越，风景优美，挑战性强",
        "start_date": 1706400000000,
        "end_date": 1706832000000,
        "status": 0,
        "route_ids": ["route_001"],
        "primary_route_id": "route_001",
        "participants": [],
        "participant_count": 4,
        "organizer_id": "mock_user_001",
        "itinerary": [],
        "cover_url": "https://picsum.photos/400/300?random=1",
        "budget": 2500.0,
        "privacy_setting": "public",
        "created_at": 1705200000000,
        "updated_at": 1705200000000
      },
      {
        "id": "trip_002",
        "name": "武功山徒步",
        "description": "江南三大名山，高山草甸，云海日出",
        "start_date": 1707004800000,
        "end_date": 1707264000000,
        "status": 0,
        "route_ids": ["route_002"],
        "primary_route_id": "route_002",
        "participants": [],
        "participant_count": 2,
        "organizer_id": "mock_user_001",
        "itinerary": [],
        "cover_url": "https://picsum.photos/400/300?random=2",
        "budget": 1200.0,
        "privacy_setting": "public",
        "created_at": 1705200000000,
        "updated_at": 1705200000000
      }
    ],
    "page": 0,
    "size": 10,
    "total_elements": 2,
    "total_pages": 1
  }
}
```

#### Scenario: 推荐路线Mock数据
- **WHEN** 请求 `GET /walkbg/api/v1/routes`
- **AND** Mock模式启用
- **THEN** 返回符合 `RouteModel` 结构的分页路线列表：
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "content": [
      {
        "id": "route_001",
        "name": "鳌太穿越",
        "description": "秦岭主脊线路，太白山到鳌山，全长约120公里",
        "region_id": "region_001",
        "region": "陕西·秦岭",
        "default_map_id": "map_001",
        "difficulty": 3,
        "cover_url": "https://picsum.photos/600/400?random=1",
        "is_favorite": false,
        "popularity": 9500,
        "route_type": false,
        "status": "planning",
        "usage_count": 156,
        "tags": ["高海拔", "雪山", "草甸", "极限挑战"],
        "ratings": {
          "overall": 4.8,
          "scenery": 5.0,
          "difficulty": 4.5,
          "safety": 4.0
        },
        "marker_points": [],
        "created_at": 1700000000000,
        "updated_at": 1705200000000
      },
      {
        "id": "route_002",
        "name": "武功山穿越",
        "description": "江南三大名山，高山草甸，云海日出",
        "region_id": "region_002",
        "region": "江西·萍乡",
        "default_map_id": "map_002",
        "difficulty": 1,
        "cover_url": "https://picsum.photos/600/400?random=2",
        "is_favorite": true,
        "popularity": 12000,
        "route_type": false,
        "status": "planning",
        "usage_count": 320,
        "tags": ["草甸", "云海", "日出", "适合新手"],
        "ratings": {
          "overall": 4.7,
          "scenery": 4.9,
          "difficulty": 3.5,
          "safety": 4.8
        },
        "marker_points": [],
        "created_at": 1700000000000,
        "updated_at": 1705200000000
      },
      {
        "id": "route_003",
        "name": "狼塔C+V线",
        "description": "新疆天山深处的顶级徒步线路",
        "region_id": "region_003",
        "region": "新疆·天山",
        "default_map_id": "map_003",
        "difficulty": 3,
        "cover_url": "https://picsum.photos/600/400?random=3",
        "is_favorite": false,
        "popularity": 6800,
        "route_type": false,
        "status": "planning",
        "usage_count": 89,
        "tags": ["高海拔", "冰川", "原始森林", "极限挑战"],
        "ratings": {
          "overall": 4.9,
          "scenery": 5.0,
          "difficulty": 5.0,
          "safety": 3.5
        },
        "marker_points": [],
        "created_at": 1700000000000,
        "updated_at": 1705200000000
      }
    ],
    "page": 0,
    "size": 10,
    "total_elements": 3,
    "total_pages": 1
  }
}
```

#### Scenario: 徒步攻略Mock数据
- **WHEN** 请求 `GET /walkbg/api/v1/guides`
- **AND** Mock模式启用
- **THEN** 返回符合 `GuideModel` 结构的分页攻略列表：
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "content": [
      {
        "id": "guide_001",
        "title": "鳌太穿越完整攻略（2024年春季版）",
        "content": "这是一份详细的鳌太穿越攻略...",
        "author": "老驴张三",
        "author_id": "author_001",
        "author_avatar_url": "https://picsum.photos/100?random=1",
        "likes": 456,
        "views": 8900,
        "publish_date": 1704067200000,
        "update_date": 1705200000000,
        "icon_code": "0xe047",
        "cover_url": "https://picsum.photos/800/600?random=11",
        "tags": ["鳌太", "秦岭", "高海拔", "装备清单"],
        "is_liked": false,
        "difficulty": 3,
        "reading_time": 15,
        "is_bookmarked": false,
        "comment_count": 89,
        "location": "陕西·秦岭",
        "best_time": "5-10月",
        "actual_cost": 2800.0,
        "actual_days": 6,
        "highlights": ["太白山顶观日出", "高山草甸", "冰川遗迹"],
        "personal_tips": ["注意高反", "天气多变需备足衣物"],
        "seasonal_advice": ["春季多雨", "夏季最佳"],
        "safety_warnings": ["不建议单人", "注意雷暴"],
        "equipment_adjustments": ["增加保暖层", "防水装备必备"],
        "route_modifications": [],
        "base_route_id": "route_001",
        "related_guide_ids": [],
        "created_at": 1704067200000,
        "updated_at": 1705200000000
      },
      {
        "id": "guide_002",
        "title": "武功山三天两夜轻装穿越",
        "content": "武功山徒步详细攻略...",
        "author": "徒步李四",
        "author_id": "author_002",
        "author_avatar_url": "https://picsum.photos/100?random=2",
        "likes": 789,
        "views": 12300,
        "publish_date": 1703462400000,
        "update_date": 1705200000000,
        "icon_code": "0xe047",
        "cover_url": "https://picsum.photos/800/600?random=12",
        "tags": ["武功山", "草甸", "云海", "新手友好"],
        "is_liked": true,
        "difficulty": 1,
        "reading_time": 10,
        "is_bookmarked": true,
        "comment_count": 156,
        "location": "江西·萍乡",
        "best_time": "4-11月",
        "actual_cost": 1500.0,
        "actual_days": 3,
        "highlights": ["十万亩高山草甸", "金顶日出", "云海奇观"],
        "personal_tips": ["提前预定山顶住宿", "早起看日出"],
        "seasonal_advice": ["秋季最美", "冬季有雪景"],
        "safety_warnings": ["注意防晒", "雷雨天气避开山顶"],
        "equipment_adjustments": ["轻量化装备", "备用电池"],
        "route_modifications": [],
        "base_route_id": "route_002",
        "related_guide_ids": [],
        "created_at": 1703462400000,
        "updated_at": 1705200000000
      },
      {
        "id": "guide_003",
        "title": "狼塔C线重装穿越记录",
        "content": "狼塔C线穿越详细记录...",
        "author": "户外王五",
        "author_id": "author_003",
        "author_avatar_url": "https://picsum.photos/100?random=3",
        "likes": 234,
        "views": 4500,
        "publish_date": 1702857600000,
        "update_date": 1705200000000,
        "icon_code": "0xe047",
        "cover_url": "https://picsum.photos/800/600?random=13",
        "tags": ["狼塔", "天山", "重装", "极限挑战"],
        "is_liked": false,
        "difficulty": 3,
        "reading_time": 20,
        "is_bookmarked": false,
        "comment_count": 67,
        "location": "新疆·天山",
        "best_time": "7-9月",
        "actual_cost": 5000.0,
        "actual_days": 8,
        "highlights": ["冰川穿越", "原始森林", "高山湖泊"],
        "personal_tips": ["体能要求极高", "必须有经验队友"],
        "seasonal_advice": ["仅夏季可行"],
        "safety_warnings": ["严禁单人", "天气突变频繁", "需要向导"],
        "equipment_adjustments": ["重装备齐全", "卫星电话"],
        "route_modifications": [],
        "base_route_id": "route_003",
        "related_guide_ids": [],
        "created_at": 1702857600000,
        "updated_at": 1705200000000
      },
      {
        "id": "guide_004",
        "title": "贡嘎大环线逆时针穿越",
        "content": "贡嘎大环线详细攻略...",
        "author": "雪山探险者",
        "author_id": "author_004",
        "author_avatar_url": "https://picsum.photos/100?random=4",
        "likes": 567,
        "views": 9800,
        "publish_date": 1702252800000,
        "update_date": 1705200000000,
        "icon_code": "0xe047",
        "cover_url": "https://picsum.photos/800/600?random=14",
        "tags": ["贡嘎", "雪山", "高海拔", "摄影天堂"],
        "is_liked": false,
        "difficulty": 2,
        "reading_time": 18,
        "is_bookmarked": false,
        "comment_count": 123,
        "location": "四川·甘孜",
        "best_time": "5-6月，9-10月",
        "actual_cost": 3500.0,
        "actual_days": 7,
        "highlights": ["贡嘎雪山", "子梅垭口", "高山花海"],
        "personal_tips": ["逆时针更省力", "子梅垭口最佳观景点"],
        "seasonal_advice": ["避开雨季", "秋季最美"],
        "safety_warnings": ["高反风险", "注意保暖"],
        "equipment_adjustments": ["防寒装备", "高原药品"],
        "route_modifications": [],
        "base_route_id": "route_004",
        "related_guide_ids": [],
        "created_at": 1702252800000,
        "updated_at": 1705200000000
      }
    ],
    "page": 0,
    "size": 10,
    "total_elements": 4,
    "total_pages": 1
  }
}
```

---

