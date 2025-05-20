import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import '../../../model/route/route_model.dart';
import '../../../model/route/track_point_model.dart';
import '../../../theme/theme/app_colors.dart';

/// 地图类型
enum MapType {
  /// 标准地图
  standard,

  /// 卫星地图
  satellite,

  /// 地形图
  terrain,
}

/// 路线地图组件
class RouteMapWidget extends StatefulWidget {
  /// 路线模型
  final RouteModel? route;

  /// 轨迹点列表
  final List<TrackPointModel>? trackPoints;

  /// 标记点列表
  final List<TrackPointModel>? waypoints;

  /// 是否显示当前位置
  final bool showCurrentLocation;

  /// 是否可编辑
  final bool editable;

  /// 初始缩放级别
  final double initialZoom;

  /// 地图类型
  final MapType mapType;

  /// 高度
  final double? height;

  /// 轨迹颜色
  final Color trackColor;

  /// 轨迹宽度
  final double trackWidth;

  /// 标记点点击回调
  final Function(TrackPointModel)? onWaypointTap;

  /// 地图点击回调
  final Function(LatLng)? onMapTap;

  /// 地图类型变更回调
  final Function(MapType)? onMapTypeChanged;

  /// 是否显示地图类型切换工具栏
  final bool showMapTypeToolbar;

  /// 构造函数
  const RouteMapWidget({
    super.key,
    this.route,
    this.trackPoints,
    this.waypoints,
    this.showCurrentLocation = false,
    this.editable = false,
    this.initialZoom = 13.0,
    this.mapType = MapType.standard,
    this.height,
    this.trackColor = Colors.orange,
    this.trackWidth = 3.0,
    this.onWaypointTap,
    this.onMapTap,
    this.onMapTypeChanged,
    this.showMapTypeToolbar = true,
  });

  @override
  State<RouteMapWidget> createState() => _RouteMapWidgetState();
}

class _RouteMapWidgetState extends State<RouteMapWidget> {
  /// 地图控制器
  final MapController _mapController = MapController();

  /// 当前地图类型
  late MapType _currentMapType;

  @override
  void initState() {
    super.initState();
    _currentMapType = widget.mapType;

    // 延迟执行以确保地图加载完成后自动适应轨迹边界
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_trackPoints.isNotEmpty) {
        fitTrackBounds();
      }
    });
  }

  /// 获取轨迹点列表
  List<TrackPointModel> get _trackPoints {
    if (widget.trackPoints != null) {
      return widget.trackPoints!;
    } else if (widget.route != null && widget.route!.trackPoints.isNotEmpty) {
      return widget.route!.trackPoints;
    }
    return [];
  }

  /// 获取标记点列表
  List<TrackPointModel> get _waypoints {
    if (widget.waypoints != null) {
      return widget.waypoints!;
    } else if (widget.route != null && widget.route!.trackPoints.isNotEmpty) {
      // 从轨迹点中提取有名称的点作为标记点
      return widget.route!.trackPoints.where((p) => p.name != null).toList();
    }
    return [];
  }

  /// 获取地图中心点
  LatLng _getMapCenter() {
    if (_trackPoints.isNotEmpty) {
      // 使用轨迹的中心点
      double sumLat = 0;
      double sumLng = 0;
      for (final point in _trackPoints) {
        sumLat += point.latitude;
        sumLng += point.longitude;
      }
      return LatLng(sumLat / _trackPoints.length, sumLng / _trackPoints.length);
    } else if (_waypoints.isNotEmpty) {
      // 使用标记点的中心点
      double sumLat = 0;
      double sumLng = 0;
      for (final point in _waypoints) {
        sumLat += point.latitude;
        sumLng += point.longitude;
      }
      return LatLng(sumLat / _waypoints.length, sumLng / _waypoints.length);
    }
    // 默认中心点（中国中心）
    return LatLng(35.0, 105.0);
  }

  /// 获取地图瓦片URL
  String _getTileUrl() {
    switch (_currentMapType) {
      case MapType.standard:
        return 'https://webrd01.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}';
      case MapType.satellite:
        return 'https://webst01.is.autonavi.com/appmaptile?style=6&x={x}&y={y}&z={z}';
      case MapType.terrain:
        return 'https://stamen-tiles-{s}.a.ssl.fastly.net/terrain/{z}/{x}/{y}{r}.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    // 打印轨迹点数量，用于调试
    print('RouteMapWidget - 轨迹点数量: ${_trackPoints.length}');
    if (_trackPoints.isNotEmpty) {
      print(
          'RouteMapWidget - 第一个轨迹点: ${_trackPoints.first.latitude}, ${_trackPoints.first.longitude}');
    } else {
      print('RouteMapWidget - 警告: 轨迹点列表为空!');
    }

    // 确保地图加载完成后自动适应轨迹边界
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_trackPoints.isNotEmpty) {
        print('RouteMapWidget - 自动适应轨迹边界');
        fitTrackBounds();
      }
    });

    return Stack(
      children: [
        // 地图主体
        SizedBox(
          height: widget.height ?? MediaQuery.of(context).size.height * 0.4,
          width: double.infinity,
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _getMapCenter(),
              initialZoom: widget.initialZoom,
              onTap: widget.onMapTap != null
                  ? (tapPosition, point) => widget.onMapTap!(point)
                  : null,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              // 地图瓦片层
              TileLayer(
                urlTemplate: _getTileUrl(),
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.walk',
                backgroundColor: const Color(0xFFE8F5E9), // 浅绿色背景
              ),

              // 轨迹线层
              if (_trackPoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _trackPoints
                          .map((p) => LatLng(p.latitude, p.longitude))
                          .toList(),
                      color: widget.trackColor,
                      strokeWidth: widget.trackWidth,
                    ),
                  ],
                ),

              // 标记点层
              if (_waypoints.isNotEmpty)
                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    maxClusterRadius: 45,
                    size: const Size(40, 40),
                    alignment: Alignment.center,
                    markers: _buildMarkers(),
                    builder: (context, markers) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.8),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            markers.length.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // 当前位置标记层
              if (widget.showCurrentLocation)
                CurrentLocationLayer(
                  positionStream: const LocationMarkerDataStreamFactory()
                      .fromGeolocatorPositionStream(),
                  style: const LocationMarkerStyle(
                    marker: DefaultLocationMarker(
                      color: Colors.blue,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                    markerSize: Size(22, 22),
                    accuracyCircleColor: Colors.blue,
                    headingSectorColor: Colors.blue,
                  ),
                ),
            ],
          ),
        ),

        // 地图类型切换工具栏
        if (widget.showMapTypeToolbar)
          Positioned(
            top: 16,
            right: 16,
            child: Column(
              children: [
                _buildMapTypeButton(MapType.standard, Icons.map, '标准地图'),
                const SizedBox(height: 8),
                _buildMapTypeButton(MapType.satellite, Icons.satellite, '卫星地图'),
                const SizedBox(height: 8),
                _buildMapTypeButton(MapType.terrain, Icons.terrain, '地形图'),
              ],
            ),
          ),

        // 缩放控制按钮
        Positioned(
          bottom: 16,
          right: 16,
          child: Column(
            children: [
              _buildControlButton(
                Icons.add,
                '放大',
                () => _mapController.move(_mapController.camera.center,
                    _mapController.camera.zoom + 1),
              ),
              const SizedBox(height: 8),
              _buildControlButton(
                Icons.remove,
                '缩小',
                () => _mapController.move(_mapController.camera.center,
                    _mapController.camera.zoom - 1),
              ),
              const SizedBox(height: 8),
              _buildControlButton(
                Icons.fit_screen,
                '适应屏幕',
                fitTrackBounds,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建地图类型按钮
  Widget _buildMapTypeButton(MapType mapType, IconData icon, String tooltip) {
    final isSelected = _currentMapType == mapType;

    return Tooltip(
      message: tooltip,
      child: Material(
        elevation: 4,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        color: isSelected ? Colors.orange : Colors.white,
        child: InkWell(
          onTap: () {
            setState(() {
              _currentMapType = mapType;
            });
            if (widget.onMapTypeChanged != null) {
              widget.onMapTypeChanged!(mapType);
            }
          },
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.black54,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  /// 构建控制按钮
  Widget _buildControlButton(
      IconData icon, String tooltip, VoidCallback onPressed) {
    return Tooltip(
      message: tooltip,
      child: Material(
        elevation: 4,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        color: Colors.white,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: Colors.black54,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  /// 构建标记点列表
  List<Marker> _buildMarkers() {
    return _waypoints.map((waypoint) {
      return Marker(
        point: LatLng(waypoint.latitude, waypoint.longitude),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () {
            if (widget.onWaypointTap != null) {
              widget.onWaypointTap!(waypoint);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.orange, width: 2),
            ),
            padding: const EdgeInsets.all(2),
            child: Icon(
              _getWaypointIcon(waypoint),
              color: Colors.orange,
              size: 20,
            ),
          ),
        ),
      );
    }).toList();
  }

  /// 根据标记点获取图标
  IconData _getWaypointIcon(TrackPointModel waypoint) {
    if (waypoint.name?.contains('营地') ?? false) {
      return Icons.night_shelter;
    } else if (waypoint.name?.contains('水源') ?? false) {
      return Icons.water_drop;
    } else if (waypoint.name?.contains('观景') ?? false) {
      return Icons.photo_camera;
    } else if (waypoint.name?.contains('休息') ?? false) {
      return Icons.restaurant;
    } else if (waypoint.name?.contains('起点') ?? false) {
      return Icons.flag;
    } else if (waypoint.name?.contains('终点') ?? false) {
      return Icons.flag;
    }
    return Icons.place;
  }

  /// 移动地图到指定位置
  void moveToLocation(LatLng location, {double? zoom}) {
    _mapController.move(location, zoom ?? widget.initialZoom);
  }

  /// 移动地图以显示所有轨迹点
  void fitTrackBounds() {
    if (_trackPoints.isEmpty) return;

    final bounds = LatLngBounds.fromPoints(
      _trackPoints.map((p) => LatLng(p.latitude, p.longitude)).toList(),
    );
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50),
      ),
    );
  }
}
