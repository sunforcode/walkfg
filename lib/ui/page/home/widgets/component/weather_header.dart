import 'package:flutter/material.dart';
import 'package:walk/model/user/user_model.dart';
import 'package:walk/theme/tokens/colors.dart';

/// 天气卡片头部组件
class WeatherHeader extends StatelessWidget {
  /// 用户模型
  final UserModel user;

  /// 刷新回调
  final Future<void> Function()? onRefresh;

  const WeatherHeader({
    Key? key,
    required this.user,
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
          child: user.avatarUrl == null ? const Icon(Icons.person) : null,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '欢迎，${user.nickname}',
              style: const TextStyle(
                color: AppColors.textOnDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _getGreetingByTime(),
              style: TextStyle(
                color: AppColors.textOnDark.withValues(alpha: 0.9),
                fontSize: 14,
              ),
            ),
          ],
        ),
        const Spacer(),
        if (onRefresh != null)
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textOnDark),
            onPressed: onRefresh,
            tooltip: '刷新天气',
          ),
      ],
    );
  }

  /// 根据时间获取问候语
  String _getGreetingByTime() {
    final hour = DateTime.now().hour;
    if (hour < 6) {
      return '夜深了，注意休息';
    } else if (hour < 9) {
      return '早上好，新的一天';
    } else if (hour < 12) {
      return '上午好，今天天气不错';
    } else if (hour < 14) {
      return '中午好，享用午餐吧';
    } else if (hour < 18) {
      return '下午好，来杯咖啡？';
    } else if (hour < 22) {
      return '晚上好，度过愉快的夜晚';
    } else {
      return '夜深了，注意休息';
    }
  }
}
