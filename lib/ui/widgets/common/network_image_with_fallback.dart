import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 通用网络图片加载组件（带有占位图和错误处理）
class NetworkImageWithFallback extends StatelessWidget {
  /// 图片URL
  final String url;
  
  /// 宽度
  final double? width;
  
  /// 高度
  final double? height;
  
  /// 填充方式
  final BoxFit fit;
  
  /// 占位图颜色
  final Color fallbackColor;
  
  /// 占位图图标
  final IconData fallbackIcon;
  
  /// 边框圆角
  final double borderRadius;
  
  /// 构造函数
  const NetworkImageWithFallback({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackColor = CupertinoColors.systemBlue,
    this.fallbackIcon = CupertinoIcons.photo,
    this.borderRadius = 0,
  });
  
  @override
  Widget build(BuildContext context) {
    final imageWidget = Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Container(
        width: width,
        height: height,
        color: fallbackColor.withOpacity(0.2),
        child: Center(
          child: Icon(
            fallbackIcon,
            size: height != null ? height! * 0.3 : 40,
            color: fallbackColor,
          ),
        ),
      ),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return Container(
          width: width,
          height: height,
          color: fallbackColor.withOpacity(0.1),
          child: Center(
            child: CupertinoActivityIndicator(
              color: fallbackColor,
            ),
          ),
        );
      },
    );

    if (borderRadius > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}