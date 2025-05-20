import 'package:flutter/material.dart';

/// 应用颜色主题
class AppColors {
  /// 蓝色系颜色列表
  static const List<Color> blueColors = [
    Color(0xFF1976D2), // 深蓝色
    Color(0xFF2196F3), // 蓝色
    Color(0xFF42A5F5), // 浅蓝色
    Color(0xFF64B5F6), // 更浅的蓝色
    Color(0xFF0D47A1), // 深邃蓝色
    Color(0xFF0288D1), // 亮蓝色
  ];
  
  /// 主色调
  static const Color primary = Color(0xFF1976D2);
  
  /// 次要色调
  static const Color secondary = Color(0xFF42A5F5);
  
  /// 强调色
  static const Color accent = Color(0xFF0288D1);
  
  /// 文本主色
  static const Color textPrimary = Color(0xFF212121);
  
  /// 文本次要色
  static const Color textSecondary = Color(0xFF757575);
  
  /// 背景色
  static const Color background = Color(0xFFF5F5F5);
  
  /// 卡片背景色
  static const Color cardBackground = Colors.white;
  
  /// 错误色
  static const Color error = Colors.red;
  
  /// 成功色
  static const Color success = Colors.green;
  
  /// 警告色
  static const Color warning = Colors.orange;
  
  /// 点赞色
  static const Color like = Colors.red;
  
  /// 获取指定索引的蓝色
  static Color getBlueColor(int index) {
    return blueColors[index % blueColors.length];
  }
  
  /// 获取带透明度的颜色
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}