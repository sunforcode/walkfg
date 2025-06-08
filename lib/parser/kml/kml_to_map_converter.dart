import 'dart:math';
import 'package:walk/model/map/map_bounds.dart';
import 'package:walk/model/map/map_data_model.dart';
import 'package:walk/model/map/map_statistics.dart';
import 'package:walk/model/map/track_point_model.dart';
import 'kml_models.dart';

/// KML到MapDataModel的转换器
///
/// 负责将KML标准数据转换为应用的业务数据模型
class KmlToMapConverter {
  /// 将KML文档转换为MapDataModel
  static MapDataModel convertToMapData(
    KmlDocument kmlDocument, {
    String? sourceUrl,
    String? rawContent,
  }) {
    // 提取轨迹点和路标点
    final ParsedTrackData parsedData = _extractTrackData(kmlDocument);
    final List<TrackPointVO> trackPoints = parsedData.trackPoints;
    final List<TrackPointVO> waypoints = parsedData.waypoints;

    if (trackPoints.isEmpty) {
      throw Exception('未找到有效的轨迹点');
    }

    // 计算边界和统计信息
    final bounds = _calculateBounds(trackPoints);
    final statistics = _calculateStatistics(trackPoints);

    // 找出最高点和最低点
    final highestPoint = _findHighestPoint(trackPoints);
    final lowestPoint = _findLowestPoint(trackPoints);

    // 创建地图数据模型
    return MapDataModel(
      id: (kmlDocument.name ?? 'unnamed').replaceAll(' ', '_').toLowerCase(),
      dataType: MapDataType.kml,
      sourceUrl: sourceUrl,
      rawContent: rawContent,
      bounds: bounds,
      totalDistance: statistics.totalDistance,
      totalDuration: statistics.totalDuration,
      totalAscent: statistics.totalAscent,
      totalDescent: statistics.totalDescent,
      maxElevation: statistics.maxElevation,
      minElevation: statistics.minElevation,
      averageSpeed: statistics.averageSpeed,
      trackPoints: trackPoints,
      waypoints: waypoints,
      highestPoint: highestPoint,
      lowestPoint: lowestPoint,
      startPoint: trackPoints.first,
      endPoint: trackPoints.last,
      pointCount: trackPoints.length,
      segmentCount: 1,
      recordedAt: DateTime.now(),
      processingStatus: 'completed',
    );
  }

  /// 从KML文档提取轨迹数据
  static ParsedTrackData _extractTrackData(KmlDocument kmlDocument) {
    final trackPoints = <TrackPointVO>[];
    final waypoints = <TrackPointVO>[];

    // 从所有地标中提取轨迹点和路标点
    _extractFromPlacemarks(kmlDocument.placemarks, trackPoints, waypoints);

    // 从文件夹中提取
    for (final folder in kmlDocument.folders) {
      _extractFromFolder(folder, trackPoints, waypoints);
    }

    return ParsedTrackData(
      trackPoints: trackPoints,
      waypoints: waypoints,
    );
  }

  /// 从文件夹中提取轨迹数据
  static void _extractFromFolder(
    KmlFolder folder,
    List<TrackPointVO> trackPoints,
    List<TrackPointVO> waypoints,
  ) {
    _extractFromPlacemarks(folder.placemarks, trackPoints, waypoints);

    // 递归处理子文件夹
    for (final subFolder in folder.folders) {
      _extractFromFolder(subFolder, trackPoints, waypoints);
    }
  }

  /// 从地标列表中提取轨迹数据
  static void _extractFromPlacemarks(
    List<KmlPlacemark> placemarks,
    List<TrackPointVO> trackPoints,
    List<TrackPointVO> waypoints,
  ) {
    print('KmlToMapConverter: 开始处理 ${placemarks.length} 个地标');

    for (int i = 0; i < placemarks.length; i++) {
      final placemark = placemarks[i];
      print('KmlToMapConverter: 处理第 ${i + 1} 个地标: ${placemark.name}');

      if (placemark.geometry == null) {
        print('KmlToMapConverter: 地标 ${placemark.name} 没有几何体，跳过');
        continue;
      }

      final geometry = placemark.geometry!;
      print('KmlToMapConverter: 几何体类型: ${geometry.runtimeType}');

      if (geometry is KmlPoint) {
        print('KmlToMapConverter: 处理点几何体');
        // 点几何体作为路标点
        waypoints.add(TrackPointVO(
          latitude: geometry.coordinates.latitude,
          longitude: geometry.coordinates.longitude,
          elevation: geometry.coordinates.altitude,
          timestamp: placemark.timeStamp?.when,
        ));
        print(
            'KmlToMapConverter: 添加路标点 (${geometry.coordinates.latitude}, ${geometry.coordinates.longitude})');
      } else if (geometry is KmlLineString) {
        print(
            'KmlToMapConverter: 处理线串几何体，坐标数量: ${geometry.coordinates.length}');
        // 线串几何体作为轨迹点
        for (int j = 0; j < geometry.coordinates.length; j++) {
          final coord = geometry.coordinates[j];
          trackPoints.add(TrackPointVO(
            latitude: coord.latitude,
            longitude: coord.longitude,
            elevation: coord.altitude,
            timestamp: placemark.timeStamp?.when,
          ));
          if (j < 3 || j >= geometry.coordinates.length - 3) {
            print(
                'KmlToMapConverter: 添加轨迹点 ${j + 1}: (${coord.latitude}, ${coord.longitude})');
          } else if (j == 3) {
            print('KmlToMapConverter: ... (省略中间坐标点) ...');
          }
        }
      } else if (geometry is KmlTrack) {
        print('KmlToMapConverter: 处理Google扩展轨迹，坐标数量: ${geometry.coord.length}');
        // Google扩展轨迹
        for (int j = 0; j < geometry.coord.length; j++) {
          final coord = geometry.coord[j];
          final timestamp = j < geometry.when.length ? geometry.when[j] : null;

          trackPoints.add(TrackPointVO(
            latitude: coord.latitude,
            longitude: coord.longitude,
            elevation: coord.altitude,
            timestamp: timestamp,
          ));
          if (j < 3 || j >= geometry.coord.length - 3) {
            print(
                'KmlToMapConverter: 添加轨迹点 ${j + 1}: (${coord.latitude}, ${coord.longitude})');
          } else if (j == 3) {
            print('KmlToMapConverter: ... (省略中间坐标点) ...');
          }
        }
      } else if (geometry is KmlMultiGeometry) {
        print(
            'KmlToMapConverter: 处理多重几何体，子几何体数量: ${geometry.geometries.length}');
        // 多重几何体递归处理
        for (final subGeometry in geometry.geometries) {
          final subPlacemark = KmlPlacemark(
            geometry: subGeometry,
            timeStamp: placemark.timeStamp,
          );
          _extractFromPlacemarks([subPlacemark], trackPoints, waypoints);
        }
      } else {
        print('KmlToMapConverter: 未知几何体类型: ${geometry.runtimeType}');
      }
    }

    print(
        'KmlToMapConverter: 处理完成，轨迹点总数: ${trackPoints.length}，路标点总数: ${waypoints.length}');
  }

  /// 计算边界
  static MapBoundsVO _calculateBounds(List<TrackPointVO> trackPoints) {
    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (final point in trackPoints) {
      minLat = min(minLat, point.latitude);
      maxLat = max(maxLat, point.latitude);
      minLng = min(minLng, point.longitude);
      maxLng = max(maxLng, point.longitude);
    }

    return MapBoundsVO(
      north: maxLat,
      south: minLat,
      east: maxLng,
      west: minLng,
    );
  }

  /// 计算统计信息
  static MapStatisticsVO _calculateStatistics(List<TrackPointVO> trackPoints) {
    double totalDistance = 0;
    double elevationGain = 0;
    double elevationLoss = 0;
    double maxElevation = -double.infinity;
    double minElevation = double.infinity;

    if (trackPoints.length == 1) {
      maxElevation = trackPoints[0].elevation;
      minElevation = trackPoints[0].elevation;
    } else {
      maxElevation = max(maxElevation, trackPoints[0].elevation);
      minElevation = min(minElevation, trackPoints[0].elevation);

      for (int i = 1; i < trackPoints.length; i++) {
        final prevPoint = trackPoints[i - 1];
        final currentPoint = trackPoints[i];

        final distance = _calculateDistance(
          prevPoint.latitude,
          prevPoint.longitude,
          currentPoint.latitude,
          currentPoint.longitude,
        );

        totalDistance += distance;

        final elevationDiff = currentPoint.elevation - prevPoint.elevation;
        if (elevationDiff > 0) {
          elevationGain += elevationDiff;
        } else {
          elevationLoss += -elevationDiff;
        }

        maxElevation = max(maxElevation, currentPoint.elevation);
        minElevation = min(minElevation, currentPoint.elevation);
      }
    }

    final estimatedDurationHours = _estimateDuration(totalDistance);
    final averageSpeed = totalDistance > 0 && estimatedDurationHours > 0
        ? totalDistance / (estimatedDurationHours * 3600)
        : 0.0;

    return MapStatisticsVO(
      totalDistance: totalDistance,
      totalDuration: estimatedDurationHours.toInt(),
      totalAscent: elevationGain,
      totalDescent: elevationLoss,
      maxElevation: maxElevation == -double.infinity ? 0.0 : maxElevation,
      minElevation: minElevation == double.infinity ? 0.0 : minElevation,
      averageSpeed: averageSpeed,
    );
  }

  /// 估算徒步时间（小时）
  static double _estimateDuration(double distanceInMeters) {
    const averageSpeedKmPerHour = 4.0;
    return distanceInMeters / 1000 / averageSpeedKmPerHour;
  }

  /// 找出最高点
  static TrackPointVO _findHighestPoint(List<TrackPointVO> trackPoints) {
    TrackPointVO highestPoint = trackPoints.first;
    for (final point in trackPoints) {
      if (point.elevation > highestPoint.elevation) {
        highestPoint = point;
      }
    }
    return highestPoint;
  }

  /// 找出最低点
  static TrackPointVO _findLowestPoint(List<TrackPointVO> trackPoints) {
    TrackPointVO lowestPoint = trackPoints.first;
    for (final point in trackPoints) {
      if (point.elevation < lowestPoint.elevation) {
        lowestPoint = point;
      }
    }
    return lowestPoint;
  }

  /// 计算两点间距离（米）
  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371000.0; // 地球半径（米）
    final phi1 = lat1 * (pi / 180);
    final phi2 = lat2 * (pi / 180);
    final deltaPhi = (lat2 - lat1) * (pi / 180);
    final deltaLambda = (lon2 - lon1) * (pi / 180);

    final a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }
}

/// 解析轨迹点结果
class ParsedTrackData {
  final List<TrackPointVO> trackPoints;
  final List<TrackPointVO> waypoints;

  ParsedTrackData({
    required this.trackPoints,
    required this.waypoints,
  });
}
