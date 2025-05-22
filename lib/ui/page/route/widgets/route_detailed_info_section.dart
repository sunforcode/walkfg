import 'package:flutter/cupertino.dart';
import '../../../../model/model/route/route_model.dart';

/// 详细信息组件
class RouteDetailedInfoSection extends StatelessWidget {
  final RouteModel route;

  const RouteDetailedInfoSection({
    super.key,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '详细信息',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // 详细信息表格
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: CupertinoColors.systemGrey5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildInfoRow('最高点', '${1000} m'),
                _buildDivider(),
                _buildInfoRow('最低点', '${1000} m'),
                _buildDivider(),
                _buildInfoRow('累计上升', '${1000} m'),
                _buildDivider(),
                _buildInfoRow('累计下降', '${1000} m'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: CupertinoColors.systemGrey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建分隔线
  Widget _buildDivider() {
    return Container(
      height: 1,
      color: CupertinoColors.systemGrey5,
    );
  }
}