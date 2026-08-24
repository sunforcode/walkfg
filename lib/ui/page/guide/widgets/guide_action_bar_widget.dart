import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:walk/model/guide/guide_model.dart';
import 'package:walk/theme/tokens/blur.dart';
import 'package:walk/theme/tokens/colors.dart';
import 'package:walk/theme/tokens/radius.dart';
import 'package:walk/theme/tokens/spacing.dart';
import 'package:walk/theme/tokens/typography.dart';

/// 底部操作栏组件。
///
/// 保留评论、点赞、收藏和分享入口，视觉使用公共暗色操作原语。
class GuideActionBarWidget extends StatelessWidget {
  final GuideModel guide;
  final bool isLiked;
  final bool isBookmarked;
  final VoidCallback onLike;
  final VoidCallback onBookmark;
  final VoidCallback onShare;
  final VoidCallback onComment;

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
          sigmaX: AppBlur.control,
          sigmaY: AppBlur.control,
        ),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.surfaceGlass,
            border: Border(
              top: BorderSide(
                color: AppColors.border,
                width: _ActionBarConstants.borderWidth,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.md,
                horizontal: AppSpacing.pageHorizontal,
              ),
              child: Row(
                children: [
                  Expanded(child: _buildCommentInput()),
                  const SizedBox(width: AppSpacing.md),
                  _buildLikeButton(),
                  const SizedBox(width: AppSpacing.md),
                  _buildBookmarkButton(),
                  const SizedBox(width: AppSpacing.md),
                  _buildShareButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommentInput() {
    return Semantics(
      button: true,
      label: _ActionBarConstants.commentPlaceholder,
      child: GestureDetector(
        onTap: onComment,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: AppRadius.borderFull,
          ),
          child: Text(
            _ActionBarConstants.commentPlaceholder,
            style: AppTypography.label.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildLikeButton() => _buildActionButton(
        semanticLabel: '点赞',
        icon: isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
        color: isLiked ? AppColors.error : AppColors.textSecondary,
        onPressed: onLike,
      );

  Widget _buildBookmarkButton() => _buildActionButton(
        semanticLabel: '收藏',
        icon: isBookmarked
            ? CupertinoIcons.bookmark_fill
            : CupertinoIcons.bookmark,
        color: isBookmarked
            ? AppColors.interactiveAccent
            : AppColors.textSecondary,
        onPressed: onBookmark,
      );

  Widget _buildShareButton() => _buildActionButton(
        semanticLabel: '分享',
        icon: CupertinoIcons.share,
        color: AppColors.textSecondary,
        onPressed: onShare,
      );

  Widget _buildActionButton({
    required String semanticLabel,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: _ActionBarConstants.buttonSize,
          height: _ActionBarConstants.buttonSize,
          decoration: const BoxDecoration(
            color: AppColors.surfaceCard,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: _ActionBarConstants.buttonIconSize,
          ),
        ),
      ),
    );
  }
}

class _ActionBarConstants {
  _ActionBarConstants._();

  // Domain geometry: preserves the existing compact action-bar hit layout.
  static const double buttonSize = 36.0;
  static const double buttonIconSize = 20.0;
  static const double borderWidth = 0.5;
  static const String commentPlaceholder = '写下你的评论...';
}
