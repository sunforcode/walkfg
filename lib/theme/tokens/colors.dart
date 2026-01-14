import 'package:flutter/material.dart';

/// 应用颜色 Token - 专业运动风格 (方案 B)
///
/// 设计风格：天空蓝调
/// 参考品牌：Strava、AllTrails、Apple Health
class AppColors {
  AppColors._();

  // ============ 主色 (Primary) - 天空蓝 ============
  /// 主色 - 天空蓝
  static const Color primary = Color(0xFF2196F3);

  /// 主色浅
  static const Color primaryLight = Color(0xFF64B5F6);

  /// 主色深
  static const Color primaryDark = Color(0xFF1976D2);

  /// 主色容器 (用于背景)
  static const Color primaryContainer = Color(0xFFBBDEFB);

  /// 主色上的文字颜色
  static const Color onPrimary = Colors.white;

  // ============ 辅助色 (Secondary) - 自然绿 ============
  /// 辅助色 - 自然绿
  static const Color secondary = Color(0xFF4CAF50);

  /// 辅助色浅
  static const Color secondaryLight = Color(0xFF81C784);

  /// 辅助色深
  static const Color secondaryDark = Color(0xFF388E3C);

  /// 辅助色容器
  static const Color secondaryContainer = Color(0xFFC8E6C9);

  /// 辅助色上的文字颜色
  static const Color onSecondary = Colors.white;

  // ============ 强调色 (Accent) ============
  /// 强调色 - 橙色
  static const Color accent = Color(0xFFFF9800);

  /// 强调色浅
  static const Color accentLight = Color(0xFFFFB74D);

  /// 强调色深
  static const Color accentDark = Color(0xFFF57C00);

  // ============ 语义色 (Semantic) ============
  /// 成功色 - 绿色
  static const Color success = Color(0xFF4CAF50);

  /// 成功色浅
  static const Color successLight = Color(0xFFE8F5E9);

  /// 警告色 - 橙色
  static const Color warning = Color(0xFFFF9800);

  /// 警告色浅
  static const Color warningLight = Color(0xFFFFF3E0);

  /// 错误色 - 红色
  static const Color error = Color(0xFFF44336);

  /// 错误色浅
  static const Color errorLight = Color(0xFFFFEBEE);

  /// 信息色 - 蓝色
  static const Color info = Color(0xFF2196F3);

  /// 信息色浅
  static const Color infoLight = Color(0xFFE3F2FD);

  // ============ 中性色 (Neutral) ============
  /// 背景色 - 极浅灰 (专业运动风格)
  static const Color background = Color(0xFFFAFAFA);

  /// 表面色 - 白色
  static const Color surface = Color(0xFFFFFFFF);

  /// 卡片背景色
  static const Color card = Color(0xFFFFFFFF);

  /// 分割线颜色
  static const Color divider = Color(0xFFE0E0E0);

  /// 边框颜色
  static const Color border = Color(0xFFE0E0E0);

  /// 禁用色
  static const Color disabled = Color(0xFFBDBDBD);

  /// 遮罩色
  static const Color overlay = Color(0x80000000);

  // ============ 文字颜色 (Text) ============
  /// 主要文字 - 深灰黑
  static const Color textPrimary = Color(0xFF212121);

  /// 次要文字 - 中灰
  static const Color textSecondary = Color(0xFF757575);

  /// 提示文字 - 浅灰
  static const Color textHint = Color(0xFFBDBDBD);

  /// 禁用文字
  static const Color textDisabled = Color(0xFF9E9E9E);

  /// 白色文字 (用于深色背景)
  static const Color textOnDark = Color(0xFFFFFFFF);

  /// 链接文字
  static const Color textLink = Color(0xFF2196F3);

  // ============ 图标颜色 (Icon) ============
  /// 主要图标
  static const Color iconPrimary = Color(0xFF757575);

  /// 次要图标
  static const Color iconSecondary = Color(0xFF9E9E9E);

  /// 激活图标
  static const Color iconActive = Color(0xFF2196F3);

  // ============ 特殊用途 ============
  /// 点赞色
  static const Color like = Color(0xFFE91E63);

  /// 收藏色
  static const Color favorite = Color(0xFFFF9800);

  /// 阴影色
  static const Color shadow = Color(0x1A000000);

  // ============ 渐变色 ============
  /// 主色渐变
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
  );

  /// 辅助色渐变
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
  );

  /// 强调色渐变
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
  );

  // ============ 蓝色系调色板 ============
  /// 蓝色系调色板 - 用于卡片等元素的循环着色
  static const List<Color> blueColors = [
    Color(0xFF2196F3), // Blue 500
    Color(0xFF03A9F4), // Light Blue 500
    Color(0xFF00BCD4), // Cyan 500
    Color(0xFF009688), // Teal 500
    Color(0xFF1976D2), // Blue 700
    Color(0xFF0288D1), // Light Blue 700
  ];

  // ============ 工具方法 ============
  /// 获取带透明度的颜色
  static Color withAlpha(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  /// 获取蓝色系颜色 (循环使用)
  static Color getBlueColor(int index) {
    return blueColors[index % blueColors.length];
  }
}
