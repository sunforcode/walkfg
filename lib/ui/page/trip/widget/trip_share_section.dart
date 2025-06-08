import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../model/trip/trip_model.dart';
import '../../../../service/share_service.dart';
import '../../../../theme/theme/app_colors.dart';

/// 行程分享区域组件
class TripShareSection extends StatelessWidget {
  final TripModel trip;
  final ShareService _shareService = ShareService();

  TripShareSection({
    super.key,
    required this.trip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Icon(
                CupertinoIcons.share,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                '分享行程',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 分享选项
          Row(
            children: [
              Expanded(
                child: _buildShareOption(
                  context: context,
                  icon: CupertinoIcons.photo,
                  title: '分享卡片',
                  subtitle: '生成精美图片',
                  color: Colors.blue,
                  onTap: () => _shareAsImage(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildShareOption(
                  context: context,
                  icon: CupertinoIcons.text_bubble,
                  title: '分享文本',
                  subtitle: '纯文本分享',
                  color: Colors.green,
                  onTap: () => _shareAsText(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 组合分享按钮
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.share_solid,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '图片+文本分享',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              onPressed: () => _shareImageWithText(context),
            ),
          ),

          const SizedBox(height: 12),

          // 分享统计（可选）
          _buildShareStats(),
        ],
      ),
    );
  }

  Widget _buildShareOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareStats() {
    final stats = _shareService.getShareStats();
    final totalShares = stats['total_shares'] ?? 0;

    if (totalShares == 0) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.info,
              size: 14,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              '分享你的徒步计划，让更多人了解你的旅程',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.heart_fill,
            size: 14,
            color: AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            '已分享 $totalShares 次',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 分享为图片
  Future<void> _shareAsImage(BuildContext context) async {
    try {
      await _shareService.shareTripCard(
        context: context,
        trip: trip,
        shareType: ShareType.image,
      );
    } catch (e) {
      _showErrorMessage(context, '分享失败，请稍后重试');
    }
  }

  /// 分享为文本
  Future<void> _shareAsText(BuildContext context) async {
    try {
      await _shareService.shareTripCard(
        context: context,
        trip: trip,
        shareType: ShareType.text,
      );
    } catch (e) {
      _showErrorMessage(context, '分享失败，请稍后重试');
    }
  }

  /// 图片和文本一起分享
  Future<void> _shareImageWithText(BuildContext context) async {
    try {
      await _shareService.shareTripCard(
        context: context,
        trip: trip,
        shareType: ShareType.both,
      );
    } catch (e) {
      _showErrorMessage(context, '分享失败，请稍后重试');
    }
  }

  /// 显示错误消息
  void _showErrorMessage(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('提示'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('确定'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
