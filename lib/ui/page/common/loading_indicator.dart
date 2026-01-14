import 'package:flutter/material.dart';
import 'package:walk/theme/tokens/colors.dart';

/// 通用加载指示器组件
class LoadingIndicator extends StatelessWidget {
  /// 高度
  final double height;
  
  /// 颜色
  final Color? color;
  
  /// 构造函数
  const LoadingIndicator({
    super.key,
    this.height = 200,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppColors.primary,
          ),
        ),
      ),
    );
  }
}