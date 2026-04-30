# Change: 路线详情 Section 布局与视觉优化

## Why

现有 section 布局存在视觉层级不清晰的问题：
- 所有 section 使用统一的浅灰背景（#F8FAFC），缺乏视觉区分
- RouteStatsCardWidget（核心数据卡片）的视觉优先级不够突出
- Section 之间的信息密度相同，用户难以快速识别关键内容

根据用户实际使用流程，路线详情的交互为：
1. **初始状态**（刚进入）：半屏展示 → 用户看到主数据卡片是焦点
2. **最小化**（向下滑动）：section 完全隐藏 → 地图全屏
3. **展开**（向上滑动）：section 全屏 → 展示详细内容

为了优化用户体验，需要：
- 主数据卡片（RouteStatsCardWidget）采用**深色背景**，视觉上突出为优先级最高的内容
- 改进 section 的**布局紧凑性**和**信息呈现方式**
- 确保 section 容器的样式与主数据卡片形成对比，但不破坏现有功能

## What Changes

### 1. RouteStatsCardWidget 升级

**布局调整**：
- 背景色：从浅灰 (#F8FAFC) 改为深色 (#1C1C1E)
- 文字颜色：调整为白色或浅色，确保对比度
- 布局优化：改为紧凑的网格排列，更有层次感
  - 第一行：主要指标（距离）大字突出
  - 分隔线
  - 第二行：三列网格（时间、爬升、下降）
  - 分隔线
  - 第三行：难度信息

**影响范围**：
- 主要修改 `route_stats_card_widget.dart`
- 保持所有数据字段不变（距离、时间、爬升、下降、难度）
- 仅调整视觉呈现方式

### 2. RouteInfoSheetWidget 容器样式调整

**特殊处理主数据卡片**：
- RouteStatsCardWidget（第一个 section）不使用通用的浅灰卡片包装
- 其他 section 仍然保持浅灰卡片样式，与主数据卡片形成对比
- 或者统一深色背景（可选方案）

**实现方式**：
- 修改 `route_info_sheet_widget.dart` 中的 `_buildSectionCards()` 方法
- 对第一个 section（主数据卡片）进行特殊处理
- 其他 section 保持现有样式

### 3. 交互体验保持不变

- 拖拽交互：完全保持现有行为
- Section 展开/折叠：不变
- 内容顺序：不变
- 所有功能：不变

## Impact

**受影响的规范**：
- `route-detail-ui`（补充 section 样式层级要求）

**受影响的代码**：
- `lib/ui/page/route/detail/widgets/route_stats_card_widget.dart`（主要修改）
- `lib/ui/page/route/detail/widgets/route_info_sheet_widget.dart`（容器处理）

**不受影响的代码**：
- `route_detail_screen.dart`（无需修改）
- 其他 section widgets（无需修改）

## Questions & Assumptions

1. **主数据卡片深色背景**是否使用 `#1C1C1E`（标准深灰），还是其他色值？
2. **其他 section** 是否保持现有浅灰样式，还是改为统一深色？
3. **logo 和头像**是否需要添加到主数据卡片顶部？

