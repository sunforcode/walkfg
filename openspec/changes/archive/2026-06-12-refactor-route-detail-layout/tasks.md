# 实现任务：路线详情页布局重构（地图全屏 + 底部抽屉）

## 1. 基础设施 - 布局结构
- [x] 1.1 用 Stack 替换根级别 Column
- [x] 1.2 将 EnhancedDailyMapWidget 作为第 1 层，全屏填充（Positioned.fill）
- [x] 1.3 将导航栏作为第 2 层，Positioned 悬浮在顶部
- [x] 1.4 将 RouteInfoSheetWidget（DraggableScrollableSheet）作为第 3 层

## 2. 导航栏
- [x] 2.1 实现透明渐变背景（上黑 50% → 全透明）
- [x] 2.2 左侧：返回按钮
- [x] 2.3 中间：路线标题（白色粗体）
- [x] 2.4 右侧：收藏 + 分享
- [x] 2.5 高度 44pt + SafeArea

## 3. 底部抽屉（RouteInfoSheetWidget）
- [x] 3.1 配置 initialChildSize: 0.50, snapSizes: [0.50, 0.90]
- [x] 3.2 纯白背景、顶部圆角 20dp
- [x] 3.3 顶部居中拖拽条（4px 高、30dp 宽、灰色）
- [x] 3.4 将 RouteStatsCardWidget 置于拖拽条下方

## 4. 抽屉内容顺序（复用现有 section）
- [x] 4.1 拖拽条
- [x] 4.2 RouteStatsCardWidget（路线头部 + 统计）
- [x] 4.3 路线概览（RouteOverviewWidget，ExpandableSection）
- [x] 4.4 每日行程（DailyItineraryListWidget，ExpandableSection）
- [x] 4.5 营地、水源、补给点（CampsitesWidget, WaterSourcesWidget, SupplyPointsWidget）
- [x] 4.6 路线分段、装备、搭车、相关路线/行程、图片库（ExpandableSection）
- [x] 4.7 主操作按钮（RouteActionButtons 或「生成我的行程」）

## 5. 状态与错误处理
- [x] 5.1 保持 _expandedSections 状态管理
- [x] 5.2 保持加载态（LoadingView）、错误态（ErrorView）
- [x] 5.3 保持地图 2D/3D 切换（地图组件内置）

## 6. 测试与验证
- [x] 6.1 抽屉拖拽流畅，快照点吸附正常
- [x] 6.2 导航栏始终可见、不遮挡
- [x] 6.3 各 section 展开/折叠正常
- [x] 6.4 不同屏幕尺寸、安全区域处理正确
