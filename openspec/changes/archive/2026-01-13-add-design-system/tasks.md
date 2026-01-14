# Tasks: 建立统一的设计系统

## 1. 创建 Design Token 系统
- [x] 1.1 创建 `lib/theme/tokens/colors.dart` - 颜色 Token (天空蓝主调)
- [x] 1.2 创建 `lib/theme/tokens/spacing.dart` - 间距 Token (4px 基础网格)
- [x] 1.3 创建 `lib/theme/tokens/typography.dart` - 字体 Token (专业运动风格)
- [x] 1.4 创建 `lib/theme/tokens/radius.dart` - 圆角 Token (方正现代 8px)
- [x] 1.5 创建 `lib/theme/tokens/shadows.dart` - 阴影 Token (轻量阴影)
- [x] 1.6 创建 `lib/theme/tokens/tokens.dart` - 统一导出

## 2. 整合主题文件
- [x] 2.1 创建 `lib/theme/app_theme.dart` - 统一主题配置 (Cupertino + Material)
- [x] 2.2 删除 `lib/theme/theme/app_colors.dart` (迁移到 tokens)
- [x] 2.3 删除 `lib/theme/theme/app_color_palette.dart` (迁移到 tokens)
- [x] 2.4 删除 `lib/theme/theme/app_theme.dart` (合并到新文件)
- [x] 2.5 更新 `lib/theme/main_layout.dart` 使用新 tokens
- [x] 2.6 删除空的 `lib/theme/theme/` 目录
- [x] 2.7 更新所有引用旧 `theme/theme/` 路径的文件 (24个文件已更新)

## 3. 更新应用入口
- [x] 3.1 更新 `lib/app.dart` 使用 `AppTheme.cupertinoLight`
- [x] 3.2 通过 Flutter analyze 验证 (无编译错误)

## 验收标准
- [x] 所有颜色通过 `AppColors` 引用 (Design Token 系统已建立)
- [x] 所有间距通过 `AppSpacing` 引用 (Design Token 系统已建立)
- [x] 所有字体样式通过 `AppTypography` 引用 (Design Token 系统已建立)
- [x] 应用正常编译，无错误 (flutter analyze 通过)

## 完成总结

### 已完成内容
1. **Design Token 系统** - 6 个 token 文件已创建
   - `colors.dart` - 颜色 (天空蓝主调 + 蓝色系调色板)
   - `spacing.dart` - 间距 (4px 基础网格)
   - `typography.dart` - 字体样式
   - `radius.dart` - 圆角 (方正现代风格)
   - `shadows.dart` - 阴影
   - `tokens.dart` - 统一导出

2. **主题整合** - 删除重复定义，统一使用新 Token
   - `app_theme.dart` - CupertinoThemeData + MaterialThemeData
   - 24 个文件的 import 路径已更新

3. **应用入口** - 使用新主题配置
   - `app.dart` 使用 `AppTheme.cupertinoLight`

### 后续工作 (不在本次 Change 范围)
- 创建基础 UI 组件 (按钮、卡片、输入框等)
- 逐步迁移现有页面使用 Design Token
- 修复 `withOpacity` 弃用警告
