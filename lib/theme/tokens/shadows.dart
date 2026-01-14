import 'package:flutter/widgets.dart';
import 'colors.dart';

/// 应用阴影 Token
///
/// 专业运动风格 - 轻量阴影
class AppShadows {
  AppShadows._();

  // ============ 阴影定义 ============
  /// 无阴影
  static const List<BoxShadow> none = [];

  /// 小阴影 - 用于悬浮按钮、小卡片
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0D000000), // 5% 透明度
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  /// 中阴影 - 用于卡片
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x14000000), // 8% 透明度
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// 大阴影 - 用于弹窗、浮层
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1F000000), // 12% 透明度
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  /// 超大阴影 - 用于模态框
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x29000000), // 16% 透明度
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  // ============ 特殊阴影 ============
  /// 底部导航栏阴影
  static const List<BoxShadow> bottomNav = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 8,
      offset: Offset(0, -2),
    ),
  ];

  /// 顶部导航栏阴影
  static const List<BoxShadow> topNav = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// 内阴影效果 (用于输入框)
  static const List<BoxShadow> inset = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 4,
      offset: Offset(0, 1),
      spreadRadius: -1,
    ),
  ];

  /// 强调阴影 (带颜色)
  static List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  /// 成功阴影 (带颜色)
  static List<BoxShadow> successGlow = [
    BoxShadow(
      color: AppColors.success.withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  /// 错误阴影 (带颜色)
  static List<BoxShadow> errorGlow = [
    BoxShadow(
      color: AppColors.error.withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // ============ BoxDecoration 快捷方式 ============
  /// 卡片装饰 (白色背景 + 中阴影 + 圆角)
  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.card,
    borderRadius: BorderRadius.circular(8),
    boxShadow: md,
  );

  /// 无阴影卡片装饰 (白色背景 + 边框 + 圆角)
  static BoxDecoration cardFlatDecoration = BoxDecoration(
    color: AppColors.card,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: AppColors.border, width: 1),
  );

  /// 浮层装饰 (白色背景 + 大阴影 + 圆角)
  static BoxDecoration popupDecoration = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(12),
    boxShadow: lg,
  );

  /// 底部表单装饰
  static BoxDecoration bottomSheetDecoration = BoxDecoration(
    color: AppColors.surface,
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
    ),
    boxShadow: xl,
  );
}
