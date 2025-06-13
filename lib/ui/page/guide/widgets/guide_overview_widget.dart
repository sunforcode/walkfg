import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/model/guide/guide_model.dart';
import 'package:walk/utils/toast_utils.dart';
import 'guide_detail_constants.dart';

/// 攻略概览组件
///
/// 显示攻略的标题、作者信息、统计数据和快速操作按钮
class GuideOverviewWidget extends StatelessWidget {
  /// 攻略数据
  final GuideModel guide;

  /// 构造函数
  const GuideOverviewWidget({
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
          // 标题和作者信息
          _buildHeaderSection(context),

          const SizedBox(height: _OverviewConstants.sectionSpacing),

          // 快速操作按钮
          _buildQuickActionsSection(context),
        ],
      ),
    );
  }

  /// 构建头部信息区域
  Widget _buildHeaderSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        _buildTitle(),
        const SizedBox(height: _OverviewConstants.titleSpacing),

        // 作者信息和统计
        Row(
          children: [
            // 作者头像和名称
            _buildAuthorInfo(context),
            const Spacer(),
            // 统计信息
            _buildStatsInfo(),
          ],
        ),
      ],
    );
  }

  /// 构建标题
  Widget _buildTitle() {
    return Text(
      guide.title,
      style: const TextStyle(
        fontSize: _OverviewConstants.titleFontSize,
        fontWeight: FontWeight.bold,
        color: CupertinoColors.label,
      ),
    );
  }

  /// 构建作者信息
  Widget _buildAuthorInfo(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAuthorProfile(context),
      child: Row(
        children: [
          _buildAuthorAvatar(),
          const SizedBox(width: _OverviewConstants.authorInfoSpacing),
          _buildAuthorDetails(),
        ],
      ),
    );
  }

  /// 构建作者头像
  Widget _buildAuthorAvatar() {
    return CircleAvatar(
      radius: _OverviewConstants.avatarRadius,
      backgroundImage: guide.authorAvatarUrl != null
          ? NetworkImage(guide.authorAvatarUrl!)
          : null,
      backgroundColor: CupertinoColors.systemBlue
          .withOpacity(_OverviewConstants.avatarBackgroundOpacity),
      child: guide.authorAvatarUrl == null
          ? Icon(
              CupertinoIcons.person,
              size: _OverviewConstants.avatarIconSize,
              color: CupertinoColors.systemBlue,
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
            fontSize: _OverviewConstants.authorNameFontSize,
            fontWeight: FontWeight.w500,
            color: CupertinoColors.label,
          ),
        ),
        Text(
          _getTimeAgo(guide.publishDate),
          style: const TextStyle(
            fontSize: _OverviewConstants.publishTimeFontSize,
            color: CupertinoColors.secondaryLabel,
          ),
        ),
      ],
    );
  }

  /// 构建统计信息
  Widget _buildStatsInfo() {
    return Row(
      children: [
        // 阅读量
        _buildStatItem(
          icon: CupertinoIcons.eye,
          value: _formatNumber(guide.views),
        ),
        const SizedBox(width: _OverviewConstants.statsSpacing),
        // 点赞数
        _buildStatItem(
          icon: CupertinoIcons.heart,
          value: _formatNumber(guide.likes),
        ),
      ],
    );
  }

  /// 构建统计项
  Widget _buildStatItem({
    required IconData icon,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: _OverviewConstants.statIconSize,
          color: CupertinoColors.secondaryLabel,
        ),
        const SizedBox(width: _OverviewConstants.statIconSpacing),
        Text(
          value,
          style: const TextStyle(
            fontSize: _OverviewConstants.statValueFontSize,
            color: CupertinoColors.secondaryLabel,
          ),
        ),
      ],
    );
  }

  /// 构建快速操作区域
  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuickActionsTitle(),
        const SizedBox(height: _OverviewConstants.quickActionsTitleSpacing),
        _buildQuickActionButtons(context),
      ],
    );
  }

  /// 构建快速操作标题
  Widget _buildQuickActionsTitle() {
    return const Text(
      _OverviewConstants.quickActionsTitle,
      style: TextStyle(
        fontSize: _OverviewConstants.quickActionsTitleFontSize,
        fontWeight: FontWeight.w600,
        color: CupertinoColors.label,
      ),
    );
  }

  /// 构建快速操作按钮列表
  Widget _buildQuickActionButtons(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildQuickActionButton(
            label: _OverviewConstants.pdfSaveLabel,
            icon: CupertinoIcons.doc_text,
            color: CupertinoColors.systemBlue,
            onPressed: () => _handlePdfSave(context),
          ),
          _buildQuickActionButton(
            label: _OverviewConstants.offlineSaveLabel,
            icon: CupertinoIcons.cloud_download,
            color: CupertinoColors.systemGreen,
            onPressed: () => _handleOfflineSave(context),
          ),
          _buildQuickActionButton(
            label: _OverviewConstants.relatedRoutesLabel,
            icon: CupertinoIcons.map,
            color: CupertinoColors.systemOrange,
            onPressed: () => _handleRelatedRoutes(context),
          ),
          _buildQuickActionButton(
            label: _OverviewConstants.equipmentListLabel,
            icon: CupertinoIcons.bag,
            color: CupertinoColors.systemPurple,
            onPressed: () => _handleEquipmentList(context),
          ),
        ],
      ),
    );
  }

  /// 构建快速操作按钮
  Widget _buildQuickActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.only(
          right: _OverviewConstants.quickActionButtonSpacing),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(
          horizontal: _OverviewConstants.quickActionButtonPaddingHorizontal,
          vertical: _OverviewConstants.quickActionButtonPaddingVertical,
        ),
        color: color.withOpacity(_OverviewConstants.quickActionButtonOpacity),
        borderRadius: BorderRadius.circular(
            _OverviewConstants.quickActionButtonBorderRadius),
        minSize: 0,
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: _OverviewConstants.quickActionIconSize,
            ),
            const SizedBox(width: _OverviewConstants.quickActionIconSpacing),
            Text(
              label,
              style: TextStyle(
                fontSize: _OverviewConstants.quickActionLabelFontSize,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 处理作者资料查看
  void _showAuthorProfile(BuildContext context) {
    ToastUtils.showToast(context, '正在查看${guide.author}的资料');
  }

  /// 处理PDF保存
  void _handlePdfSave(BuildContext context) {
    ToastUtils.showToast(context, _OverviewConstants.pdfSaveMessage);
  }

  /// 处理离线保存
  void _handleOfflineSave(BuildContext context) {
    ToastUtils.showToast(context, _OverviewConstants.offlineSaveMessage);
  }

  /// 处理相关路线
  void _handleRelatedRoutes(BuildContext context) {
    ToastUtils.showToast(context, _OverviewConstants.relatedRoutesMessage);
  }

  /// 处理装备清单
  void _handleEquipmentList(BuildContext context) {
    ToastUtils.showToast(context, _OverviewConstants.equipmentListMessage);
  }

  /// 格式化数字
  String _formatNumber(int number) {
    if (number >= _OverviewConstants.thousandThreshold) {
      final double result = number / _OverviewConstants.thousandThreshold;
      return '${result.toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  /// 获取相对时间
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > _OverviewConstants.yearInDays) {
      return '${(difference.inDays / _OverviewConstants.yearInDays).floor()}年前';
    } else if (difference.inDays > _OverviewConstants.monthInDays) {
      return '${(difference.inDays / _OverviewConstants.monthInDays).floor()}月前';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return _OverviewConstants.justNowText;
    }
  }
}

/// 概览组件私有常量
class _OverviewConstants {
  _OverviewConstants._();

  // ==================== 布局尺寸 ====================

  /// 区域间距
  static const double sectionSpacing = 20.0;

  /// 标题间距
  static const double titleSpacing = 12.0;

  /// 头像半径
  static const double avatarRadius = 16.0;

  /// 头像图标大小
  static const double avatarIconSize = 16.0;

  /// 作者信息间距
  static const double authorInfoSpacing = 8.0;

  /// 统计信息间距
  static const double statsSpacing = 16.0;

  /// 统计图标间距
  static const double statIconSpacing = 4.0;

  /// 快速操作标题间距
  static const double quickActionsTitleSpacing = 12.0;

  /// 快速操作按钮间距
  static const double quickActionButtonSpacing = 8.0;

  /// 快速操作按钮内边距 - 水平
  static const double quickActionButtonPaddingHorizontal = 12.0;

  /// 快速操作按钮内边距 - 垂直
  static const double quickActionButtonPaddingVertical = 6.0;

  /// 快速操作按钮圆角半径
  static const double quickActionButtonBorderRadius = 16.0;

  /// 快速操作图标间距
  static const double quickActionIconSpacing = 4.0;

  // ==================== 字体大小 ====================

  /// 标题字体大小
  static const double titleFontSize = 24.0;

  /// 作者名称字体大小
  static const double authorNameFontSize = 14.0;

  /// 发布时间字体大小
  static const double publishTimeFontSize = 12.0;

  /// 统计图标大小
  static const double statIconSize = 16.0;

  /// 统计值字体大小
  static const double statValueFontSize = 14.0;

  /// 快速操作标题字体大小
  static const double quickActionsTitleFontSize = 16.0;

  /// 快速操作图标大小
  static const double quickActionIconSize = 14.0;

  /// 快速操作标签字体大小
  static const double quickActionLabelFontSize = 12.0;

  // ==================== 透明度 ====================

  /// 头像背景透明度
  static const double avatarBackgroundOpacity = 0.1;

  /// 快速操作按钮背景透明度
  static const double quickActionButtonOpacity = 0.1;

  // ==================== 时间计算 ====================

  /// 一年的天数
  static const int yearInDays = 365;

  /// 一月的天数
  static const int monthInDays = 30;

  /// 千位数阈值
  static const int thousandThreshold = 1000;

  // ==================== 文本内容 ====================

  /// 快速操作标题
  static const String quickActionsTitle = '快速操作';

  /// PDF保存标签
  static const String pdfSaveLabel = 'PDF保存';

  /// 离线保存标签
  static const String offlineSaveLabel = '离线保存';

  /// 相关路线标签
  static const String relatedRoutesLabel = '相关路线';

  /// 装备清单标签
  static const String equipmentListLabel = '装备清单';

  /// PDF保存消息
  static const String pdfSaveMessage = 'PDF保存功能开发中';

  /// 离线保存消息
  static const String offlineSaveMessage = '攻略已保存到离线列表';

  /// 相关路线消息
  static const String relatedRoutesMessage = '相关路线功能开发中';

  /// 装备清单消息
  static const String equipmentListMessage = '装备清单功能开发中';

  /// 刚刚文本
  static const String justNowText = '刚刚';
}
