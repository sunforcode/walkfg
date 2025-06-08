import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:walk/model/map/track_point_model.dart';

/// 标记点类型
enum MarkerType {
  /// 起点
  startPoint,

  /// 终点
  endPoint,

  /// 兴趣点
  pointOfInterest,

  /// 休息点
  restPoint,

  /// 危险点
  dangerPoint,

  /// 拍照点
  photoPoint,

  /// 公里标记
  kilometerMarker,

  /// 当前位置
  currentLocation,

  /// 自定义标记
  custom,
}

/// 标记样式配置
class MarkerStyleConfig {
  /// 标记大小
  final double size;

  /// 标记颜色
  final Color color;

  /// 边框颜色
  final Color borderColor;

  /// 边框宽度
  final double borderWidth;

  /// 图标
  final IconData? icon;

  /// 是否显示阴影
  final bool showShadow;

  const MarkerStyleConfig({
    this.size = 24.0,
    this.color = Colors.red,
    this.borderColor = Colors.white,
    this.borderWidth = 2.0,
    this.icon,
    this.showShadow = true,
  });
}

/// 标记数据
class MarkerData {
  /// 轨迹点
  final TrackPointVO point;

  /// 标记类型
  final MarkerType type;

  /// 自定义样式
  final MarkerStyleConfig? customStyle;

  /// 显示文本
  final String? displayText;

  const MarkerData({
    required this.point,
    required this.type,
    this.customStyle,
    this.displayText,
  });
}

/// 标记图层组件 - 专门负责各种标记点的显示
///
/// 职责：
/// 1. 显示不同类型的标记点
/// 2. 处理标记点样式
/// 3. 处理标记点交互
/// 4. 支持自定义标记样式
class CustomMarkerLayer extends StatelessWidget {
  /// 标记数据列表
  final List<MarkerData> markers;

  /// 标记点击回调
  final void Function(MarkerData marker)? onMarkerTap;

  /// 默认样式配置
  final Map<MarkerType, MarkerStyleConfig> defaultStyles;

  const CustomMarkerLayer({
    super.key,
    required this.markers,
    this.onMarkerTap,
    this.defaultStyles = const {},
  });

  /// 获取默认样式配置
  static Map<MarkerType, MarkerStyleConfig> get _defaultStyleConfigs => {
        MarkerType.startPoint: const MarkerStyleConfig(
          color: Colors.green,
          icon: Icons.play_arrow,
          size: 28.0,
        ),
        MarkerType.endPoint: const MarkerStyleConfig(
          color: Colors.red,
          icon: Icons.stop,
          size: 28.0,
        ),
        MarkerType.pointOfInterest: const MarkerStyleConfig(
          color: Colors.purple,
          icon: Icons.camera_alt,
          size: 24.0,
        ),
        MarkerType.restPoint: const MarkerStyleConfig(
          color: Colors.blue,
          icon: Icons.local_cafe,
          size: 24.0,
        ),
        MarkerType.dangerPoint: const MarkerStyleConfig(
          color: Colors.red,
          icon: Icons.warning,
          size: 26.0,
        ),
        MarkerType.photoPoint: const MarkerStyleConfig(
          color: Colors.pink,
          icon: Icons.photo_camera,
          size: 24.0,
        ),
        MarkerType.kilometerMarker: const MarkerStyleConfig(
          color: Colors.white,
          borderColor: Colors.grey,
          size: 30.0,
          showShadow: true,
        ),
        MarkerType.currentLocation: const MarkerStyleConfig(
          color: Colors.blue,
          borderColor: Colors.white,
          size: 20.0,
          borderWidth: 3.0,
        ),
        MarkerType.custom: const MarkerStyleConfig(
          color: Colors.grey,
          icon: Icons.place,
          size: 24.0,
        ),
      };

  /// 获取标记样式
  MarkerStyleConfig _getMarkerStyle(MarkerData markerData) {
    // 优先使用自定义样式
    if (markerData.customStyle != null) {
      return markerData.customStyle!;
    }

    // 使用传入的默认样式
    if (defaultStyles.containsKey(markerData.type)) {
      return defaultStyles[markerData.type]!;
    }

    // 使用内置默认样式
    return _defaultStyleConfigs[markerData.type] ??
        _defaultStyleConfigs[MarkerType.custom]!;
  }

  /// 构建标记点Widget
  Widget _buildMarkerWidget(MarkerData markerData) {
    final style = _getMarkerStyle(markerData);

    return GestureDetector(
      onTap: () => onMarkerTap?.call(markerData),
      child: Container(
        width: style.size,
        height: style.size,
        decoration: BoxDecoration(
          color: style.color,
          shape: BoxShape.circle,
          border: Border.all(
            color: style.borderColor,
            width: style.borderWidth,
          ),
          boxShadow: style.showShadow
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: _buildMarkerContent(markerData, style),
      ),
    );
  }

  /// 构建标记内容
  Widget _buildMarkerContent(MarkerData markerData, MarkerStyleConfig style) {
    // 公里标记显示数字
    if (markerData.type == MarkerType.kilometerMarker) {
      return Center(
        child: Text(
          markerData.displayText ?? '?',
          style: TextStyle(
            fontSize: style.size * 0.3,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      );
    }

    // 当前位置不显示图标
    if (markerData.type == MarkerType.currentLocation) {
      return const SizedBox.shrink();
    }

    // 其他标记显示图标或文本
    if (style.icon != null) {
      return Icon(
        style.icon,
        color: Colors.white,
        size: style.size * 0.6,
      );
    }

    // 显示自定义文本
    if (markerData.displayText != null) {
      return Center(
        child: Text(
          markerData.displayText!.isNotEmpty ? markerData.displayText![0] : '?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: style.size * 0.4,
          ),
        ),
      );
    }

    // 默认显示位置图标
    return Icon(
      Icons.place,
      color: Colors.white,
      size: style.size * 0.6,
    );
  }

  /// 构建Flutter Map的Marker列表
  List<Marker> _buildFlutterMapMarkers() {
    return markers.map((markerData) {
      final style = _getMarkerStyle(markerData);

      return Marker(
        point: LatLng(
          markerData.point.latitude,
          markerData.point.longitude,
        ),
        width: style.size,
        height: style.size,
        child: _buildMarkerWidget(markerData),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (markers.isEmpty) {
      return const SizedBox.shrink();
    }

    return MarkerLayer(
      markers: _buildFlutterMapMarkers(),
    );
  }
}

/// 标记图层构建器 - 提供便捷的构建方法
class MarkerLayerBuilder {
  /// 从轨迹点构建起点和终点标记
  static List<MarkerData> buildStartEndMarkers(List<TrackPointVO> trackPoints) {
    if (trackPoints.isEmpty) return [];

    final markers = <MarkerData>[];

    // 起点
    markers.add(MarkerData(
      point: trackPoints.first,
      type: MarkerType.startPoint,
      displayText: '起点',
    ));

    // 终点（如果不是同一个点）
    if (trackPoints.length > 1) {
      markers.add(MarkerData(
        point: trackPoints.last,
        type: MarkerType.endPoint,
        displayText: '终点',
      ));
    }

    return markers;
  }

  /// 从路标点构建兴趣点标记
  static List<MarkerData> buildPointsOfInterest(List<TrackPointVO> waypoints) {
    // 简化实现：将所有路标点作为兴趣点
    return waypoints
        .map((point) => MarkerData(
              point: point,
              type: MarkerType.pointOfInterest,
              displayText: 'POI',
            ))
        .toList();
  }

  /// 构建公里标记
  static List<MarkerData> buildKilometerMarkers(
      List<TrackPointVO> trackPoints) {
    final markers = <MarkerData>[];

    if (trackPoints.isEmpty) return markers;

    // 根据累计距离计算公里标记
    for (int i = 0; i < trackPoints.length; i++) {
      final point = trackPoints[i];
      final distance = point.distanceFromStart ?? 0.0;

      // 每公里添加一个标记
      if (distance > 0 &&
          (distance / 1000).floor() > 0 &&
          (distance % 1000) < 100) {
        // 允许100米的误差
        final kmNumber = (distance / 1000).floor();
        markers.add(MarkerData(
          point: point,
          type: MarkerType.kilometerMarker,
          displayText: '${kmNumber}km',
        ));
      }
    }

    return markers;
  }

  /// 构建当前位置标记
  static MarkerData? buildCurrentLocationMarker(LatLng? currentLocation) {
    if (currentLocation == null) return null;

    return MarkerData(
      point: TrackPointVO(
        latitude: currentLocation.latitude,
        longitude: currentLocation.longitude,
        elevation: 0.0,
      ),
      type: MarkerType.currentLocation,
      displayText: '当前位置',
    );
  }

  /// 构建自定义标记
  static MarkerData buildCustomMarker({
    required TrackPointVO point,
    required MarkerType type,
    String? displayText,
    MarkerStyleConfig? customStyle,
  }) {
    return MarkerData(
      point: point,
      type: type,
      displayText: displayText,
      customStyle: customStyle,
    );
  }

  /// 构建特殊位置标记（最高点、最低点等）
  static List<MarkerData> buildSpecialPointMarkers({
    TrackPointVO? highestPoint,
    TrackPointVO? lowestPoint,
    TrackPointVO? startPoint,
    TrackPointVO? endPoint,
  }) {
    final markers = <MarkerData>[];

    if (highestPoint != null) {
      markers.add(MarkerData(
        point: highestPoint,
        type: MarkerType.pointOfInterest,
        displayText: '最高点',
        customStyle: const MarkerStyleConfig(
          color: Colors.orange,
          icon: Icons.keyboard_arrow_up,
          size: 26.0,
        ),
      ));
    }

    if (lowestPoint != null) {
      markers.add(MarkerData(
        point: lowestPoint,
        type: MarkerType.pointOfInterest,
        displayText: '最低点',
        customStyle: const MarkerStyleConfig(
          color: Colors.blue,
          icon: Icons.keyboard_arrow_down,
          size: 26.0,
        ),
      ));
    }

    return markers;
  }
}
