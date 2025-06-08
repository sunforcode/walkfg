import 'package:flutter/cupertino.dart';
import 'package:walk/model/trip/trip_model.dart';

/// 天气安全展示组件
class TripWeatherSafetyDisplayWidget extends StatelessWidget {
  final TripModel trip;

  const TripWeatherSafetyDisplayWidget({
    super.key,
    required this.trip,
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
            child: const Text(
              '🌤️ 天气安全',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text('天气预报和安全提醒展示区域'),
          ),
        ],
      ),
    );
  }
}