import 'package:flutter/cupertino.dart';
import 'package:walk/model/trip/trip_model.dart';

/// 预算展示组件
class TripBudgetDisplayWidget extends StatelessWidget {
  final TripModel trip;

  const TripBudgetDisplayWidget({
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
              '💰 费用预算',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: trip.budget != null && trip.budget! > 0
                ? const Text('预算信息展示区域')
                : const Text('暂未设置预算'),
          ),
        ],
      ),
    );
  }
}