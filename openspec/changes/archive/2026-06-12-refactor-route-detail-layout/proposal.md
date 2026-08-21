# Change: 路线详情页布局重构 - 地图全屏 + 底部抽屉

## Why

路线详情是应用主功能，用户核心路径为：看地图（路线在哪）→ 看每日行程（每天怎么走）→ 决定是否规划行程。当前 Column 布局（导航栏 + 固定高度地图 + 可滚动内容）导致地图仅占约 50% 屏高，无法最大化地图可见性。采用地图全屏底层 + 底部可上滑抽屉的模式，可突出地图作为主视觉，同时通过抽屉提供渐进式信息展示，符合户外/旅游类应用的主流设计。

## What Changes

- **布局结构**：用 Stack 替换根级别 Column
  - 第 1 层：地图全屏底层（EnhancedDailyMapWidget）
  - 第 2 层：悬浮透明导航栏（返回、标题、收藏、分享）
  - 第 3 层：DraggableScrollableSheet 底部抽屉

- **底部抽屉**：使用 RouteInfoSheetWidget（DraggableScrollableSheet）
  - 初始高度约 50% 屏高，支持半屏/全屏快照点
  - 顶部圆角 20dp，纯白背景，拖拽条
  - 内容顺序：拖拽条 → 路线头部 → 统计卡片 → 现有可展开区块 → 主操作按钮

- **内容复用**：以现有 section 为基准，不新增模块
  - RouteStatsCardWidget、RouteOverviewWidget、DailyItineraryListWidget
  - CampsitesWidget、WaterSourcesWidget、SupplyPointsWidget
  - RouteSegmentsWidget、SeasonalEquipmentWidget、HitchhikeContactsWidget
  - RelatedRoutesWidget、RelatedTripsWidget、RouteGalleryWidget
  - RouteActionButtons（或收敛为主 CTA「生成我的行程」）

- **导航栏**：透明渐变背景，悬浮在地图上，不遮挡轨迹查看

## Impact

- **受影响的规范**：`route-detail-ui`（更新布局模式为 Stack + 抽屉）
- **受影响的代码**：
  - `lib/ui/page/route/detail/route_detail_screen.dart`（主要重构）
  - `lib/ui/page/route/detail/widgets/route_info_sheet_widget.dart`（接入使用）
  - `lib/ui/page/route/detail/widgets/route_stats_card_widget.dart`（可能微调）
