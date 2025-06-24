import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:walk/model/map/track_point_model.dart';
import 'package:walk/model/map/marker_point_model.dart';

import 'package:walk/ui/map/core/unified_map_core.dart';
import 'package:walk/ui/map/core/map_enum.dart';
import 'package:walk/ui/map/layers/track_layer.dart';
import 'package:walk/ui/map/layers/marker_layer.dart';
import 'package:walk/ui/map/widgets/elevation_chart_widget.dart';

/// 地图显示模式
enum MapDisplayMode {
  compact, // 紧凑模式 - 300px，固定显示
  standard, // 标准模式 - 400px，跟随滚动
  immersive, // 沉浸模式 - 全屏，固定显示
}

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

  /// 显示模式（可选，如果不提供则不显示模式切换按钮）
  final MapDisplayMode? displayMode;

  /// 模式切换回调
  final void Function(MapDisplayMode mode)? onDisplayModeChanged;

  const EnhancedDailyMapWidget({
    super.key,
    required this.trackPoints,
    this.markers = const [],
    this.days = 1,
    this.height = 400.0,
    this.selectedDay,
    this.onDayChanged,
    this.displayMode,
    this.onDisplayModeChanged,
  });

  @override
  State<EnhancedDailyMapWidget> createState() => _EnhancedDailyMapWidgetState();
}

class _EnhancedDailyMapWidgetState extends State<EnhancedDailyMapWidget> {
  int? _selectedDay;
  bool _showElevationChart = false;
  bool _isRecording = false;
  bool _isFollowingLocation = false;
  MapType _currentMapType = MapType.standard;

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
    final currentTrackPoints = _getCurrentTrackPoints();

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          // 地图
          UnifiedMapCore(
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

          // 右侧功能按钮组
          Positioned(
            top: 16,
            right: 16,
            child: _buildRightButtonGroup(),
          ),

          // 地图模式切换按钮（如果提供了displayMode参数）
          if (widget.displayMode != null)
            Positioned(
              top: 16,
              right: 80, // 避免与右侧按钮重叠
              child: _buildMapModeButton(),
            ),

          // 左上角功能按钮组
          Positioned(
            top: 16,
            left: 16,
            child: _buildLeftButtonGroup(),
          ),

          // 左下角功能按钮组
          Positioned(
            bottom: _showElevationChart ? 200 : 16,
            left: 16,
            child: _buildBottomLeftButtonGroup(),
          ),

          // 海拔图表切换按钮 - 悬浮在右下角
          if (currentTrackPoints.isNotEmpty)
            Positioned(
              bottom: 16,
              right: 16,
              child: _buildElevationToggleButton(),
            ),

          // 海拔图表 - 悬浮在底部
          if (currentTrackPoints.isNotEmpty && _showElevationChart)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildFloatingElevationChart(currentTrackPoints),
            ),
        ],
      ),
    );
  }

  /// 构建海拔图表切换按钮
  Widget _buildElevationToggleButton() {
    return CupertinoButton(
      padding: const EdgeInsets.all(12),
      color: CupertinoColors.systemBlue.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(25),
      minSize: 0,
      onPressed: () {
        setState(() {
          _showElevationChart = !_showElevationChart;
        });
      },
      child: Icon(
        _showElevationChart
            ? CupertinoIcons.chart_bar_square_fill
            : CupertinoIcons.chart_bar_square,
        color: CupertinoColors.white,
        size: 20,
      ),
    );
  }

  /// 构建悬浮的海拔图表
  Widget _buildFloatingElevationChart(List<TrackPointVO> trackPoints) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题栏
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: CupertinoColors.separator,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  '海拔图表',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 0,
                  onPressed: () {
                    setState(() {
                      _showElevationChart = false;
                    });
                  },
                  child: const Icon(
                    CupertinoIcons.xmark,
                    size: 18,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
          // 海拔图表
          ElevationChartWidget(
            trackPoints: trackPoints,
            config: const ElevationChartConfig(
              height: 120.0,
              showLabels: false, // 禁用内部标签，避免重复
              enableInteraction: true,
            ),
            events: ElevationChartEvents(
              onPointSelected: (index, point) {
                print('选中海拔点: $index, 海拔: ${point.elevation}m');
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 构建右侧功能按钮组
  Widget _buildRightButtonGroup() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 定位按钮
        _buildMapButton(
          icon: _isFollowingLocation
              ? CupertinoIcons.location_fill
              : CupertinoIcons.location,
          isActive: _isFollowingLocation,
          onPressed: () {
            setState(() {
              _isFollowingLocation = !_isFollowingLocation;
            });
            // TODO: 实现定位功能
            print('定位按钮点击: $_isFollowingLocation');
          },
        ),
        const SizedBox(height: 8),

        // 轨迹录制按钮
        _buildMapButton(
          icon: _isRecording
              ? CupertinoIcons.stop_fill
              : CupertinoIcons.circle_fill,
          isActive: _isRecording,
          activeColor: _isRecording
              ? CupertinoColors.systemRed
              : CupertinoColors.systemBlue,
          onPressed: () {
            setState(() {
              _isRecording = !_isRecording;
            });
            // TODO: 实现轨迹录制功能
            print('录制按钮点击: $_isRecording');
          },
        ),
        const SizedBox(height: 8),

        // 添加标记点按钮
        _buildMapButton(
          icon: CupertinoIcons.add_circled,
          onPressed: () {
            // TODO: 实现添加标记点功能
            print('添加标记点');
          },
        ),
      ],
    );
  }

  /// 构建左上角功能按钮组
  Widget _buildLeftButtonGroup() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 地图类型切换按钮
        _buildMapButton(
          icon: CupertinoIcons.map,
          onPressed: () {
            _showMapTypeSelector();
          },
        ),
        const SizedBox(height: 8),

        // 图层控制按钮
        _buildMapButton(
          icon: CupertinoIcons.layers_alt,
          onPressed: () {
            // TODO: 实现图层控制功能
            print('图层控制');
          },
        ),
      ],
    );
  }

  /// 构建左下角功能按钮组
  Widget _buildBottomLeftButtonGroup() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 测量工具按钮
        _buildMapButton(
          icon: CupertinoIcons.triangle,
          onPressed: () {
            // TODO: 实现测量工具功能
            print('测量工具');
          },
        ),
        const SizedBox(height: 8),

        // 回到轨迹中心按钮
        _buildMapButton(
          icon: CupertinoIcons.scope,
          onPressed: () {
            // TODO: 实现回到轨迹中心功能
            print('回到轨迹中心');
          },
        ),
        const SizedBox(height: 8),

        // 更多功能按钮
        _buildMapButton(
          icon: CupertinoIcons.ellipsis,
          onPressed: () {
            _showMoreOptions();
          },
        ),
      ],
    );
  }

  /// 构建通用地图按钮
  Widget _buildMapButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isActive = false,
    Color? activeColor,
  }) {
    final buttonColor = isActive
        ? (activeColor ?? CupertinoColors.systemBlue)
        : CupertinoColors.systemGrey4;

    final iconColor = isActive ? CupertinoColors.white : CupertinoColors.label;

    return CupertinoButton(
      padding: const EdgeInsets.all(12),
      color: buttonColor.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(25),
      minSize: 0,
      onPressed: onPressed,
      child: Icon(
        icon,
        color: iconColor,
        size: 20,
      ),
    );
  }

  /// 显示地图类型选择器
  void _showMapTypeSelector() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('选择地图类型'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() {
                _currentMapType = MapType.standard;
              });
              Navigator.pop(context);
              // TODO: 实现地图类型切换
              print('切换到标准地图');
            },
            child: const Text('标准地图'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() {
                _currentMapType = MapType.satellite;
              });
              Navigator.pop(context);
              // TODO: 实现地图类型切换
              print('切换到卫星地图');
            },
            child: const Text('卫星地图'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() {
                _currentMapType = MapType.terrain;
              });
              Navigator.pop(context);
              // TODO: 实现地图类型切换
              print('切换到地形地图');
            },
            child: const Text('地形地图'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
      ),
    );
  }

  /// 显示更多选项
  void _showMoreOptions() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('更多功能'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 实现轨迹导出功能
              print('导出轨迹');
            },
            child: const Text('导出轨迹'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 实现离线地图功能
              print('离线地图');
            },
            child: const Text('离线地图'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 实现天气信息功能
              print('天气信息');
            },
            child: const Text('天气信息'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 实现设置功能
              print('设置');
            },
            child: const Text('设置'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
      ),
    );
  }

  /// 构建地图模式切换按钮
  Widget _buildMapModeButton() {
    IconData icon;
    String tooltip;

    switch (widget.displayMode!) {
      case MapDisplayMode.compact:
        icon = CupertinoIcons.minus_rectangle;
        tooltip = '紧凑模式';
        break;
      case MapDisplayMode.standard:
        icon = CupertinoIcons.rectangle;
        tooltip = '标准模式';
        break;
      case MapDisplayMode.immersive:
        icon = CupertinoIcons.plus_rectangle;
        tooltip = '沉浸模式';
        break;
    }

    return _buildMapButton(
      icon: icon,
      isActive: widget.displayMode != MapDisplayMode.standard,
      onPressed: _toggleMapDisplayMode,
    );
  }

  /// 切换地图显示模式
  void _toggleMapDisplayMode() {
    MapDisplayMode newMode;
    switch (widget.displayMode!) {
      case MapDisplayMode.compact:
        newMode = MapDisplayMode.standard;
        break;
      case MapDisplayMode.standard:
        newMode = MapDisplayMode.immersive;
        break;
      case MapDisplayMode.immersive:
        newMode = MapDisplayMode.compact;
        break;
    }

    // 通知父组件模式改变
    widget.onDisplayModeChanged?.call(newMode);
  }
}
