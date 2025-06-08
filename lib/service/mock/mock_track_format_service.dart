import 'dart:math';
import 'package:latlong2/latlong.dart';
import 'package:xml/xml.dart';
import '../../model/map/track_point_model.dart';
import '../track_format_service.dart';

/// 轨迹格式服务实现
class MockTrackFormatService implements TrackFormatService {
  @override
  List<TrackPointVO> parseKmlFile(String content) {
    try {
      print(
          'TrackFormatService.parseKmlFile - 开始解析KML文件，内容长度: ${content.length}');
      final document = XmlDocument.parse(content);
      final points = <TrackPointVO>[];

      // 解析坐标
      final coordinates = document.findAllElements('coordinates');
      print(
          'TrackFormatService.parseKmlFile - 找到坐标元素数量: ${coordinates.length}');

      for (final coordinate in coordinates) {
        final coordText = coordinate.text.trim();
        final coordList = coordText.split(' ');
        print('TrackFormatService.parseKmlFile - 坐标点数量: ${coordList.length}');

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
      print('TrackFormatService.parseKmlFile - 找到地标元素数量: ${placemarks.length}');

      for (final placemark in placemarks) {
        final name = placemark.findElements('name').firstOrNull?.text;
        final description =
            placemark.findElements('description').firstOrNull?.text;
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

      print(
          'TrackFormatService.parseKmlFile - KML解析完成，共解析出 ${points.length} 个点');
      if (points.isNotEmpty) {
        print(
            'TrackFormatService.parseKmlFile - 第一个点: ${points.first.latitude}, ${points.first.longitude}');
      }
      return points;
    } catch (e) {
      print('TrackFormatService.parseKmlFile - KML解析错误: $e');
      print('TrackFormatService.parseKmlFile - 错误堆栈: ${StackTrace.current}');
      return [];
    }
  }

  @override
  double calculateTrackDistance(List<TrackPointVO> trackPoints) {
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
  double _calculateDistance(
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
  double _toRadians(double degree) {
    return degree * (pi / 180.0);
  }

  @override
  double calculateElevationGain(List<TrackPointVO> trackPoints) {
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

  @override
  double calculateElevationLoss(List<TrackPointVO> trackPoints) {
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

  @override
  double calculateHighestElevation(List<TrackPointVO> trackPoints) {
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

  @override
  double calculateLowestElevation(List<TrackPointVO> trackPoints) {
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

  @override
  String convertToGPX(List<TrackPointVO> trackPoints, {String name = 'Track'}) {
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

  @override
  String convertToKML(List<TrackPointVO> trackPoints, {String name = 'Track'}) {
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

  @override
  String convertToGeoJSON(List<TrackPointVO> trackPoints,
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
