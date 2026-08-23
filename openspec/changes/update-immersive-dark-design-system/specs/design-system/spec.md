## ADDED Requirements

### Requirement: 沉浸式暗色主视觉

应用 SHALL 以全屏封面式大图作为内容型页面的主视觉模式。影像 SHALL 占据首屏主体，页面标题、核心指标和主要操作 SHALL 通过暗色渐变遮罩直接叠加在影像上，非必要卡片 SHALL 被弱化或移除。

#### Scenario: 路线发现首屏

- **WHEN** 用户进入路线发现等内容型页面
- **THEN** 首屏 SHALL 以单个路线或目的地影像作为视觉主体
- **THEN** 页面 SHALL 使用显著的大标题和有限的核心指标
- **THEN** 页面 MUST NOT 以多个同权重的小卡片作为首屏主体

#### Scenario: 内容缺少有效图片

- **WHEN** 内容没有封面图或图片加载失败
- **THEN** 页面 SHALL 使用统一的暗色渐变、抽象山形或领域占位图降级
- **THEN** 标题、指标和操作的布局层级 SHALL 保持不变

### Requirement: 页面视觉模式

应用 SHALL 提供 `immersive` 和 `utility` 两种同源暗色页面模式。`immersive` 用于以路线、目的地、攻略或行程为主体的内容型页面；`utility` 用于编辑、设置、表单和高密度信息页面。

#### Scenario: 内容型页面选择模式

- **WHEN** 页面主要表达具有核心视觉内容的户外对象
- **THEN** 页面 SHALL 使用 `immersive` 模式
- **THEN** 全屏封面式大图 SHALL 作为默认首选布局

#### Scenario: 工具型页面选择模式

- **WHEN** 页面主要用于编辑或高密度操作
- **THEN** 页面 SHALL 使用 `utility` 模式
- **THEN** 页面 SHALL 使用同一暗色 Token、导航和组件
- **THEN** 页面 MUST NOT 强制添加无业务意义的大图

### Requirement: Hero 影像可读性

Hero 影像 SHALL 通过统一的裁剪、焦点、渐变遮罩和前景对比度规则保证文字与操作可读。图片本身不得直接承担文字可读性保证。

#### Scenario: 文字叠加在复杂图片上

- **WHEN** 标题或指标叠加在亮暗变化明显的图片上
- **THEN** 组件 SHALL 自动应用符合内容位置的暗色渐变遮罩
- **THEN** 主要文字与背景的对比度 SHALL 达到 WCAG AA 要求

#### Scenario: 图片焦点与文字冲突

- **WHEN** 图片主体与文字区域重叠
- **THEN** 页面 SHALL 通过焦点裁剪、文字位置或遮罩强度解决冲突
- **THEN** 页面 MUST NOT 通过新增不透明大卡片默认遮挡图片主体

### Requirement: 沉浸式页面公共组件

应用 SHALL 提供统一的沉浸式页面骨架、Hero 影像、遮罩、叠图标题、指标组和毛玻璃操作组件。公共组件 SHALL 只提供语义明确的受控变体。

#### Scenario: 创建新的沉浸式内容页

- **WHEN** 开发者创建路线、攻略或行程内容页
- **THEN** 开发者 SHALL 组合使用公共沉浸式页面组件
- **THEN** 开发者 MUST NOT 在页面内重新实现图片加载、遮罩、叠图标题和按压反馈

#### Scenario: 需要不同 Hero 构图

- **WHEN** 页面需要全屏封面、编辑式构图或带悬浮信息层的构图
- **THEN** 开发者 SHALL 使用 Hero 组件的受控语义变体
- **THEN** 调用方 MUST NOT 通过任意颜色、圆角和阴影参数创建新的视觉体系

### Requirement: 通用状态与导航组件

应用 SHALL 为两种页面模式提供统一的导航、Section Header、网络图片、加载、错误、空态和操作反馈组件，并允许通过受控变体适配沉浸式与工具型上下文。

#### Scenario: 页面加载数据

- **WHEN** 普通页面展示加载、失败或空状态
- **THEN** 页面 SHALL 使用统一异步状态组件
- **THEN** 特殊页面 MAY 通过公开变体组合品牌化视觉，但 MUST NOT 复制状态逻辑

#### Scenario: 页面展示网络图片

- **WHEN** 页面加载远程封面或缩略图
- **THEN** 页面 SHALL 使用统一网络图片组件
- **THEN** 缓存、加载、失败占位和裁剪行为 SHALL 由公共组件负责

### Requirement: 公共组件晋升规则

公共组件 SHALL 基于稳定、重复的语义模式建立。只有至少两个真实使用场景共享同一结构和行为时，业务组件才 SHOULD 晋升为公共组件。

#### Scenario: 单一页面出现特殊布局

- **WHEN** 一个布局只有单一业务使用场景
- **THEN** 该布局 MAY 保留在业务目录
- **THEN** 该布局 MUST 组合公共 Token 与视觉原语

#### Scenario: 多个页面复制同一模式

- **WHEN** 两个或以上页面重复实现相同的结构和交互
- **THEN** 该模式 SHALL 被收敛为公共组件或现有组件的受控变体

## MODIFIED Requirements

### Requirement: Design Token - Colors

应用 SHALL 提供以下以沉浸式暗色界面为基准的语义颜色 Token：

- `bgBase`: `#0A0A1A`，页面基础背景
- `bgPanel`: `#1A1A2E`，工具型面板背景
- `surfaceCard`: `rgba(255,255,255,0.06)`，图片或暗色背景上的轻量表面
- `surfaceGlass`: `rgba(255,255,255,0.12)`，毛玻璃操作表面
- `border`: `rgba(255,255,255,0.10)`，暗色边框
- `textPrimary`: `#FFFFFF`，主要文字
- `textSecondary`: `rgba(255,255,255,0.70)`，次要文字
- `textWeak`: `rgba(255,255,255,0.50)`，弱化信息
- `interactiveAccent`: `#64C8FF`，主交互强调色
- `success`: `#4CAF50`
- `warning`: `#FFB74D`
- `error`: `#FF6464`
- `info`: `#64C8FF`
- `heroScrim`: 从 `rgba(3,8,12,0.04)` 到 `rgba(3,8,12,0.90)` 的底部加重渐变

天空蓝 MAY 作为交互强调色，自然绿 MAY 作为户外状态色，但两者 MUST NOT 被用作大面积页面底色。

#### Scenario: 使用页面基础背景

- **WHEN** 页面没有 Hero 影像覆盖
- **THEN** 页面 SHALL 通过 `AppColors.bgBase` 获取背景色

#### Scenario: 使用图片遮罩

- **WHEN** 页面在 Hero 影像上叠加内容
- **THEN** 页面 SHALL 使用 `AppColors.heroScrim`
- **THEN** 页面 MUST NOT 在业务代码中硬编码遮罩颜色

#### Scenario: 使用语义状态色

- **WHEN** 页面显示成功、警告、错误或信息状态
- **THEN** 页面 SHALL 使用对应语义色
- **THEN** 状态色 SHALL 在暗色背景和图片遮罩上保持可辨识

### Requirement: Design Token - Typography

应用 SHALL 提供以下语义字体 Token，并使用项目已注册的 `NotoSansSC` 字体权重：

- `heroTitle`: 48sp / w700 / line-height 1.0，用于全屏封面核心标题
- `heroSubtitle`: 16sp / w400 / line-height 1.4，用于封面辅助信息
- `displayTitle`: 32sp / w700 / line-height 1.1，用于内容页大标题
- `pageTitle`: 28sp / w700 / line-height 1.2，用于普通页面主标题
- `sectionTitle`: 20sp / w600 / line-height 1.3，用于 Section 标题
- `cardTitle`: 18sp / w600 / line-height 1.3，用于工具型卡片标题
- `bodyLarge`: 16sp / w400 / line-height 1.5
- `body`: 15sp / w400 / line-height 1.5
- `caption`: 13sp / w400 / line-height 1.5
- `label`: 12sp / w500 / line-height 1.3
- `metricValue`: 18sp / w600，使用等宽数字特性
- `metricUnit`: 12sp / w400

#### Scenario: Hero 页面标题

- **WHEN** 内容型页面在封面影像上展示核心标题
- **THEN** 页面 SHALL 使用 `AppTypography.heroTitle`
- **THEN** 标题 SHALL 支持最多两行、紧凑行高和图片遮罩配合
- **THEN** 可用宽度不足 360dp 时 SHALL 使用受控缩放，但字号 MUST NOT 小于 40sp

#### Scenario: 工具型页面标题

- **WHEN** 工具型页面展示页面或 Section 标题
- **THEN** 页面 SHALL 使用 `pageTitle` 或 `sectionTitle`
- **THEN** 页面 MUST NOT 使用 `heroTitle` 制造无意义的视觉权重

### Requirement: Design Token - Spacing

应用 SHALL 使用 4dp 基础网格，并提供 `xs=4`、`sm=8`、`md=12`、`lg=16`、`xl=24`、`xxl=32`、`xxxl=48` 和 `hero=80` 的唯一基础间距刻度。语义间距 SHALL 包含 `pageHorizontal=16`、`heroHorizontal=20`、`componentPadding=16`、`listItemGap=12` 和 `sectionGap=24`。安全区 MUST 从 `MediaQuery.viewPadding` 或 `SafeArea` 获取，不得使用固定高度 Token 模拟设备安全区。

#### Scenario: 页面水平边距

- **WHEN** 页面布局工具型普通内容
- **THEN** 页面 SHALL 使用 `AppSpacing.pageHorizontal`
- **WHEN** 页面布局 Hero 叠层内容
- **THEN** 页面 SHALL 使用 `AppSpacing.heroHorizontal`
- **THEN** 业务页面 MUST NOT 自行定义新的基础页面边距

#### Scenario: 适配设备安全区

- **WHEN** 页面在不同设备或方向显示
- **THEN** 页面 SHALL 使用系统提供的真实安全区数据
- **THEN** 页面 MUST NOT 使用固定的顶部或底部安全区高度

### Requirement: Design Token - Radius

应用 SHALL 提供 `none=0`、`small=8`、`control=12`、`panel=16`、`overlay=24` 和 `full=9999` 的唯一语义圆角。圆角 SHALL 根据组件语义选择，而不是由业务页面任意指定。

#### Scenario: 毛玻璃操作

- **WHEN** 页面展示悬浮毛玻璃操作
- **THEN** 普通操作 SHALL 使用 `AppRadius.control`
- **THEN** 圆形操作 SHALL 使用 `AppRadius.full`

#### Scenario: 普通暗色面板

- **WHEN** 工具型页面展示信息面板
- **THEN** 组件 SHALL 使用 `AppRadius.panel`

#### Scenario: 大型悬浮信息层

- **WHEN** 沉浸式页面在大图上展示大型信息层
- **THEN** 组件 SHALL 使用 `AppRadius.overlay`

### Requirement: 主题配置

应用 SHALL 以暗色主题作为默认且唯一受支持的视觉基准，统一配置 Cupertino 主题以及实际使用的 Material 控件主题。主题入口 SHALL 引用同一组 Design Token，不得存在名为亮色但实际指向暗色的兼容主题。

#### Scenario: 应用启动

- **WHEN** 应用启动
- **THEN** 根应用 SHALL 安装统一暗色主题
- **THEN** Cupertino 与 Material 控件 SHALL 使用一致的颜色、文字和交互语义

### Requirement: 禁止硬编码样式

所有生产 UI 代码 MUST 通过 Design Token 或公共组件表达颜色、基础间距、字体层级、圆角、阴影、模糊和动效。只有无法形成稳定语义的几何计算值或绘制坐标 MAY 保留局部数值，并应通过上下文说明用途。

#### Scenario: 业务页面直接声明样式

- **WHEN** Code Review 发现业务页面直接声明可由现有 Token 表达的颜色或样式值
- **THEN** 该变更 SHALL 被标记为需要修改

#### Scenario: 现有 Token 无法表达需求

- **WHEN** 新设计确实需要新的跨页面语义值
- **THEN** 开发者 SHALL 先更新 Design Token 与 Spec
- **THEN** 开发者 MUST NOT 以页面私有常量绕过设计系统

### Requirement: 信息架构 - 三层结构

应用 SHALL 保持概览、列表和详情三层信息架构。概览层 SHALL 以低信息密度突出关键内容和快捷操作；列表层 SHALL 展示多项内容的核心参数并支持扫描比较；详情层 SHALL 展示完整信息和深入操作。视觉表达 SHALL 根据页面意图选择 `immersive` 或 `utility` 模式。

#### Scenario: 用户浏览路线

- **WHEN** 用户进入路线发现概览
- **THEN** 页面 SHALL 优先展示一个全屏封面式路线主体及 1 至 3 个核心指标
- **WHEN** 用户进入可比较的路线列表
- **THEN** 每个路线项 SHALL 显示名称、距离、海拔、难度等核心参数
- **WHEN** 用户进入路线详情
- **THEN** 页面 SHALL 使用 Hero、地图或领域主视觉承载首屏
- **THEN** 页面 SHALL 提供概览、分段、地图和评论等完整信息入口

### Requirement: 页面布局 - 列表页布局

列表页 SHALL 包含导航、可选的筛选或分段控制、可滚动列表和可选的主操作入口，并根据内容比较需求选择沉浸式分页列表或工具型标准列表。列表页 SHALL 支持下拉刷新、分页加载以及业务需要的筛选和搜索。以目的地、路线、攻略为主体时 SHOULD 使用大图主导的列表；以编辑、管理和快速扫描为主体时 SHALL 使用工具型暗色列表。

#### Scenario: 路线发现列表

- **WHEN** 用户以发现和浏览为目的查看路线
- **THEN** 页面 SHALL 使用大图主导的沉浸式列表或全屏分页
- **THEN** 每个主体 SHALL 只展示做出进入详情决策所需的有限指标
- **WHEN** 用户执行下拉刷新、分页加载、筛选或搜索
- **THEN** 页面 SHALL 保持相应功能可用

#### Scenario: 装备管理列表

- **WHEN** 用户以管理和操作为目的查看装备
- **THEN** 页面 SHALL 使用工具型暗色列表
- **THEN** 页面 SHALL 优先保证扫描、选择和编辑效率

### Requirement: 页面布局 - 详情页布局

详情页 SHALL 使用领域主视觉加暗色内容区的结构。主视觉 MAY 为全屏封面图、地图或其他与业务直接相关的可视内容；导航和主要操作 SHALL 叠加在主视觉上或使用统一悬浮层。详细信息 SHALL 在滚动后的暗色区域、Bottom Sheet 或工具型子页面中展示。详情页 SHALL 保留业务需要的 Tab、可折叠 Header、吸顶内容和底部主操作。

#### Scenario: 路线详情页

- **WHEN** 用户进入具有有效封面的路线详情
- **THEN** 页面 SHALL 以封面图或地图作为首屏主体
- **THEN** 路线名称、难度和总距离等核心指标 SHALL 与主视觉形成清晰层级
- **THEN** 页面 SHALL 提供概览、分段、地图和评论等切换能力
- **THEN** 完整分段、补给和评论信息 SHALL 在后续内容区展示
- **THEN** 页面 SHALL 保留“开始导航”等主操作
- **WHEN** 用户滚动详情内容
- **THEN** Header MAY 折叠且 Tab MAY 吸顶，但业务内容和操作 MUST 保持可达

## REMOVED Requirements

### Requirement: 页面布局 - 仪表盘布局

**Reason**: 固定的欢迎区、统计卡片区和多内容区块仪表盘与确定的全屏封面式首页方向冲突。

**Migration**: 首页迁移为单一主视觉主体；次级数据和入口通过叠层、滑动或后续页面承载。

#### Scenario: 迁移旧首页仪表盘

- **WHEN** 旧首页仍使用多个同权重统计卡片和模块入口
- **THEN** 实现 SHALL 迁移到沉浸式首页骨架

### Requirement: 组件规范 - 统计卡片 (StatCard)

**Reason**: 固定白色背景和仪表盘用途不再是全局设计系统要求。

**Migration**: 指标展示迁移到统一 `MetricGroup`；工具型页面确有需要时可使用暗色数据面板。

#### Scenario: 迁移统计值展示

- **WHEN** 页面需要展示距离、海拔或时长
- **THEN** 页面 SHALL 使用统一指标组或工具型数据面板

### Requirement: 组件规范 - 数据卡片 (DataCard)

**Reason**: 固定缩略图加白色卡片的结构与沉浸式内容页方向冲突，且无法覆盖工具型列表和全屏封面列表两类需求。

**Migration**: 内容发现使用 Hero 或大图列表组件；管理操作使用工具型暗色列表组件。

#### Scenario: 迁移路线卡片

- **WHEN** 旧路线列表使用固定白色 DataCard
- **THEN** 页面 SHALL 根据使用意图迁移到沉浸式大图项或工具型暗色列表项
