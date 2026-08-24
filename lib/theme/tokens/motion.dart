import 'package:flutter/animation.dart';

/// Semantic motion tokens.
class AppMotion {
  AppMotion._();

  static const Duration press = Duration(milliseconds: 100);
  static const Duration feedback = Duration(milliseconds: 200);
  static const Duration transition = Duration(milliseconds: 300);
  static const Duration drawer = Duration(milliseconds: 350);
  static const Duration loading = Duration(milliseconds: 1500);

  static const Curve spring = Cubic(0.32, 0.72, 0, 1);
  static const Curve material = Cubic(0.4, 0, 0.2, 1);
  static const Curve standard = Curves.ease;
  static const Curve out = Curves.easeOut;
  static const Curve linear = Curves.linear;
}
