import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/model/guide/guide_model.dart';
import 'package:walk/theme/theme/app_colors.dart';
import 'package:walk/utils/toast_utils.dart';

/// 攻略概览组件
class GuideOverviewWidget extends StatelessWidget {
  final GuideModel guide;

  const GuideOverviewWidget({
    super.key,
    required this.guide,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CupertinoColors.separator,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题和作者信息
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: CupertinoColors.separator,
                  width: 0.5,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                Text(
                  guide.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.label,
                  ),
                ),
                const SizedBox(height: 16),

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
            ),
          ),

          // 快速操作按钮
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '快速操作',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildQuickActionButton(
                        'PDF保存',
                        CupertinoIcons.doc_text,
                        CupertinoColors.systemBlue,
                        () => _showToast(context, 'PDF保存功能开发中'),
                      ),
                      _buildQuickActionButton(
                        '离线保存',
                        CupertinoIcons.cloud_download,
                        CupertinoColors.systemGreen,
                        () => _showToast(context, '攻略已保存到离线列表'),
                      ),
                      _buildQuickActionButton(
                        '相关路线',
                        CupertinoIcons.map,
                        CupertinoColors.systemOrange,
                        () => _showToast(context, '相关路线功能开发中'),
                      ),
                      _buildQuickActionButton(
                        '装备清单',
                        CupertinoIcons.bag,
                        CupertinoColors.systemPurple,
                        () => _showToast(context, '装备清单功能开发中'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建作者信息
  Widget _buildAuthorInfo(BuildContext context) {
    return GestureDetector(
      onTap: () => _showToast(context, '正在查看${guide.author}的资料'),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: guide.authorAvatarUrl != null
                ? NetworkImage(guide.authorAvatarUrl!)
                : null,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: guide.authorAvatarUrl == null
                ? Icon(
                    CupertinoIcons.person,
                    size: 16,
                    color: AppColors.primary,
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                guide.author,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: CupertinoColors.label,
                ),
              ),
              Text(
                _getTimeAgo(guide.publishDate),
                style: const TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建统计信息
  Widget _buildStatsInfo() {
    return Row(
      children: [
        // 阅读量
        Row(
          children: [
            const Icon(
              CupertinoIcons.eye,
              size: 16,
              color: CupertinoColors.secondaryLabel,
            ),
            const SizedBox(width: 4),
            Text(
              _formatNumber(guide.views),
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        // 点赞数
        Row(
          children: [
            const Icon(
              CupertinoIcons.heart,
              size: 16,
              color: CupertinoColors.secondaryLabel,
            ),
            const SizedBox(width: 4),
            Text(
              _formatNumber(guide.likes),
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建快速操作按钮
  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        minSize: 0,
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示提示信息
  void _showToast(BuildContext context, String message) {
    ToastUtils.showToast(context, message);
  }

  /// 格式化数字
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
