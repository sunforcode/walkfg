import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 通用信息标签组件
class InfoChip extends StatelessWidget {
  /// 图标
  final IconData icon;
  
  /// 标签文本
  final String label;
  
  /// 颜色
  final Color color;
  
  /// 边框宽度
  final double borderWidth;
  
  /// 圆角半径
  final double borderRadius;
  
  /// 构造函数
  const InfoChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.borderWidth = 1,
    this.borderRadius = 16,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: color.withOpacity(0.3), width: borderWidth),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}