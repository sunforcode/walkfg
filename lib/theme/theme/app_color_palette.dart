import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 应用颜色调色板
class AppColorPalette {
  /// 蓝色系颜色列表
  static const List<Color> blueColors = [
    Color(0xFF1976D2), // 深蓝色
    Color(0xFF2196F3), // 蓝色
    Color(0xFF42A5F5), // 浅蓝色
    Color(0xFF64B5F6), // 更浅的蓝色
    Color(0xFF0D47A1), // 深邃蓝色
    Color(0xFF0288D1), // 亮蓝色
  ];
  
  /// 获取蓝色系颜色
  static Color getBlueColor(int index) {
    return blueColors[index % blueColors.length];
  }
  
  /// 蓝色系渐变
  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1976D2), // 深蓝色
      Color(0xFF42A5F5), // 浅蓝色
    ],
  );
  
  /// 绿色系渐变
  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF388E3C), // 深绿色
      Color(0xFF66BB6A), // 浅绿色
    ],
  );
  
  /// 橙色系渐变
  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE64A19), // 深橙色
      Color(0xFFFF7043), // 浅橙色
    ],
  );
  
  /// 紫色系渐变
  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF7B1FA2), // 深紫色
      Color(0xFFAB47BC), // 浅紫色
    ],
  );
  
  /// 根据索引获取渐变色
  static LinearGradient getGradient(int index) {
    final gradients = [
      blueGradient,
      greenGradient,
      orangeGradient,
      purpleGradient,
    ];
    return gradients[index % gradients.length];
  }
}