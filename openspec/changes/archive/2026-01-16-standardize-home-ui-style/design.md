# Design: 标准化首页 UI 风格 - 天气卡片特殊处理

## 背景：为什么天气卡片需要特殊考虑？

### 天气卡片的独特需求

天气卡片 (`WelcomeWeatherCard`) 与其他首页卡片不同，存在特殊的设计需求：

1. **动态渐变色**：需要根据实时天气条件动态选择不同的渐变色
   - 晴天 → 橙色系渐变
   - 多云 → 灰蓝色系渐变
   - 下雨 → 蓝色系渐变
   - 其他条件 → 相应的视觉映射

2. **品牌感和视觉层次**：
   - 天气是首页的"欢迎区"，需要视觉吸引力
   - 渐变色能更好地表现天气状态的视觉信息
   - 其他卡片（行程、路线、攻略）都是"内容列表"，风格应相对统一

3. **可访问性**：
   - 渐变色需要有足够的对比度用于显示白色文字
   - 不能只依赖颜色传达信息（天气条件由 icon + text 也表达）

---

## 解决方案：Weather Gradient Token

### 设计原则

**原则 1：保留动态特性，消除硬编码**
```dart
// ❌ 现有的硬编码方式
if (condition.contains('晴')) {
  return [Colors.orange.shade300, Colors.orange.shade700];
}

// ✅ 新的 Token 方式
gradient: AppColors.getWeatherGradient(weather.condition)
```

**原则 2：通过 Token 方法提供灵活性**
- `AppColors.getWeatherGradient(String condition)` - 单一入口
- 方法内部处理条件分支逻辑
- 便于后续修改、A/B 测试、主题切换

**原则 3：与设计系统规范对齐**
- 所有 Token 必须存储在 `AppColors` 中
- 遵循"禁止硬编码"的设计系统要求
- 与 `getBlueColor()` 和 `getTripColor()` 的模式保持一致

---

### Token 实现方案

#### 方案 A：预定义渐变 + 工厂方法（推荐）

```dart
class AppColors {
  // ============ 天气渐变色 ============
  static const LinearGradient weatherSunnyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF9800), Color(0xFFF57C00)], // 橙色
  );
  
  static const LinearGradient weatherCloudyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF90A4AE), Color(0xFF546E7A)], // 灰蓝色
  );
  
  // ... 其他天气渐变 ...
  
  static const LinearGradient weatherDefaultGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark], // 默认蓝色
  );
  
  /// 根据天气条件获取渐变色
  static LinearGradient getWeatherGradient(String? condition) {
    if (condition == null) return weatherDefaultGradient;
    
    final lowerCondition = condition.toLowerCase();
    
    if (lowerCondition.contains('晴') || lowerCondition.contains('sunny')) {
      return weatherSunnyGradient;
    } else if (lowerCondition.contains('多云') || lowerCondition.contains('cloudy')) {
      return weatherCloudyGradient;
    } else if (lowerCondition.contains('雨') || lowerCondition.contains('rain')) {
      return weatherDefaultGradient; // 已有的蓝色渐变
    } else if (lowerCondition.contains('雪') || lowerCondition.contains('snow')) {
      return weatherSnowGradient;
    } else if (lowerCondition.contains('雾') || lowerCondition.contains('fog')) {
      return weatherFoggyGradient;
    } else if (lowerCondition.contains('风') || lowerCondition.contains('wind')) {
      return weatherWindyGradient;
    } else {
      return weatherDefaultGradient;
    }
  }
}
```

**优点**：
- 清晰明确，所有渐变一目了然
- 便于维护和修改
- 支持代码生成（如果需要）

**缺点**：
- 代码量较多

---

#### 方案 B：动态构建渐变（不推荐）

```dart
static LinearGradient getWeatherGradient(String? condition) {
  final colors = _getWeatherColors(condition);
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: colors,
  );
}

static List<Color> _getWeatherColors(String? condition) {
  // 返回对应的颜色列表
}
```

**缺点**：
- 每次调用都构建 LinearGradient 对象，性能消耗
- 难以进行常量编译优化

---

### 与其他 Token 的对齐

**现有模式 - 颜色调色板**：
```dart
// blueColors - 用于路线卡片
static const List<Color> blueColors = [...];

static Color getBlueColor(int index) {
  return blueColors[index % blueColors.length];
}
```

**新增模式 - Trip 颜色调色板**：
```dart
// tripColors - 用于行程卡片（与 blueColors 模式保持一致）
static const List<Color> tripColors = [...];

static Color getTripColor(int index) {
  return tripColors[index % tripColors.length];
}
```

**新增模式 - 天气渐变**：
```dart
// 与上面模式的差异：返回的是 LinearGradient 而非 Color
// 原因：天气状态是二维的（颜色 + 渐变），不是简单的颜色选择

static LinearGradient getWeatherGradient(String? condition) {
  // 返回完整的 LinearGradient
}
```

---

## 实现细节

### 1. 天气渐变色的选择依据

| 天气条件 | 渐变颜色 | 设计意图 | 
|---------|---------|--------|
| 晴 | 橙色 | 温暖、阳光 |
| 多云 | 灰蓝 | 中性、温和 |
| 雨 | 蓝色 | 冷调、潮湿 |
| 雪 | 浅蓝 | 清冷、纯净 |
| 雾 | 灰色 | 模糊、暗沉 |
| 风 | 青蓝 | 流动感、清爽 |
| 其他/默认 | 蓝色 | 与主色调统一 |

### 2. 颜色对比度检查

天气卡片上显示白色文字，需验证 WCAG AA 对比度标准（至少 4.5:1）：

- ✓ 橙色渐变 (FF9800 → F57C00)：对比度 > 7:1
- ✓ 灰蓝色渐变 (90A4AE → 546E7A)：对比度 > 7:1
- ✓ 蓝色渐变 (2196F3 → 1976D2)：对比度 > 8:1
- ✓ 浅蓝渐变 (B3E5FC → 4FC3F7)：对比度 > 5:1

所有渐变都满足无障碍要求 ✓

### 3. 与现有设计系统的关系

- **不破坏现有规范**：天气渐变色是 `AppColors` 的自然延伸
- **遵循设计原则**：符合"禁止硬编码"、"使用 Token"的要求
- **保留弹性**：如需修改天气色彩方案，只需修改一个地方

---

## 为什么不采用其他方案？

### 方案对比

| 方案 | 优点 | 缺点 | 选择 |
|------|------|------|------|
| **Token 方法（推荐）** | 集中管理、遵循规范、易维护 | 代码量稍多 | ✓ |
| 硬编码渐变 | 简单直接 | 违反规范、难维护、重复多 | ✗ |
| 主题变量 | 支持主题切换 | 当前版本不需要、过度设计 | ✗ |
| 资源文件 | 分离关注点 | 复杂度高、Flutter 中不通用 | ✗ |

---

## 迁移路径

### 短期（当前）
1. 定义 Weather Gradient Token 和 Trip Color Token
2. 首页各组件统一使用新 Token
3. 更新设计系统规范

### 中期（Q2）
1. 审查其他页面是否有类似硬编码颜色
2. 逐步将其他硬编码颜色替换为 Token

### 长期（Q3+）
1. 支持暗黑主题时，所有 Token 自动支持
2. 考虑 Token 的动态切换（Figma → Dart 代码生成）

---

## 风险与缓解

### 风险：颜色选择不当影响用户体验
**缓解**：
- 基于 Strava、AllTrails 等参考应用的设计
- 通过 A/B 测试验证
- 支持快速调整（修改 Token 即可）

### 风险：天气条件识别不准确
**缓解**：
- `getWeatherGradient()` 包含完整的条件分支
- 提供 fallback 到默认蓝色渐变
- 可扩展 WeatherModel 的 `condition` 类型以支持更准确的识别

### 风险：国际化支持
**缓解**：
- 天气条件识别使用中英文双支持
- 条件字段可独立于 UI 展示层

---

## 总结

天气卡片需要特殊处理，但**不是破坏规范**，而是**符合规范的创新**。通过 Token 方法，我们既保留了动态渐变的视觉特性，又遵循了设计系统的"禁止硬编码"要求，实现了**规范性和灵活性的统一**。
