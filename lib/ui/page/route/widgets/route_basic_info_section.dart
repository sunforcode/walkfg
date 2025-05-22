import 'package:flutter/cupertino.dart';
import '../../../../model/model/route/route_model.dart';
import '../../../../theme/theme/app_colors.dart';

/// 基本信息组件
class RouteBasicInfoSection extends StatelessWidget {
  final RouteModel route;

  const RouteBasicInfoSection({
    super.key,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 路线名称
          Text(
            route.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // 路线基本信息
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(
                context,
                CupertinoIcons.arrow_right_arrow_left,
                '距离',
                '${route.basicInfo.distance} km',
              ),
              _buildInfoItem(
                context,
                CupertinoIcons.time,
                '时长',
                route.basicInfo.duration,
              ),
              _buildInfoItem(
                context,
                CupertinoIcons.arrow_up_right,
                '海拔增益',
                '${route.basicInfo.elevationGain} m',
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建信息项
  Widget _buildInfoItem(
      BuildContext context, IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: CupertinoColors.systemGrey.resolveFrom(context),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
