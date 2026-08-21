import 'package:flutter/cupertino.dart';
import 'package:walk/theme/tokens/colors.dart';
import 'package:walk/model/trip/transportation_info_model.dart';

/// 行程交通组件
class TripTransportationWidget extends StatelessWidget {
  /// 交通信息列表
  final List<TransportationInfoModel> transportations;

  /// 构造函数
  const TripTransportationWidget({
    Key? key,
    required this.transportations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (transportations.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            '暂无交通安排',
            style: TextStyle(
              color: CupertinoColors.systemGrey,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: transportations
          .map((transport) => _buildTransportItem(transport))
          .toList(),
    );
  }

  /// 构建交通项
  Widget _buildTransportItem(TransportationInfoModel transport) {
    final IconData directionIcon = transport.type == '去程'
        ? CupertinoIcons.arrow_right_circle_fill
        : transport.type == '返程'
            ? CupertinoIcons.arrow_left_circle_fill
            : CupertinoIcons.arrow_up_right_diamond_fill;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  directionIcon,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${transport.type}: ${transport.from} → ${transport.to}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transport.method,
                      style: const TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transport.time,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: transport.isBooked
                      ? CupertinoColors.systemGreen.withValues(alpha: 0.1)
                      : CupertinoColors.systemYellow.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  transport.isBooked ? '已预订' : '未预订',
                  style: TextStyle(
                    color: transport.isBooked
                        ? CupertinoColors.systemGreen
                        : CupertinoColors.systemYellow,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (transportations.last != transport)
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
              child: Container(
                width: 1,
                height: 20,
                color: CupertinoColors.systemGrey5,
              ),
            ),
        ],
      ),
    );
  }
}
