import 'package:flutter/animation.dart';

/// Walk v1 Design Token — 动画 (PRD §8.1.6)
///
/// 时长 + 缓动曲线。
class AppMotion {
  AppMotion._();

  // ============ 时长 ============
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration moderate = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 350);
  static const Duration lazy = Duration(milliseconds: 400);
  static const Duration slower = Duration(milliseconds: 500);
  static const Duration shimmer = Duration(milliseconds: 1500);

  // ============ 缓动曲线 ============
  /// 弹簧缓动：页面转场、抽屉、面板
  static const Curve spring = Cubic(0.32, 0.72, 0, 1);

  /// Material 缓动：Push/Pop、底部弹出、列表回流
  static const Curve material = Cubic(0.4, 0, 0.2, 1);

  /// 标准缓动：折叠、遮罩、入场错开
  static const Curve standard = Curves.ease;

  /// 退出缓动：Pop 返回、淡出、Toast
  static const Curve out = Curves.easeOut;

  /// 线性：骨架屏、加载旋转
  static const Curve linear = Curves.linear;
}
