import 'package:flutter/cupertino.dart';
import 'package:walk/model/trip/trip_model.dart';

/// 交通住宿展示组件
class TripTransportationDisplayWidget extends StatelessWidget {
  final TripModel trip;

  const TripTransportationDisplayWidget({
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
              '🚗 交通住宿',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text('交通住宿安排展示区域'),
          ),
        ],
      ),
    );
  }
}