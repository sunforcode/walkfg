import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../model/guide/guide_model.dart';
import 'package:walk/theme/tokens/colors.dart';
import '../../common/network_image_with_fallback.dart';
import '../guide_detail_screen.dart';

/// 攻略卡片组件
class GuideCard extends StatelessWidget {
  /// 攻略数据
  final GuideModel guide;

  /// 卡片颜色
  final Color accentColor;

  /// 点赞状态变更回调
  final Function(bool isLiked) onLikeChanged;

  /// 构造函数
  const GuideCard({
    super.key,
    required this.guide,
    required this.accentColor,
    required this.onLikeChanged,
  });

  @override
  Widget build(BuildContext context) {

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide.none, // 移除边框
      ),
      elevation: 4,
      shadowColor: accentColor.withValues(alpha: 0.4),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          // 导航到攻略详情页 - 使用iOS风格导航
          Navigator.of(context, rootNavigator: true).push(
            CupertinoPageRoute(
              builder: (context) => GuideDetailScreen(
                guideId: guide.id,
                guide: guide,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 攻略封面图片 - 填充剩余空间
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 封面图片或图标
                  guide.coverUrl != null
                      ? Hero(
                          tag: 'guide_image_${guide.id}',
                          child: NetworkImageWithFallback(
                            url: guide.coverUrl!,
                            fit: BoxFit.cover,
                            borderRadius: 0,
                            fallbackColor: accentColor,
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                accentColor.withValues(alpha: 0.8),
                                accentColor.withValues(alpha: 0.5),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(Icons.ac_unit),
                          ),
                        ),

                  // 标签
                  if (guide.tags.isNotEmpty)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          guide.tags.first,
                          style: const TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 标题和用户信息部分 - 固定高度
            Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 标题部分 - 最多两行
                  SizedBox(
                    height: 40, // 固定高度，容纳两行文本
                    child: Text(
                      guide.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 底部交互区域 - 作者信息和点赞
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 作者头像和名称
                      Expanded(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 10,
                              backgroundImage: guide.authorAvatarUrl != null
                                  ? NetworkImage(guide.authorAvatarUrl!)
                                  : null,
                              backgroundColor: accentColor.withValues(alpha: 0.1),
                              child: guide.authorAvatarUrl == null
                                  ? Icon(CupertinoIcons.person,
                                      size: 10,
                                      color: accentColor.withValues(alpha: 0.5))
                                  : null,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                guide.author,
                                style: TextStyle(
                                  fontSize: 11,
                                  color:
                                      AppColors.textSecondary.withValues(alpha: 0.7),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 右侧信息：阅读量和点赞
                      Row(
                        children: [
                          // 阅读量
                          Icon(
                            CupertinoIcons.eye,
                            size: 10,
                            color: AppColors.textSecondary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            _formatNumber(guide.views),
                            style: TextStyle(
                              fontSize: 9,
                              color: AppColors.textSecondary.withValues(alpha: 0.5),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // 点赞按钮
                          _buildLikeButton(guide, accentColor),
                        ],
                      ),
                    ],
                  ),

                  // 底部时间指示
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _getTimeAgo(guide.publishDate),
                        style: TextStyle(
                          fontSize: 9,
                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建点赞按钮
  Widget _buildLikeButton(GuideModel guide, Color accentColor) {
    final likeColor = guide.isLiked
        ? AppColors.like.withValues(alpha: 0.7)
        : accentColor.withValues(alpha: 0.5);

    return GestureDetector(
      onTap: () {
        onLikeChanged(!guide.isLiked);
      },
      child: Row(
        children: [
          Icon(
            guide.isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
            size: 12,
            color: likeColor,
          ),
          const SizedBox(width: 2),
          Text(
            _formatNumber(guide.likes),
            style: TextStyle(
              fontSize: 11,
              color: likeColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 格式化数字（大于1000显示为k）
  String _formatNumber(int number) {
    if (number >= 1000) {
      final double result = number / 1000;
      return '${result.toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  /// 获取相对时间
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}年前';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}月前';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}
