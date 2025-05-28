import 'package:flutter/material.dart';
import 'package:walk/model/route/route_enums.dart';

/// 行程工具类
class TripUtils {
  /// 获取难度名称
  static String getDifficultyName(RouteDifficulty difficulty) {
    return difficulty.getName();
  }

  /// 获取难度颜色
  static Color getDifficultyColor(RouteDifficulty difficulty) {
    return difficulty.getColor();
  }
}
