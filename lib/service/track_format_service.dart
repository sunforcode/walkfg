import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart';
import '../model/map/track_point_model.dart';

/// 轨迹格式类型
enum TrackFormatType {
  /// GPX格式
  gpx,

  /// KML格式
  kml,

  /// GeoJSON格式
  geojson,
}

/// 轨迹格式服务
///
/// 使用静态方法，无需实例化
class TrackFormatService {
  // 禁止实例化
  TrackFormatService._();

  /// 解析KML格式文件
  static List<TrackPointVO> parseKmlFile(String content) {
    try {
      final document = XmlDocument.parse(content);
      final points = <TrackPointVO>[];

      // 解析坐标
      final coordinates = document.findAllElements('coordinates');

      for (final coordinate in coordinates) {
        final coordText = coordinate.text.trim();
        final coordList = coordText.split(' ');

        for (final coord in coordList) {
          if (coord.trim().isEmpty) continue;

          final parts = coord.split(',');
          if (parts.length >= 2) {
            final longitude = double.tryParse(parts[0]);
            final latitude = double.tryParse(parts[1]);
            final elevation =
                parts.length > 2 ? double.tryParse(parts[2]) ?? 0.0 : 0.0;

            if (longitude != null && latitude != null) {
              points.add(TrackPointVO(
                latitude: latitude,
                longitude: longitude,
                elevation: elevation,
              ));
            }
          }
        }
      }

      // 解析路径点
      final placemarks = document.findAllElements('Placemark');

      for (final placemark in placemarks) {
        final point = placemark.findElements('Point').firstOrNull;

        if (point != null) {
          final coordElement = point.findElements('coordinates').firstOrNull;
          if (coordElement != null) {
            final coordText = coordElement.text.trim();
            final parts = coordText.split(',');

            if (parts.length >= 2) {
              final longitude = double.tryParse(parts[0]);
              final latitude = double.tryParse(parts[1]);
              final elevation =
                  parts.length > 2 ? double.tryParse(parts[2]) ?? 0.0 : 0.0;

              if (longitude != null && latitude != null) {
                points.add(TrackPointVO(
                    latitude: latitude,
                    longitude: longitude,
                    elevation: elevation));
              }
            }
          }
        }
      }

      return points;
    } catch (e) {
      debugPrint('TrackFormatService.parseKmlFile - KML解析错误: $e');
      return [];
    }
  }

  /// 计算轨迹总距离（米）
  static double calculateTrackDistance(List<TrackPointVO> trackPoints) {
    if (trackPoints.isEmpty || trackPoints.length < 2) {
      return 0.0;
    }

    double totalDistance = 0.0;
    for (int i = 0; i < trackPoints.length - 1; i++) {
      totalDistance += _calculateDistance(
        trackPoints[i].latitude,
        trackPoints[i].longitude,
        trackPoints[i + 1].latitude,
        trackPoints[i + 1].longitude,
      );
    }

    return totalDistance;
  }

  /// 计算两点之间的距离（米）
  static double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // 地球半径（米）
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = sin(dLat / 2.0) * sin(dLat / 2.0) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2.0) *
            sin(dLon / 2.0);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  /// 角度转弧度
  static double _toRadians(double degree) {
    return degree * (pi / 180.0);
  }

  /// 计算累计上升高度（米）
  static double calculateElevationGain(List<TrackPointVO> trackPoints) {
    if (trackPoints.isEmpty || trackPoints.length < 2) {
      return 0.0;
    }

    double totalGain = 0.0;
    for (int i = 0; i < trackPoints.length - 1; i++) {
      final double elevationDiff =
          trackPoints[i + 1].elevation - trackPoints[i].elevation;
      if (elevationDiff > 0) {
        totalGain += elevationDiff;
      }
    }

    return totalGain;
  }

  /// 计算累计下降高度（米）
  static double calculateElevationLoss(List<TrackPointVO> trackPoints) {
    if (trackPoints.isEmpty || trackPoints.length < 2) {
      return 0.0;
    }

    double totalLoss = 0.0;
    for (int i = 0; i < trackPoints.length - 1; i++) {
      final double elevationDiff =
          trackPoints[i].elevation - trackPoints[i + 1].elevation;
      if (elevationDiff > 0) {
        totalLoss += elevationDiff;
      }
    }

    return totalLoss;
  }

  /// 计算最高点海拔（米）
  static double calculateHighestElevation(List<TrackPointVO> trackPoints) {
    if (trackPoints.isEmpty) {
      return 0.0;
    }

    double highest = trackPoints[0].elevation;
    for (int i = 1; i < trackPoints.length; i++) {
      if (trackPoints[i].elevation > highest) {
        highest = trackPoints[i].elevation;
      }
    }

    return highest;
  }

  /// 计算最低点海拔（米）
  static double calculateLowestElevation(List<TrackPointVO> trackPoints) {
    if (trackPoints.isEmpty) {
      return 0.0;
    }

    double lowest = trackPoints[0].elevation;
    for (int i = 1; i < trackPoints.length; i++) {
      if (trackPoints[i].elevation < lowest) {
        lowest = trackPoints[i].elevation;
      }
    }

    return lowest;
  }

  /// 将轨迹转换为GPX格式
  static String convertToGPX(List<TrackPointVO> trackPoints, {String name = 'Track'}) {
    final StringBuffer gpx = StringBuffer();

    // GPX头部
    gpx.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    gpx.writeln(
        '<gpx version="1.1" creator="Walk App" xmlns="http://www.topografix.com/GPX/1/1">');

    // 轨迹名称
    gpx.writeln('  <trk>');
    gpx.writeln('    <name>$name</name>');
    gpx.writeln('    <trkseg>');

    // 轨迹点
    for (final point in trackPoints) {
      gpx.writeln(
          '      <trkpt lat="${point.latitude}" lon="${point.longitude}">');
      gpx.writeln('        <ele>${point.elevation}</ele>');
      if (point.timestamp != null) {
        gpx.writeln(
            '        <time>${point.timestamp!.toIso8601String()}</time>');
      }
      gpx.writeln('      </trkpt>');
    }

    // GPX尾部
    gpx.writeln('    </trkseg>');
    gpx.writeln('  </trk>');
    gpx.writeln('</gpx>');

    return gpx.toString();
  }

  /// 将轨迹转换为KML格式
  static String convertToKML(List<TrackPointVO> trackPoints, {String name = 'Track'}) {
    final StringBuffer kml = StringBuffer();

    // KML头部
    kml.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    kml.writeln('<kml xmlns="http://www.opengis.net/kml/2.2">');
    kml.writeln('  <Document>');
    kml.writeln('    <name>$name</name>');

    // 轨迹样式
    kml.writeln('    <Style id="track">');
    kml.writeln('      <LineStyle>');
    kml.writeln('        <color>ff0000ff</color>');
    kml.writeln('        <width>4</width>');
    kml.writeln('      </LineStyle>');
    kml.writeln('    </Style>');

    // 轨迹
    kml.writeln('    <Placemark>');
    kml.writeln('      <name>$name</name>');
    kml.writeln('      <styleUrl>#track</styleUrl>');

    // KML尾部
    kml.writeln('  </Document>');
    kml.writeln('</kml>');

    return kml.toString();
  }

  /// 将轨迹转换为GeoJSON格式
  static String convertToGeoJSON(List<TrackPointVO> trackPoints,
      {String name = 'Track'}) {
    final StringBuffer geojson = StringBuffer();
    geojson.writeln('{');
    geojson.writeln('  "type": "FeatureCollection",');
    geojson.writeln('  "name": "$name",');
    geojson.writeln('  "features": [');

    // 轨迹线
    geojson.writeln('    {');
    geojson.writeln('      "type": "Feature",');
    geojson.writeln('      "properties": {');
    geojson.writeln('        "name": "$name"');
    geojson.writeln('      },');
    geojson.writeln('      "geometry": {');
    geojson.writeln('        "type": "LineString",');
    geojson.writeln('        "coordinates": [');

    // 轨迹点
    for (int i = 0; i < trackPoints.length; i++) {
      final point = trackPoints[i];
      geojson.write(
          '          [${point.longitude}, ${point.latitude}, ${point.elevation}]');
      if (i < trackPoints.length - 1) {
        geojson.writeln(',');
      } else {
        geojson.writeln();
      }
    }

    geojson.writeln('        ]');
    geojson.writeln('      }');
    geojson.writeln('    }');

    geojson.writeln('  ]');
    geojson.writeln('}');

    return geojson.toString();
  }
}
