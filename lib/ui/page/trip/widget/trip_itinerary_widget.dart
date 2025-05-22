import 'package:flutter/cupertino.dart';
import 'package:walk/model/trip/trip_day_plan_model.dart';

class TripItineraryWidget extends StatelessWidget {
  final List<TripDayPlanModel> itinerary;

  const TripItineraryWidget({
    super.key,
    required this.itinerary,
  });

  @override
  Widget build(BuildContext context) {
    if (itinerary.isEmpty) {
      return const Text(
        '暂无行程安排',
        style: TextStyle(
          fontSize: 16,
          color: CupertinoColors.systemGrey,
        ),
      );
    }

    return Column(
      children: itinerary.map((day) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 日期标题
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.activeBlue.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: CupertinoColors.activeBlue,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(
                            color: CupertinoColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            day.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${day.startPoint} → ${day.endPoint}',
                            style: TextStyle(
                              fontSize: 12,
                              color: CupertinoColors.systemGrey.darkColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 日程内容
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      day.description,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildItineraryInfoItem(
                      CupertinoIcons.location,
                      '距离: ${day.distance.toStringAsFixed(1)}km',
                    ),
                    const SizedBox(height: 4),
                    _buildItineraryInfoItem(
                      CupertinoIcons.arrow_up,
                      '爬升: ${day.elevationGain}m',
                    ),
                    const SizedBox(height: 4),
                    _buildItineraryInfoItem(
                      CupertinoIcons.arrow_down,
                      '下降: ${day.elevationLoss}m',
                    ),
                    const SizedBox(height: 4),
                    _buildItineraryInfoItem(
                      CupertinoIcons.time,
                      '预计时间: ${_formatTime(day.estimatedTime)}',
                    ),
                    if (day.notes != null && day.notes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildItineraryInfoItem(
                        CupertinoIcons.info,
                        '备注: ${day.notes}',
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildItineraryInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: CupertinoColors.systemGrey,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(double hours) {
    final int wholeHours = hours.floor();
    final int minutes = ((hours - wholeHours) * 60).round();

    if (wholeHours > 0) {
      return '$wholeHours小时${minutes > 0 ? ' $minutes分钟' : ''}';
    } else {
      return '$minutes分钟';
    }
  }
}
