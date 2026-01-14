import 'package:flutter/widgets.dart';

/// 应用间距 Token
///
/// 使用 4px 基础网格系统
class AppSpacing {
  AppSpacing._();

  // ============ 基础间距值 ============
  /// 极小间距 - 4px (图标与文字间距)
  static const double xs = 4.0;

  /// 小间距 - 8px (列表项内部间距)
  static const double sm = 8.0;

  /// 中间距 - 16px (卡片内边距、标准间距)
  static const double md = 16.0;

  /// 大间距 - 24px (区块间距)
  static const double lg = 24.0;

  /// 超大间距 - 32px (页面边距)
  static const double xl = 32.0;

  /// 特大间距 - 48px (区域分隔)
  static const double xxl = 48.0;

  // ============ 特殊间距 ============
  /// 页面水平边距
  static const double pageHorizontal = 16.0;

  /// 页面垂直边距
  static const double pageVertical = 16.0;

  /// 卡片内边距
  static const double cardPadding = 16.0;

  /// 列表项间距
  static const double listItemSpacing = 12.0;

  /// 区块间距
  static const double sectionSpacing = 24.0;

  /// 导航栏高度
  static const double navBarHeight = 44.0;

  /// 底部安全区域
  static const double bottomSafeArea = 34.0;

  // ============ EdgeInsets 快捷方式 ============
  /// 全部 xs 间距
  static const EdgeInsets allXs = EdgeInsets.all(xs);

  /// 全部 sm 间距
  static const EdgeInsets allSm = EdgeInsets.all(sm);

  /// 全部 md 间距
  static const EdgeInsets allMd = EdgeInsets.all(md);

  /// 全部 lg 间距
  static const EdgeInsets allLg = EdgeInsets.all(lg);

  /// 全部 xl 间距
  static const EdgeInsets allXl = EdgeInsets.all(xl);

  /// 水平 sm 间距
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);

  /// 水平 md 间距
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);

  /// 水平 lg 间距
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);

  /// 垂直 sm 间距
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);

  /// 垂直 md 间距
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);

  /// 垂直 lg 间距
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);

  /// 页面标准内边距
  static const EdgeInsets page = EdgeInsets.symmetric(
    horizontal: pageHorizontal,
    vertical: pageVertical,
  );

  /// 卡片标准内边距
  static const EdgeInsets card = EdgeInsets.all(cardPadding);

  // ============ SizedBox 快捷方式 ============
  /// 水平间距 xs
  static const SizedBox gapXs = SizedBox(width: xs);

  /// 水平间距 sm
  static const SizedBox gapSm = SizedBox(width: sm);

  /// 水平间距 md
  static const SizedBox gapMd = SizedBox(width: md);

  /// 水平间距 lg
  static const SizedBox gapLg = SizedBox(width: lg);

  /// 垂直间距 xs
  static const SizedBox gapVerticalXs = SizedBox(height: xs);

  /// 垂直间距 sm
  static const SizedBox gapVerticalSm = SizedBox(height: sm);

  /// 垂直间距 md
  static const SizedBox gapVerticalMd = SizedBox(height: md);

  /// 垂直间距 lg
  static const SizedBox gapVerticalLg = SizedBox(height: lg);

  /// 垂直间距 xl
  static const SizedBox gapVerticalXl = SizedBox(height: xl);

  /// 垂直间距 xxl
  static const SizedBox gapVerticalXxl = SizedBox(height: xxl);
}
