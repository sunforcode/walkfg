import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../model/guide_model.dart';
import '../../../service/mock_api_service.dart';
import '../../theme/app_colors.dart';

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
    final mockService = MockApiService();
    
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide.none, // 移除边框
      ),
      elevation: 4,
      shadowColor: accentColor.withOpacity(0.4),
      child: InkWell(
        onTap: () {
          // 导航到攻略详情页
          context.go('/guides/${guide.id}');
        },
        splashColor: accentColor.withOpacity(0.1),
        highlightColor: accentColor.withOpacity(0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 攻略封面图片 - 强化部分
            Stack(
              children: [
                // 封面图片或图标
                guide.coverUrl != null
                    ? Hero(
                        tag: 'guide_image_${guide.id}',
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: AspectRatio(
                            aspectRatio: 4/3, // 增大图片比例
                            child: Image.network(
                              guide.coverUrl!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      accentColor.withOpacity(0.8),
                                      accentColor.withOpacity(0.5),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    mockService.getIconData(guide.iconCode),
                                    size: 48,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : AspectRatio(
                        aspectRatio: 4/3, // 增大图片比例
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                accentColor.withOpacity(0.8),
                                accentColor.withOpacity(0.5),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              mockService.getIconData(guide.iconCode),
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                // 标签
                if (guide.tags.isNotEmpty)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        guide.tags.first,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // 标题部分
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
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

            // 底部交互区域 - 弱化部分
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  // 作者头像和名称
                  CircleAvatar(
                    radius: 10,
                    backgroundImage: guide.authorAvatarUrl != null
                        ? NetworkImage(guide.authorAvatarUrl!)
                        : null,
                    backgroundColor: accentColor.withOpacity(0.1),
                    child: guide.authorAvatarUrl == null
                        ? Icon(Icons.person, size: 10, color: accentColor.withOpacity(0.5))
                        : null,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    guide.author,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const Spacer(),

                  // 阅读量
                  Icon(
                    Icons.remove_red_eye,
                    size: 10,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    _formatNumber(guide.views),
                    style: TextStyle(
                      fontSize: 9,
                      color: AppColors.textSecondary.withOpacity(0.5),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // 点赞按钮
                  _buildLikeButton(guide, accentColor),
                ],
              ),
            ),

            // 底部时间指示
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 12, bottom: 6),
                child: Text(
                  _getTimeAgo(guide.publishDate),
                  style: TextStyle(
                    fontSize: 9,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建点赞按钮 - 弱化
  Widget _buildLikeButton(GuideModel guide, Color accentColor) {
    final likeColor = guide.isLiked ? AppColors.like.withOpacity(0.7) : accentColor.withOpacity(0.5);

    return GestureDetector(
      onTap: () {
        onLikeChanged(!guide.isLiked);
      },
      child: Row(
        children: [
          Icon(
            guide.isLiked ? Icons.favorite : Icons.favorite_border,
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