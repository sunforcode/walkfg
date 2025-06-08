import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:walk/model/guide/guide_model.dart';
import 'package:walk/theme/theme/app_colors.dart';

/// 底部操作栏组件
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
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground.withOpacity(0.8),
            border: const Border(
              top: BorderSide(
                color: CupertinoColors.separator,
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                // 评论输入框
                Expanded(
                  child: GestureDetector(
                    onTap: onComment,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '写下你的评论...',
                        style: TextStyle(
                          color: CupertinoColors.secondaryLabel,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // 点赞按钮
                _buildActionButton(
                  isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                  isLiked
                      ? CupertinoColors.systemRed
                      : CupertinoColors.secondaryLabel,
                  onLike,
                ),

                const SizedBox(width: 12),

                // 收藏按钮
                _buildActionButton(
                  isBookmarked
                      ? CupertinoIcons.bookmark_fill
                      : CupertinoIcons.bookmark,
                  isBookmarked
                      ? AppColors.primary
                      : CupertinoColors.secondaryLabel,
                  onBookmark,
                ),

                const SizedBox(width: 12),

                // 分享按钮
                _buildActionButton(
                  CupertinoIcons.share,
                  CupertinoColors.secondaryLabel,
                  onShare,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButton(
      IconData icon, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
    );
  }
}