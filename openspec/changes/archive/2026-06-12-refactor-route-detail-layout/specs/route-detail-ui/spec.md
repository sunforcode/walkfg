# 规范：路线详情 UI 布局

## ADDED Requirements

### Requirement: 路线详情页面布局结构
路线详情页面 SHALL 采用 Stack 布局：地图全屏底层 + 悬浮导航栏 + 底部可上滑抽屉。

#### Scenario: 用户打开路线详情
- **WHEN** 用户导航到路线详情屏幕时
- **THEN** 布局按层级显示：
  1. 第 1 层：地图全屏底层（EnhancedDailyMapWidget）
  2. 第 2 层：悬浮透明导航栏（返回、标题、收藏、分享）
  3. 第 3 层：底部抽屉（DraggableScrollableSheet）
- **AND** 地图始终占满屏幕，作为主视觉
- **AND** 导航栏悬浮在地图上，不遮挡轨迹查看
- **AND** 地图组件具有 2D/3D 切换按钮（内置在地图组件中）

#### Scenario: 用户拖拽底部抽屉
- **WHEN** 用户上滑底部抽屉时
- **THEN** 抽屉可展开至全屏（约 90% 屏高）
- **WHEN** 用户下滑底部抽屉时
- **THEN** 抽屉可收起到半屏（约 50% 屏高）
- **AND** 快照点提供自然的着陆区
- **AND** 地图在抽屉下方保持可见

### Requirement: 导航栏显示
路线详情页面 SHALL 在顶部显示悬浮透明导航栏，具有返回、收藏和分享按钮。

#### Scenario: 导航控件可见
- **WHEN** 用户查看路线详情时
- **THEN** 返回按钮出现在左上角
- **AND** 路线标题显示在导航栏中央（白色粗体）
- **AND** 收藏和分享按钮出现在右上角
- **AND** 导航栏具有透明渐变背景（上黑 50% → 全透明）
- **AND** 导航栏高度 44pt + SafeArea

### Requirement: 地图部分显示
路线详情页面 SHALL 将地图作为全屏底层显示。

#### Scenario: 地图正确显示
- **WHEN** 用户查看路线详情时
- **THEN** 地图以全屏方式显示在底层
- **AND** 地图显示完整的路线及所有跟踪点和标记
- **AND** 地图可在 2D 和 3D 视图之间切换（按钮在地图组件中）
- **AND** 底部抽屉覆盖在地图之上，不遮挡地图交互（缩放、拖拽）

### Requirement: 底部抽屉内容部分
路线详情页面 SHALL 在底部抽屉的可滚动区域中显示路线信息，以现有 section 为基准。

#### Scenario: 内容部分显示
- **WHEN** 用户查看抽屉内容区域时
- **THEN** 按顺序显示以下部分：
  - 拖拽条（顶部居中）
  - 路线统计卡片（RouteStatsCardWidget）
  - 路线概览（RouteOverviewWidget，可展开）
  - 每日行程（DailyItineraryListWidget，可展开）
  - 营地信息（CampsitesWidget，可展开）
  - 水源（WaterSourcesWidget，可展开）
  - 补给点（SupplyPointsWidget，可展开）
  - 路线分段（RouteSegmentsWidget，可展开）
  - 装备建议（SeasonalEquipmentWidget，可展开）
  - 搭车联系人（HitchhikeContactsWidget，可展开）
  - 相关路线（RelatedRoutesWidget，可展开）
  - 相关行程（RelatedTripsWidget，可展开）
  - 图片库（RouteGalleryWidget，可展开）
  - 操作按钮（规划行程、收藏等）
- **AND** 每个部分用可展开区块包装，可展开/折叠
- **AND** 展开/折叠状态在滚动期间得以保留
- **AND** 抽屉具有纯白背景、顶部圆角 20dp

#### Scenario: 用户滚动抽屉内容
- **WHEN** 用户在抽屉内容区域内滚动时
- **THEN** 滚动平滑且反应迅速
- **AND** 到达底部时显示适当的填充
- **AND** 地图在抽屉下方保持可见
