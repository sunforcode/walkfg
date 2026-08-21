import 'package:flutter/cupertino.dart';
import 'package:walk/model/guide/guide_model.dart';
import 'guide_detail_constants.dart';

/// 作者推荐组件
///
/// 显示攻略作者的信息和个人提示
class GuideAuthorWidget extends StatelessWidget {
  /// 攻略数据
  final GuideModel guide;

  /// 构造函数
  const GuideAuthorWidget({
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

          const SizedBox(height: _AuthorConstants.headerSpacing),

          // 作者信息行
          _buildAuthorInfo(context),

          const SizedBox(height: _AuthorConstants.sectionSpacing),

          // 作者提示
          _buildAuthorTips(),
        ],
      ),
    );
  }

  /// 构建头部标题
  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          CupertinoIcons.person_circle,
          size: _AuthorConstants.headerIconSize,
          color: CupertinoColors.systemPurple,
        ),
        const SizedBox(width: _AuthorConstants.headerIconSpacing),
        Text(
          _AuthorConstants.headerTitle,
          style: const TextStyle(
            fontSize: _AuthorConstants.headerFontSize,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.label,
          ),
        ),
      ],
    );
  }

  /// 构建作者信息行
  Widget _buildAuthorInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_AuthorConstants.authorInfoPadding),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius:
            BorderRadius.circular(_AuthorConstants.authorInfoBorderRadius),
      ),
      child: Row(
        children: [
          // 作者头像
          _buildAuthorAvatar(),
          const SizedBox(width: _AuthorConstants.authorInfoSpacing),
          // 作者信息
          Expanded(
            child: _buildAuthorDetails(),
          ),
          // 关注按钮
          _buildFollowButton(context),
        ],
      ),
    );
  }

  /// 构建作者头像
  Widget _buildAuthorAvatar() {
    final double diameter = _AuthorConstants.avatarRadius * 2;
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: CupertinoColors.systemPurple
            .withValues(alpha: _AuthorConstants.avatarBackgroundOpacity),
        image: guide.authorAvatarUrl != null
            ? DecorationImage(
                image: NetworkImage(guide.authorAvatarUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: guide.authorAvatarUrl == null
          ? Icon(
              CupertinoIcons.person,
              size: _AuthorConstants.avatarIconSize,
              color: CupertinoColors.systemPurple,
            )
          : null,
    );
  }

  /// 构建作者详细信息
  Widget _buildAuthorDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          guide.author,
          style: const TextStyle(
            fontSize: _AuthorConstants.authorNameFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: _AuthorConstants.authorDetailsSpacing),
        Text(
          guide.getAuthorExperienceText(),
          style: const TextStyle(
            fontSize: _AuthorConstants.experienceFontSize,
            color: CupertinoColors.secondaryLabel,
          ),
        ),
      ],
    );
  }

  /// 构建关注按钮
  Widget _buildFollowButton(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: _AuthorConstants.followButtonPaddingHorizontal,
          vertical: _AuthorConstants.followButtonPaddingVertical,
        ),
        decoration: BoxDecoration(
          color: CupertinoColors.systemPurple
              .withValues(alpha: _AuthorConstants.followButtonBackgroundOpacity),
          borderRadius:
              BorderRadius.circular(_AuthorConstants.followButtonBorderRadius),
          border: Border.all(
            color: CupertinoColors.systemPurple,
            width: _AuthorConstants.followButtonBorderWidth,
          ),
        ),
        child: Text(
          _AuthorConstants.followButtonText,
          style: const TextStyle(
            fontSize: _AuthorConstants.followButtonFontSize,
            color: CupertinoColors.systemPurple,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      onPressed: () => _handleFollow(context),
    );
  }

  /// 构建作者提示区域
  Widget _buildAuthorTips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTipsTitle(),
        const SizedBox(height: _AuthorConstants.tipsSpacing),
        _buildTipsContent(),
      ],
    );
  }

  /// 构建提示标题
  Widget _buildTipsTitle() {
    return const Text(
      _AuthorConstants.tipsTitle,
      style: TextStyle(
        fontSize: _AuthorConstants.tipsTitleFontSize,
        fontWeight: FontWeight.w600,
        color: CupertinoColors.label,
      ),
    );
  }

  /// 构建提示内容
  Widget _buildTipsContent() {
    return Container(
      padding: const EdgeInsets.all(_AuthorConstants.tipsContentPadding),
      decoration: BoxDecoration(
        color: CupertinoColors.systemYellow
            .withValues(alpha: _AuthorConstants.tipsBackgroundOpacity),
        borderRadius: BorderRadius.circular(_AuthorConstants.tipsBorderRadius),
        border: Border.all(
          color: CupertinoColors.systemYellow
              .withValues(alpha: _AuthorConstants.tipsBorderOpacity),
          width: _AuthorConstants.tipsBorderWidth,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            CupertinoIcons.lightbulb_fill,
            color: CupertinoColors.systemYellow,
            size: _AuthorConstants.tipsIconSize,
          ),
          const SizedBox(width: _AuthorConstants.tipsIconSpacing),
          Expanded(
            child: Text(
              _getTipsText(),
              style: const TextStyle(
                fontSize: _AuthorConstants.tipsTextFontSize,
                color: CupertinoColors.label,
                height: _AuthorConstants.tipsTextLineHeight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 获取提示文本
  String _getTipsText() {
    return guide.personalTips.isNotEmpty
        ? guide.personalTips.join(' ')
        : _AuthorConstants.defaultTipsText;
  }

  /// 处理关注操作
  void _handleFollow(BuildContext context) {
    // TODO: 实现关注功能
  }
}

/// 作者组件私有常量
class _AuthorConstants {
  _AuthorConstants._();

  // ==================== 布局尺寸 ====================

  /// 头部间距
  static const double headerSpacing = 16.0;

  /// 头部图标大小
  static const double headerIconSize = 20.0;

  /// 头部图标间距
  static const double headerIconSpacing = 8.0;

  /// 区域间距
  static const double sectionSpacing = 16.0;

  /// 作者信息内边距
  static const double authorInfoPadding = 16.0;

  /// 作者信息圆角半径
  static const double authorInfoBorderRadius = 12.0;

  /// 作者信息间距
  static const double authorInfoSpacing = 12.0;

  /// 头像半径
  static const double avatarRadius = 20.0;

  /// 头像图标大小
  static const double avatarIconSize = 20.0;

  /// 作者详情间距
  static const double authorDetailsSpacing = 4.0;

  /// 关注按钮内边距 - 水平
  static const double followButtonPaddingHorizontal = 12.0;

  /// 关注按钮内边距 - 垂直
  static const double followButtonPaddingVertical = 6.0;

  /// 关注按钮圆角半径
  static const double followButtonBorderRadius = 16.0;

  /// 关注按钮边框宽度
  static const double followButtonBorderWidth = 0.5;

  /// 提示间距
  static const double tipsSpacing = 12.0;

  /// 提示内容内边距
  static const double tipsContentPadding = 12.0;

  /// 提示圆角半径
  static const double tipsBorderRadius = 8.0;

  /// 提示边框宽度
  static const double tipsBorderWidth = 0.5;

  /// 提示图标大小
  static const double tipsIconSize = 16.0;

  /// 提示图标间距
  static const double tipsIconSpacing = 8.0;

  // ==================== 字体大小 ====================

  /// 头部标题字体大小
  static const double headerFontSize = 18.0;

  /// 作者名称字体大小
  static const double authorNameFontSize = 16.0;

  /// 经验文本字体大小
  static const double experienceFontSize = 12.0;

  /// 关注按钮字体大小
  static const double followButtonFontSize = 14.0;

  /// 提示标题字体大小
  static const double tipsTitleFontSize = 16.0;

  /// 提示文本字体大小
  static const double tipsTextFontSize = 13.0;

  /// 提示文本行高
  static const double tipsTextLineHeight = 1.4;

  // ==================== 透明度 ====================

  /// 头像背景透明度
  static const double avatarBackgroundOpacity = 0.1;

  /// 关注按钮背景透明度
  static const double followButtonBackgroundOpacity = 0.1;

  /// 提示背景透明度
  static const double tipsBackgroundOpacity = 0.1;

  /// 提示边框透明度
  static const double tipsBorderOpacity = 0.3;

  // ==================== 文本内容 ====================

  /// 头部标题
  static const String headerTitle = '作者推荐';

  /// 关注按钮文本
  static const String followButtonText = '关注';

  /// 提示标题
  static const String tipsTitle = '作者提示';

  /// 默认提示文本
  static const String defaultTipsText =
      '这条路线在雨季可能会有部分路段泥泞，建议携带防水鞋套和雨衣。夏季蚊虫较多，请做好防蚊准备。';
}
