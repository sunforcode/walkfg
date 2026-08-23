## Context

Walk 当前的首页已经形成可辨识的视觉原型：深色基底、全屏构图、路线或山野视觉作为主体、信息直接叠加、较大的标题、弱化容器边界和毛玻璃操作。其他模块仍以传统卡片和系统默认控件为主，导致同一 App 内出现多套视觉语言。

本变更需要解决的不是单页美化，而是建立长期可执行的约束：设计规范必须与运行代码一致；公共组件必须覆盖高频视觉原语；Agent 必须在写 UI 前主动查找并优先使用这些组件。

## Goals / Non-Goals

Goals:

- 将“全屏封面式大图”确立为 Walk 内容型页面的主视觉模式。
- 为不适合大图的工具型页面提供同源暗色模式，而不是强行套用 Hero 图。
- 让 Design Token、主题、公共组件、页面实现和 Agent 工作流指向同一标准。
- 通过少量语义明确的公共组件减少重复实现和视觉漂移。
- 支持渐进迁移，避免一次性重写带来的业务风险。

Non-Goals:

- 本变更不改变业务流程、接口、数据模型或导航信息架构。
- 不要求每个页面都使用背景图片。
- 不建立重量级组件库、可视化搭建平台或动态主题编辑器。
- 不创建参数无限增长的万能卡片或万能页面组件。
- 不在提案阶段确定所有页面的像素级设计稿。

## Decisions

### Decision 1: 以页面意图区分沉浸式页面和工具型页面

内容型页面使用 `immersive` 模式：影像占据首屏主体或全屏，标题和核心信息叠加在影像上，卡片仅作为必要的信息层出现。典型页面包括首页、路线发现、路线详情、攻略和行程入口。

工具型页面使用 `utility` 模式：使用统一暗色背景、导航、文字、输入、列表和状态组件，优先保证扫描效率与编辑效率，不强制引入无业务意义的大图。典型页面包括装备编辑、设置、表单和高密度数据页。

这样既保持品牌统一，又避免为了形式牺牲可用性。

### 页面模式与迁移基线

以下基线只落实 `immersive` / `utility` 两类页面。Route Detail 的全屏地图是已确认的 `immersive` 领域主视觉例外；其他内容型页面默认使用与内容直接相关的封面大图。迁移按“基准与样本 → 视觉断层模块 → 其余页面”推进，不使用额外优先级标签。

第一阶段基准与样本包括：Home 作为现有 `immersive` 基准；Route Discovery 作为第二个 `immersive` 验证场景；Equipment List 与 Equipment Detail 作为两个 `utility` 验证场景。稳定结构经过这些真实场景验证后才晋升公共组件。

第二阶段优先处理视觉断层：Trip List 和 Trip Detail 归入 `immersive`，使用行程封面大图；Trip Create、Trip Edit、Trip Gear List、Trip Gear Detail 和 Trip Gear Create 归入 `utility`。Guide List 和 Guide Detail 归入 `immersive`，使用攻略封面大图；攻略正文和操作区进入暗色内容区。

后续页面按明确归属收敛：Route Detail 归入 `immersive` 并保留全屏地图；Weather、Profile、Search、Calendar、登录、注册和找回密码归入 `utility`。天气内容可以使用强调型数据区，但不扩展新的页面模式，也不以数据替代已确认的大图主视觉规则。

各模块当前迁移方向如下：Home 保留全屏构图并逐步复用统一 Hero、标题、指标、毛玻璃操作和异步状态；Route Discovery 从缩略图卡片列表迁移为大图主导列表或全屏分页；Route Detail 收敛悬浮导航、指标层和暗色内容 Sheet；Trip 清理亮色卡片与 Sheet Token 误用；Guide 清理页面私有样式；Equipment、Weather、Profile、Search、Calendar 与账户页面统一工具型暗色骨架、导航和状态组件。

### Decision 2: 大图是结构，不是装饰

Hero 影像必须承担地点、路线、行程或攻略内容表达，不能使用与内容无关的装饰图。图像容器负责裁剪、加载、失败占位和焦点区域；遮罩负责保证文字对比度；内容叠层负责标题、标签、指标和主操作。

默认优先采用全屏封面布局：单屏单主体、标题尺度显著大于普通页面标题、底部渐变承载信息、非必要卡片隐藏。编辑式大图和大图加悬浮信息层作为受控变体，而不是新的独立风格。

### Decision 3: 公共组件按视觉原语和页面骨架分层

基础层提供语义 Token 和低层视觉原语，例如影像、遮罩、毛玻璃、按压反馈、文字层级、间距和安全区。

组合层提供可复用组件，例如 `ImmersiveHero`、`HeroTitleOverlay`、`MetricGroup`、`GlassAction`、`AppNavigationBar`、`AsyncStateView` 和 `AppNetworkImage`。

页面骨架层提供 `ImmersivePageScaffold` 与 `UtilityPageScaffold`，统一安全区、背景、导航和滚动边界，但不承载业务数据或业务分支。

业务组件继续位于业务目录，通过组合公共组件表达领域内容。只有经过两个以上真实使用场景验证的模式才晋升为公共组件。

### Decision 4: 受控变体优于页面复制，也优于万能组件

公共组件只暴露有明确语义的变体，例如 Hero 的 `fullBleed`、`editorial`、`layered`，按钮的 `primaryGlass`、`secondaryGlass`、`danger`。调用方不得传入任意颜色、任意圆角和任意阴影来重新定义组件风格。

当现有组件不能覆盖需求时，Agent 应优先判断是扩展已有受控变体，还是保留为业务局部组件；不得仅因局部尺寸差异复制整套实现。

### Decision 5: Agent 工作流成为可验证的工程规则

固定顺序为：读取设计 Spec → 识别页面类型 → 搜索公共组件 → 选择组合或受控扩展 → 编写失败测试或视觉契约测试 → 实现 → 检查硬编码和重复模式 → 执行聚焦验证。

Agent 在提案或报告中必须说明复用了哪些公共组件、为何新增组件、是否引入新的 Token。代码审查应将绕过公共组件、无理由硬编码样式和创建重复异步状态视图视为问题。

仅靠提示词不能完全保证执行，因此实现阶段还应补充可机器检查的约束，包括 Widget 测试、静态搜索或自定义 lint 可行性评估。第一阶段不强制引入新的 lint 依赖，先用测试和仓库规则形成闭环。

## 现有公共 UI 审计

第一阶段审计确认仓库已经具备可复用原语，应优先扩展而不是平行新建。`SectionHeader` 作为标准标题与操作行，只在补充测试后增加语义暗色上下文。`NetworkImageWithFallback` 已负责缓存、加载、失败、适配与裁剪；缩略图、Hero 和头像应形成受控变体，而 Hero 遮罩继续由上层组合负责。`LoadingIndicator`、`ErrorMessageWidget` 和 `EmptyContentWidget` 是首选状态视觉；功能重叠的 `LoadingView` 与 `ErrorView` 不再新增调用。`AsyncContentBuilder` 可保留现有 Future 场景，但不作为统一状态所有者。

Home 与 Route Discovery 继续作为沉浸式骨架的两个组合样本，Equipment List 与 Equipment Detail 继续作为工具型骨架的两个组合样本。当前结构尚不足以提前抽取新的 Scaffold 类。Home 品牌化加载、错误与空态、Route Discovery 骨架、Guide 操作栏、路线操作栏和地图控件继续保留为业务组合；其中共享的图片、状态内容、毛玻璃表面和按压反馈原语，只有在测试和双场景验证后才允许抽取。

## Risks / Trade-offs

大图对内容资源质量依赖较高。缓解方式是统一裁剪、焦点区域、占位图、失败态和遮罩规则，并允许无图时退化到抽象山形或暗色渐变，而不是显示破损图片。

沉浸式页面的信息密度较低。缓解方式是仅在内容型入口和 Hero 区使用，详细数据通过滚动后的暗色内容区、Bottom Sheet 或工具型子页面承载。

毛玻璃可能带来性能成本。缓解方式是限制模糊层数量与覆盖面积，提供低性能平台的半透明实色降级，并在实现阶段进行 profile 验证。

一次性迁移所有页面风险较高。缓解方式是先落地基础设施和代表性页面，再按 Trip、Guide、普通页面导航与状态组件顺序迁移。

## Migration Plan

第一阶段校准 Spec、Token 与主题入口，删除亮色默认主题的规范冲突，建立暗色语义基线。

第二阶段建立页面骨架和高频公共组件，并通过独立 Widget 测试固定视觉契约和交互状态。

第三阶段以 Home 与 Route Discovery 验证 `immersive` 模式，以 Equipment List 与 Equipment Detail 验证 `utility` 模式。

第四阶段迁移 Trip 和 Guide，收敛导航、卡片、标题、网络图片和异步状态重复实现。

第五阶段审计剩余页面，只有在公共组件与代表页面稳定后再移除遗留 Token 和兼容别名。

## Open Questions

- 真实封面图的来源、版权和离线缓存策略需要在具体页面实施前确认。
- 是否在后续单独引入 Golden Test 基线，需要根据现有 CI 对字体和平台渲染稳定性的验证结果决定。
