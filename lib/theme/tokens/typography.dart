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
  static const String fontFamilyMono = 'NotoSansSC';

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

  /// 品牌名 WALK — 42px/800; letter-spacing: 2px
  static const TextStyle displayBrand = TextStyle(
    fontFamily: fontFamily,
    fontSize: 42,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: 2,
    color: AppColors.textPrimary,
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
    color: AppColors.textBody,
  );

  /// 说明文字 — 13px/400
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textBody,
  );

  // ============ 标注型 ============
  /// 标签 — 12px/400
  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
    color: AppColors.textSubtitle,
  );

  /// 极小标注 — 11px/400
  static const TextStyle overline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.3,
    color: AppColors.textHint,
  );

  /// 微型标注 — 10px/400
  static const TextStyle micro = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 1.3,
    color: AppColors.textHint,
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

  /// 大按钮
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
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

  // ============ 兼容旧 API ============
  // 保留 TextTheme 名称映射，让现有代码逐步迁移
  static const TextStyle displayLarge = displayLg;
  static const TextStyle displayMedium = displayMd;
  static const TextStyle displaySmall = displaySm;
  static const TextStyle headlineLarge = headline;
  static const TextStyle headlineMedium = titleLg;
  static const TextStyle headlineSmall = title;
  static const TextStyle titleLarge = title;
  static const TextStyle titleMedium = body;
  static const TextStyle titleSmall = bodySm;
  static const TextStyle bodyLarge = bodyLg;
  static const TextStyle bodyMedium = body;
  static const TextStyle bodySmall = bodySm;
  static const TextStyle labelLarge = label;
  static const TextStyle labelMedium = label;
  static const TextStyle labelSmall = micro;

  // 数据展示（保留兼容）
  static const TextStyle dataNumber = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.2,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle dataNumberLarge = displayLg;

  static const TextStyle unit = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.2,
    color: AppColors.textSubtitle,
  );

  static const TextStyle statValue = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.2,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle statUnit = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.2,
    color: AppColors.textSubtitle,
  );

  static const TextStyle statLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 1.2,
    color: AppColors.textHint,
  );

  static const TextStyle metricValue = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle metricLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.2,
    color: AppColors.textSubtitle,
  );

  // ============ 工具方法 ============
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }
}
