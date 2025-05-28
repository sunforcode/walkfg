import 'dart:math';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';
import 'package:walk/model/map/map_bounds.dart';
import 'package:walk/model/map/map_data_model.dart';
import 'package:walk/model/map/track_point_model.dart';

/// 解析轨迹点结果
class ParsedTrackData {
  final List<TrackPointVO> trackPoints;
  final List<TrackPointVO> waypoints;

  ParsedTrackData({
    required this.trackPoints,
    required this.waypoints,
  });
}

/// KML 文件解析器
class KmlParser {
  /// 从 KML 文件解析地图数据
  static Future<MapDataModel> parseFromAsset(String assetPath) async {
    try {
      // 读取 KML 文件内容
      final String kmlContent = await rootBundle.loadString(assetPath);
      return parseFromString(kmlContent, sourceUrl: assetPath);
    } catch (e) {
      print('KML 文件读取错误: $e');
      rethrow;
    }
  }

  /// 从 KML 字符串解析地图数据
  static MapDataModel parseFromString(String kmlContent, {String? sourceUrl}) {
    try {
      // 解析 XML
      final document = XmlDocument.parse(kmlContent);

      // 获取文档名称和描述
      final documentName = _getDocumentName(document);
      final documentDescription = _getDocumentDescription(document);

      // 解析轨迹点
      final ParsedTrackData parsedData = _parseTrackPoints(document);
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
        id: documentName.replaceAll(' ', '_').toLowerCase(),
        dataType: MapDataType.kml,
        sourceUrl: sourceUrl,
        rawContent: kmlContent,
        bounds: bounds,
        totalDistance: statistics['totalDistance'],
        totalDuration: statistics['totalDuration'],
        totalAscent: statistics['totalAscent'],
        totalDescent: statistics['totalDescent'],
        maxElevation: statistics['maxElevation'],
        minElevation: statistics['minElevation'],
        averageSpeed: statistics['averageSpeed'],
        trackPoints: trackPoints,
        waypoints: waypoints,
        highestPoint: highestPoint,
        lowestPoint: lowestPoint,
        startPoint: trackPoints.first,
        endPoint: trackPoints.last,
        pointCount: trackPoints.length,
        segmentCount: 1, // 简化处理，假设只有一个轨迹段
        recordedAt: DateTime.now(),
        processingStatus: 'completed',
      );
    } catch (e) {
      print('KML 解析错误: $e');
      rethrow;
    }
  }

  /// 获取文档名称
  static String _getDocumentName(XmlDocument document) {
    try {
      final nameElement = document.findAllElements('name').firstOrNull;
      return nameElement?.innerText ?? 'Unnamed Track';
    } catch (e) {
      print('获取文档名称失败: $e');
      return 'Unnamed Track';
    }
  }

  /// 获取文档描述
  static String _getDocumentDescription(XmlDocument document) {
    try {
      final descriptionElement =
          document.findAllElements('description').firstOrNull;
      return descriptionElement?.innerText ?? '';
    } catch (e) {
      print('获取文档描述失败: $e');
      return '';
    }
  }

  /// 解析轨迹点
  static ParsedTrackData _parseTrackPoints(XmlDocument document) {
    final List<TrackPointVO> trackPoints = [];
    final List<TrackPointVO> waypoints = [];

    // 检查文档中包含哪些类型的数据
    final hasCoordinates = document.findAllElements('coordinates').isNotEmpty;
    final hasGxCoord = document.findAllElements('gx:coord').isNotEmpty;
    final hasPlacemarks = document.findAllElements('Placemark').isNotEmpty;

    print(
        'KML文件包含: coordinates=$hasCoordinates, gx:coord=$hasGxCoord, Placemark=$hasPlacemarks');

    // 根据文档类型选择解析策略
    if (hasGxCoord) {
      // 如果有 gx:coord 元素，优先使用它们作为轨迹点（通常包含时间戳）
      _parseGxCoordElements(document, trackPoints);
    } else if (hasCoordinates) {
      // 否则使用 coordinates 元素
      _parseCoordinatesElements(document, trackPoints);
    }

    // 解析 Placemark 元素作为兴趣点/路标
    if (hasPlacemarks) {
      _parsePlacemarkElements(document, waypoints);
    }

    // 如果没有轨迹点但有路标，将路标作为轨迹点
    if (trackPoints.isEmpty && waypoints.isNotEmpty) {
      trackPoints.addAll(waypoints);
    }

    print('总共解析到 ${trackPoints.length} 个轨迹点, ${waypoints.length} 个路标点');
    return ParsedTrackData(
      trackPoints: trackPoints,
      waypoints: waypoints,
    );
  }

  /// 解析 coordinates 元素中的轨迹点
  static void _parseCoordinatesElements(
      XmlDocument document, List<TrackPointVO> trackPoints) {
    final coordinatesElements = document.findAllElements('coordinates');
    print('找到 ${coordinatesElements.length} 个 coordinates 元素');

    // 查找 LineString 元素中的 coordinates
    final lineStringElements = document.findAllElements('LineString');
    for (final lineStringElement in lineStringElements) {
      final coordElement =
          lineStringElement.findElements('coordinates').firstOrNull;
      if (coordElement != null) {
        final String coordinatesText = coordElement.innerText.trim();
        _parseCoordinatesText(coordinatesText, trackPoints);
      }
    }

    // 查找其他 coordinates 元素（如果没有在 LineString 中找到）
    if (trackPoints.isEmpty) {
      for (final coordinatesElement in coordinatesElements) {
        final String coordinatesText = coordinatesElement.innerText.trim();
        _parseCoordinatesText(coordinatesText, trackPoints);
      }
    }
  }

  /// 解析坐标文本
  static void _parseCoordinatesText(
      String coordinatesText, List<TrackPointVO> trackPoints) {
    // 处理多行坐标
    final List<String> coordinatesList = coordinatesText.split(RegExp(r'\s+'));

    for (final String coordinates in coordinatesList) {
      final String trimmedCoordinates = coordinates.trim();
      if (trimmedCoordinates.isEmpty) continue;

      _parseCoordinateString(trimmedCoordinates, trackPoints);
    }
  }

  /// 解析 gx:coord 元素中的轨迹点
  static void _parseGxCoordElements(
      XmlDocument document, List<TrackPointVO> trackPoints) {
    final gxCoordElements = document.findAllElements('gx:coord');
    print('找到 ${gxCoordElements.length} 个 gx:coord 元素');

    // 获取时间戳（如果有）
    final whenElements = document.findAllElements('when');
    final List<DateTime> timestamps = whenElements
        .map((e) => DateTime.tryParse(e.innerText.trim()))
        .where((e) => e != null)
        .cast<DateTime>()
        .toList();

    int timestampIndex = 0;

    for (final gxCoordElement in gxCoordElements) {
      final String coordText = gxCoordElement.innerText.trim();

      // gx:coord 使用空格分隔
      final List<String> parts = coordText.split(' ');
      if (parts.length >= 2) {
        try {
          final double longitude = double.parse(parts[0].trim());
          final double latitude = double.parse(parts[1].trim());
          final double elevation =
              parts.length > 2 ? double.parse(parts[2].trim()) : 0.0;

          // 获取时间戳（如果有）
          DateTime? timestamp;
          if (timestampIndex < timestamps.length) {
            timestamp = timestamps[timestampIndex++];
          }

          trackPoints.add(TrackPointVO.fromKml(
            latitude: latitude,
            longitude: longitude,
            elevation: elevation,
            timestamp: timestamp,
            rawData: {'coordText': coordText},
          ));
        } catch (e) {
          print('解析 gx:coord 失败: $coordText - $e');
        }
      }
    }
  }

  /// 解析 Placemark 元素中的轨迹点
  static void _parsePlacemarkElements(
      XmlDocument document, List<TrackPointVO> waypoints) {
    final placemarkElements = document.findAllElements('Placemark');
    print('找到 ${placemarkElements.length} 个 Placemark 元素');

    for (final placemarkElement in placemarkElements) {
      // 获取名称和描述
      final name = placemarkElement.findElements('name').firstOrNull?.innerText;
      final description =
          placemarkElement.findElements('description').firstOrNull?.innerText;

      // 如果没有名称，跳过（可能是轨迹线而不是路标点）
      if (name == null || name.isEmpty) {
        continue;
      }

      // 检查是否有 Point 元素
      final pointElement = placemarkElement.findElements('Point').firstOrNull;
      if (pointElement != null) {
        final coordElement =
            pointElement.findElements('coordinates').firstOrNull;
        if (coordElement != null) {
          final String coordText = coordElement.innerText.trim();
          _parseCoordinateString(coordText, waypoints,
              name: name, description: description, isWaypoint: true);
        }
      }

      // 检查是否有 LineString 元素（通常不是路标点，但为了完整性也解析）
      final lineStringElement =
          placemarkElement.findElements('LineString').firstOrNull;
      if (lineStringElement != null && pointElement == null) {
        // 只有在没有 Point 元素时才解析 LineString
        final coordElement =
            lineStringElement.findElements('coordinates').firstOrNull;
        if (coordElement != null) {
          final String coordText = coordElement.innerText.trim();

          // 从 LineString 中提取第一个点作为路标点
          final List<String> coordinatesList = coordText.split(RegExp(r'\s+'));
          if (coordinatesList.isNotEmpty) {
            final String trimmedCoordinates = coordinatesList.first.trim();
            if (trimmedCoordinates.isNotEmpty) {
              _parseCoordinateString(trimmedCoordinates, waypoints,
                  name: name, description: description, isWaypoint: true);
            }
          }
        }
      }
    }
  }

  /// 解析坐标字符串
  static void _parseCoordinateString(
      String coordText, List<TrackPointVO> points,
      {String? name, String? description, bool isWaypoint = false}) {
    // 坐标格式：经度,纬度,高程
    final List<String> parts = coordText.split(',');
    if (parts.length >= 2) {
      try {
        final double longitude = double.parse(parts[0].trim());
        final double latitude = double.parse(parts[1].trim());
        final double elevation =
            parts.length > 2 ? double.parse(parts[2].trim()) : 0.0;

        points.add(TrackPointVO.fromKml(
          latitude: latitude,
          longitude: longitude,
          elevation: elevation,
          name: name,
          description: description,
          type: isWaypoint ? (name ?? '路标点') : null,
          rawData: {'coordText': coordText, 'isWaypoint': isWaypoint},
        ));
      } catch (e) {
        print('解析坐标失败: $coordText - $e');
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
  static Map<String, dynamic> _calculateStatistics(
      List<TrackPointVO> trackPoints) {
    double totalDistance = 0;
    double elevationGain = 0;
    double elevationLoss = 0;
    double maxElevation = -double.infinity;
    double minElevation = double.infinity;

    for (int i = 1; i < trackPoints.length; i++) {
      final prevPoint = trackPoints[i - 1];
      final currentPoint = trackPoints[i];

      // 计算距离
      final distance = _calculateDistance(
        prevPoint.latitude,
        prevPoint.longitude,
        currentPoint.latitude,
        currentPoint.longitude,
      );

      totalDistance += distance;

      // 计算高程变化
      final elevationDiff = currentPoint.elevation - prevPoint.elevation;
      if (elevationDiff > 0) {
        elevationGain += elevationDiff;
      } else {
        elevationLoss += -elevationDiff;
      }

      // 更新最高和最低高程
      maxElevation = max(maxElevation, currentPoint.elevation);
      minElevation = min(minElevation, currentPoint.elevation);
    }

    // 如果只有一个点，确保最高和最低高程有效
    if (trackPoints.length == 1) {
      maxElevation = trackPoints[0].elevation;
      minElevation = trackPoints[0].elevation;
    }

    return {
      "totalDistance": totalDistance / 1000, // 转换为公里
      "totalDuration":
          _estimateDuration(totalDistance).toInt(), // 估算徒步时间（小时）转为整数
      "totalAscent": elevationGain,
      "totalDescent": elevationLoss,
      "maxElevation": maxElevation,
      "minElevation": minElevation,
      "averageSpeed": totalDistance > 0
          ? _estimateDuration(totalDistance) > 0
              ? totalDistance / (_estimateDuration(totalDistance) * 1000)
              : 0
          : 0, // 平均速度（米/秒）
    };
  }

  /// 估算徒步时间（小时）
  static double _estimateDuration(double distanceInMeters) {
    // 假设平均步行速度为 4 公里/小时
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
    return highestPoint.copyWith(type: '最高点');
  }

  /// 找出最低点
  static TrackPointVO _findLowestPoint(List<TrackPointVO> trackPoints) {
    TrackPointVO lowestPoint = trackPoints.first;
    for (final point in trackPoints) {
      if (point.elevation < lowestPoint.elevation) {
        lowestPoint = point;
      }
    }
    return lowestPoint.copyWith(type: '最低点');
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
