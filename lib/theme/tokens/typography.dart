import 'package:flutter/cupertino.dart';
import 'colors.dart';

/// Walk v1 Design Token — 字体 (PRD §8.1.3)
///
/// 字体 Alias Token：展示型 / 标题型 / 正文型 / 标注型。
/// 所有颜色引用 AppColors，不硬编码。
class AppTypography {
  AppTypography._();

  // ============ 字体族 ============
  static const String fontFamily = 'NotoSansSC';

  // ============ 沉浸式语义字体 ============
  static const TextStyle heroTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1,
    color: AppColors.textPrimary,
  );
  static const TextStyle heroSubtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textSecondary,
  );
  static const TextStyle displayTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.1,
    color: AppColors.textPrimary,
  );
  static const TextStyle pageTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.textPrimary,
  );
  static const TextStyle sectionTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );
  static const TextStyle cardTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  // ============ 展示型 ============
  /// 超大数字（天气温度）— 48px/200
  static const TextStyle displayHero = TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w200,
    height: 1.2,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// 大数字（路线距离）— 32px/800
  static const TextStyle displayLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    height: 1.2,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// 页面主标题 — 28px/800
  static const TextStyle displayMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  /// 区块主标题 — 26px/800
  static const TextStyle displaySm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w800,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  // ============ 标题型 ============
  /// 卡片标题 — 22px/700
  static const TextStyle headline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  /// 大数值 — 20px/700
  static const TextStyle titleLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// 统计值、月份标题 — 18px/600
  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  /// 导航栏标题 — 17px/600
  static const TextStyle titleSm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  // ============ 正文型 ============
  /// 大正文 — 16px/400
  static const TextStyle bodyLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  /// 正文 — 15px/400
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  /// 小正文 — 14px/400
  static const TextStyle bodySm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textWeak,
  );

  /// 说明文字 — 13px/400
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textWeak,
  );

  // ============ 标注型 ============
  /// 标签 — 12px/400
  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: AppColors.textWeak,
  );

  /// 微型标注 — 10px/400
  static const TextStyle micro = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 1.3,
    color: AppColors.textWeak,
  );

  // ============ 特殊样式 ============
  /// 按钮
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  /// 链接
  static const TextStyle link = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.interactiveAccent,
    decoration: TextDecoration.underline,
  );

  /// 导航栏标题
  static const TextStyle navTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  /// Tab 标签
  static const TextStyle tab = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.2,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodyLarge = bodyLg;

  // ============ 数据展示 ============
  static const TextStyle unit = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.2,
    color: AppColors.textWeak,
  );

  static const TextStyle metricValue = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle metricUnit = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // ============ 工具方法 ============
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }
}
