# design-system Specification Delta

## ADDED Requirements

### Requirement: Design Token - 天气渐变色
应用 SHALL 为不同天气条件提供预定义的渐变色 Token，避免天气卡片硬编码颜色：

**天气渐变色方案**:
- `weatherSunny`: 晴天 - 从 `#FF9800` 到 `#F57C00`（橙色渐变）
- `weatherCloudy`: 多云 - 从 `#90A4AE` 到 `#546E7A`（灰蓝色渐变）
- `weatherRainy`: 雨天 - 从 `#2196F3` 到 `#1565C0`（蓝色渐变）
- `weatherSnowy`: 雪天 - 从 `#B3E5FC` 到 `#4FC3F7`（浅蓝色渐变）
- `weatherFoggy`: 有雾 - 从 `#78909C` 到 `#455A64`（灰色渐变）
- `weatherWindy`: 有风 - 从 `#009688` 到 `#00796B`（青蓝色渐变）

**实现方式**:
- 提供方法 `getWeatherGradient(String condition)` 返回对应的 `LinearGradient`
- 支持 null safe 处理，无法识别的条件返回默认蓝色渐变
- 方法定义在 `AppColors` 类中，可被所有组件复用

#### Scenario: 天气卡片使用渐变色
- **WHEN** 开发者在天气卡片中显示渐变
- **THEN** 调用 `AppColors.getWeatherGradient(weather.condition)` 获取渐变
- **THEN** 渐变应用到卡片背景，无需硬编码颜色值

#### Scenario: 无法识别的天气条件
- **WHEN** 天气条件为不支持的值或 null
- **THEN** 返回默认的蓝色渐变 `#2196F3` 到 `#1976D2`

---

### Requirement: Design Token - Trip 颜色调色板
应用 SHALL 为行程卡片提供统一的绿色系颜色调色板 Token，避免颜色数组硬编码：

**Trip 颜色调色板**:
定义包含 6 个绿色系颜色的数组：
- `#388E3C` - 深绿色
- `#4CAF50` - 标准绿色
- `#66BB6A` - 浅绿色
- `#81C784` - 更浅的绿色
- `#1B5E20` - 深邃绿色
- `#00C853` - 亮绿色

**实现方式**:
- 定义常量 `tripColors` 为 `List<Color>` 类型
- 提供方法 `getTripColor(int index)` 返回循环使用的颜色值
- 与现有的 `getBlueColor(int index)` 模式保持一致

#### Scenario: 规划行程卡片使用 Trip 颜色
- **WHEN** 开发者为行程卡片分配颜色
- **THEN** 调用 `AppColors.getTripColor(index)` 获取对应颜色
- **THEN** 颜色循环使用，每个行程卡片使用不同的绿色系

#### Scenario: 多个行程卡片颜色分配
- **WHEN** 用户有 8 个规划行程，但只有 6 个颜色
- **THEN** 第 7 个行程使用第 1 个颜色，第 8 个使用第 2 个颜色（循环）

---

## MODIFIED Requirements

### Requirement: 禁止硬编码样式
开发规范 SHALL 要求所有 UI 代码禁止硬编码样式值：

- 颜色 MUST 通过 `AppColors` 引用
- 间距 MUST 通过 `AppSpacing` 引用
- 字体样式 MUST 通过 `AppTypography` 引用
- 圆角 MUST 通过 `AppRadius` 引用
- 阴影 MUST 通过 `AppShadows` 引用
- **天气渐变色 MUST 通过 `AppColors.getWeatherGradient()` 获取** (新增)
- **颜色调色板 MUST 通过 `AppColors.getTripColor()` 等方法获取** (新增)

#### Scenario: Code Review 检查
- **WHEN** 提交代码包含 `Color(0x...)` 硬编码
- **THEN** Code Review 应标记为需要修改

#### Scenario: 天气卡片颜色硬编码检查
- **WHEN** 审查天气卡片代码
- **THEN** 检查是否通过 `AppColors.getWeatherGradient()` 获取渐变
- **THEN** 不允许直接硬编码 `LinearGradient(colors: [...])`

#### Scenario: 颜色数组硬编码检查
- **WHEN** 审查首页各部分代码
- **THEN** 检查是否直接定义 `List<Color> colors = [...]`
- **THEN** 应改为调用 `AppColors` 中的颜色调色板方法

#### Scenario: 正确使用天气渐变色
- **WHEN** 开发者需要在卡片中使用渐变色
- **THEN** 使用 `gradient: AppColors.getWeatherGradient(weatherCondition)` 而非 `gradient: LinearGradient(colors: [Colors.orange, ...])`

---
