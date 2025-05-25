import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:walk/model/map/track_point_model.dart';

/// 公里标记工具类
class KilometerMarkers {
  /// 构建公里标记
  static List<Marker> build(List<TrackPointVO> kilometerMarkers) {
    return kilometerMarkers.map((point) {
      return Marker(
        point: LatLng(point.latitude, point.longitude),
        width: 30,
        height: 30,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Center(
            child: Text(
              point.name!.split(' ')[0],
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}

/// 兴趣点标记工具类
class PointsOfInterestMarkers {
  /// 构建兴趣点标记
  static List<Marker> build(
    List<TrackPointVO> pointsOfInterest, {
    required Function(TrackPointVO) onTap,
  }) {
    return pointsOfInterest.map((point) {
      IconData icon;
      Color color;

      if (point.type == '最高点') {
        icon = Icons.arrow_upward;
        color = Colors.red;
      } else if (point.type == '最低点') {
        icon = Icons.arrow_downward;
        color = Colors.blue;
      } else {
        icon = Icons.place;
        color = Colors.green;
      }

      return Marker(
        point: LatLng(point.latitude, point.longitude),
        width: 30,
        height: 30,
        child: GestureDetector(
          onTap: () => onTap(point),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
      );
    }).toList();
  }
}