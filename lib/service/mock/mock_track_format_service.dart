import 'dart:math';
import 'package:xml/xml.dart';
import '../track_format_service.dart';
import '../../model/model/map/track_point_model.dart';

/// Mock轨迹格式服务实现
class MockTrackFormatService implements TrackFormatService {
  /// 单例实例
  static final MockTrackFormatService _instance =
      MockTrackFormatService._internal();

  /// 工厂构造函数
  factory MockTrackFormatService() {
    return _instance;
  }

  /// 私有构造函数
  MockTrackFormatService._internal();

  @override
  List<TrackPointVO> parseKmlFile(String content) {
    try {
      // 解析KML文件
      final document = XmlDocument.parse(content);
      final placemarks = document.findAllElements('Placemark');

      List<TrackPointVO> trackPoints = [];

      for (var placemark in placemarks) {
        final coordinates = placemark.findAllElements('coordinates').first.text;
        final coordList = coordinates.trim().split(' ');

        for (var coord in coordList) {
          if (coord.trim().isEmpty) continue;

          final parts = coord.split(',');
          if (parts.length >= 3) {
            final longitude = double.parse(parts[0]);
            final latitude = double.parse(parts[1]);

            trackPoints.add(TrackPointVO(
                latitude: latitude, longitude: longitude, elevation: 10));
          }
        }
      }
      return trackPoints;
    } catch (e) {
      print('解析KML文件失败: $e');
      return [];
    }
  }

  @override
  double calculateElevationGain(List<TrackPointVO> trackPoints) {
    if (trackPoints.isEmpty || trackPoints.length < 2) {
      return 0.0;
    }

    double totalGain = 0.0;
    for (int i = 0; i < trackPoints.length - 1; i++) {
      final double elevationDiff =
          trackPoints[i + 1].elevation ?? 0 - (trackPoints[i].elevation ?? 0);
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
          trackPoints[i].elevation ?? 0 - (trackPoints[i + 1].elevation ?? 0);
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

    double highest = trackPoints[0].elevation ?? 0;
    for (int i = 1; i < trackPoints.length; i++) {
      if ((trackPoints[i].elevation ?? 0) > (highest ?? 0)) {
        highest = trackPoints[i].elevation ?? 0;
      }
    }

    return highest;
  }

  @override
  double calculateLowestElevation(List<TrackPointVO> trackPoints) {
    if (trackPoints.isEmpty) {
      return 0.0;
    }

    double lowest = trackPoints[0].elevation ?? 0;
    for (int i = 1; i < trackPoints.length; i++) {
      if ((trackPoints[i].elevation ?? 0) < lowest) {
        lowest = trackPoints[i].elevation ?? 0;
      }
    }

    return lowest;
  }

  @override
  String convertToKML(List<TrackPointVO> trackPoints, {String name = 'Track'}) {
    throw UnimplementedError();
  }

  @override
  String convertToGeoJSON(List<TrackPointVO> trackPoints,
      {String name = 'Track'}) {
    throw UnimplementedError();
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

  /// 计算两点之间的距离（哈弗辛公式）
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // 地球半径，单位：米
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
  String convertToGPX(List<TrackPointVO> trackPoints, {String name = 'Track'}) {
    final buffer = StringBuffer();
    buffer.write('<?xml version="1.0" encoding="UTF-8"?>\n');
    buffer.write(
        '<gpx version="1.1" creator="Walk App" xmlns="http://www.topografix.com/GPX/1/1">\n');
    buffer.write('  <trk>\n');
    buffer.write('    <name>$name</name>\n');
    buffer.write('    <trkseg>\n');

    for (var point in trackPoints) {
      buffer.write(
          '      <trkpt lat="${point.latitude}" lon="${point.longitude}">\n');
      buffer.write('        <ele>${point.elevation}</ele>\n');
      if (point.timestamp != null) {
        buffer.write(
            '        <time>${point.timestamp!.toIso8601String()}</time>\n');
      }
      if (point.name != null) {
        buffer.write('        <name>${point.name}</name>\n');
      }
      if (point.description != null) {
        buffer.write('        <desc>${point.description}</desc>\n');
      }
      buffer.write('      </trkpt>\n');
    }

    buffer.write('    </trkseg>\n');
    buffer.write('  </trk>\n');
    buffer.write('</gpx>');

    return buffer.toString();
  }
}
