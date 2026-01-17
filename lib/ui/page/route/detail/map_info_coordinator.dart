import 'package:flutter/foundation.dart';
import 'package:walk/model/map/map_bounds.dart';
import 'package:walk/model/map/track_point_model.dart';

/// 地图边界简单类型定义
/// 作为不需要全部的直接引用
typedef MapBounds = MapBoundsVO;

/// 地图-信息联动的交互数据模型
class MapHighlightInfo {
  /// 高亮类型
  final MapHighlightType type;

  /// 对应的地理坐标范围
  final MapBounds bounds;

  /// 高亮的标记点（如果有）
  final List<TrackPointVO>? trackPoints;

  /// 高亮持续时长（毫秒）
  final Duration duration;

  /// 描述信息
  final String? description;

  MapHighlightInfo({
    required this.type,
    required this.bounds,
    this.trackPoints,
    this.duration = const Duration(milliseconds: 1500),
    this.description,
  });

  @override
  String toString() =>
      'MapHighlightInfo(type: $type, bounds: $bounds, duration: $duration)';
}

/// 地图高亮类型
enum MapHighlightType {
  /// 某一天的轨迹
  dailyTrack,

  /// 某个路线分段
  segment,

  /// 单个位置点（营地、水源、补给点）
  pointLocation,

  /// 多个位置点
  multiPoints,
}

/// 地图-信息联动管理器
/// 
/// 负责：
/// - 管理地图与列表项的交互状态
/// - 提供高亮和缩放指令
/// - 处理地图回调
class MapInfoCoordinator extends ChangeNotifier {
  /// 当前高亮信息
  MapHighlightInfo? _currentHighlight;

  /// 获取当前高亮
  MapHighlightInfo? get currentHighlight => _currentHighlight;

  /// 是否正在高亮中
  bool get isHighlighting => _currentHighlight != null;

  /// 高亮变化的回调
  final ValueNotifier<MapHighlightInfo?> highlightNotifier =
      ValueNotifier(null);

  /// 设置高亮信息并触发地图交互
  void highlight(MapHighlightInfo info) {
    _currentHighlight = info;
    highlightNotifier.value = info;

    // 自动清除高亮（根据指定的持续时长）
    Future.delayed(info.duration, () {
      clearHighlight();
    });

    notifyListeners();
  }

  /// 清除高亮
  void clearHighlight() {
    _currentHighlight = null;
    highlightNotifier.value = null;
    notifyListeners();
  }

  /// 高亮某一天的轨迹
  void highlightDailyTrack(
    int dayIndex,
    MapBounds dayBounds,
    List<TrackPointVO> dayTrackPoints, {
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    highlight(MapHighlightInfo(
      type: MapHighlightType.dailyTrack,
      bounds: dayBounds,
      trackPoints: dayTrackPoints,
      duration: duration,
      description: '第 ${dayIndex + 1} 天轨迹',
    ));
  }

  /// 高亮某个路线分段
  void highlightSegment(
    int segmentIndex,
    MapBounds segmentBounds,
    List<TrackPointVO> segmentTrackPoints, {
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    highlight(MapHighlightInfo(
      type: MapHighlightType.segment,
      bounds: segmentBounds,
      trackPoints: segmentTrackPoints,
      duration: duration,
      description: '分段 ${segmentIndex + 1}',
    ));
  }

  /// 高亮单个位置点
  void highlightPoint(
    MapBounds pointBounds,
    TrackPointVO point, {
    String? name,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    highlight(MapHighlightInfo(
      type: MapHighlightType.pointLocation,
      bounds: pointBounds,
      trackPoints: [point],
      duration: duration,
      description: name ?? '位置',
    ));
  }

  /// 高亮多个位置点
  void highlightMultiPoints(
    MapBounds bounds,
    List<TrackPointVO> points, {
    String? name,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    highlight(MapHighlightInfo(
      type: MapHighlightType.multiPoints,
      bounds: bounds,
      trackPoints: points,
      duration: duration,
      description: name ?? '多个位置',
    ));
  }

  @override
  void dispose() {
    highlightNotifier.dispose();
    super.dispose();
  }
}
