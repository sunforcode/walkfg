# Change: 标准化首页 UI 风格 - 统一 Design Token 使用

## Why

当前首页组件虽然整体设计合理，但存在大量硬编码的样式值（颜色、圆角、间距），与项目的 Design Token 规范不一致。这违反了设计系统中"禁止硬编码样式"的要求，导致：

1. 风格不一致：不同部分使用不同的硬编码颜色数组、圆角值
2. 维护成本高：修改主题时需要改多个地方
3. 代码审查难度大：难以检查样式是否符合规范

需要标准化首页各组件的 UI 实现，统一使用 `AppColors`、`AppRadius`、`AppSpacing` 等 Token。

## What Changes

### 1. 首页天气卡片 (`WelcomeWeatherCard`)
- **颜色**：需要特殊处理 - 根据天气条件使用动态渐变色，但应定义为 `AppColors` 中的**天气渐变色 Token**（而非硬编码）
- **圆角**：统一为 `AppRadius.xl` (16px) - 保持现有视觉
- **间距**：内边距改为 `AppSpacing.md` (16px)

### 2. 规划行程卡片 (`PlannedTripsSection`)
- **颜色**：定义绿色系颜色数组为 `AppColors` 中的 **Trip 颜色调色板 Token**
- **圆角**：统一为 `AppRadius.lg` (12px)
- **间距**：卡片内边距 `AppSpacing.sm`，列表项间距 `AppSpacing.sm`

### 3. 推荐路线卡片 (`RecommendedRoutesSection`)
- **颜色**：使用现有的 `AppColors.blueColors`（已定义）
- **圆角**：统一为 `AppRadius.lg` (12px)
- **间距**：卡片内边距 `AppSpacing.sm`，列表项间距 `AppSpacing.md`

### 4. 徒步攻略卡片 (`HikingGuidesSection`)
- **颜色**：已使用 `AppColors.getBlueColor()` ✓
- **间距**：网格间距统一为 `AppSpacing.sm`

### 5. 设计系统扩展 (新增)
- **天气渐变色 Token**：为不同天气条件定义渐变色方案
- **Trip 颜色调色板 Token**：为行程卡片定义绿色系颜色数组

## Impact

- **Affected specs**: `design-system`
- **Affected code**: 
  - `lib/ui/page/home/widgets/welcome_weather_card.dart`
  - `lib/ui/page/home/widgets/planned_trips_section.dart`
  - `lib/ui/page/home/widgets/recommended_routes_section.dart`
  - `lib/ui/page/home/widgets/hiking_guides_section.dart`
  - `lib/ui/page/home/widgets/component/*.dart`
  - `lib/theme/tokens/colors.dart` (新增 Weather 渐变色、Trip 颜色)
- **Breaking changes**: 无，为重构优化

## References

- 设计规范：`specs/design-system/spec.md` - 禁止硬编码样式
- 现有 Token：`lib/theme/tokens/{colors,radius,spacing}.dart`
- 参考案例：已正确使用 Token 的组件（HikingGuidesSection）
