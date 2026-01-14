import 'package:flutter/cupertino.dart';
import 'colors.dart';

/// 应用字体 Token
///
/// 专业运动风格 - 清晰易读，数据展示优先
class AppTypography {
  AppTypography._();

  // ============ 字体族 ============
  /// 默认字体族 (系统字体)
  static const String fontFamily = '.SF Pro Text';

  /// 等宽字体 (用于数据展示)
  static const String fontFamilyMono = '.SF Mono';

  // ============ 字重 ============
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // ============ 字体大小 ============
  static const double fontSizeXs = 10.0;
  static const double fontSizeSm = 12.0;
  static const double fontSizeMd = 14.0;
  static const double fontSizeLg = 16.0;
  static const double fontSizeXl = 18.0;
  static const double fontSizeXxl = 20.0;
  static const double fontSizeDisplay = 24.0;
  static const double fontSizeDisplayLg = 28.0;
  static const double fontSizeDisplayXl = 32.0;

  // ============ 行高 ============
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.75;

  // ============ Display 样式 (大标题) ============
  /// Display Large - 32px
  static const TextStyle displayLarge = TextStyle(
    fontSize: fontSizeDisplayXl,
    fontWeight: bold,
    height: lineHeightTight,
    color: AppColors.textPrimary,
  );

  /// Display Medium - 28px
  static const TextStyle displayMedium = TextStyle(
    fontSize: fontSizeDisplayLg,
    fontWeight: bold,
    height: lineHeightTight,
    color: AppColors.textPrimary,
  );

  /// Display Small - 24px
  static const TextStyle displaySmall = TextStyle(
    fontSize: fontSizeDisplay,
    fontWeight: bold,
    height: lineHeightTight,
    color: AppColors.textPrimary,
  );

  // ============ Headline 样式 (标题) ============
  /// Headline Large - 22px
  static const TextStyle headlineLarge = TextStyle(
    fontSize: fontSizeXxl + 2,
    fontWeight: semiBold,
    height: lineHeightTight,
    color: AppColors.textPrimary,
  );

  /// Headline Medium - 20px
  static const TextStyle headlineMedium = TextStyle(
    fontSize: fontSizeXxl,
    fontWeight: semiBold,
    height: lineHeightTight,
    color: AppColors.textPrimary,
  );

  /// Headline Small - 18px
  static const TextStyle headlineSmall = TextStyle(
    fontSize: fontSizeXl,
    fontWeight: semiBold,
    height: lineHeightTight,
    color: AppColors.textPrimary,
  );

  // ============ Title 样式 (副标题) ============
  /// Title Large - 16px semibold
  static const TextStyle titleLarge = TextStyle(
    fontSize: fontSizeLg,
    fontWeight: semiBold,
    height: lineHeightNormal,
    color: AppColors.textPrimary,
  );

  /// Title Medium - 14px semibold
  static const TextStyle titleMedium = TextStyle(
    fontSize: fontSizeMd,
    fontWeight: semiBold,
    height: lineHeightNormal,
    color: AppColors.textPrimary,
  );

  /// Title Small - 12px semibold
  static const TextStyle titleSmall = TextStyle(
    fontSize: fontSizeSm,
    fontWeight: semiBold,
    height: lineHeightNormal,
    color: AppColors.textPrimary,
  );

  // ============ Body 样式 (正文) ============
  /// Body Large - 16px
  static const TextStyle bodyLarge = TextStyle(
    fontSize: fontSizeLg,
    fontWeight: regular,
    height: lineHeightNormal,
    color: AppColors.textPrimary,
  );

  /// Body Medium - 14px
  static const TextStyle bodyMedium = TextStyle(
    fontSize: fontSizeMd,
    fontWeight: regular,
    height: lineHeightNormal,
    color: AppColors.textPrimary,
  );

  /// Body Small - 12px
  static const TextStyle bodySmall = TextStyle(
    fontSize: fontSizeSm,
    fontWeight: regular,
    height: lineHeightNormal,
    color: AppColors.textSecondary,
  );

  // ============ Label 样式 (标签) ============
  /// Label Large - 14px medium
  static const TextStyle labelLarge = TextStyle(
    fontSize: fontSizeMd,
    fontWeight: medium,
    height: lineHeightTight,
    color: AppColors.textPrimary,
  );

  /// Label Medium - 12px medium
  static const TextStyle labelMedium = TextStyle(
    fontSize: fontSizeSm,
    fontWeight: medium,
    height: lineHeightTight,
    color: AppColors.textPrimary,
  );

  /// Label Small - 10px medium
  static const TextStyle labelSmall = TextStyle(
    fontSize: fontSizeXs,
    fontWeight: medium,
    height: lineHeightTight,
    color: AppColors.textSecondary,
  );

  // ============ 特殊样式 ============
  /// 按钮文字
  static const TextStyle button = TextStyle(
    fontSize: fontSizeMd,
    fontWeight: semiBold,
    height: lineHeightTight,
    color: AppColors.textOnDark,
  );

  /// 大按钮文字
  static const TextStyle buttonLarge = TextStyle(
    fontSize: fontSizeLg,
    fontWeight: semiBold,
    height: lineHeightTight,
    color: AppColors.textOnDark,
  );

  /// 链接文字
  static const TextStyle link = TextStyle(
    fontSize: fontSizeMd,
    fontWeight: regular,
    height: lineHeightNormal,
    color: AppColors.textLink,
    decoration: TextDecoration.underline,
  );

  /// 数据数字 (等宽字体)
  static const TextStyle dataNumber = TextStyle(
    fontSize: fontSizeXxl,
    fontWeight: bold,
    height: lineHeightTight,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// 大数据数字
  static const TextStyle dataNumberLarge = TextStyle(
    fontSize: fontSizeDisplayLg,
    fontWeight: bold,
    height: lineHeightTight,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// 单位文字
  static const TextStyle unit = TextStyle(
    fontSize: fontSizeSm,
    fontWeight: regular,
    height: lineHeightTight,
    color: AppColors.textSecondary,
  );

  /// 导航栏标题
  static const TextStyle navTitle = TextStyle(
    fontSize: fontSizeLg + 1,
    fontWeight: semiBold,
    height: lineHeightTight,
    color: AppColors.textPrimary,
  );

  /// Tab 标签
  static const TextStyle tab = TextStyle(
    fontSize: fontSizeXs,
    fontWeight: medium,
    height: lineHeightTight,
  );

  // ============ 工具方法 ============
  /// 获取带颜色的样式
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// 获取带字重的样式
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }
}
