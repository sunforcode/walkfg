import 'package:flutter/cupertino.dart';
import 'package:walk/model/guide/guide_model.dart';
import 'package:walk/theme/tokens/colors.dart';
import 'package:walk/ui/page/common/network_image_with_fallback.dart';

import 'guide_detail_constants.dart';

/// 攻略封面组件
///
/// 显示攻略的封面图片、标签、难度等基本信息
class GuideCoverWidget extends StatelessWidget {
  /// 攻略数据
  final GuideModel guide;

  /// 构造函数
  const GuideCoverWidget({
    super.key,
    required this.guide,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _CoverConstants.coverHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 背景图片
          _buildCoverImage(),

          // 渐变遮罩
          _buildGradientOverlay(),

          // 标签
          if (guide.tags.isNotEmpty) _buildTagBadge(),

          // 底部信息
          _buildBottomInfo(),
        ],
      ),
    );
  }

  /// 构建封面图片
  Widget _buildCoverImage() {
    return Hero(
      tag: 'guide_image_${guide.id}',
      child: guide.coverUrl != null
          ? NetworkImageWithFallback(
              url: guide.coverUrl!,
              fit: BoxFit.cover,
              fallbackColor: AppColors.interactiveAccent,
              errorBuilder: (_) => _buildFallbackImage(),
            )
          : _buildFallbackImage(),
    );
  }

  /// 构建占位图片
  Widget _buildFallbackImage() {
    return Container(
      color: AppColors.interactiveAccent
          .withValues(alpha: _CoverConstants.fallbackImageOpacity),
      child: const Center(
        child: Icon(
          CupertinoIcons.photo,
          size: _CoverConstants.fallbackIconSize,
          color: AppColors.interactiveAccent,
        ),
      ),
    );
  }

  /// 构建渐变遮罩
  Widget _buildGradientOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: _CoverConstants.gradientHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              CupertinoColors.black.withValues(alpha: 0.0),
              CupertinoColors.black
                  .withValues(alpha: _CoverConstants.gradientOpacity),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建标签徽章
  Widget _buildTagBadge() {
    return Positioned(
      top: GuideDetailConstants.horizontalPadding,
      right: GuideDetailConstants.horizontalPadding,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: _CoverConstants.tagPaddingHorizontal,
          vertical: _CoverConstants.tagPaddingVertical,
        ),
        decoration: BoxDecoration(
          color: AppColors.interactiveAccent,
          borderRadius: BorderRadius.circular(_CoverConstants.tagBorderRadius),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black
                  .withValues(alpha: _CoverConstants.shadowOpacity),
              blurRadius: _CoverConstants.shadowBlurRadius,
              offset: const Offset(0, _CoverConstants.shadowOffsetY),
            ),
          ],
        ),
        child: Text(
          guide.tags.first,
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: _CoverConstants.tagFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// 构建底部信息
  Widget _buildBottomInfo() {
    return Positioned(
      bottom: GuideDetailConstants.horizontalPadding,
      left: GuideDetailConstants.horizontalPadding,
      right: GuideDetailConstants.horizontalPadding,
      child: Row(
        children: [
          // 难度指示
          _buildInfoBadge(
            icon: CupertinoIcons.chart_bar_alt_fill,
            text: guide.getDifficultyName(),
          ),
          const SizedBox(width: _CoverConstants.badgeSpacing),
          // 阅读时长
          _buildInfoBadge(
            icon: CupertinoIcons.time,
            text: guide.getReadingTimeText(),
          ),
          const Spacer(),
          // 阅读量
          _buildInfoBadge(
            icon: CupertinoIcons.eye,
            text: _formatNumber(guide.views),
          ),
        ],
      ),
    );
  }

  /// 构建信息徽章
  Widget _buildInfoBadge({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _CoverConstants.infoBadgePaddingHorizontal,
        vertical: _CoverConstants.infoBadgePaddingVertical,
      ),
      decoration: BoxDecoration(
        color: CupertinoColors.white
            .withValues(alpha: _CoverConstants.infoBadgeOpacity),
        borderRadius:
            BorderRadius.circular(_CoverConstants.infoBadgeBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: CupertinoColors.white,
            size: _CoverConstants.infoBadgeIconSize,
          ),
          const SizedBox(width: _CoverConstants.infoBadgeIconSpacing),
          Text(
            text,
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: _CoverConstants.infoBadgeFontSize,
            ),
          ),
        ],
      ),
    );
  }

  /// 格式化数字
  String _formatNumber(int number) {
    if (number >= _CoverConstants.thousandThreshold) {
      final double result = number / _CoverConstants.thousandThreshold;
      return '${result.toStringAsFixed(1)}k';
    }
    return number.toString();
  }
}

/// 封面组件私有常量
class _CoverConstants {
  _CoverConstants._();

  // ==================== 布局尺寸 ====================

  /// 封面高度
  static const double coverHeight = 250.0;

  /// 渐变遮罩高度
  static const double gradientHeight = 100.0;

  /// 标签内边距 - 水平
  static const double tagPaddingHorizontal = 12.0;

  /// 标签内边距 - 垂直
  static const double tagPaddingVertical = 6.0;

  /// 标签圆角半径
  static const double tagBorderRadius = 16.0;

  /// 信息徽章内边距 - 水平
  static const double infoBadgePaddingHorizontal = 10.0;

  /// 信息徽章内边距 - 垂直
  static const double infoBadgePaddingVertical = 4.0;

  /// 信息徽章圆角半径
  static const double infoBadgeBorderRadius = 12.0;

  /// 徽章间距
  static const double badgeSpacing = 8.0;

  /// 信息徽章图标间距
  static const double infoBadgeIconSpacing = 4.0;

  // ==================== 字体大小 ====================

  /// 标签字体大小
  static const double tagFontSize = 14.0;

  /// 信息徽章字体大小
  static const double infoBadgeFontSize = 12.0;

  /// 信息徽章图标大小
  static const double infoBadgeIconSize = 12.0;

  /// 占位图标大小
  static const double fallbackIconSize = 64.0;

  // ==================== 透明度和颜色 ====================

  /// 渐变遮罩透明度
  static const double gradientOpacity = 0.7;

  /// 信息徽章背景透明度
  static const double infoBadgeOpacity = 0.2;

  /// 占位图片背景透明度
  static const double fallbackImageOpacity = 0.2;

  /// 阴影透明度
  static const double shadowOpacity = 0.2;

  // ==================== 阴影配置 ====================

  /// 阴影模糊半径
  static const double shadowBlurRadius = 4.0;

  /// 阴影Y轴偏移
  static const double shadowOffsetY = 2.0;

  // ==================== 数值配置 ====================

  /// 千位数阈值
  static const int thousandThreshold = 1000;
}
