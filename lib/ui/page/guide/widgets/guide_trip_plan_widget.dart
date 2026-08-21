import 'package:flutter/cupertino.dart';
import 'package:walk/model/guide/guide_model.dart';
import 'guide_detail_constants.dart';

/// 行程规划组件
///
/// 显示攻略的行程规划信息和亮点
class GuideTripPlanWidget extends StatelessWidget {
  /// 攻略数据
  final GuideModel guide;

  /// 构造函数
  const GuideTripPlanWidget({
    super.key,
    required this.guide,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(GuideDetailConstants.horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          _buildHeader(),

          const SizedBox(height: _TripPlanConstants.headerSpacing),

          // 推荐行程概览
          _buildTripOverview(context),

          const SizedBox(height: _TripPlanConstants.sectionSpacing),

          // 行程亮点
          _buildHighlightsSection(),

          const SizedBox(height: _TripPlanConstants.sectionSpacing),

          // 查看完整行程按钮
          _buildViewFullPlanButton(context),
        ],
      ),
    );
  }

  /// 构建头部标题
  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          CupertinoIcons.map,
          size: _TripPlanConstants.headerIconSize,
          color: CupertinoColors.systemOrange,
        ),
        const SizedBox(width: _TripPlanConstants.headerIconSpacing),
        Text(
          _TripPlanConstants.headerTitle,
          style: const TextStyle(
            fontSize: _TripPlanConstants.headerFontSize,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.label,
          ),
        ),
      ],
    );
  }

  /// 构建行程概览
  Widget _buildTripOverview(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_TripPlanConstants.overviewPadding),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius:
            BorderRadius.circular(_TripPlanConstants.overviewBorderRadius),
      ),
      child: Row(
        children: [
          // 图标
          _buildTripIcon(),
          const SizedBox(width: _TripPlanConstants.overviewSpacing),
          // 信息
          Expanded(
            child: _buildTripInfo(),
          ),
          // 按钮
          _buildViewButton(context),
        ],
      ),
    );
  }

  /// 构建行程图标
  Widget _buildTripIcon() {
    return Container(
      padding: const EdgeInsets.all(_TripPlanConstants.iconPadding),
      decoration: BoxDecoration(
        color: CupertinoColors.systemOrange
            .withOpacity(_TripPlanConstants.iconBackgroundOpacity),
        borderRadius:
            BorderRadius.circular(_TripPlanConstants.iconBorderRadius),
      ),
      child: Icon(
        CupertinoIcons.location,
        color: CupertinoColors.systemOrange,
        size: _TripPlanConstants.iconSize,
      ),
    );
  }

  /// 构建行程信息
  Widget _buildTripInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          _TripPlanConstants.recommendedTripTitle,
          style: TextStyle(
            fontSize: _TripPlanConstants.tripTitleFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: _TripPlanConstants.tripInfoSpacing),
        Text(
          guide.getTripDescription(),
          style: const TextStyle(
            fontSize: _TripPlanConstants.tripDescriptionFontSize,
            color: CupertinoColors.secondaryLabel,
          ),
        ),
      ],
    );
  }

  /// 构建查看按钮
  Widget _buildViewButton(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: _TripPlanConstants.viewButtonPaddingHorizontal,
          vertical: _TripPlanConstants.viewButtonPaddingVertical,
        ),
        decoration: BoxDecoration(
          color: CupertinoColors.systemOrange,
          borderRadius:
              BorderRadius.circular(_TripPlanConstants.viewButtonBorderRadius),
        ),
        child: const Text(
          _TripPlanConstants.viewButtonText,
          style: TextStyle(
            fontSize: _TripPlanConstants.viewButtonFontSize,
            color: CupertinoColors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      onPressed: () => _handleViewTrip(context),
    );
  }

  /// 构建行程亮点区域
  Widget _buildHighlightsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHighlightsTitle(),
        const SizedBox(height: _TripPlanConstants.highlightsSpacing),
        _buildHighlightsList(),
      ],
    );
  }

  /// 构建亮点标题
  Widget _buildHighlightsTitle() {
    return const Text(
      _TripPlanConstants.highlightsTitle,
      style: TextStyle(
        fontSize: _TripPlanConstants.highlightsTitleFontSize,
        fontWeight: FontWeight.w600,
        color: CupertinoColors.label,
      ),
    );
  }

  /// 构建亮点列表
  Widget _buildHighlightsList() {
    final highlights = guide.highlights.isNotEmpty
        ? guide.highlights.map((highlight) => (highlight, '')).toList()
        : _TripPlanConstants.defaultHighlights;

    return Column(
      children: highlights
          .map((highlight) => _buildHighlightItem(highlight.$1, highlight.$2))
          .toList(),
    );
  }

  /// 构建查看完整行程按钮
  Widget _buildViewFullPlanButton(BuildContext context) {
    return Center(
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(
          horizontal: _TripPlanConstants.fullPlanButtonPaddingHorizontal,
          vertical: _TripPlanConstants.fullPlanButtonPaddingVertical,
        ),
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(
            _TripPlanConstants.fullPlanButtonBorderRadius),
        child: Text(
          _TripPlanConstants.fullPlanButtonText,
          style: const TextStyle(
            fontSize: _TripPlanConstants.fullPlanButtonFontSize,
            color: CupertinoColors.systemOrange,
            fontWeight: FontWeight.w500,
          ),
        ),
        onPressed: () => _handleViewFullPlan(context),
      ),
    );
  }

  /// 构建行程亮点项
  Widget _buildHighlightItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(
          bottom: _TripPlanConstants.highlightItemSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            CupertinoIcons.checkmark_circle_fill,
            color: CupertinoColors.systemGreen,
            size: _TripPlanConstants.highlightIconSize,
          ),
          const SizedBox(width: _TripPlanConstants.highlightContentSpacing),
          Expanded(
            child: _buildHighlightContent(title, description),
          ),
        ],
      ),
    );
  }

  /// 构建亮点内容
  Widget _buildHighlightContent(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: _TripPlanConstants.highlightTitleFontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (description.isNotEmpty)
          Text(
            description,
            style: const TextStyle(
              fontSize: _TripPlanConstants.highlightDescriptionFontSize,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
      ],
    );
  }

  /// 处理查看行程
  void _handleViewTrip(BuildContext context) {
    // TODO: 实现查看行程功能
  }

  /// 处理查看完整行程规划
  void _handleViewFullPlan(BuildContext context) {
    // TODO: 实现查看完整行程规划功能
  }
}

/// 行程规划组件私有常量
class _TripPlanConstants {
  _TripPlanConstants._();

  // ==================== 布局尺寸 ====================

  /// 头部间距
  static const double headerSpacing = 16.0;

  /// 头部图标大小
  static const double headerIconSize = 20.0;

  /// 头部图标间距
  static const double headerIconSpacing = 8.0;

  /// 区域间距
  static const double sectionSpacing = 16.0;

  /// 概览内边距
  static const double overviewPadding = 16.0;

  /// 概览圆角半径
  static const double overviewBorderRadius = 12.0;

  /// 概览间距
  static const double overviewSpacing = 12.0;

  /// 图标内边距
  static const double iconPadding = 8.0;

  /// 图标大小
  static const double iconSize = 16.0;

  /// 图标圆角半径
  static const double iconBorderRadius = 8.0;

  /// 行程信息间距
  static const double tripInfoSpacing = 4.0;

  /// 查看按钮内边距 - 水平
  static const double viewButtonPaddingHorizontal = 12.0;

  /// 查看按钮内边距 - 垂直
  static const double viewButtonPaddingVertical = 6.0;

  /// 查看按钮圆角半径
  static const double viewButtonBorderRadius = 16.0;

  /// 亮点间距
  static const double highlightsSpacing = 12.0;

  /// 亮点项间距
  static const double highlightItemSpacing = 8.0;

  /// 亮点图标大小
  static const double highlightIconSize = 16.0;

  /// 亮点内容间距
  static const double highlightContentSpacing = 8.0;

  /// 完整行程按钮内边距 - 水平
  static const double fullPlanButtonPaddingHorizontal = 24.0;

  /// 完整行程按钮内边距 - 垂直
  static const double fullPlanButtonPaddingVertical = 8.0;

  /// 完整行程按钮圆角半径
  static const double fullPlanButtonBorderRadius = 20.0;

  // ==================== 字体大小 ====================

  /// 头部标题字体大小
  static const double headerFontSize = 18.0;

  /// 行程标题字体大小
  static const double tripTitleFontSize = 16.0;

  /// 行程描述字体大小
  static const double tripDescriptionFontSize = 14.0;

  /// 查看按钮字体大小
  static const double viewButtonFontSize = 14.0;

  /// 亮点标题字体大小
  static const double highlightsTitleFontSize = 16.0;

  /// 亮点项标题字体大小
  static const double highlightTitleFontSize = 14.0;

  /// 亮点项描述字体大小
  static const double highlightDescriptionFontSize = 12.0;

  /// 完整行程按钮字体大小
  static const double fullPlanButtonFontSize = 14.0;

  // ==================== 透明度 ====================

  /// 图标背景透明度
  static const double iconBackgroundOpacity = 0.1;

  // ==================== 文本内容 ====================

  /// 头部标题
  static const String headerTitle = '行程规划';

  /// 推荐行程标题
  static const String recommendedTripTitle = '推荐行程';

  /// 查看按钮文本
  static const String viewButtonText = '查看';

  /// 亮点标题
  static const String highlightsTitle = '行程亮点';

  /// 完整行程按钮文本
  static const String fullPlanButtonText = '查看完整行程规划';

  // ==================== 默认数据 ====================

  /// 默认亮点列表
  static const List<(String, String)> defaultHighlights = [
    ('精选路线', '经验丰富的向导精心规划的最佳路线'),
    ('风景优美', '沿途风景如画，适合拍照留念'),
    ('难度适中', '适合大多数徒步爱好者，无需专业装备'),
  ];
}
