# Design: 路线详情 UI 布局重构

## Context

路线详情屏幕目前使用全页面可滚动布局。用户希望在浏览路线信息时能够看到突出显示的地图，受现代旅游和健身应用的启发。本设计实现了固定地图背景和可拖拽信息表单的方式。

## Goals / Non-Goals

### Goals
- 最大化地图可见性作为主要元素
- 通过表单拖拽提供直观的信息逐步展示
- 在不破坏现有功能的情况下保持所有现有功能
- 改善用户路线探索体验

### Non-Goals
- 重新设计数据模型或 API 契约
- 添加新的统计数据收集
- 实现实时跟踪功能
- 创建交互式地图元素（超出现有功能范围）

## Decisions

### 1. DraggableScrollableSheet 与自定义实现

**决策**：使用 Flutter 内置的 `DraggableScrollableSheet`

**理由**：
- 开箱即用提供平滑的物理感拖拽
- 经过充分测试和验证
- 减少自定义代码和潜在错误
- 与 Flutter/iOS 交互模式一致

**考虑的替代方案**：
- 自定义拖拽实现：提供更多控制，但复杂度更高
- BottomSheet：灵活性较低，不支持任意高度之间的拖拽

### 2. 表单高度配置

**决策**：
- 初始高度：0.50（屏幕高度的 50%），首屏可见路线头部 + 每日行程入口
- 最小范围：0.15（屏幕高度的 15%）
- 最大范围：0.90（屏幕高度的 90%）
- 快照点：[0.50, 0.90]（半屏 / 全屏）

**理由**：
- 50% 默认值保证地图与核心信息同时可见
- 90% 最大值在顶部留下小的地图可见性
- 快照点通过提供自然的"着陆区"来改善用户体验
- 避免覆盖系统状态栏或手势区域

### 3. 导航栏透明度

**决策**：使导航栏透明渐变（上黑 50% → 全透明），将返回/收藏/分享按钮定位为浮动覆盖层

**理由**：
- 最大化地图可见性
- 现代应用设计模式
- 返回按钮仍然可见便于导航
- 收藏、分享提供快速操作访问

### 4. 统计信息显示优先级

**决策**：按以下优先级显示 RouteModel 字段：
1. 距离（route.distance 或 route.defaultMap.distance）
2. 预计时间（route.defaultMap.estimatedTime）
3. 爬升高度（route.elevationGain 或 route.defaultMap.elevationGain）
4. 下降高度（route.elevationLoss 或 route.defaultMap.elevationLoss）

**理由**：
- 这些是路线规划中最重要的指标
- 直接可从现有数据模型获得
- 匹配参考截图风格

### 5. 布局结构

**决策**：根级别 Stack 包含：
- 底部：固定地图层（EnhancedDailyMapWidget）
- 中部：导航栏层
- 顶部：DraggableScrollableSheet

**理由**：
- 关注点清晰分离
- 地图保持固定，无论表单如何交互
- 导航始终可访问
- 自然的 z-index 排序

## Architecture

### 组件层级

```
RouteDetailScreen（StatefulWidget）
├── Stack（主容器）
│   ├── [第 1 层] EnhancedDailyMapWidget（固定）
│   ├── [第 2 层] 导航栏（透明，浮动）
│   │   ├── 返回按钮
│   │   └── 分享按钮
│   └── [第 3 层] RouteInfoSheetWidget（DraggableScrollableSheet）
│       ├── 手柄/拖拽指示器
│       ├── RouteStatsCardWidget（统计信息）
│       └── 内容部分容器
│           ├── RouteOverviewWidget
│           ├── DailyItineraryListWidget
│           ├── CampsitesWidget
│           ├── WaterSourcesWidget
│           ├── SupplyPointsWidget
│           ├── SeasonalEquipmentWidget
│           ├── HitchhikeContactsWidget
│           ├── RelatedRoutesWidget
│           ├── RelatedTripsWidget
│           └── RouteGalleryWidget
```

### 新建小部件

#### RouteInfoSheetWidget
- **目的**：用通用配置包装 DraggableScrollableSheet
- **属性**：route, expandedSections, onExpandedChanged, children (sections)
- **职责**：
  - 配置 DraggableScrollableSheet 参数
  - 管理表单视觉样式（圆角、背景等）
  - 提供拖拽手柄 UI
  - 处理表单状态变化

#### RouteStatsCardWidget
- **目的**：在显著网格布局中显示核心路线统计信息
- **属性**：route
- **职责**：
  - 提取和格式化统计信息
  - 以网格形式排列（2-3 列）
  - 应用大字体样式
  - 处理缺失数据的回退值

### 修改的小部件

#### RouteDetailScreen
**变更**：
- 用 `Stack` 替换根级别的 `CustomScrollView`
- 添加地图作为固定背景层
- 添加透明导航栏
- 用 `RouteInfoSheetWidget` 包装所有内容部分
- 为 `_expandedSections` 保持现有状态管理

**关键考虑**：
- 保留所有现有功能（收藏、导航等）
- 保持 3D 地图切换工作正常（地图组件内置）
- 保持错误状态和加载视图
- 以现有 section 为基准，不新增模块

#### RouteOverviewWidget
**变更**：
- 移除标题显示（标题在导航区域显示）
- 可选地使描述显示可切换
- 调整表单上下文中的填充
- 保留标签、地区、评分信息

**兼容性**：
- 应该在表单和独立上下文中都能工作
- 可能需要调整宽度约束

## Data Flow

```
RouteDetailScreen
│
├─→ 通过 _loadRouteDetail() 加载 RouteModel
│
├─→ 为 RouteStatsCardWidget 提取统计信息：
│   ├─ route.distance
│   ├─ route.defaultMap.estimatedTime
│   ├─ route.elevationGain
│   └─ route.elevationLoss
│
└─→ 将完整 RouteModel 传递给部分小部件
    ├─ RouteOverviewWidget
    ├─ DailyItineraryListWidget
    ├─ 等等...
```

## Migration Plan

### 第 1 阶段：基础设施（第 1 天）
- 更新 RouteDetailScreen 布局结构
- 添加 DraggableScrollableSheet 包装器
- 定位地图和导航栏

### 第 2 阶段：统计显示（第 1 天）
- 创建 RouteStatsCardWidget
- 连接统计数据
- 测试数据格式化

### 第 3 阶段：内容组织（第 2 天）
- 将现有部分重新组织到表单中
- 更新 RouteOverviewWidget
- 在表单中测试部分功能

### 第 4 阶段：打磨和测试（第 2 天）
- 优化拖拽交互
- 处理边界情况
- 在各种设备上测试
- 如果需要进行性能优化

## Risks / Trade-offs

| 风险 | 缓解措施 |
|------|---------|
| 表单拖拽与地图交互冲突 | 使用适当的 z-index 和手势处理；在表单拖拽期间测试地图点击 |
| 大内容导致的性能问题 | 延迟加载部分；为昂贵的小部件使用 RepaintBoundary |
| 缺口设备上的安全区域处理 | 使用 MediaQuery.of(context).padding 配置表单 |
| 表单展开时加载数据 | 在表单中显示加载状态；实现适当的异步处理 |
| 现有测试破坏 | 更新测试以考虑新的布局结构 |

## Open Questions

- [ ] 表单交互期间地图应该是否交互，还是手势应该被表单消费？
- [ ] 远离时是否应该有崩溃动画？
- [ ] 是否需要横屏模式支持？
- [ ] 路线转换期间是否应该保留部分状态？
