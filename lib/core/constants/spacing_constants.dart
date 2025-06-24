import 'package:flutter/widgets.dart';

/// 间距常量定义
///
/// 统一管理应用中的间距规范，确保UI的一致性
class SpacingConstants {
  SpacingConstants._();

  // 基础间距单位
  static const double unit = 4.0;

  // 微小间距
  static const double xs = unit; // 4
  static const double sm = unit * 2; // 8

  // 标准间距
  static const double md = unit * 3; // 12
  static const double lg = unit * 4; // 16
  static const double xl = unit * 5; // 20

  // 大间距
  static const double xxl = unit * 6; // 24
  static const double xxxl = unit * 8; // 32

  // 特殊间距
  static const double section = xxl; // 24 - 用于章节间距
  static const double page = xxxl; // 32 - 用于页面级间距
  static const double safe = xxxl; // 32 - 用于安全区域间距

  // 水平间距（页面边距）
  static const double horizontalPadding = lg; // 16

  // 垂直间距预设
  static const double componentSpacing = xl; // 20 - 组件间距
  static const double sectionSpacing = xxl; // 24 - 章节间距
  static const double pageSpacing = xxxl; // 32 - 页面间距
}

/// 间距扩展方法
extension SpacingExtension on double {
  /// 转换为SizedBox高度
  Widget get verticalSpace => SizedBox(height: this);

  /// 转换为SizedBox宽度
  Widget get horizontalSpace => SizedBox(width: this);
}

/// 常用间距组件
class Spacing {
  Spacing._();

  // 垂直间距
  static const Widget xs = SizedBox(height: SpacingConstants.xs);
  static const Widget sm = SizedBox(height: SpacingConstants.sm);
  static const Widget md = SizedBox(height: SpacingConstants.md);
  static const Widget lg = SizedBox(height: SpacingConstants.lg);
  static const Widget xl = SizedBox(height: SpacingConstants.xl);
  static const Widget xxl = SizedBox(height: SpacingConstants.xxl);
  static const Widget xxxl = SizedBox(height: SpacingConstants.xxxl);

  // 特殊间距
  static const Widget component =
      SizedBox(height: SpacingConstants.componentSpacing);
  static const Widget section =
      SizedBox(height: SpacingConstants.sectionSpacing);
  static const Widget page = SizedBox(height: SpacingConstants.pageSpacing);
  static const Widget safe = SizedBox(height: SpacingConstants.safe);

  // 水平间距
  static const Widget horizontalXs = SizedBox(width: SpacingConstants.xs);
  static const Widget horizontalSm = SizedBox(width: SpacingConstants.sm);
  static const Widget horizontalMd = SizedBox(width: SpacingConstants.md);
  static const Widget horizontalLg = SizedBox(width: SpacingConstants.lg);
  static const Widget horizontalXl = SizedBox(width: SpacingConstants.xl);
  static const Widget horizontalXxl = SizedBox(width: SpacingConstants.xxl);
  static const Widget horizontalXxxl = SizedBox(width: SpacingConstants.xxxl);
}

/// 边距常量
class PaddingConstants {
  PaddingConstants._();

  // 标准页面边距
  static const EdgeInsets page = EdgeInsets.all(SpacingConstants.lg);
  static const EdgeInsets pageHorizontal =
      EdgeInsets.symmetric(horizontal: SpacingConstants.lg);
  static const EdgeInsets pageVertical =
      EdgeInsets.symmetric(vertical: SpacingConstants.lg);

  // 组件边距
  static const EdgeInsets component = EdgeInsets.all(SpacingConstants.md);
  static const EdgeInsets componentHorizontal =
      EdgeInsets.symmetric(horizontal: SpacingConstants.md);
  static const EdgeInsets componentVertical =
      EdgeInsets.symmetric(vertical: SpacingConstants.md);

  // 小边距
  static const EdgeInsets small = EdgeInsets.all(SpacingConstants.sm);
  static const EdgeInsets smallHorizontal =
      EdgeInsets.symmetric(horizontal: SpacingConstants.sm);
  static const EdgeInsets smallVertical =
      EdgeInsets.symmetric(vertical: SpacingConstants.sm);

  // 大边距
  static const EdgeInsets large = EdgeInsets.all(SpacingConstants.xl);
  static const EdgeInsets largeHorizontal =
      EdgeInsets.symmetric(horizontal: SpacingConstants.xl);
  static const EdgeInsets largeVertical =
      EdgeInsets.symmetric(vertical: SpacingConstants.xl);
}
