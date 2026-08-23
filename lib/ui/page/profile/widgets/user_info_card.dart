import 'package:flutter/cupertino.dart';

import '../../../../model/user/user_model.dart';
import '../../../../theme/tokens/colors.dart';
import '../../common/network_image_with_fallback.dart';

/// 用户信息卡片组件
class UserInfoCard extends StatelessWidget {
  /// 用户数据
  final UserModel? user;

  /// 点击编辑按钮的回调
  final VoidCallback onEditPressed;

  /// 构造函数
  const UserInfoCard({
    super.key,
    required this.user,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgPanel,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.surfaceOverlay,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 头像
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.interactiveAccentBg,
              border: Border.all(
                color: AppColors.interactiveAccentSoft,
                width: 2,
              ),
            ),
            child: user?.avatarUrl != null
                ? NetworkImageWithFallback(
                    url: user!.avatarUrl!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    borderRadius: 50,
                  )
                : Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.interactiveAccentBg,
                      border: Border.all(
                        color: AppColors.interactiveAccentSoft,
                        width: 2,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        CupertinoIcons.person_fill,
                        size: 40,
                        color: AppColors.interactiveAccent,
                      ),
                    ),
                  ),
          ),

          const SizedBox(width: 16),

          // 用户信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.nickname ?? '未知用户',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${user?.id ?? '未知'}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textWeak,
                  ),
                ),
                if (user?.bio != null && user!.bio!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    user!.bio!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textWeak,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // 编辑按钮
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.pencil),
            onPressed: onEditPressed,
          ),
        ],
      ),
    );
  }
}
