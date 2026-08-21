# Walk v1 缺字段记录与默认值方案

> 本文档记录 PRD §7 数据字典中定义但当前 API 未返回的字段，以及 v1 使用的默认值策略。
> 当后端 API 补齐字段后，移除对应行即可。

## 默认值策略

| 类型 | 默认值 | 说明 |
|------|--------|------|
| String? | null | UI 层显示时用 placeholder（如 "暂无数据"） |
| double? | null | UI 层显示时用 "--" 或隐藏该行 |
| int? | null | 同 double? |
| bool | false | 构造函数提供默认值，@JsonKey(defaultValue: false) |
| List<T>? | null | UI 层判断为 null 则隐藏整个区块 |
| List<T> | const [] | 构造函数提供默认值，UI 层显示空状态 |

---

## RouteModel 缺失字段（7 项）

| 字段 | JSON key | 类型 | 默认值 | PRD 来源 | v2 备注 |
|------|----------|------|--------|----------|---------|
| maxAltitude | max_altitude | double? | null | §7.1 路线 | 后端需新增 |
| bestSeason | best_season | String? | null | §7.1 路线 | 后端需新增 |
| trafficInfo | traffic_info | String? | null | §7.1 路线 | 后端需新增 |
| signalInfo | signal_info | String? | null | §7.1 路线 | 后端需新增 |
| seasonalGear | seasonal_gear | List&lt;GearItemModel&gt;? | null | §7.1 路线 | 后端需新增，关联 GearItemModel |
| relatedRoutes | related_routes | List&lt;RouteModel&gt;? | null | §7.1 路线 | 后端需新增 |
| relatedTrips | related_trips | List&lt;TripSummaryModel&gt;? | null | §7.1 路线 | 后端需新增，关联 TripSummaryModel |

## TripModel 缺失字段（4 项）

| 字段 | JSON key | 类型 | 默认值 | PRD 来源 | v2 备注 |
|------|----------|------|--------|----------|---------|
| transport | transport | String? | null | §7.2 行程 | 后端需新增 |
| accommodation | accommodation | String? | null | §7.2 行程 | 后端需新增 |
| weatherForecast | weather_forecast | List&lt;DayWeatherModel&gt;? | null | §7.2 行程 | 后端需新增，关联 DayWeatherModel |
| safetyReminders | safety_reminders | List&lt;String&gt;? | null | §7.2 行程 | 后端需新增 |

## CampsiteModel 缺失字段（2 项）

| 字段 | JSON key | 类型 | 默认值 | PRD 来源 | v2 备注 |
|------|----------|------|--------|----------|---------|
| facilities | — | List&lt;String&gt; | const [] | §7.7 营地 | 构造函数默认空数组 |
| capacity | — | int? | null | §7.7 营地 | 后端需新增 |

> 注：facilityLevelText、capacityText 已从硬编码 "未知" 改为基于实际字段计算。

## 其他模型缺失字段（7 项）

| 模型 | 字段 | JSON key | 类型 | 默认值 | PRD 来源 | v2 备注 |
|------|------|----------|------|--------|----------|---------|
| SupplyPointModel | availableItems | available_items | String? | null | §7.6 补给点 | 后端需新增 |
| SegmentModel | isHighlighted | is_highlighted | bool | false | §7.4 分段 | 构造函数默认值 |
| HitchhikeContactModel | route | route | String? | null | §7.10 搭车 | 后端需新增 |
| WeatherInfoVO | windDirection | wind_direction | String? | null | §7.11 天气 | 后端需新增 |
| WeatherInfoVO | alert | alert | String? | null | §7.11 天气 | 后端需新增 |
| MealPlanModel | status | — | MealPlanStatus | draft | §7.8 食物计划 | 构造函数默认值 |
| MealPlanModel | mealsPerDay | meals_per_day | int? | null | §7.8 食物计划 | 后端需新增 |
| WaterPlanModel | status | — | WaterPlanStatus | draft | §7.9 饮水计划 | 构造函数默认值 |
| WaterPlanModel | litersPerDay | liters_per_day | double? | null | §7.9 饮水计划 | 后端需新增 |

## 新增模型（4 个）

| 模型 | 文件 | 字段数 | 说明 |
|------|------|--------|------|
| TripSummaryModel | model/trip/trip_summary_model.dart | 6 | 行程摘要，用于路线详情"相关行程" |
| DayWeatherModel | model/weather/day_weather_model.dart | 8 | 逐日天气，含 DayWeatherCondition 枚举 |
| GearItemModel | model/route/gear_item_model.dart | 3 | 季节装备建议，含 GearPriority 枚举 |
| ParticipantModel | model/trip/participant_model.dart | 5 | 行程参与者，含 ConfirmationStatus 枚举 |

---

## UI 层使用指引

当字段为 null 时，UI 不应显示该区块或显示占位符：

```dart
// 示例：路线详情页
if (route.maxAltitude != null)
  _buildInfoRow('最高海拔', '${route.maxAltitude!.toInt()}m'),

if (route.seasonalGear != null && route.seasonalGear!.isNotEmpty)
  _buildSeasonalGearSection(route.seasonalGear!),

// 示例：行程详情页
if (trip.weatherForecast != null && trip.weatherForecast!.isNotEmpty)
  _buildWeatherForecastSection(trip.weatherForecast!),
```
