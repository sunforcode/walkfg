## Purpose

本变更更新设计系统规范，引入三层信息架构、页面布局模式、核心 UI 组件和交互模式，实现卡片渐进展开 + 数据优先的设计理念。

## ADDED Requirements

### Requirement: 信息架构 - 三层结构
应用 SHALL 采用三层信息架构进行界面设计：

**第一层：概览层 (Overview)**
- 用于首页仪表盘、模块入口
- 展示关键统计数据和快捷操作
- 信息密度：低，突出重点

**第二层：列表层 (List)**
- 用于路线列表、行程列表、装备列表等
- 展示多项内容的核心参数
- 信息密度：中，便于扫描比较

**第三层：详情层 (Detail)**
- 用于路线详情、行程详情等
- 展示完整信息，支持分区切换
- 信息密度：高，支持深入了解

#### Scenario: 用户浏览路线
- **WHEN** 用户在首页看到推荐路线卡片
- **THEN** 显示路线名称和 1-2 个关键指标（概览层）
- **WHEN** 用户点击"查看更多"进入路线列表
- **THEN** 每个路线卡片显示名称、距离、海拔、难度等核心参数（列表层）
- **WHEN** 用户点击某条路线
- **THEN** 进入详情页，可通过 Tab 切换查看概览、分段、地图、评论等（详情层）

---

### Requirement: 页面布局 - 仪表盘布局
首页 SHALL 采用仪表盘布局模式：

**布局结构**:
1. 顶部欢迎区：欢迎语、天气信息
2. 统计卡片区：横向排列的关键数据卡片
3. 内容区块：分区展示不同模块入口，每区块含标题和"更多"入口
4. 可滚动：整体内容可垂直滚动

**间距规范**:
- 区块间距：`AppSpacing.lg` (24dp)
- 卡片内边距：`AppSpacing.md` (16dp)
- 统计卡片间距：`AppSpacing.sm` (8dp)

#### Scenario: 首页仪表盘展示
- **WHEN** 用户打开应用进入首页
- **THEN** 显示欢迎语和当前天气
- **THEN** 显示关键统计数据（总里程、已完成路线数等）
- **THEN** 显示推荐路线、近期行程等内容区块

---

### Requirement: 页面布局 - 列表页布局
列表页 SHALL 采用标准列表布局模式：

**布局结构**:
1. 导航栏：标题、筛选/搜索操作
2. 分段控制（可选）：Tab 或 Segment 切换不同分类
3. 列表区：卡片式或列表式内容
4. 操作入口（可选）：FAB 或底部操作栏

**交互规范**:
- 支持下拉刷新
- 支持上拉加载更多
- 支持筛选和搜索

#### Scenario: 路线列表页
- **WHEN** 用户进入路线列表页
- **THEN** 导航栏显示"路线"标题和搜索按钮
- **THEN** 列表以卡片形式展示路线，每张卡片显示缩略图和核心参数
- **WHEN** 用户下拉
- **THEN** 触发刷新加载最新数据

---

### Requirement: 页面布局 - 详情页布局
详情页 SHALL 采用 Header + Tab 内容区布局模式：

**布局结构**:
1. 导航栏：返回按钮、操作菜单
2. Header 区：标题、关键数据标签、封面图（可选）
3. Tab 栏：概览、分段、地图、评论等切换
4. 内容区：根据 Tab 显示对应内容，支持可展开区块
5. 底部操作栏（可选）：主操作按钮

**滚动行为**:
- Header 区可随滚动折叠
- Tab 栏固定或吸顶
- 内容区可垂直滚动

#### Scenario: 路线详情页
- **WHEN** 用户进入路线详情页
- **THEN** Header 区显示路线名称、难度标签、总距离等
- **THEN** Tab 栏提供"概览"、"分段"、"地图"、"评论"切换
- **WHEN** 用户切换到"分段"Tab
- **THEN** 显示路线各分段的详细信息列表
- **THEN** 底部显示"开始导航"主操作按钮

---

### Requirement: 组件规范 - 统计卡片 (StatCard)
应用 SHALL 提供统一的统计卡片组件用于数据展示：

**视觉规范**:
- 布局：图标 + 数值 + 单位（可选）+ 标签
- 数值字体：`AppTypography.statValue` (28sp, bold)
- 单位字体：`AppTypography.statUnit` (12sp, regular)
- 标签字体：`AppTypography.labelSmall` (10sp)
- 背景：`AppColors.surface`
- 圆角：`AppRadius.md` (8dp)

**尺寸规范**:
- 最小宽度：100dp
- 推荐高度：80-100dp
- 内边距：`AppSpacing.md` (16dp)

#### Scenario: 首页统计卡片
- **WHEN** 开发者需要展示关键统计数据
- **THEN** 使用 `StatCard` 组件
- **THEN** 数值突出显示，单位和标签弱化

---

### Requirement: 组件规范 - 数据卡片 (DataCard)
应用 SHALL 提供统一的数据卡片组件用于列表展示：

**视觉规范**:
- 布局：缩略图（可选）+ 标题 + 副标题 + 指标区
- 缩略图比例：16:9 或 1:1
- 指标区：水平排列，图标 + 数值格式
- 背景：`AppColors.card`
- 圆角：`AppRadius.md` (8dp)
- 边框：1dp `AppColors.border`

**尺寸规范**:
- 内边距：`AppSpacing.md` (16dp)
- 缩略图高度：120-160dp（带图模式）
- 指标间距：`AppSpacing.md` (16dp)

**交互规范**:
- 点击反馈：轻微缩放 (scale: 0.98)
- 支持长按预览（可选）

#### Scenario: 路线列表卡片
- **WHEN** 开发者需要展示路线列表
- **THEN** 使用 `DataCard` 组件
- **THEN** 显示路线缩略图、名称、位置、距离和海拔指标

---

### Requirement: 组件规范 - 可展开区块 (ExpandableSection)
应用 SHALL 提供可展开/折叠的内容区块组件：

**视觉规范**:
- 标题区：标题文字 + 展开/折叠图标
- 内容区：折叠时隐藏，展开时显示
- 分割线：区块之间使用分割线分隔

**动效规范**:
- 展开/折叠动画时长：300ms
- 缓动函数：easeInOut
- 图标旋转：90度

#### Scenario: 详情页可展开信息
- **WHEN** 用户查看路线详情页的"详细信息"区块
- **THEN** 默认折叠显示标题
- **WHEN** 用户点击标题
- **THEN** 区块展开显示完整内容，展开图标旋转

---

### Requirement: 组件规范 - 操作栏 (ActionBar)
应用 SHALL 提供底部固定操作栏组件：

**视觉规范**:
- 位置：固定在页面底部
- 背景：`AppColors.surface`
- 阴影：`AppShadows.md`
- 安全区：适配底部安全区域

**布局规范**:
- 主操作：占据主要宽度的主按钮
- 次操作：图标按钮排列在主按钮旁边
- 内边距：`AppSpacing.md` (16dp)

#### Scenario: 路线详情页操作栏
- **WHEN** 用户查看路线详情页
- **THEN** 底部显示固定操作栏
- **THEN** 主按钮显示"开始导航"
- **THEN** 次按钮显示分享、收藏图标

---

### Requirement: 交互规范 - 加载状态
应用 SHALL 提供统一的加载状态展示：

**Skeleton 骨架屏**:
- 用于初次加载页面
- 模拟真实布局的占位块
- 使用渐变动画效果
- 颜色：`AppColors.divider` 到 `AppColors.background` 渐变

**刷新加载**:
- 下拉刷新：使用 `CupertinoSliverRefreshControl`
- 上拉加载：列表底部显示加载指示器

**操作加载**:
- 按钮内置 loading 状态
- 禁用重复点击

#### Scenario: 列表页初次加载
- **WHEN** 用户进入列表页，数据尚未加载完成
- **THEN** 显示 Skeleton 骨架屏占位
- **WHEN** 数据加载完成
- **THEN** 骨架屏淡出，真实内容淡入

#### Scenario: 列表页下拉刷新
- **WHEN** 用户在列表页下拉
- **THEN** 显示下拉刷新指示器
- **WHEN** 刷新完成
- **THEN** 指示器收起，列表更新

---

### Requirement: 交互规范 - 过渡动效
应用 SHALL 提供统一的过渡动效规范：

**页面切换**:
- iOS：右滑入/左滑出（系统默认）
- 时长：300-350ms

**卡片点击**:
- 按压反馈：scale 缩放到 0.98
- 时长：100ms

**Tab 切换**:
- 内容横向滑动过渡
- 指示器滑动跟随

**展开/折叠**:
- 高度动画
- 时长：300ms
- 缓动：easeInOut

#### Scenario: 卡片点击反馈
- **WHEN** 用户按压数据卡片
- **THEN** 卡片轻微缩小 (scale: 0.98)
- **WHEN** 用户松开
- **THEN** 卡片恢复原大小并触发点击事件

---

### Requirement: Design Token - 数据展示字体
应用 SHALL 提供数据展示专用的字体样式 Token：

| Token | 字号 | 字重 | 用途 |
|-------|------|------|------|
| `statValue` | 28sp | w700 | 统计卡片数值 |
| `statUnit` | 12sp | w400 | 统计卡片单位 |
| `statLabel` | 10sp | w400 | 统计卡片标签 |
| `metricValue` | 14sp | w600 | 指标数值 |
| `metricLabel` | 12sp | w400 | 指标标签 |

#### Scenario: 使用数据展示字体
- **WHEN** 开发者需要显示统计数值
- **THEN** 使用 `AppTypography.statValue` 获取预定义样式

---

### Requirement: Design Token - 卡片阴影层级
应用 SHALL 提供多层级的卡片阴影 Token：

| Token | 用途 | 偏移 | 模糊 | 颜色 |
|-------|------|------|------|------|
| `cardElevation0` | 扁平卡片 | 无 | 无 | 仅边框 |
| `cardElevation1` | 普通卡片 | (0, 1) | 3 | 6% 黑 |
| `cardElevation2` | 悬浮卡片 | (0, 2) | 6 | 10% 黑 |
| `cardElevation3` | 弹出层 | (0, 4) | 12 | 15% 黑 |

#### Scenario: 使用卡片阴影
- **WHEN** 开发者创建普通列表卡片
- **THEN** 使用 `AppShadows.cardElevation1` 获取阴影配置

---

### Requirement: Design Token - 交互状态颜色
应用 SHALL 提供交互状态相关的颜色 Token：

| Token | 颜色值 | 用途 |
|-------|--------|------|
| `pressed` | #000000 4% | 按压态叠加色 |
| `hovered` | #000000 2% | 悬停态叠加色 |
| `focused` | primary | 聚焦态边框色 |
| `dragging` | #000000 8% | 拖拽态叠加色 |

#### Scenario: 按钮按压状态
- **WHEN** 用户按压按钮
- **THEN** 按钮背景叠加 `AppColors.pressed` 颜色
