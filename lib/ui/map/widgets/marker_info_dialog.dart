import 'package:flutter/cupertino.dart';
import 'package:walk/model/map/track_point_model.dart';
import 'package:walk/model/map/marker_point_model.dart';

/// 显示标记点/轨迹点详情弹窗
void showMarkerInfoDialog(BuildContext context, TrackPointVO point) {
  if (point is MarkerPointModel) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(point.displayTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('类型: ${point.markerTypeText}'),
            Text('海拔: ${point.elevation.toStringAsFixed(1)}m'),
            Text(
                '坐标: ${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}'),
            if (point.description != null && point.description!.isNotEmpty)
              Text('描述: ${point.description}'),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('确定'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  } else {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('轨迹点'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('海拔: ${point.elevation.toStringAsFixed(1)}m'),
            Text(
                '坐标: ${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}'),
            if (point.timestamp != null)
              Text(
                  '时间: ${point.timestamp!.toLocal().toString().substring(0, 19)}'),
            if (point.distanceFromStart != null)
              Text(
                  '距离起点: ${(point.distanceFromStart! / 1000).toStringAsFixed(2)}km'),
          ],
        ),
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
