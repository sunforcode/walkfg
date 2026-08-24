import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

  /// 受控加载占位；未提供时使用默认进度指示器。
  final WidgetBuilder? placeholderBuilder;

  /// 受控失败占位；未提供时使用默认图标占位。
  final WidgetBuilder? errorBuilder;

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
    this.placeholderBuilder,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final imageWidget = url.trim().isEmpty
        ? errorBuilder?.call(context) ?? _buildDefaultError()
        : CachedNetworkImage(
            imageUrl: url,
            width: width,
            height: height,
            fit: fit,
            placeholder: (context, url) =>
                placeholderBuilder?.call(context) ??
                Container(
                  width: width,
                  height: height,
                  color: fallbackColor.withValues(alpha: 0.1),
                  child: Center(
                    child: CupertinoActivityIndicator(color: fallbackColor),
                  ),
                ),
            errorWidget: (context, url, error) =>
                errorBuilder?.call(context) ?? _buildDefaultError(),
            // 缓存配置
            memCacheWidth: 800,
            memCacheHeight: 800,
            maxWidthDiskCache: 1500,
            maxHeightDiskCache: 1500,
          );

    if (borderRadius > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildDefaultError() {
    return Container(
      width: width,
      height: height,
      color: fallbackColor.withValues(alpha: 0.2),
      child: Center(
        child: Icon(
          fallbackIcon,
          size: height != null ? height! * 0.3 : 40,
          color: fallbackColor,
        ),
      ),
    );
  }
}
