# Design System Specification

## ADDED Requirements

### Requirement: Design Token - Colors
应用 SHALL 提供统一的颜色 Token 系统，包含以下颜色定义：

**主色 (Primary) - 天空蓝**
- `primary`: #2196F3 (天空蓝)
- `primaryLight`: #64B5F6
- `primaryDark`: #1976D2

**辅助色 (Secondary) - 自然绿**
- `secondary`: #4CAF50 (自然绿)
- `secondaryLight`: #81C784
- `secondaryDark`: #388E3C

**强调色 (Accent)**
- `accent`: #FF9800 (橙色)

**语义色 (Semantic)**
- `success`: #4CAF50 (绿色)
- `warning`: #FF9800 (橙色)
- `error`: #F44336 (红色)
- `info`: #2196F3 (蓝色)

**中性色 (Neutral)**
- `background`: #FAFAFA (极浅灰，专业运动风格)
- `surface`: #FFFFFF
- `textPrimary`: #212121
- `textSecondary`: #757575
- `textHint`: #BDBDBD
- `divider`: #E0E0E0

#### Scenario: 使用主色
- **WHEN** 开发者需要使用主色
- **THEN** 通过 `AppColors.primary` 获取颜色值

#### Scenario: 使用语义色
- **WHEN** 开发者需要显示错误状态
- **THEN** 通过 `AppColors.error` 获取红色

---

### Requirement: Design Token - Spacing
应用 SHALL 提供统一的间距 Token 系统：

| Token | 值 | 用途 |
|-------|-----|------|
| `xs` | 4.0 | 极小间距（图标与文字） |
| `sm` | 8.0 | 小间距（列表项内部） |
| `md` | 16.0 | 中间距（卡片内边距） |
| `lg` | 24.0 | 大间距（区块间距） |
| `xl` | 32.0 | 超大间距（页面边距） |
| `xxl` | 48.0 | 特大间距（区域分隔） |

#### Scenario: 使用间距
- **WHEN** 开发者需要设置 padding
- **THEN** 通过 `AppSpacing.md` 获取 16.0 的间距值

---

### Requirement: Design Token - Typography
应用 SHALL 提供统一的字体样式 Token：

**字体大小**
| Token | 值 | 用途 |
|-------|-----|------|
| `displayLarge` | 32.0 | 大标题 |
| `displayMedium` | 28.0 | 中标题 |
| `displaySmall` | 24.0 | 小标题 |
| `headlineLarge` | 22.0 | 页面标题 |
| `headlineMedium` | 20.0 | 区块标题 |
| `headlineSmall` | 18.0 | 卡片标题 |
| `titleLarge` | 16.0 | 大正文 |
| `titleMedium` | 14.0 | 正文 |
| `titleSmall` | 12.0 | 小正文 |
| `bodyLarge` | 16.0 | 大段落 |
| `bodyMedium` | 14.0 | 段落 |
| `bodySmall` | 12.0 | 小段落 |
| `labelLarge` | 14.0 | 大标签 |
| `labelMedium` | 12.0 | 标签 |
| `labelSmall` | 10.0 | 小标签 |

**字重**
- `regular`: FontWeight.w400
- `medium`: FontWeight.w500
- `semiBold`: FontWeight.w600
- `bold`: FontWeight.w700

#### Scenario: 使用标题样式
- **WHEN** 开发者需要页面标题样式
- **THEN** 通过 `AppTypography.headlineLarge` 获取预定义的 TextStyle

---

### Requirement: Design Token - Radius
应用 SHALL 提供统一的圆角 Token：

| Token | 值 | 用途 |
|-------|-----|------|
| `none` | 0.0 | 无圆角 |
| `xs` | 4.0 | 极小圆角 |
| `sm` | 6.0 | 小圆角（标签） |
| `md` | 8.0 | 中圆角（按钮、卡片）- 方正现代风格 |
| `lg` | 12.0 | 大圆角（弹窗） |
| `xl` | 16.0 | 超大圆角 |
| `full` | 9999.0 | 全圆角（圆形） |

#### Scenario: 使用卡片圆角
- **WHEN** 开发者创建卡片组件
- **THEN** 通过 `AppRadius.md` 获取 12.0 的圆角值

---

### Requirement: Design Token - Shadows
应用 SHALL 提供统一的阴影 Token：

| Token | 用途 |
|-------|------|
| `none` | 无阴影 |
| `sm` | 小阴影（悬浮按钮） |
| `md` | 中阴影（卡片） |
| `lg` | 大阴影（弹窗） |

#### Scenario: 使用卡片阴影
- **WHEN** 开发者创建卡片组件
- **THEN** 通过 `AppShadows.md` 获取预定义的 BoxShadow 列表

---

### Requirement: 主题配置
应用 SHALL 提供统一的 CupertinoThemeData 配置：

- 主色调使用 `AppColors.primary`
- 背景色使用 `AppColors.background`
- 文字主题使用 `AppTypography` 定义的样式

#### Scenario: 应用使用统一主题
- **WHEN** 应用启动
- **THEN** CupertinoApp 使用 `AppTheme.light` 作为主题

---

### Requirement: 禁止硬编码样式
开发规范 SHALL 要求所有 UI 代码禁止硬编码样式值：

- 颜色 MUST 通过 `AppColors` 引用
- 间距 MUST 通过 `AppSpacing` 引用
- 字体样式 MUST 通过 `AppTypography` 引用
- 圆角 MUST 通过 `AppRadius` 引用
- 阴影 MUST 通过 `AppShadows` 引用

#### Scenario: Code Review 检查
- **WHEN** 提交代码包含 `Color(0x...)` 硬编码
- **THEN** Code Review 应标记为需要修改

#### Scenario: 正确使用颜色
- **WHEN** 开发者需要设置背景色
- **THEN** 使用 `color: AppColors.background` 而非 `color: Color(0xFFF5F5F5)`
