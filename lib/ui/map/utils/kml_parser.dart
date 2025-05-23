import 'dart:math';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';
import 'package:walk/model/model/map/map_bounds.dart';
import 'package:walk/model/model/map/map_data_model.dart';
import 'package:walk/model/model/map/map_statistics.dart';
import 'package:walk/model/model/map/track_point_model.dart';

/// KML 文件解析器
class KmlParser {
  /// 从 KML 文件解析地图数据
  static Future<MapDataModel> parseFromAsset(String assetPath) async {
    try {
      // 读取 KML 文件内容
      final String kmlContent = await rootBundle.loadString(assetPath);

      print('KML 内容: $kmlContent'); // 调试输出

      // 解析 XML
      final document = XmlDocument.parse(kmlContent);

      // 获取文档名称
      final nameElement = document.findAllElements('name').first;
      final name = nameElement.innerText;

      // 获取文档描述
      final descriptionElement = document.findAllElements('description').first;
      final description = descriptionElement.innerText;

      // 获取所有坐标点
      final coordinatesElements = document.findAllElements('coordinates');

      // 解析轨迹点
      final List<TrackPointVO> trackPoints = [];

      // 处理每个坐标集合
      for (final coordinatesElement in coordinatesElements) {
        final String coordinatesText = coordinatesElement.innerText.trim();
        print('坐标文本: $coordinatesText'); // 调试输出

        final List<String> coordinatesList = coordinatesText.split('\n');

        for (final String coordinates in coordinatesList) {
          final String trimmedCoordinates = coordinates.trim();
          if (trimmedCoordinates.isEmpty) continue;

          final List<String> parts = trimmedCoordinates.split(',');
          if (parts.length >= 3) {
            try {
              final double longitude = double.parse(parts[0].trim());
              final double latitude = double.parse(parts[1].trim());
              final double elevation = double.parse(parts[2].trim());

              print('解析坐标: 经度=$longitude, 纬度=$latitude, 高程=$elevation'); // 调试输出

              trackPoints.add(TrackPointVO(
                latitude: latitude,
                longitude: longitude,
                elevation: elevation,
                timestamp: DateTime.now(),
              ));
            } catch (e) {
              print('解析坐标失败: $trimmedCoordinates - $e');
            }
          }
        }
      }

      print('解析到 ${trackPoints.length} 个轨迹点'); // 调试输出

      if (trackPoints.isEmpty) {
        throw Exception('未找到有效的轨迹点');
      }

      // 计算边界
      double minLat = double.infinity;
      double maxLat = -double.infinity;
      double minLng = double.infinity;
      double maxLng = -double.infinity;
      double minElevation = double.infinity;
      double maxElevation = -double.infinity;

      for (final point in trackPoints) {
        minLat = point.latitude < minLat ? point.latitude : minLat;
        maxLat = point.latitude > maxLat ? point.latitude : maxLat;
        minLng = point.longitude < minLng ? point.longitude : minLng;
        maxLng = point.longitude > maxLng ? point.longitude : maxLng;

        minElevation =
            point.elevation < minElevation ? point.elevation : minElevation;
        maxElevation =
            point.elevation > maxElevation ? point.elevation : maxElevation;
      }

      // 创建边界对象
      final bounds = MapBoundsVO(
        north: maxLat,
        south: minLat,
        east: maxLng,
        west: minLng,
      );

      print('边界: 北=$maxLat, 南=$minLat, 东=$maxLng, 西=$minLng'); // 调试输出

      // 计算统计信息
      double totalDistance = 0;
      double elevationGain = 0;
      double elevationLoss = 0;

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
      }

      // 创建统计对象
      final statistics = MapStatisticsVO(
          totalDistance: totalDistance / 1000, // 转换为公里
          totalDuration: 2, // 假设的徒步时间
          totalAscent: elevationGain,
          totalDescent: elevationLoss,
          maxElevation: 5.0, // 假设的最大速度
          averageSpeed: 3.0, // 假设的平均速度
          minElevation: 1);

      // 找出最高点和最低点
      TrackPointVO? highestPoint;
      TrackPointVO? lowestPoint;

      for (final point in trackPoints) {
        if (highestPoint == null || point.elevation > highestPoint.elevation) {
          highestPoint = point;
        }
        if (lowestPoint == null || point.elevation < lowestPoint.elevation) {
          lowestPoint = point;
        }
      }

      // 创建地图数据模型
      return MapDataModel(
        id: name.replaceAll(' ', '_').toLowerCase(),
        dataType: MapDataType.kml,
        sourceUrl: assetPath,
        rawContent: kmlContent,
        bounds: bounds,
        statistics: statistics,
        trackPoints: trackPoints,
        highestPoint: highestPoint,
        lowestPoint: lowestPoint,
        startPoint: trackPoints.first,
        endPoint: trackPoints.last,
        pointCount: trackPoints.length,
        segmentCount: 1,
        recordedAt: DateTime.now(),
        processingStatus: 'completed',
      );
    } catch (e) {
      print('KML 解析错误: $e');
      rethrow;
    }
  }

  /// 计算两点间距离（米）
  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371000.0; // 地球半径（米）
    final phi1 = lat1 * (3.141592653589793 / 180);
    final phi2 = lat2 * (3.141592653589793 / 180);
    final deltaPhi = (lat2 - lat1) * (3.141592653589793 / 180);
    final deltaLambda = (lon2 - lon1) * (3.141592653589793 / 180);

    final a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }
}
