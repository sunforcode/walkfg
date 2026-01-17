# Tasks: 标准化首页 UI 风格

## 1. 设计系统扩展

### 1.1 添加天气渐变色 Token
- [x] 在 `lib/theme/tokens/colors.dart` 中添加 `weatherGradients` 方法
- [x] 定义不同天气条件下的渐变色方案（晴、多云、雨、雪、雾、风等）
- [x] 添加方法 `getWeatherGradient(WeatherCondition condition)` 返回对应渐变
- [x] 确保使用设计系统中已有的颜色 Token（不新增颜色值）

### 1.2 添加 Trip 颜色调色板 Token
- [x] 在 `lib/theme/tokens/colors.dart` 中添加 `tripColors` 常量数组
- [x] 包含 6 个绿色系颜色值（对应 PlannedTripsSection 的绿色组）
- [x] 添加方法 `getTripColor(int index)` 返回循环使用的颜色

### 1.3 更新设计系统规范
- [x] 在 `specs/design-system/spec.md` 中添加"天气渐变色 Token"需求
- [x] 添加"Trip 颜色调色板 Token"需求
- [x] 更新"禁止硬编码样式"要求的场景说明

---

## 2. 首页天气卡片重构

### 2.1 WeatherMainInfo 组件
- [x] 将硬编码的 `Colors.white.withOpacity()` 改为使用 `AppColors` 中的 `textOnDark`
- [x] 将硬编码的 `Colors.green` 和 `Colors.red` 改为 `AppColors.success` 和 `AppColors.error`
- [x] 更新背景圆角，确保与卡片圆角一致

### 2.2 WeatherDetailsRow 组件
- [x] 审查所有颜色硬编码，统一改为 `AppColors` Token
- [x] 更新间距硬编码为 `AppSpacing` Token

### 2.3 WelcomeWeatherCard 主组件
- [x] 将 `_getWeatherGradient()` 方法改为调用 `AppColors.getWeatherGradient()`
- [x] 将 `BorderRadius.circular(16)` 改为 `AppRadius.xl`
- [x] 将 `EdgeInsets.all(20)` 改为 `AppSpacing.md`
- [x] 修改 `BoxShadow` 中的硬编码不透明度为 `AppColors.shadow`

---

## 3. 规划行程卡片重构

### 3.1 PlannedTripsSection 组件
- [x] 将 `greenColors` 数组替换为 `AppColors.tripColors`
- [x] 将颜色获取改为使用 `AppColors.getTripColor(index)`
- [x] 将 `BorderRadius.circular(12)` 改为 `AppRadius.lg`
- [x] 将 `EdgeInsets.all(12)` 改为 `AppSpacing.sm`
- [x] 将 `EdgeInsets.only(right: 12)` 改为 `EdgeInsets.only(right: AppSpacing.sm)`
- [x] 审查所有其他硬编码的间距和圆角，替换为对应 Token
- [x] 将 `CupertinoColors.systemGrey.darkColor` 改为 `AppColors.textSecondary`

---

## 4. 推荐路线卡片重构

### 4.1 RecommendedRoutesSection 组件
- [x] 将 `blueColors` 数组替换为 `AppColors.blueColors`（已存在，只需改代码）
- [x] 将颜色获取改为使用 `AppColors.getBlueColor(index)`
- [x] 将 `BorderRadius.circular(12)` 改为 `AppRadius.lg`
- [x] 将 `EdgeInsets.only(right: 16)` 改为 `EdgeInsets.only(right: AppSpacing.md)`
- [x] 将 `EdgeInsets.all(12)` 改为 `AppSpacing.sm`
- [x] 审查 `_buildRouteCard()` 中的所有硬编码圆角和间距

### 4.2 BoxShadow 硬编码修复
- [x] 将 `color.withOpacity(0.2)` 改为使用 `AppColors.shadow`

---

## 5. 徒步攻略卡片优化

### 5.1 HikingGuidesSection 组件
- [x] 将 `crossAxisSpacing: 12` 改为 `AppSpacing.sm`
- [x] 将 `mainAxisSpacing: 12` 改为 `AppSpacing.sm`
- [x] 验证 `AppColors.getBlueColor()` 的正确使用

---

## 6. 天气组件子组件修复

### 6.1 weather_header.dart
- [x] 审查并修复所有硬编码颜色和间距

### 6.2 weather_detail_item.dart
- [x] 审查并修复所有硬编码颜色和间距

### 6.3 loading_card.dart 和 error_card.dart
- [x] 确保使用正确的 Token

### 6.4 altitude_button.dart
- [x] 修复的虬色硬编码

---

## 7. 测试与验证

### 7.1 代码审查
- [x] 运行 `flutter analyze` 检查无分析错误
- [x] 运行 `flutter format .` 格式化代码

### 7.2 视觉验证
- [x] 验证首页布局视觉效果未改变
- [x] 验证天气卡片渐变色正确显示
- [x] 验证所有卡片圆角和间距一致

### 7.3 单元测试（可选）
- [x] 为新增的 Token 方法编写测试

---

## 8. 文档更新

### 8.1 规范同步
- [x] 更新 `specs/design-system/spec.md`
- [x] 添加天气渐变色和 Trip 颜色的需求说明
- [x] 更新场景示例

---

## 优先级与并行度

- **高优先级（必须先做）**：1.1, 1.2 - 定义新 Token
- **中优先级（可并行）**：2, 3, 4, 5 - 各组件重构
- **低优先级（最后做）**：7, 8 - 测试与文档

