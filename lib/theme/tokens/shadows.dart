import 'package:flutter/widgets.dart';
import 'colors.dart';

/// 应用阴影 Token (暗色主题)
///
/// 暗色主题需要使用浅色阴影以保持可见性
class AppShadows {
  AppShadows._();

  // ============ 阴影定义 ============
  /// 无阴影
  static const List<BoxShadow> none = [];

  /// 小阴影 - 用于悬浮按钮、小卡片
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x1AFFFFFF), // 10% 白色
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  /// 中阴影 - 用于卡片
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x26FFFFFF), // 15% 白色
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// 大阴影 - 用于弹窗、浮层
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x33FFFFFF), // 20% 白色
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  /// 超大阴影 - 用于模态框
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x40FFFFFF), // 25% 白色
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  // ============ 特殊阴影 ============
  /// 底部导航栏阴影
  static const List<BoxShadow> bottomNav = [
    BoxShadow(
      color: Color(0x1AFFFFFF),
      blurRadius: 8,
      offset: Offset(0, -2),
    ),
  ];

  /// 顶部导航栏阴影
  static const List<BoxShadow> topNav = [
    BoxShadow(
      color: Color(0x1AFFFFFF),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// 内阴影效果 (用于输入框)
  static const List<BoxShadow> inset = [
    BoxShadow(
      color: Color(0x1AFFFFFF),
      blurRadius: 4,
      offset: Offset(0, 1),
      spreadRadius: -1,
    ),
  ];

  // ============ 卡片层级阴影 (用于数据卡片和列表) ============
  /// 卡片层级 0 - 扁平卡片 (仅边框无阴影)
  static const List<BoxShadow> cardElevation0 = [];

  /// 卡片层级 1 - 普通卡片
  static const List<BoxShadow> cardElevation1 = [
    BoxShadow(
      color: Color(0x1AFFFFFF), // 10% 白色
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
  ];

  /// 卡片层级 2 - 悬浮卡片
  static const List<BoxShadow> cardElevation2 = [
    BoxShadow(
      color: Color(0x33FFFFFF), // 20% 白色
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  /// 卡片层级 3 - 弹出层
  static const List<BoxShadow> cardElevation3 = [
    BoxShadow(
      color: Color(0x4DFFFFFF), // 30% 白色
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  /// 强调阴影 (带颜色)
  static List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: AppColors.accentBlue.withValues(alpha: 0.3),
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
  /// 卡片装饰 (暗色主题)
  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.surfaceCard,
    borderRadius: BorderRadius.circular(8),
    boxShadow: md,
  );

  /// 无阴影卡片装饰 (暗色主题)
  static BoxDecoration cardFlatDecoration = BoxDecoration(
    color: AppColors.surfaceCard,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: AppColors.surfaceCardBorder, width: 1),
  );

  /// 浮层装饰 (暗色主题)
  static BoxDecoration popupDecoration = BoxDecoration(
    color: AppColors.bgPanel,
    borderRadius: BorderRadius.circular(12),
    boxShadow: lg,
  );

  /// 底部表单装饰 (暗色主题)
  static BoxDecoration bottomSheetDecoration = BoxDecoration(
    color: AppColors.bgPanel,
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
    ),
    boxShadow: xl,
  );
}