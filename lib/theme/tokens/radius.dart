import 'package:flutter/widgets.dart';

/// 应用圆角 Token
///
/// 专业运动风格 - 方正现代 (小圆角)
class AppRadius {
  AppRadius._();

  // ============ 圆角值 ============
  /// 无圆角
  static const double none = 0.0;

  /// 极小圆角 - 4px
  static const double xs = 4.0;

  /// 小圆角 - 6px (标签)
  static const double sm = 6.0;

  /// 中圆角 - 8px (按钮、卡片) - 方正现代风格主要圆角
  static const double md = 8.0;

  /// 大圆角 - 12px (弹窗、底部表单)
  static const double lg = 12.0;

  /// 超大圆角 - 16px
  static const double xl = 16.0;

  /// 全圆角 (圆形)
  static const double full = 9999.0;

  // ============ BorderRadius 快捷方式 ============
  /// 无圆角
  static const BorderRadius borderNone = BorderRadius.zero;

  /// 极小圆角
  static const BorderRadius borderXs = BorderRadius.all(Radius.circular(xs));

  /// 小圆角
  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(sm));

  /// 中圆角 (按钮、卡片)
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(md));

  /// 大圆角 (弹窗)
  static const BorderRadius borderLg = BorderRadius.all(Radius.circular(lg));

  /// 超大圆角
  static const BorderRadius borderXl = BorderRadius.all(Radius.circular(xl));

  /// 全圆角
  static const BorderRadius borderFull = BorderRadius.all(Radius.circular(full));

  // ============ 特殊圆角 ============
  /// 顶部圆角 (底部表单)
  static BorderRadius topLg = const BorderRadius.only(
    topLeft: Radius.circular(lg),
    topRight: Radius.circular(lg),
  );

  /// 顶部圆角 xl
  static BorderRadius topXl = const BorderRadius.only(
    topLeft: Radius.circular(xl),
    topRight: Radius.circular(xl),
  );

  /// 底部圆角
  static BorderRadius bottomLg = const BorderRadius.only(
    bottomLeft: Radius.circular(lg),
    bottomRight: Radius.circular(lg),
  );

  /// 左侧圆角
  static BorderRadius leftMd = const BorderRadius.only(
    topLeft: Radius.circular(md),
    bottomLeft: Radius.circular(md),
  );

  /// 右侧圆角
  static BorderRadius rightMd = const BorderRadius.only(
    topRight: Radius.circular(md),
    bottomRight: Radius.circular(md),
  );

  // ============ Radius 值 ============
  /// 极小 Radius
  static const Radius radiusXs = Radius.circular(xs);

  /// 小 Radius
  static const Radius radiusSm = Radius.circular(sm);

  /// 中 Radius
  static const Radius radiusMd = Radius.circular(md);

  /// 大 Radius
  static const Radius radiusLg = Radius.circular(lg);

  /// 超大 Radius
  static const Radius radiusXl = Radius.circular(xl);

  /// 全圆 Radius
  static const Radius radiusFull = Radius.circular(full);
}
