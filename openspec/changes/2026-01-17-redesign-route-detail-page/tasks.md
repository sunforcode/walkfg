# Route Detail Page Redesign - Task Breakdown

**Status**: Planning  
**Last Updated**: 2026-01-17  
**Latest Update**: 根据每日行程优先级调整，路线分段为辅助信息

## Task Overview

本项目分为 4 个阶段，共计 15+ 个具体任务。信息架构优先级调整为：每日行程（核心） > 营地/水源/补给点（重要） > 路线分段详情（参考）。

---

## Phase 1: 规范和原型设计 (已完成)

### Tasks

- [x] 创建 OpenSpec 提案文档
- [x] 创建详细的页面布局规范 (`route-detail-layout/spec.md`)
- [x] 创建设计文档 (`design.md`)
- [ ] 设计原型和交互流程图（可选）

---

## Phase 2: 核心组件实现

### Task 2.1: 创建 ExpandableSection 组件

**目标**: 实现可展开/折叠的卡片组件

**具体工作**:
- [ ] 创建 `expandable_section.dart` 文件
- [ ] 实现以下功能:
  - 标题区点击展开/折叠
  - 箭头旋转动画（0° → 90°）
  - 内容高度变化动画（300ms，easeInOut）
  - 支持自定义图标、标题、内容
  - 支持初始展开/折叠状态
  - 支持禁用状态
- [ ] 添加必要的样式 Token 引用
- [ ] 编写单元测试

**文件**: `lib/ui/page/route/detail/widgets/expandable_section.dart`

**设计规范参考**: `specs/route-detail-layout/spec.md` - Requirement: 可折叠分类卡片组件

---

### Task 2.2: 改进地图区域组件

**目标**: 支持半固定、可展开的地图区域

**具体工作**:
- [ ] 改进 `_buildMapSection()` 方法
  - 支持地图高度动态变化（350dp → 600dp 可展开）
  - 地图滚动时逐渐变小（折叠）
  - 实现 sticky 效果（地图不完全消失）
- [ ] 添加地图展开/收起手势识别
- [ ] 确保 2D/3D 切换按钮位置合理
- [ ] 性能优化：地图瓦片缓存

**文件**: `lib/ui/page/route/detail/route_detail_screen.dart`

**设计规范参考**: `specs/route-detail-layout/spec.md` - Requirement: 页面布局结构

---

### Task 2.3: 创建地图-信息联动管理器

**目标**: 管理地图与列表项的单向交互（信息 → 地图）

**具体工作**:
- [ ] 创建 `map_info_coordinator.dart` 工具类
- [ ] 实现以下功能:
  - 点击列表项时，地图缩放并高亮对应标记点
  - 管理高亮状态和动画时长
  - 支持多种标记点类型（营地、水源、补给点等）
- [ ] 创建对应的 Model 类（如 `HighlightInfo`）

**文件**: 
- `lib/ui/page/route/detail/map_info_coordinator.dart`
- `lib/model/route/map_interaction_model.dart`

**设计规范参考**: `specs/route-detail-layout/spec.md` - Requirement: 地图-信息联动

---

## Phase 3: 页面和子组件重构

### Task 3.1: 重构 RouteDetailScreen

**目标**: 整合新的布局结构，使用 ExpandableSection 替代 Tab 栏

**具体工作**:
- [ ] 重构 `route_detail_screen.dart` 主页面
  - 移除或隐藏 Tab 栏逻辑
  - 使用 ExpandableSection 包装各个分类卡片
  - 集成地图-信息联动逻辑
  - **优先级调整**: 调整分类卡片顺序为：
    1. 页面概览 (RouteOverviewWidget) - 展开
    2. **每日行程** (DailyItineraryListWidget) - 展开 ⭐ (核心)
    3. 营地信息 (CampsitesWidget) - 展开 ⭐
    4. 水源信息 (WaterSourcesWidget) - 展开 ⭐
    5. 补给点 (SupplyPointsWidget) - 展开 ⭐
    6. 路线分段详情 (RouteSegmentsWidget) - 收起 (参考信息)
    7. 季节装备建议 (SeasonalEquipmentWidget) - 收起
  - 调整布局：地图 → 标题 → 可折叠分类卡片 → 操作栏
- [ ] 确保所有 padding 和 spacing 使用 Design Token
- [ ] 移除所有硬编码样式值
- [ ] 确保页面滚动流畅

**文件**: `lib/ui/page/route/detail/route_detail_screen.dart`

**预期行数**: 保持在 400-500 行以内

---

### Task 3.2: 调整 RouteOverviewWidget

**目标**: 适配新的布局，确保作为可展开的概览分类卡片

**具体工作**:
- [ ] 改进 `route_overview_widget.dart`
  - 调整内容布局（可使用网格或两列排列）
  - 确保充分利用空间
  - 遵循设计规范的字体和颜色
- [ ] 测试展开/折叠时的显示效果

**文件**: `lib/ui/page/route/detail/widgets/route_overview_widget.dart`

---

### Task 3.3: 调整日程卡片和其他子组件

**目标**: 使各个子组件适配可折叠结构

**优先级顺序**:

1. **⭐ 高优先级 (立即调整)**
   - [ ] `daily_itinerary_list_widget.dart` - 核心组件，适配可折叠格式
     - 改进样式，去除硬编码
     - 创建 `DailyItineraryTimelineWidget` 以提升视觉层级
     - 支持列表项点击地图交互
   - [ ] `campsites_widget.dart` - 支持列表项点击高亮和地图联动
   - [ ] `water_sources_widget.dart` - 支持列表项点击高亮和地图联动
   - [ ] `supply_points_widget.dart` - 支持列表项点击高亮和地图联动

2. **⭐ 中优先级 (后续调整)**
   - [ ] `route_segments_widget.dart` - 作为参考信息，默认收起

3. **普通优先级 (完善)**
   - [ ] `seasonal_equipment_widget.dart` - 适配可折叠格式
   - [ ] 其他相关组件的微调

**目标**: 所有组件均使用 Design Token，无硬编码值

---

### Task 3.4: 创建列表项交互组件

**目标**: 为需要地图交互的列表项创建统一的组件

**具体工作**:
- [ ] 创建 `daily_itinerary_item.dart` 组件 ⭐ (核心)
  - 支持点击反馈（scale 动画）
  - 支持高亮状态
  - 点击时触发地图交互
- [ ] 创建 `campsite_item.dart` 组件 ⭐
  - 支持点击反馈（scale 动画）
  - 支持高亮状态
  - 点击时触发地图交互
- [ ] 创建 `water_source_item.dart` 组件 ⭐
  - 同上
- [ ] 创建 `supply_point_item.dart` 组件 ⭐
  - 同上
- [ ] 为这些组件添加统一的样式 mixin 或基类

**文件**: `lib/ui/page/route/detail/widgets/item_components/`

---

## Phase 4: 测试、优化和完善

### Task 4.1: 功能测试

**目标**: 确保所有功能正常运作

**具体工作**:
- [ ] 展开/折叠分类卡片
  - 验证动画流畅性
  - 验证箭头旋转
  - 验证状态保持（用户展开卡片，滚动后返回仍展开）
  - 验证初始状态符合优先级（每日行程/营地/水源/补给点默认展开，其他默认收起）
- [ ] 地图交互
  - 地图缩放/平移
  - 标记点高亮
  - 2D/3D 切换
- [ ] 列表项交互
  - 点击反馈
  - 地图高亮
  - 分类卡片自动展开（点击收起的卡片中的项时）
- [ ] 页面滚动
  - 地图逐渐变小
  - 标题吸顶
  - 无明显卡顿

---

### Task 4.2: 性能优化

**目标**: 优化页面加载速度和滚动帧率

**具体工作**:
- [ ] 分析页面加载性能
  - 地图加载时间
  - 数据渲染时间
- [ ] 实现列表虚拟化（如果列表项过多）
- [ ] 优化地图缓存策略
- [ ] 优化图片加载和缓存
- [ ] 性能测试：确保滚动帧率 > 50fps
- [ ] 使用 Flutter DevTools 检查过度重建

---

### Task 4.3: UI 细节调整

**目标**: 完善视觉细节，确保符合设计规范

**具体工作**:
- [ ] 验证所有颜色使用 Design Token
- [ ] 验证所有字体样式符合规范
- [ ] 验证所有间距使用 AppSpacing Token
- [ ] 验证所有圆角使用 AppRadius Token
- [ ] 验证所有阴影使用 AppShadows Token
- [ ] 检查无内容状态的占位符显示
- [ ] 验证不同屏幕尺寸下的显示效果

---

### Task 4.4: 可访问性测试

**目标**: 确保应用符合可访问性标准

**具体工作**:
- [ ] 验证 VoiceOver 支持
- [ ] 检查所有可交互元素的最小点击区域（44×44dp）
- [ ] 验证色彩对比度
- [ ] 测试减少运动设置下的动画表现

---

### Task 4.5: 文档和注释

**目标**: 为代码添加清晰的文档和注释

**具体工作**:
- [ ] 为主要类和方法添加文档注释
- [ ] 为复杂逻辑添加行内注释
- [ ] 更新项目 README 中的设计系统部分
- [ ] 创建组件使用示例文档

---

## Task Dependencies

```
Task 2.1: ExpandableSection
    ↓
Task 2.2: 地图区域
    ↓
Task 2.3: 地图-信息联动
    ↓
Task 3.1: RouteDetailScreen (依赖 2.1, 2.2, 2.3)
    ↓
Task 3.2: RouteOverviewWidget
    ↓
Task 3.3: 子组件调整 (优先级: 每日行程 > 营地/水源/补给点 > 其他)
    ↓
Task 3.4: 列表项交互组件 (与 3.3 并行)
    ↓
Task 4.1-4.5: 测试和优化 (串行 → 并行)
```

---

## Effort Estimation

| 阶段 | 任务数 | 预期工作量 | 所需时间 |
|------|--------|----------|--------|
| Phase 1 | 4 | 完成 | ✓ |
| Phase 2 | 4 | 高 | 6-8 小时 |
| Phase 3 | 4 | 高 | 10-14 小时 (每日行程优先) |
| Phase 4 | 5 | 中 | 4-6 小时 |
| **总计** | **17** | - | **20-28 小时** |

---

## Success Metrics

- [ ] 页面完全移除 Tab 栏交互
- [ ] 所有分类卡片可展开/折叠，动画流畅
- [ ] 地图与列表项实现单向联动（信息 → 地图）
- [ ] 页面无硬编码样式值，100% 使用 Design Token
- [ ] 每日行程、营地、水源、补给点默认展开（高优先级信息）
- [ ] 路线分段详情默认收起（参考信息）
- [ ] 页面滚动帧率 ≥ 50fps
- [ ] 符合项目的代码规范和注释要求
- [ ] 用户反馈积极

---

## Review Checklist

完成后需要进行以下检查：

- [ ] 代码格式化 (`flutter format .`)
- [ ] 静态分析通过 (`flutter analyze`)
- [ ] 单元测试通过 (`flutter test`)
- [ ] Widget 大小合理（<150 行单个文件）
- [ ] 所有样式值使用 Design Token
- [ ] 添加必要的文档注释
- [ ] 优先级信息架构符合预期
- [ ] 提交 Code Review

---

## Appendix: Related Files

### 需要修改的文件

- `lib/ui/page/route/detail/route_detail_screen.dart` (重构)
- `lib/ui/page/route/detail/widgets/route_overview_widget.dart` (调整)
- `lib/ui/page/route/detail/widgets/daily_itinerary_list_widget.dart` (调整 ⭐)
- `lib/ui/page/route/detail/widgets/campsites_widget.dart` (调整 ⭐)
- `lib/ui/page/route/detail/widgets/water_sources_widget.dart` (调整 ⭐)
- `lib/ui/page/route/detail/widgets/supply_points_widget.dart` (调整 ⭐)
- `lib/ui/page/route/detail/widgets/route_segments_widget.dart` (调整)
- 其他相关组件

### 需要新建的文件

- `lib/ui/page/route/detail/widgets/expandable_section.dart` (新组件)
- `lib/ui/page/route/detail/map_info_coordinator.dart` (协调器)
- `lib/model/route/map_interaction_model.dart` (模型)
- `lib/ui/page/route/detail/widgets/item_components/daily_itinerary_item.dart` ⭐
- `lib/ui/page/route/detail/widgets/item_components/campsite_item.dart` ⭐
- `lib/ui/page/route/detail/widgets/item_components/water_source_item.dart` ⭐
- `lib/ui/page/route/detail/widgets/item_components/supply_point_item.dart` ⭐

### 参考文件

- `openspec/specs/design-system/spec.md` - Design Token 规范
- `openspec/project.md` - 项目背景
- `lib/theme/tokens/` - 设计系统实现

---

## Version History

| 版本 | 日期 | 变更 |
|------|------|------|
| 1.0 | 2026-01-17 | 初始版本 |
| 1.1 | 2026-01-17 | 根据每日行程优先级调整任务顺序和优先级 |
