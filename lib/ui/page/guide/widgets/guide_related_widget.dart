import 'package:flutter/cupertino.dart';
import 'package:walk/model/guide/guide_model.dart';
import 'package:walk/theme/tokens/colors.dart';
import 'package:walk/ui/page/common/network_image_with_fallback.dart';

import 'guide_detail_constants.dart';

/// 相关攻略组件
///
/// 显示与当前攻略相关的其他攻略推荐
class GuideRelatedWidget extends StatelessWidget {
  /// 攻略数据
  final GuideModel guide;

  /// 构造函数
  const GuideRelatedWidget({
    super.key,
    required this.guide,
  });

  @override
  Widget build(BuildContext context) {
    final relatedGuides = guide.relatedGuides ?? [];

    return Container(
      margin: const EdgeInsets.all(GuideDetailConstants.horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          _buildHeader(),

          const SizedBox(height: _RelatedConstants.headerSpacing),

          // 相关攻略内容
          relatedGuides.isNotEmpty
              ? _buildRelatedGuidesList(relatedGuides)
              : _buildEmptyState(),
        ],
      ),
    );
  }

  /// 构建头部标题
  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          CupertinoIcons.doc_text_search,
          size: _RelatedConstants.headerIconSize,
          color: CupertinoColors.systemTeal,
        ),
        const SizedBox(width: _RelatedConstants.headerIconSpacing),
        Text(
          _RelatedConstants.headerTitle,
          style: const TextStyle(
            fontSize: _RelatedConstants.headerFontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  /// 构建相关攻略列表
  Widget _buildRelatedGuidesList(List<GuideModel> relatedGuides) {
    return SizedBox(
      height: _RelatedConstants.listHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: relatedGuides.length,
        itemBuilder: (context, index) {
          final relatedGuide = relatedGuides[index];
          return _buildRelatedGuideCard(relatedGuide);
        },
      ),
    );
  }

  /// 构建相关攻略卡片
  Widget _buildRelatedGuideCard(GuideModel relatedGuide) {
    return Container(
      width: _RelatedConstants.cardWidth,
      margin: const EdgeInsets.only(right: _RelatedConstants.cardSpacing),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(_RelatedConstants.cardBorderRadius),
      ),
      child: GestureDetector(
        onTap: () => _handleGuideCardTap(relatedGuide),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片
            _buildCardImage(relatedGuide),

            // 内容
            _buildCardContent(relatedGuide),
          ],
        ),
      ),
    );
  }

  /// 构建卡片图片
  Widget _buildCardImage(GuideModel relatedGuide) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(_RelatedConstants.cardBorderRadius),
      ),
      child: SizedBox(
        height: _RelatedConstants.imageHeight,
        width: double.infinity,
        child: relatedGuide.coverUrl != null
            ? NetworkImageWithFallback(
                url: relatedGuide.coverUrl!,
                fit: BoxFit.cover,
                fallbackColor: AppColors.interactiveAccent,
                errorBuilder: (_) => _buildFallbackImage(),
              )
            : _buildFallbackImage(),
      ),
    );
  }

  /// 构建卡片内容
  Widget _buildCardContent(GuideModel relatedGuide) {
    return Padding(
      padding: const EdgeInsets.all(_RelatedConstants.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Text(
            relatedGuide.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: _RelatedConstants.titleFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: _RelatedConstants.contentSpacing),

          // 位置
          Text(
            relatedGuide.location,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: _RelatedConstants.locationFontSize,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: _RelatedConstants.contentSpacing),

          // 统计信息
          _buildCardStats(relatedGuide),
        ],
      ),
    );
  }

  /// 构建卡片统计信息
  Widget _buildCardStats(GuideModel relatedGuide) {
    return Row(
      children: [
        Icon(
          CupertinoIcons.eye,
          size: _RelatedConstants.statIconSize,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: _RelatedConstants.statIconSpacing),
        Text(
          _formatNumber(relatedGuide.views),
          style: const TextStyle(
            fontSize: _RelatedConstants.statFontSize,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: _RelatedConstants.difficultyPaddingHorizontal,
            vertical: _RelatedConstants.difficultyPaddingVertical,
          ),
          decoration: BoxDecoration(
            color: CupertinoColors.systemTeal.withValues(
                alpha: _RelatedConstants.difficultyBackgroundOpacity),
            borderRadius:
                BorderRadius.circular(_RelatedConstants.difficultyBorderRadius),
          ),
          child: Text(
            relatedGuide.getDifficultyName(),
            style: const TextStyle(
              fontSize: _RelatedConstants.difficultyFontSize,
              color: CupertinoColors.systemTeal,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建占位图片
  Widget _buildFallbackImage() {
    return Container(
      color: CupertinoColors.systemTeal
          .withValues(alpha: _RelatedConstants.fallbackImageOpacity),
      child: Icon(
        CupertinoIcons.photo,
        size: _RelatedConstants.fallbackIconSize,
        color: CupertinoColors.systemTeal
            .withValues(alpha: _RelatedConstants.fallbackIconOpacity),
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Container(
      height: _RelatedConstants.emptyStateHeight,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius:
            BorderRadius.circular(_RelatedConstants.emptyStateBorderRadius),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.doc_text,
              size: _RelatedConstants.emptyStateIconSize,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: _RelatedConstants.emptyStateSpacing),
            Text(
              _RelatedConstants.emptyStateText,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: _RelatedConstants.emptyStateFontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 处理攻略卡片点击
  void _handleGuideCardTap(GuideModel relatedGuide) {
    // TODO: 实现导航到相关攻略
  }

  /// 格式化数字
  String _formatNumber(int number) {
    if (number >= _RelatedConstants.thousandThreshold) {
      final double result = number / _RelatedConstants.thousandThreshold;
      return '${result.toStringAsFixed(1)}k';
    }
    return number.toString();
  }
}

/// 相关攻略组件私有常量
class _RelatedConstants {
  _RelatedConstants._();

  // ==================== 布局尺寸 ====================

  /// 头部间距
  static const double headerSpacing = 16.0;

  /// 头部图标大小
  static const double headerIconSize = 20.0;

  /// 头部图标间距
  static const double headerIconSpacing = 8.0;

  /// 列表高度
  static const double listHeight = 180.0;

  /// 卡片宽度
  static const double cardWidth = 200.0;

  /// 卡片间距
  static const double cardSpacing = 12.0;

  /// 卡片圆角半径
  static const double cardBorderRadius = 12.0;

  /// 卡片内边距
  static const double cardPadding = 12.0;

  /// 图片高度
  static const double imageHeight = 100.0;

  /// 内容间距
  static const double contentSpacing = 4.0;

  /// 统计图标大小
  static const double statIconSize = 12.0;

  /// 统计图标间距
  static const double statIconSpacing = 4.0;

  /// 难度标签内边距 - 水平
  static const double difficultyPaddingHorizontal = 6.0;

  /// 难度标签内边距 - 垂直
  static const double difficultyPaddingVertical = 2.0;

  /// 难度标签圆角半径
  static const double difficultyBorderRadius = 8.0;

  /// 占位图标大小
  static const double fallbackIconSize = 32.0;

  /// 空状态高度
  static const double emptyStateHeight = 120.0;

  /// 空状态圆角半径
  static const double emptyStateBorderRadius = 12.0;

  /// 空状态图标大小
  static const double emptyStateIconSize = 32.0;

  /// 空状态间距
  static const double emptyStateSpacing = 8.0;

  // ==================== 字体大小 ====================

  /// 头部标题字体大小
  static const double headerFontSize = 18.0;

  /// 卡片标题字体大小
  static const double titleFontSize = 14.0;

  /// 位置字体大小
  static const double locationFontSize = 12.0;

  /// 统计字体大小
  static const double statFontSize = 12.0;

  /// 难度字体大小
  static const double difficultyFontSize = 10.0;

  /// 空状态字体大小
  static const double emptyStateFontSize = 14.0;

  // ==================== 透明度 ====================

  /// 难度标签背景透明度
  static const double difficultyBackgroundOpacity = 0.1;

  /// 占位图片背景透明度
  static const double fallbackImageOpacity = 0.1;

  /// 占位图标透明度
  static const double fallbackIconOpacity = 0.5;

  // ==================== 数值配置 ====================

  /// 千位数阈值
  static const int thousandThreshold = 1000;

  // ==================== 文本内容 ====================

  /// 头部标题
  static const String headerTitle = '相关攻略';

  /// 空状态文本
  static const String emptyStateText = '暂无相关攻略';
}
