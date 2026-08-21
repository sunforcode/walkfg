import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:walk/model/map/map_bounds.dart';
import 'package:walk/model/map/map_data_model.dart';
import 'package:walk/model/map/map_statistics.dart';
import 'package:walk/model/map/track_point_model.dart';
import 'package:walk/model/route/segment_model.dart';
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

    // 解析分段数据
    final List<SegmentModel> segments = _parseSegments(kmlDocument);

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
      segmentCount: segments.isNotEmpty ? segments.length : 1,
      segments: segments,
      recordedAt: DateTime.now(),
      processingStatus: 'completed',
    );
  }

  /// 从KML文档解析分段数据
  static List<SegmentModel> _parseSegments(KmlDocument kmlDocument) {
    final segments = <SegmentModel>[];

    // 从ExtendedData中获取segments
    final segmentsJson = kmlDocument.extendedData['segments'];
    if (segmentsJson == null || segmentsJson.isEmpty) {
      return segments;
    }

    try {
      final List<dynamic> parsedList = json.decode(segmentsJson);
      for (final item in parsedList) {
        if (item is Map<String, dynamic>) {
          // 将id转换为字符串（KML中的id可能是数字）
          final id = item['id']?.toString() ?? 'segment_${segments.length + 1}';
          final name = item['name'] ?? '分段 ${segments.length + 1}';
          final sequenceNumber = item['sequence_number'] ?? segments.length + 1;
          final trackStartIndex = item['track_start_index'] as int?;
          final trackEndIndex = item['track_end_index'] as int?;
          final color = item['color'] as String?;
          final distance = item['distance'] as double?;
          final elevationGain = item['elevation_gain'] as double?;
          final elevationLoss = item['elevation_loss'] as double?;
          final difficulty = item['difficulty'] as int?;

          segments.add(SegmentModel(
            id: id,
            name: name,
            sequenceNumber: sequenceNumber,
            trackStartIndex: trackStartIndex,
            trackEndIndex: trackEndIndex,
            color: color,
            distance: distance,
            elevationGain: elevationGain,
            elevationLoss: elevationLoss,
            difficulty: difficulty,
          ));
        }
      }

      // 按sequenceNumber排序
      segments.sort((a, b) => a.sequenceNumber.compareTo(b.sequenceNumber));
    } catch (e) {
      debugPrint('KmlToMapConverter: 解析分段数据失败: $e');
    }

    return segments;
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
    for (int i = 0; i < placemarks.length; i++) {
      final placemark = placemarks[i];

      if (placemark.geometry == null) {
        continue;
      }

      final geometry = placemark.geometry!;

      if (geometry is KmlPoint) {
        // 点几何体作为路标点
        waypoints.add(TrackPointVO(
          latitude: geometry.coordinates.latitude,
          longitude: geometry.coordinates.longitude,
          elevation: geometry.coordinates.altitude,
          timestamp: placemark.timeStamp?.when,
        ));
      } else if (geometry is KmlLineString) {
        // 线串几何体作为轨迹点
        for (int j = 0; j < geometry.coordinates.length; j++) {
          final coord = geometry.coordinates[j];
          trackPoints.add(TrackPointVO(
            latitude: coord.latitude,
            longitude: coord.longitude,
            elevation: coord.altitude,
            timestamp: placemark.timeStamp?.when,
          ));
        }
      } else if (geometry is KmlTrack) {
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
        }
      } else if (geometry is KmlMultiGeometry) {
        // 多重几何体递归处理
        for (final subGeometry in geometry.geometries) {
          final subPlacemark = KmlPlacemark(
            geometry: subGeometry,
            timeStamp: placemark.timeStamp,
          );
          _extractFromPlacemarks([subPlacemark], trackPoints, waypoints);
        }
      } else {
        debugPrint('KmlToMapConverter: 未知几何体类型: ${geometry.runtimeType}');
      }
    }
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
