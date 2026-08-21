import 'dart:math' as math;
import 'package:walk/model/map/track_point_model.dart';

/// GCJ-02 <-> WGS-84 坐标转换工具
///
/// 两步路（2bulu.com）等国内轨迹软件使用 GCJ-02 坐标系
/// Mapbox 使用 WGS-84 坐标系（GPS 标准）
/// 需要在渲染前做转换，误差约 1-2 米，徒步场景可接受
class CoordinateTransformUtils {
  static const double _pi = math.pi;
  static const double _a = 6378245.0; // 长半轴
  static const double _ee = 0.00669342162296594323; // 扁率

  /// 判断坐标是否在中国大陆范围内
  ///
  /// GCJ-02 加密仅对中国大陆生效，境外坐标不做偏移修正
  static bool isInChina(double lat, double lng) {
    return lng >= 72.004 &&
        lng <= 137.8347 &&
        lat >= 0.8293 &&
        lat <= 55.8271;
  }

  /// GCJ-02 → WGS-84 单点转换
  static ({double lat, double lng}) gcj02ToWgs84(double lat, double lng) {
    if (!isInChina(lat, lng)) {
      return (lat: lat, lng: lng);
    }
    final dLat = _transformLat(lng - 105.0, lat - 35.0);
    final dLng = _transformLng(lng - 105.0, lat - 35.0);
    final radLat = lat / 180.0 * _pi;
    double magic = math.sin(radLat);
    magic = 1 - _ee * magic * magic;
    final sqrtMagic = math.sqrt(magic);
    final dLatFinal = (dLat * 180.0) / ((_a * (1 - _ee)) / (magic * sqrtMagic) * _pi);
    final dLngFinal = (dLng * 180.0) / (_a / sqrtMagic * math.cos(radLat) * _pi);
    return (lat: lat - dLatFinal, lng: lng - dLngFinal);
  }

  /// 批量转换轨迹点列表，保留海拔/时间戳等所有其他字段
  static List<TrackPointVO> transformList(List<TrackPointVO> points) {
    return points.map((point) {
      final converted = gcj02ToWgs84(point.latitude, point.longitude);
      return point.copyWith(
        latitude: converted.lat,
        longitude: converted.lng,
      );
    }).toList();
  }

  // ————— 内部辅助方法 —————

  static double _transformLat(double lng, double lat) {
    double ret = -100.0 +
        2.0 * lng +
        3.0 * lat +
        0.2 * lat * lat +
        0.1 * lng * lat +
        0.2 * math.sqrt(lng.abs());
    ret += (20.0 * math.sin(6.0 * lng * _pi) +
            20.0 * math.sin(2.0 * lng * _pi)) *
        2.0 /
        3.0;
    ret += (20.0 * math.sin(lat * _pi) + 40.0 * math.sin(lat / 3.0 * _pi)) *
        2.0 /
        3.0;
    ret +=
        (160.0 * math.sin(lat / 12.0 * _pi) + 320 * math.sin(lat * _pi / 30.0)) *
            2.0 /
            3.0;
    return ret;
  }

  static double _transformLng(double lng, double lat) {
    double ret = 300.0 +
        lng +
        2.0 * lat +
        0.1 * lng * lng +
        0.1 * lng * lat +
        0.1 * math.sqrt(lng.abs());
    ret += (20.0 * math.sin(6.0 * lng * _pi) +
            20.0 * math.sin(2.0 * lng * _pi)) *
        2.0 /
        3.0;
    ret += (20.0 * math.sin(lng * _pi) + 40.0 * math.sin(lng / 3.0 * _pi)) *
        2.0 /
        3.0;
    ret +=
        (150.0 * math.sin(lng / 12.0 * _pi) + 300.0 * math.sin(lng / 30.0 * _pi)) *
            2.0 /
            3.0;
    return ret;
  }
}
