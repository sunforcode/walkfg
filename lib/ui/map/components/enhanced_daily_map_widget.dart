import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:walk/model/map/track_point_model.dart';
import 'package:walk/model/map/marker_point_model.dart';
import 'package:walk/ui/map/core/unified_map_core.dart';
import 'package:walk/ui/map/core/map_enum.dart';
import 'package:walk/ui/map/layers/track_layer.dart';
import 'package:walk/ui/map/layers/marker_layer.dart';

/// 增强日程地图组件
///
/// 专门用于显示多日行程的地图，支持按天切换显示不同的轨迹段
class EnhancedDailyMapWidget extends StatefulWidget {
  /// 轨迹点数据
  final List<TrackPointVO> trackPoints;

  /// 标记点数据（使用新的MarkerPointModel）
  final List<MarkerPointModel> markers;

  /// 天数
  final int days;

  /// 地图高度
  final double height;

  /// 当前选中的天数（null表示显示全部）
  final int? selectedDay;

  /// 天数切换回调
  final void Function(int? day)? onDayChanged;

  const EnhancedDailyMapWidget({
    super.key,
    required this.trackPoints,
    this.markers = const [],
    this.days = 1,
    this.height = 400.0,
    this.selectedDay,
    this.onDayChanged,
  });

  @override
  State<EnhancedDailyMapWidget> createState() => _EnhancedDailyMapWidgetState();
}

class _EnhancedDailyMapWidgetState extends State<EnhancedDailyMapWidget> {
  int? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.selectedDay;
  }

  @override
  void didUpdateWidget(EnhancedDailyMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDay != oldWidget.selectedDay) {
      _selectedDay = widget.selectedDay;
    }
  }

  /// 按天数分割轨迹点
  List<List<TrackPointVO>> _splitTrackByDays() {
    if (widget.trackPoints.isEmpty || widget.days <= 1) {
      return [widget.trackPoints];
    }

    final pointsPerDay = (widget.trackPoints.length / widget.days).ceil();
    final result = <List<TrackPointVO>>[];

    for (int i = 0; i < widget.days; i++) {
      final start = i * pointsPerDay;
      final end = (i == widget.days - 1)
          ? widget.trackPoints.length
          : (i + 1) * pointsPerDay;

      if (start < widget.trackPoints.length) {
        result.add(widget.trackPoints
            .sublist(start, end.clamp(0, widget.trackPoints.length)));
      }
    }

    return result;
  }

  /// 获取当前显示的轨迹点
  List<TrackPointVO> _getCurrentTrackPoints() {
    final dailyTracks = _splitTrackByDays();

    if (_selectedDay == null) {
      // 显示全部
      return widget.trackPoints;
    } else if (_selectedDay! >= 0 && _selectedDay! < dailyTracks.length) {
      // 显示指定天数
      return dailyTracks[_selectedDay!];
    } else {
      return widget.trackPoints;
    }
  }

  /// 获取当前显示的标记点
  List<MarkerPointModel> _getCurrentMarkers() {
    // 标记点通常不按天数分割，始终显示所有可见的标记点
    return widget.markers.where((marker) => marker.isVisible).toList();
  }

  /// 获取轨迹颜色
  Color _getTrackColor() {
    if (_selectedDay == null) {
      return const Color(0xFF2196F3); // 蓝色 - 全部
    } else {
      // 根据天数返回不同颜色
      final colors = [
        const Color(0xFF4CAF50), // 绿色 - 第1天
        const Color(0xFFFF9800), // 橙色 - 第2天
        const Color(0xFF9C27B0), // 紫色 - 第3天
        const Color(0xFFE91E63), // 粉色 - 第4天
        const Color(0xFF00BCD4), // 青色 - 第5天
      ];
      return colors[_selectedDay! % colors.length];
    }
  }

  /// 处理天数切换
  void _handleDayChanged(int? day) {
    setState(() {
      _selectedDay = day;
    });
    widget.onDayChanged?.call(day);
  }

  /// 构建天数切换按钮
  Widget _buildDaySelector() {
    final dailyTracks = _splitTrackByDays();

    return Container(
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // 全部按钮
            _buildDayButton(
              label: '全部',
              isSelected: _selectedDay == null,
              onTap: () => _handleDayChanged(null),
            ),
            const SizedBox(width: 8),

            // 各天按钮
            ...List.generate(dailyTracks.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildDayButton(
                  label: '第${index + 1}天',
                  isSelected: _selectedDay == index,
                  onTap: () => _handleDayChanged(index),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 构建天数按钮
  Widget _buildDayButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color:
          isSelected ? CupertinoColors.activeBlue : CupertinoColors.systemGrey4,
      borderRadius: BorderRadius.circular(20),
      minSize: 0,
      onPressed: onTap,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: isSelected ? Colors.white : CupertinoColors.label,
        ),
      ),
    );
  }

  /// 构建地图图层
  List<Widget> _buildMapLayers() {
    final currentTrackPoints = _getCurrentTrackPoints();
    final currentMarkers = _getCurrentMarkers();
    final layers = <Widget>[];

    // 轨迹图层
    if (currentTrackPoints.isNotEmpty) {
      layers.add(
        TrackLayer(
          trackPoints: currentTrackPoints,
          config: TrackRenderConfig(
            renderMode: TrackRenderMode.normal,
            strokeWidth: 3.0,
            defaultColor: _getTrackColor(),
          ),
        ),
      );
    }

    // 标记图层
    final allMarkers = <MarkerData>[];

    // 添加起终点标记
    if (currentTrackPoints.isNotEmpty) {
      allMarkers
          .addAll(MarkerLayerBuilder.buildStartEndMarkers(currentTrackPoints));
    }

    // 添加普通标记点
    for (final marker in currentMarkers) {
      allMarkers.add(MarkerData(
        point: marker,
        type: _getMarkerTypeFromMarkerPoint(marker),
      ));
    }

    if (allMarkers.isNotEmpty) {
      layers.add(
        CustomMarkerLayer(
          markers: allMarkers,
          onMarkerTap: (marker) {
            // 显示标记信息
            _showMarkerInfo(marker);
          },
        ),
      );
    }

    return layers;
  }

  /// 将MarkerPointModel的类型映射到MarkerType
  MarkerType _getMarkerTypeFromMarkerPoint(MarkerPointModel markerPoint) {
    switch (markerPoint.markerType) {
      case MarkerPointType.poi:
        return MarkerType.pointOfInterest;
      case MarkerPointType.landmark:
        return MarkerType.pointOfInterest;
      case MarkerPointType.viewpoint:
        return MarkerType.photoPoint;
      case MarkerPointType.restPoint:
        return MarkerType.restPoint;
      case MarkerPointType.dangerPoint:
        return MarkerType.dangerPoint;
      case MarkerPointType.infoPoint:
        return MarkerType.pointOfInterest;
      case MarkerPointType.other:
        return MarkerType.custom;
    }
  }

  /// 显示标记信息
  void _showMarkerInfo(MarkerData marker) {
    // 判断是否为MarkerPointModel
    if (marker.point is MarkerPointModel) {
      final markerPoint = marker.point as MarkerPointModel;
      _showMarkerPointInfo(markerPoint);
    } else {
      // 处理普通TrackPointVO
      _showTrackPointInfo(marker.point);
    }
  }

  /// 显示标记点信息
  void _showMarkerPointInfo(MarkerPointModel markerPoint) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(markerPoint.displayTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('类型: ${markerPoint.markerTypeText}'),
            Text('海拔: ${markerPoint.elevation.toStringAsFixed(1)}m'),
            Text(
                '坐标: ${markerPoint.latitude.toStringAsFixed(4)}, ${markerPoint.longitude.toStringAsFixed(4)}'),
            if (markerPoint.description != null &&
                markerPoint.description!.isNotEmpty)
              Text('描述: ${markerPoint.description}'),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('确定'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  /// 显示轨迹点信息
  void _showTrackPointInfo(TrackPointVO trackPoint) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('轨迹点'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('海拔: ${trackPoint.elevation.toStringAsFixed(1)}m'),
            Text(
                '坐标: ${trackPoint.latitude.toStringAsFixed(4)}, ${trackPoint.longitude.toStringAsFixed(4)}'),
            if (trackPoint.timestamp != null)
              Text(
                  '时间: ${trackPoint.timestamp!.toLocal().toString().substring(0, 19)}'),
            if (trackPoint.distanceFromStart != null)
              Text(
                  '距离起点: ${(trackPoint.distanceFromStart! / 1000).toStringAsFixed(2)}km'),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('确定'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  /// 计算地图边界
  LatLngBounds? _calculateBounds() {
    final currentTrackPoints = _getCurrentTrackPoints();
    final currentMarkers = _getCurrentMarkers();

    final allPoints = <TrackPointVO>[];
    allPoints.addAll(currentTrackPoints);
    allPoints.addAll(currentMarkers);

    if (allPoints.isEmpty) return null;

    double minLat = 90.0;
    double maxLat = -90.0;
    double minLng = 180.0;
    double maxLng = -180.0;

    for (final point in allPoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    const padding = 0.01;
    return LatLngBounds(
      LatLng(minLat - padding, minLng - padding),
      LatLng(maxLat + padding, maxLng + padding),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 地图
        SizedBox(
          height: widget.height,
          child: UnifiedMapCore(
            config: UnifiedMapConfig(
              mapType: MapType.standard,
              mapProvider: MapProviderType.osm,
              enableInteraction: true,
              initialBounds: _calculateBounds(),
            ),
            events: UnifiedMapEvents(
              onTap: (position) {
                print('地图点击: $position');
              },
            ),
            layers: _buildMapLayers(),
          ),
        ),

        // 天数选择器
        if (widget.days > 1) _buildDaySelector(),
      ],
    );
  }
}
