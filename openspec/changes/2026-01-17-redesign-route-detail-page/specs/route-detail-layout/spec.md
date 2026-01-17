# Route Detail Page Layout Specification

**Version**: 1.0  
**Last Updated**: 2026-01-17

## Purpose

定义新的路由详情页布局规范，采用悬浮地图 + 可折叠分类卡片的设计方案，提供优雅的信息展示和交互体验。

## Requirement: 页面布局结构

### 布局层次

路由详情页由以下几个层次组成：

1. **导航栏** (Fixed)
   - 返回按钮、标题、操作菜单
   - 位置：固定在页面顶部
   - 高度：44dp (iOS standard)

2. **地图区域** (Semi-floating)
   - 显示路线轨迹、标记点
   - 初始高度：350dp
   - 可向上滑动折叠，但不完全消失
   - 当列表滚动时，地图可逐渐变小（从 350dp → 200dp）

3. **标题和关键信息** (Sticky)
   - 路线名称、难度、距离等关键指标
   - 当地图折叠时，标题区吸顶（sticky behavior）
   - 高度：~100dp

4. **可折叠分类卡片区** (Scrollable)
   - 主要内容区
   - 包含多个可展开/折叠的分类卡片
   - 完全可滚动

5. **底部操作栏** (Fixed)
   - 主操作按钮（开始导航、规划行程等）
   - 位置：固定在页面底部
   - 适配安全区域

### 具体尺寸规范

| 元素 | 尺寸 | 说明 |
|------|------|------|
| 导航栏高度 | 44dp | 标准 iOS 尺寸 |
| 地图初始高度 | 350dp | 用户可见的默认高度 |
| 地图最小高度 | 150dp | 折叠时的最小高度 |
| 地图最大高度 | 600dp | 用户可展开的最大高度 |
| 标题区高度 | ~100dp | 路线名称 + 关键指标 |
| 卡片圆角 | AppRadius.md (8dp) | 统一圆角 |
| 卡片间距 | AppSpacing.lg (24dp) | 分类卡片之间的距离 |
| 卡片内边距 | AppSpacing.md (16dp) | 卡片内部的边距 |

---

## Requirement: 可折叠分类卡片组件 (ExpandableSection)

应用 SHALL 提供可展开/折叠的分类卡片组件，用于替代传统 Tab 栏。

### 视觉规范

**标题区**:
- 布局：`[icon] 标题文本 [→] 展开/折叠图标`
- 标题字体：`AppTypography.headlineSmall` (18sp, w600)
- 高度：48dp
- 可点击区域：整个标题行

**内容区**:
- 展开时显示完整内容
- 折叠时隐藏内容
- 使用 `ClipRRect` 配合高度动画实现平滑过渡
- 内边距：`AppSpacing.md` (16dp)

**分割线**:
- 颜色：`AppColors.divider`
- 高度：1dp
- 在标题上、下方各一条

### 尺寸规范

| 元素 | 尺寸 |
|------|------|
| 卡片高度 | 自适应（展开时） |
| 标题高度 | 48dp |
| 图标大小 | 20dp |
| 箭头大小 | 16dp |
| 圆角 | AppRadius.md (8dp) |

### 动效规范

**展开/折叠动画**:
- 时长：300ms
- 缓动函数：`Curves.easeInOut`
- 箭头旋转：0° → 90°（折叠 → 展开）
- 高度变化：0 → maxHeight（平滑变化）

**触发条件**:
- 用户点击标题区时触发
- 自动展开第一个分类（概览）
- 其他分类默认折叠

### 背景和边框

- 背景色：`AppColors.surface` (#FFFFFF)
- 边框：1dp `AppColors.divider`
- 阴影：`AppShadows.md`
- 圆角：`AppRadius.md` (8dp)

#### Scenario: 用户展开分类卡片
- **WHEN** 用户点击"营地"分类标题
- **THEN** 标题下的箭头旋转 90°，展开动画播放（300ms）
- **THEN** 内容区平滑展开显示营地列表
- **THEN** 其他已展开的分类自动折叠（可选，根据 UX 决定）

---

## Requirement: 地图-信息联动

应用 SHALL 实现地图与下方分类信息的单向交互机制：**点击下方信息项时，地图显示对应位置**。

### 交互模式

**点击信息项反馈**:
- 用户点击列表中的信息项（如营地、水源等）
- 信息项在列表中短暂高亮（背景色变浅，持续 300-500ms）
- **地图自动缩放和平移**到对应位置
- 对应的标记点在地图上高亮显示（如闪动、脉冲）
- 地图高亮提示持续 1-1.5 秒后消失
- 用户可继续浏览其他信息，地图随时更新

**具体流程**:
1. 用户在"营地"卡片中点击某个营地项
2. 列表项背景色变浅（AppColors.primary 5% 透明度）
3. 地图立即缩放和平移到该营地位置
4. 营地标记点闪动 1-1.5 秒
5. 之后恢复正常状态，用户可继续交互

**地图交互**:
- 支持双指捏合放大/缩小
- 支持双指旋转（可选）
- 支持点击标记显示详情气泡

### 实现指南

**地图高亮效果**:
- 方式1：标记点闪动（推荐，轻量级）
- 方式2：标记点放大（可选，需性能评估）
- 持续时间：1000-1500ms
- 缓动函数：`Curves.easeInOut`

**列表项高亮效果**:
- 点击/激活时：背景色变为 `AppColors.primaryLight` 5% 透明
- 缩放动画：scale 0.98 → 1.0，时长 200ms
- 边框提示：1dp 虚线，颜色 `AppColors.primary`（可选）

#### Scenario: 用户点击营地信息
- **WHEN** 用户在营地列表中点击某个营地项
- **THEN** 列表项背景色变浅（AppColors.primary 5% 透明度），持续 300-500ms
- **THEN** 地图立即缩放和平移到该营地位置
- **THEN** 营地标记点闪动/脉冲，持续 1-1.5 秒
- **WHEN** 用户点击另一个营地或其他信息项
- **THEN** 地图立即更新到新位置，过程无缝衔接
- **THEN** 旧的高亮消失，新的高亮显示

---

## Requirement: 分类卡片内容规范

### 分类卡片列表

路由详情页包含以下分类卡片（按优先级顺序）：

**第一优先级（必须展开）**

1. **概览** (Overview)
   - 包含：距离、海拔、难度、最佳季节等关键指标
   - 默认展开
   - 内容格式：网格式或并排显示

2. **每日行程** (Daily Itinerary) ⭐ 主角
   - 包含：每日计划、距离、海拔、住宿信息
   - 默认展开
   - 内容格式：时间轴式（简洁水平排布，可点击展开详情）
   - 与地图联动：点击某一天 → 地图显示该天轨迹

**第二优先级（默认折叠，按需展开）**

3. **路线分段** (Route Segments) ⭐ 辅助
   - 包含：分段名称、距离、海拔、路况、起终点
   - 默认折叠（月字条水平一行简轴）
   - 内容格式：第一层是简轴（所有分段一行展示），可点击展开详情
   - 与地图联动：点击某一段 → 地图高亮该段轨迹

4. **户外资源** (Outdoor Resources) - 合并卡片
   - 包含：水源点、补给点、营地（合并为一个卡片）
   - 默认折叠
   - 内容格式：分批展示或分类选项卡
   - 与地图联动：点击某个位置 → 地图标记该位置

5. **装备建议** (Equipment Recommendation)
   - 包含：帐篷、睡袋、背包等季节性建议
   - 默认折叠
   - 内容格式：分组列表（按装备类型）

**第三优先级（下沉）**

6. **用户评论和图片** (User Reviews & Gallery)
   - 包含：用户评论、用户拍摄的图片库
   - 默认折叠

7. **相关路线** (Related Routes)
   - 包含：相似难度或类型的其他路线
   - 默认折叠

### 卡片标题规范

| 优先级 | 分类 | 图标 | 标题 | 默认状态 |
|------|------|------|------|--------|
| P0 | 概览 | ℹ | 概览 | Expanded |
| P0 | 每日行程 | 📅 | 每日行程 | Expanded |
| P1 | 路线分段 | 📍 | 路线分段 | Collapsed |
| P1 | 户外资源 | 🏕 | 户外资源 | Collapsed |
| P2 | 装备建议 | 🎒 | 当季装备建议 | Collapsed |
| P3 | 用户评论 | 💬 | 评论和图片 | Collapsed |
| P3 | 相关路线 | 🗺 | 相关路线 | Collapsed |

#### Scenario: 页面加载
- **WHEN** 用户进入路由详情页
- **THEN** 页面显示地图头图
- **THEN** 概览分类默认展开（快速判断路线是否合适）
- **THEN** 每日行程默认展开（时间轴式，了解日程节奏）
- **THEN** 路线分段默认折叠（简轴显示，可点击展开）
- **THEN** 户外资源、装备建议等默认折叠，按需展开

---

## Requirement: 响应式设计

应用 SHALL 在不同屏幕尺寸上保持一致的设计体验。

### 屏幕断点

| 屏幕尺寸 | 地图高度 | 卡片宽度 | 调整 |
|---------|--------|--------|------|
| 小屏幕 (<375dp) | 300dp | full width | 减少 padding |
| 标准屏幕 (375-428dp) | 350dp | full width | 标准 padding |
| 大屏幕 (>428dp) | 400dp | centered (90%) | 增加 padding |

### 平板支持

- 平板上可考虑分栏布局（地图左侧，内容右侧）
- 暂不实现，仅支持竖屏模式

---

## Requirement: 性能优化

应用 SHALL 确保页面在大量内容时保持流畅性。

### 优化策略

1. **列表虚拟化**
   - 长列表（如有大量水源点、营地）使用 `ListView.builder`
   - 只渲染可见区域的内容

2. **地图优化**
   - 使用地图缓存，避免重复加载瓦片
   - 控制标记点数量（超过一定数量时进行聚合）

3. **动画优化**
   - 展开/折叠动画使用 `AnimatedContainer` 或 `AnimatedSize`
   - 避免过度的 `setState` 调用
   - 使用 `const` widget 减少重建

4. **图片优化**
   - 使用缓存和延迟加载
   - 根据屏幕尺寸加载合适分辨率的图片

---

## Requirement: 交互规范 - 基础操作

应用 SHALL 定义统一的交互反馈规范。

### 点击反馈

**分类标题点击**:
- 视觉反馈：背景色变浅（4% 黑色叠加）
- 时长：200ms
- 缓动：`Curves.easeInOut`

**卡片内容项点击**:
- 视觉反馈：scale 缩放到 0.98
- 时长：100-200ms
- 可选：短暂背景高亮

**地图标记点击**:
- 视觉反馈：标记点放大或显示详情气泡
- 时长：300ms

### 无内容状态

**空状态处理**:
- 分类无内容时显示占位符文本（如"暂无水源点数据"）
- 使用 `AppColors.textSecondary` 颜色
- 字体：`AppTypography.bodyMedium`

---

## Requirement: 样式规范 - 颜色和字体

应用 SHALL 严格遵循 Design System 颜色和字体规范。

### 颜色规范

| 元素 | 颜色 Token | 说明 |
|------|-----------|------|
| 背景 | AppColors.background | 页面背景 |
| 卡片背景 | AppColors.surface | 分类卡片背景 |
| 标题文字 | AppColors.textPrimary | 分类标题 |
| 正文 | AppColors.textPrimary | 卡片内容 |
| 副文本 | AppColors.textSecondary | 描述、说明文字 |
| 分割线 | AppColors.divider | 卡片分割线 |
| 高亮 | AppColors.primary | 链接、按钮 |
| 边框 | AppColors.divider | 卡片边框 |

### 字体规范

| 元素 | 字体 Token | 说明 |
|------|-----------|------|
| 分类标题 | AppTypography.headlineSmall (18sp, w600) | 可折叠卡片标题 |
| 项目标题 | AppTypography.titleMedium (14sp, w600) | 列表项标题 |
| 正文内容 | AppTypography.bodyMedium (14sp, w400) | 普通文字 |
| 辅助文字 | AppTypography.bodySmall (12sp, w400) | 说明、描述 |
| 标签 | AppTypography.labelMedium (12sp, w500) | 标签、属性 |

### 禁止硬编码

- **禁止** 直接使用 `Color(0x...)` 或具体数值
- **必须** 通过 `AppColors`、`AppTypography`、`AppSpacing` 等 Token 引用
- 所有样式值必须来自 Design System

---

## Implementation Examples

### ExpandableSection 组件使用示例

```dart
ExpandableSection(
  title: '水源点',
  icon: Icons.water_drop,
  onTitleTap: () => print('展开水源点'),
  children: waterSources.map((source) {
    return WaterSourceItem(
      waterSource: source,
      onTap: () => _handleWaterSourceTap(source),
    );
  }).toList(),
)
```

### 地图-信息联动示例

```dart
// 点击水源项时高亮地图
void _handleWaterSourceTap(WaterSource source) {
  // 1. 地图缩放到该位置
  _mapController.animateTo(source.location);
  
  // 2. 高亮标记点
  _mapController.highlightMarker(source.id, duration: 1500);
}
```

---

## Related Specifications

- `design-system/spec.md` - 设计系统规范（颜色、字体、间距、圆角、阴影）
- `project.md` - 项目背景和技术栈

## Version History

| 版本 | 日期 | 变更 |
|------|------|------|
| 1.0 | 2026-01-17 | 初始版本 |
