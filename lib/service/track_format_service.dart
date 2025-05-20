import '../model/route/track_point_model.dart';

/// 轨迹格式类型
enum TrackFormatType {
  /// GPX格式
  gpx,

  /// KML格式
  kml,

  /// GeoJSON格式
  geojson,
}

/// 轨迹格式服务抽象类
abstract class TrackFormatService {
  /// 解析KML格式文件
  List<TrackPointModel> parseKmlFile(String content);

  /// 计算轨迹总距离（米）
  double calculateTrackDistance(List<TrackPointModel> trackPoints);

  /// 计算累计上升高度（米）
  double calculateElevationGain(List<TrackPointModel> trackPoints);

  /// 计算累计下降高度（米）
  double calculateElevationLoss(List<TrackPointModel> trackPoints);

  /// 计算最高点海拔（米）
  double calculateHighestElevation(List<TrackPointModel> trackPoints);

  /// 计算最低点海拔（米）
  double calculateLowestElevation(List<TrackPointModel> trackPoints);

  /// 将轨迹转换为GPX格式
  String convertToGPX(List<TrackPointModel> trackPoints,
      {String name = 'Track'});

  /// 将轨迹转换为KML格式
  String convertToKML(List<TrackPointModel> trackPoints,
      {String name = 'Track'});

  /// 将轨迹转换为GeoJSON格式
  String convertToGeoJSON(List<TrackPointModel> trackPoints,
      {String name = 'Track'});
}
