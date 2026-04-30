# 规范：路线详情 Section 布局与视觉层级

## MODIFIED Requirements

### Requirement: 主数据卡片（RouteStatsCardWidget）视觉样式

路线详情页面 SHALL 在底部抽屉中使用深色背景的主数据卡片来突出显示核心统计信息。

#### Scenario: 主数据卡片样式
- **WHEN** 用户查看路线详情时
- **THEN** RouteStatsCardWidget 应显示以下样式：
  - 背景色：深色 (#1C1C1E)
  - 文字色：白色或浅色（确保可读性）
  - 圆角：12dp
  - 内间距：上下 24px，左右 20px
- **AND** 与其他浅灰色 section 形成视觉对比

#### Scenario: 主数据卡片内容布局
- **WHEN** 用户查看主数据卡片时
- **THEN** 内容应按以下顺序排列：
  1. **第一行**：距离（大字突出，字号 40px）
     - 左对齐显示"xx.xx km"
     - 标签"距离"显示在数值下方
  2. **分隔线**：1px 白色半透明线（opacity 0.1）
  3. **第二行**：三列网格（等宽分布）
     - 列 1：时间（标签 + 数值）
     - 列 2：爬升（标签 + 数值）
     - 列 3：下降（标签 + 数值）
     - 列间距：16px
  4. **分隔线**：1px 白色半透明线（opacity 0.1）
  5. **第三行**：难度信息（左对齐）
     - 显示：难度标签 + 难度名称 + 区域信息（右对齐）
- **AND** 所有文字使用白色或浅色以确保对比度

#### Scenario: 数据字段显示
- **WHEN** 用户查看主数据卡片的数据时
- **THEN** 应显示以下字段（保持不变）：
  - 距离：从 route.defaultMap.distance 或 route.distance 获取，保留 2 位小数
  - 时间：从 route.defaultMap.getEstimatedTimeText() 或 route.duration 获取
  - 爬升：从 route.defaultMap.elevationGain 或 route.elevationGain 获取，转换为整数米
  - 下降：从 route.defaultMap.elevationLoss 或 route.elevationLoss 获取，转换为整数米
  - 难度：从 route.difficulty 获取，使用彩色图标和名称
  - 区域：从 route.region 获取

### Requirement: Section 容器样式分层

路线详情页面 SHALL 在底部抽屉中区分主数据卡片和其他 section 的视觉样式。

#### Scenario: 主数据卡片容器
- **WHEN** RouteStatsCardWidget（第 0 个 section）被渲染时
- **THEN** 不应被通用卡片包装器包装
- **AND** 直接显示其深色背景样式
- **AND** 与底部抽屉容器的白色背景有适当的视觉分离

#### Scenario: 其他 Section 容器
- **WHEN** 其他 section（第 1+ 个）被渲染时
- **THEN** 应使用通用卡片包装器：
  - 背景色：浅灰 (#F8FAFC)
  - 圆角：16dp
  - 阴影：BoxShadow (offset: (0, 2), blurRadius: 8)
  - 间距：下间距 12px
- **AND** 与主数据卡片形成清晰的视觉对比

#### Scenario: Section 顺序
- **WHEN** 用户查看抽屉内容时
- **THEN** section 的顺序应为：
  1. 主数据卡片（RouteStatsCardWidget）- 深色背景
  2. 其他所有 section（浅灰背景）
- **AND** 顺序保持现有不变

### Requirement: 视觉对比与可读性

路线详情页面 SHALL 确保主数据卡片与其他 section 之间的视觉对比清晰。

#### Scenario: 色彩对比
- **WHEN** 用户查看路线详情抽屉时
- **THEN** 颜色对比应满足：
  - 深色背景 (#1C1C1E) 上的白色文字：对比度 ≥ 7:1（WCAG AAA）
  - 主数据卡片与浅灰 section 形成明显的视觉分离
  - 在 iOS Light Mode 和 Dark Mode 下都能正常显示

#### Scenario: 间距与排列
- **WHEN** 用户查看多个 section 时
- **THEN** section 之间的间距应：
  - 主数据卡片下方：12px 间隔后开始其他 section
  - 所有 section 左右对齐，形成整齐的竖向排列
  - 不同屏幕尺寸（手机/平板）上布局保持一致

## UNCHANGED Requirements

- 拖拽交互（DraggableScrollableSheet 的行为不变）
- Section 展开/折叠功能（保持现有状态管理）
- 导航栏显示（悬浮透明导航栏保持不变）
- 地图显示（全屏地图保持不变）
- 所有 section 的数据内容（不修改任何 section widget）
- 功能交互（收藏、分享、规划行程等）

