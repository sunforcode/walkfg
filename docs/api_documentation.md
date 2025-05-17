# Walk 徒步旅行助手 API 文档

本文档描述了 Walk 徒步旅行助手应用的 API 接口。

## 基础信息

- **基础URL**: `https://api.walk-app.com/v1`
- **认证方式**: Bearer Token
- **响应格式**: JSON

## 用户相关接口

### 获取当前用户信息

获取当前登录用户的基本信息。

- **URL**: `/users/me`
- **方法**: `GET`
- **认证**: 需要
- **响应**:

\`\`\`json
{
  "id": "user1",
  "username": "hikingfan",
  "nickname": "徒步爱好者",
  "avatar_url": null,
  "completed_routes": 3,
  "equipment_lists": 2,
  "favorite_routes": 5
}
\`\`\`

### 获取用户统计信息

获取当前用户的统计数据。

- **URL**: `/users/me/stats`
- **方法**: `GET`
- **认证**: 需要
- **响应**:

\`\`\`json
{
  "id": "user1",
  "username": "hikingfan",
  "nickname": "徒步爱好者",
  "avatar_url": null,
  "completed_routes": 3,
  "equipment_lists": 2,
  "favorite_routes": 5
}
\`\`\`

## 天气相关接口

### 获取天气信息

根据经纬度获取当前天气信息。

- **URL**: `/weather`
- **方法**: `GET`
- **参数**:
  - `latitude`: 纬度
  - `longitude`: 经度
- **认证**: 不需要
- **响应**:

\`\`\`json
{
  "temperature": "23°C",
  "condition": "晴",
  "is_suitable_for_hiking": true,
  "icon_code": "clear_day",
  "humidity": 45,
  "wind_speed": 3.5,
  "advice": "今天是个徒步的好日子！"
}
\`\`\`

## 路线相关接口

### 获取推荐路线

获取推荐的徒步路线列表。

- **URL**: `/routes/recommended`
- **方法**: `GET`
- **参数**:
  - `season`: (可选) 季节筛选
  - `limit`: (可选) 返回数量限制
- **认证**: 不需要
- **响应**:

\`\`\`json
[
  {
    "id": "route1",
    "name": "黄山主峰徒步路线",
    "description": "黄山主峰徒步路线是一条经典的徒步路线，沿途可以欣赏到黄山的壮丽景色。",
    "distance": 15.5,
    "duration": "6小时",
    "difficulty": "medium",
    "best_season": "春季最佳",
    "elevation_gain": 1200,
    "elevation_loss": 800,
    "highest_point": 1864,
    "lowest_point": 680,
    "image_urls": ["https://example.com/huangshan1.jpg", "https://example.com/huangshan2.jpg"],
    "gpx_url": "https://example.com/huangshan.gpx"
  },
  {
    "id": "route2",
    "name": "莫干山竹海徒步",
    "description": "莫干山竹海徒步路线穿越茂密的竹林，空气清新，视野开阔。",
    "distance": 8.2,
    "duration": "3小时",
    "difficulty": "easy",
    "best_season": "四季皆宜",
    "elevation_gain": 450,
    "elevation_loss": 450,
    "highest_point": 758,
    "lowest_point": 350,
    "image_urls": ["https://example.com/moganshan1.jpg"],
    "gpx_url": null
  }
]
\`\`\`

### 获取路线详情

获取特定路线的详细信息。

- **URL**: `/routes/{routeId}`
- **方法**: `GET`
- **认证**: 不需要
- **响应**:

\`\`\`json
{
  "id": "route1",
  "name": "黄山主峰徒步路线",
  "description": "黄山主峰徒步路线是一条经典的徒步路线，沿途可以欣赏到黄山的壮丽景色。",
  "distance": 15.5,
  "duration": "6小时",
  "difficulty": "medium",
  "best_season": "春季最佳",
  "elevation_gain": 1200,
  "elevation_loss": 800,
  "highest_point": 1864,
  "lowest_point": 680,
  "image_urls": ["https://example.com/huangshan1.jpg", "https://example.com/huangshan2.jpg"],
  "gpx_url": "https://example.com/huangshan.gpx"
}
\`\`\`

### 获取收藏路线

获取用户收藏的路线列表。

- **URL**: `/routes/favorites`
- **方法**: `GET`
- **认证**: 需要
- **响应**:

\`\`\`json
[
  {
    "id": "route1",
    "name": "黄山主峰徒步路线",
    "description": "黄山主峰徒步路线是一条经典的徒步路线，沿途可以欣赏到黄山的壮丽景色。",
    "distance": 15.5,
    "duration": "6小时",
    "difficulty": "medium",
    "best_season": "春季最佳",
    "elevation_gain": 1200,
    "elevation_loss": 800,
    "highest_point": 1864,
    "lowest_point": 680,
    "image_urls": ["https://example.com/huangshan1.jpg", "https://example.com/huangshan2.jpg"],
    "gpx_url": "https://example.com/huangshan.gpx"
  }
]
\`\`\`

### 收藏路线

收藏一条路线。

- **URL**: `/routes/{routeId}/favorite`
- **方法**: `POST`
- **认证**: 需要
- **响应**:

\`\`\`json
{
  "success": true
}
\`\`\`

### 取消收藏路线

取消收藏一条路线。

- **URL**: `/routes/{routeId}/favorite`
- **方法**: `DELETE`
- **认证**: 需要
- **响应**:

\`\`\`json
{
  "success": true
}
\`\`\`

## 计划路线相关接口

### 获取计划路线列表

获取用户的计划路线列表。

- **URL**: `/planned-routes`
- **方法**: `GET`
- **认证**: 需要
- **响应**:

\`\`\`json
[
  {
    "id": "plan1",
    "route_id": "route1",
    "name": "五一假期黄山之旅",
    "date": "2023-05-01T00:00:00Z",
    "days": 3,
    "status": "planning",
    "notes": "需要提前预订住宿"
  },
  {
    "id": "plan2",
    "route_id": "route2",
    "name": "周末莫干山一日游",
    "date": "2023-04-15T00:00:00Z",
    "days": 1,
    "status": "completed",
    "notes": null
  }
]
\`\`\`

### 创建计划路线

创建一条新的计划路线。

- **URL**: `/planned-routes`
- **方法**: `POST`
- **认证**: 需要
- **请求体**:

\`\`\`json
{
  "route_id": "route1",
  "name": "五一假期黄山之旅",
  "date": "2023-05-01T00:00:00Z",
  "days": 3,
  "status": "planning",
  "notes": "需要提前预订住宿"
}
\`\`\`

- **响应**:

\`\`\`json
{
  "id": "plan1",
  "route_id": "route1",
  "name": "五一假期黄山之旅",
  "date": "2023-05-01T00:00:00Z",
  "days": 3,
  "status": "planning",
  "notes": "需要提前预订住宿"
}
\`\`\`

### 更新计划路线

更新一条计划路线。

- **URL**: `/planned-routes/{plannedRouteId}`
- **方法**: `PUT`
- **认证**: 需要
- **请求体**:

\`\`\`json
{
  "name": "五一假期黄山之旅",
  "date": "2023-05-01T00:00:00Z",
  "days": 4,
  "status": "planning",
  "notes": "需要提前预订住宿，已预订"
}
\`\`\`

- **响应**:

\`\`\`json
{
  "id": "plan1",
  "route_id": "route1",
  "name": "五一假期黄山之旅",
  "date": "2023-05-01T00:00:00Z",
  "days": 4,
  "status": "planning",
  "notes": "需要提前预订住宿，已预订"
}
\`\`\`

### 删除计划路线

删除一条计划路线。

- **URL**: `/planned-routes/{plannedRouteId}`
- **方法**: `DELETE`
- **认证**: 需要
- **响应**:

\`\`\`json
{
  "success": true
}
\`\`\`

## 徒步攻略相关接口

### 获取徒步攻略列表

获取徒步攻略列表。

- **URL**: `/guides`
- **方法**: `GET`
- **参数**:
  - `limit`: (可选) 返回数量限制
  - `offset`: (可选) 分页偏移量
  - `tag`: (可选) 标签筛选
- **认证**: 不需要
- **响应**:

\`\`\`json
[
  {
    "id": "guide1",
    "title": "初级徒步装备选购指南",
    "content": "本指南将帮助初学者选择合适的徒步装备...",
    "author": "山野君",
    "author_id": "author1",
    "likes": 256,
    "views": 1024,
    "publish_date": "2023-03-15T00:00:00Z",
    "update_date": "2023-03-15T00:00:00Z",
    "icon_code": "shopping_bag",
    "cover_url": null,
    "tags": ["装备", "入门"]
  },
  {
    "id": "guide2",
    "title": "高海拔徒步注意事项",
    "content": "在高海拔地区徒步需要特别注意以下几点...",
    "author": "登山者",
    "author_id": "author2",
    "likes": 189,
    "views": 876,
    "publish_date": "2023-02-20T00:00:00Z",
    "update_date": "2023-02-25T00:00:00Z",
    "icon_code": "terrain",
    "cover_url": null,
    "tags": ["高海拔", "安全"]
  }
]
\`\`\`

### 获取攻略详情

获取特定攻略的详细信息。

- **URL**: `/guides/{guideId}`
- **方法**: `GET`
- **认证**: 不需要
- **响应**:

\`\`\`json
{
  "id": "guide1",
  "title": "初级徒步装备选购指南",
  "content": "本指南将帮助初学者选择合适的徒步装备...",
  "author": "山野君",
  "author_id": "author1",
  "likes": 256,
  "views": 1024,
  "publish_date": "2023-03-15T00:00:00Z",
  "update_date": "2023-03-15T00:00:00Z",
  "icon_code": "shopping_bag",
  "cover_url": null,
  "tags": ["装备", "入门"]
}
\`\`\`

### 点赞攻略

点赞一篇攻略。

- **URL**: `/guides/{guideId}/like`
- **方法**: `POST`
- **认证**: 需要
- **响应**:

\`\`\`json
{
  "success": true
}
\`\`\`

### 取消点赞攻略

取消点赞一篇攻略。

- **URL**: `/guides/{guideId}/like`
- **方法**: `DELETE`
- **认证**: 需要
- **响应**:

\`\`\`json
{
  "success": true
}
\`\`\`

## 错误响应

所有API在发生错误时会返回适当的HTTP状态码和错误信息：

\`\`\`json
{
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "请求的资源不存在"
  }
}
\`\`\`

常见错误码：

- `UNAUTHORIZED`: 未授权访问
- `RESOURCE_NOT_FOUND`: 资源不存在
- `VALIDATION_ERROR`: 请求参数验证失败
- `INTERNAL_SERVER_ERROR`: 服务器内部错误