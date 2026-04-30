# Design: 路线详情 Section 布局与视觉优化

## Context

路线详情页面已实现"地图全屏 + 底部可上滑抽屉"的布局。现阶段用户反馈显示：
- 所有 section 视觉层级相同，主数据卡片（核心路线统计）的优先级不够突出
- 用户在快速浏览时难以快速定位关键信息（距离、时长、爬升）

根据现代运动和旅游应用（如 Strava、AllTrails 等）的设计模式，应将核心统计数据突出显示，使用对比明显的视觉样式。

## Goals

- 提升主数据卡片（RouteStatsCardWidget）的视觉优先级
- 保持所有现有功能和交互行为不变
- 优化 section 布局，使信息呈现更紧凑、更有层次感
- 改善用户快速浏览体验

## Non-Goals

- 修改任何 section 的内容或功能
- 添加新的数据字段或数据源
- 改变拖拽交互或快照点行为
- 修改其他 widgets

## Decisions

### 1. 主数据卡片深色背景

**决策**：RouteStatsCardWidget 使用深色背景 (#1C1C1E)，文字为白色/浅色

**理由**：
- 创建明显的视觉对比，突出核心信息
- 符合现代 UI 设计（深浅对比）
- 提升用户对关键数据的感知

**实现**：
- 直接修改 widget 内部的背景色和文字色
- 不需要外部容器包装

### 2. 其他 Section 样式处理

**决策**：其他 section 保持浅灰背景（#F8FAFC），与主数据卡片形成对比

**理由**：
- 保持现有的视觉一致性
- 主卡片通过深色背景自然地脱颖而出
- 降低重构范围

**替代方案**（可选）：
- 将所有 section 改为深色背景
  - 优点：统一设计语言
  - 缺点：工作量大，需修改所有 section widgets

### 3. 布局改进方案

**决策**：RouteStatsCardWidget 改为紧凑的网格布局

**当前布局结构**：
```
[距离]（大字）
[时间 | 爬升 | 下降]
[难度信息]
```

**改进后布局结构**：
```
┌─────────────────────────┐
│ 距离    xx.xx km        │  ← 主要指标（大字突出）
├─────────────────────────┤
│ 时间    │ 爬升    │ 下降 │  ← 三列网格
├─────────────────────────┤
│ 难度: 中等  | 区域信息   │  ← 附加信息
└─────────────────────────┘
```

**实现细节**：
- 第一行：距离数据单独占一行，字号更大（40px）
- 分隔线：使用 1px 白色透明分割线
- 第二行：使用 Row + Expanded 实现三列等宽网格
- 第三行：难度和区域信息

### 4. RouteInfoSheetWidget 容器处理

**决策**：特殊处理第一个 section（主数据卡片），不应用通用卡片包装

**实现**：
- 修改 `_buildSectionCards()` 方法
- 检查当前 section 是否为第 0 个（主数据卡片）
- 第 0 个：直接使用 widget，不包装
- 其他的：使用现有卡片包装（浅灰背景、圆角、阴影）

**代码逻辑**：
```dart
for (int i = 0; i < widget.sections.length; i++) {
  if (i == 0) {
    // 主数据卡片：直接添加，不包装
    cards.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: widget.sections[i],
      ),
    );
  } else {
    // 其他 section：使用卡片包装
    cards.add(
      Container(
        decoration: BoxDecoration(...),
        child: widget.sections[i],
      ),
    );
  }
}
```

## Architecture

### 修改的组件

#### RouteStatsCardWidget
- **位置**：`lib/ui/page/route/detail/widgets/route_stats_card_widget.dart`
- **修改内容**：
  1. 背景色改为深色 #1C1C1E
  2. 所有文字改为白色或浅色
  3. 布局改为网格式（分隔线 + 多行）
  4. 保留所有数据字段

#### RouteInfoSheetWidget
- **位置**：`lib/ui/page/route/detail/widgets/route_info_sheet_widget.dart`
- **修改内容**：
  1. `_buildSectionCards()` 方法添加特殊处理
  2. 第 0 个 section 不使用卡片包装
  3. 其他 section 保持不变

### 不修改的组件

- RouteDetailScreen（不需要修改）
- 所有其他 section widgets（不需要修改）
- 拖拽交互逻辑（不需要修改）
- 导航栏样式（不需要修改）

## Data Flow

无数据流修改，仅为展示层优化。所有数据来源保持不变：
- 距离、时长、爬升、下降等数据仍从 RouteModel 获取
- 难度、区域信息保持不变

## Migration Path

### 第 1 阶段：主数据卡片深色化（1小时）
- 修改 RouteStatsCardWidget：背景色、文字色、间距
- 测试字体大小和颜色对比度

### 第 2 阶段：布局优化（1小时）
- 调整 section 排列为网格式
- 添加分隔线
- 测试不同屏幕尺寸

### 第 3 阶段：容器特殊处理（30分钟）
- 修改 RouteInfoSheetWidget 的 `_buildSectionCards()`
- 确保主数据卡片不被外层包装

### 第 4 阶段：验证与测试（30分钟）
- 验证深色背景的可读性
- 检查 iOS/Android 在不同主题下的表现
- 测试拖拽交互流畅性

## Risks & Trade-offs

| 风险 | 缓解措施 |
|------|---------|
| 深色背景在深色主题下可读性问题 | 使用 CupertinoColors 确保主题自适应；测试 Dark Mode |
| 修改后与其他 section 视觉不协调 | 进行视觉对比测试；确保间距和排列整齐 |
| 文字颜色对比度不足（可访问性） | 确保白色文字在深色背景上的对比度 ≥ 7:1 |

## Open Questions

1. 深色背景色是否固定为 #1C1C1E，或根据主题变化？
2. 白色文字是否需要在深色主题下有所调整？
3. 是否需要为主数据卡片添加顶部的 logo/用户头像区域（目前图片显示有）？

