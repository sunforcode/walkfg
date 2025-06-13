import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:walk/model/guide/guide_model.dart';

/// 底部操作栏组件
///
/// 提供点赞、收藏、分享、评论等操作功能
class GuideActionBarWidget extends StatelessWidget {
  /// 攻略数据
  final GuideModel guide;

  /// 是否已点赞
  final bool isLiked;

  /// 是否已收藏
  final bool isBookmarked;

  /// 点赞回调
  final VoidCallback onLike;

  /// 收藏回调
  final VoidCallback onBookmark;

  /// 分享回调
  final VoidCallback onShare;

  /// 评论回调
  final VoidCallback onComment;

  /// 构造函数
  const GuideActionBarWidget({
    super.key,
    required this.guide,
    required this.isLiked,
    required this.isBookmarked,
    required this.onLike,
    required this.onBookmark,
    required this.onShare,
    required this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: _ActionBarConstants.blurSigma,
          sigmaY: _ActionBarConstants.blurSigma,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: _ActionBarConstants.verticalPadding,
            horizontal: _ActionBarConstants.horizontalPadding,
          ),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground
                .withOpacity(_ActionBarConstants.backgroundOpacity),
            border: const Border(
              top: BorderSide(
                color: CupertinoColors.separator,
                width: _ActionBarConstants.borderWidth,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                // 评论输入框
                Expanded(
                  child: _buildCommentInput(),
                ),

                const SizedBox(width: _ActionBarConstants.buttonSpacing),

                // 点赞按钮
                _buildLikeButton(),

                const SizedBox(width: _ActionBarConstants.buttonSpacing),

                // 收藏按钮
                _buildBookmarkButton(),

                const SizedBox(width: _ActionBarConstants.buttonSpacing),

                // 分享按钮
                _buildShareButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建评论输入框
  Widget _buildCommentInput() {
    return GestureDetector(
      onTap: onComment,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: _ActionBarConstants.commentInputPaddingHorizontal,
          vertical: _ActionBarConstants.commentInputPaddingVertical,
        ),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(
              _ActionBarConstants.commentInputBorderRadius),
        ),
        child: const Text(
          _ActionBarConstants.commentPlaceholder,
          style: TextStyle(
            color: CupertinoColors.secondaryLabel,
            fontSize: _ActionBarConstants.commentInputFontSize,
          ),
        ),
      ),
    );
  }

  /// 构建点赞按钮
  Widget _buildLikeButton() {
    return _buildActionButton(
      isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
      isLiked ? CupertinoColors.systemRed : CupertinoColors.secondaryLabel,
      onLike,
    );
  }

  /// 构建收藏按钮
  Widget _buildBookmarkButton() {
    return _buildActionButton(
      isBookmarked ? CupertinoIcons.bookmark_fill : CupertinoIcons.bookmark,
      isBookmarked
          ? CupertinoColors.systemBlue
          : CupertinoColors.secondaryLabel,
      onBookmark,
    );
  }

  /// 构建分享按钮
  Widget _buildShareButton() {
    return _buildActionButton(
      CupertinoIcons.share,
      CupertinoColors.secondaryLabel,
      onShare,
    );
  }

  /// 构建操作按钮
  Widget _buildActionButton(
      IconData icon, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: _ActionBarConstants.buttonSize,
        height: _ActionBarConstants.buttonSize,
        decoration: BoxDecoration(
          color: color.withOpacity(_ActionBarConstants.buttonBackgroundOpacity),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: color,
          size: _ActionBarConstants.buttonIconSize,
        ),
      ),
    );
  }
}

/// 操作栏组件私有常量
class _ActionBarConstants {
  _ActionBarConstants._();

  // ==================== 布局尺寸 ====================

  /// 垂直内边距
  static const double verticalPadding = 12.0;

  /// 水平内边距
  static const double horizontalPadding = 16.0;

  /// 按钮间距
  static const double buttonSpacing = 12.0;

  /// 按钮大小
  static const double buttonSize = 36.0;

  /// 按钮图标大小
  static const double buttonIconSize = 20.0;

  /// 评论输入框内边距 - 水平
  static const double commentInputPaddingHorizontal = 16.0;

  /// 评论输入框内边距 - 垂直
  static const double commentInputPaddingVertical = 8.0;

  /// 评论输入框圆角半径
  static const double commentInputBorderRadius = 20.0;

  /// 边框宽度
  static const double borderWidth = 0.5;

  // ==================== 字体大小 ====================

  /// 评论输入框字体大小
  static const double commentInputFontSize = 14.0;

  // ==================== 透明度和效果 ====================

  /// 背景透明度
  static const double backgroundOpacity = 0.8;

  /// 按钮背景透明度
  static const double buttonBackgroundOpacity = 0.1;

  /// 模糊效果强度
  static const double blurSigma = 10.0;

  // ==================== 文本内容 ====================

  /// 评论输入框占位符
  static const String commentPlaceholder = '写下你的评论...';
}
