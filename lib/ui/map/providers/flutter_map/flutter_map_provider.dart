import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:walk/model/map/map_bounds.dart';
import 'package:walk/model/map/map_data_model.dart';
import 'package:walk/ui/map/core/map_controller.dart' as app;
import 'package:walk/ui/map/core/map_enum.dart';
import 'package:walk/ui/map/core/map_provider.dart';
import 'flutter_map_controller.dart';
import 'cached_tile_provider.dart';

/// Flutter Map提供商实现
class FlutterMapProvider implements MapProvider {
  final CachedTileProvider _tileProvider = CachedTileProvider();

  // 地图类型变更回调，使用可空类型并初始化为null
  void Function(MapType)? _onMapTypeChanged;

  // 重建地图回调
  void _rebuildMap(MapType mapType) {
    // 仅用于触发重建
  }

  @override
  app.MapController createController(MapDataModel? mapData) {
    return FlutterMapController(mapData);
  }

  @override
  Widget buildMap({
    required app.MapController controller,
    required BuildContext context,
    MapType mapType = MapType.standard,
    bool showUserLocation = false,
    bool showScale = true,
    bool showCompass = true,
    bool showMapTypeSelector = false,
    VoidCallback? onMapCreated,
    void Function(MapType)? onMapTypeChanged,
    void Function(double, double, double)? onCameraMove,
    void Function(double, double)? onTap,
  }) {
    final flutterMapController = controller as FlutterMapController;

    // 设置初始地图类型
    flutterMapController.setMapType(mapType);

    // 添加地图类型变更监听器
    if (onMapTypeChanged != null) {
      // 如果之前设置过监听器，先移除
      if (_onMapTypeChanged != null) {
        flutterMapController.removeMapTypeListener(_onMapTypeChanged!);
      }

      // 添加新的监听器
      _onMapTypeChanged = onMapTypeChanged;
      flutterMapController.addMapTypeListener(_onMapTypeChanged!);
    }

    // 创建状态管理器，用于重建地图瓦片
    return StatefulBuilder(
      builder: (context, setState) {
        // 添加地图类型变更监听器，用于重建地图
        flutterMapController.removeMapTypeListener(_rebuildMap);
        flutterMapController.addMapTypeListener((newMapType) {
          setState(() {
            // 触发重建
            debugPrint('重建地图，类型: $newMapType');
          });
        });

        return FlutterMap(
          mapController: flutterMapController.mapController,
          options: MapOptions(
            center: LatLng(39.9, 116.4), // 初始中心点，北京
            zoom: 10.0, // 初始缩放级别
            maxZoom: 18.0,
            interactiveFlags: InteractiveFlag.all,
            onMapReady: () {
              if (onMapCreated != null) {
                onMapCreated();
              }
            },
            onPositionChanged: (position, hasGesture) {
              if (onCameraMove != null && position.center != null) {
                onCameraMove(
                  position.center!.latitude,
                  position.center!.longitude,
                  position.zoom ?? 10.0,
                );
              }

              // 当缩放级别变化时，更新轨迹精度
              if (hasGesture && position.zoom != null) {
                _updateTrackPrecision(flutterMapController, position.zoom!);
              }
            },
            onTap: (tapPosition, point) {
              if (onTap != null) {
                onTap(point.latitude, point.longitude);
              }
            },
          ),
          children: [
            // 基础地图图层
            TileLayer(
              urlTemplate: _getUrlTemplateForMapType(
                  flutterMapController.currentMapType),
              subdomains: ['a', 'b', 'c'],
              tileProvider: _tileProvider,
              userAgentPackageName: 'com.example.walk',
              maxZoom: 19,
              // 添加错误处理
              errorImage: NetworkImage(
                  'https://via.placeholder.com/256x256/CCCCCC/FF0000?text=Error'),
            ),

            // 轨迹线图层
            PolylineLayer(
              polylines: flutterMapController.polylines,
            ),

            // 标记图层
            MarkerLayer(
              markers: flutterMapController.markers,
            ),

            // 用户位置图层
            if (showUserLocation)
              // 使用自定义用户位置图层
              _buildUserLocationLayer(),

            // 比例尺
            if (showScale)
              // 使用自定义比例尺
              _buildScaleLayer(),

            // 指南针
            if (showCompass)
              // 使用自定义指南针
              _buildCompassLayer(),

            // 自定义属性标注
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                color: Colors.white.withOpacity(0.7),
                child: Text(
                  _getAttributionForMapType(
                      flutterMapController.currentMapType),
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // 更新轨迹精度
  void _updateTrackPrecision(FlutterMapController controller, double zoom) {
    // 当缩放级别变化时，重新显示轨迹
    controller.showTrack(useElevationGradient: true);
  }

  /// 构建用户位置图层
  Widget _buildUserLocationLayer() {
    // 简单实现，实际项目中可以使用flutter_map_location_marker插件
    return Positioned(
      right: 16,
      bottom: 16,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.7),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    );
  }

  /// 构建比例尺图层
  Widget _buildScaleLayer() {
    return Positioned(
      bottom: 16,
      left: 16,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                '比例尺',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建指南针图层
  Widget _buildCompassLayer() {
    return Positioned(
      top: 16,
      right: 16,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.navigation,
            size: 24,
          ),
        ),
      ),
    );
  }

  @override
  Future<bool> isOfflineMapAvailable(MapBoundsVO bounds, int zoom) async {
    return _tileProvider.isOfflineAvailable(bounds, zoom);
  }

  @override
  Future<void> downloadOfflineMap(MapBoundsVO bounds, int minZoom, int maxZoom,
      void Function(double) progressCallback) async {
    await _tileProvider.downloadRegion(
      bounds,
      minZoom,
      maxZoom,
      progressCallback,
    );
  }

  @override
  String get providerName => 'OpenStreetMap';

  @override
  IconData get providerIcon => Icons.map;

  @override
  bool get supportsOfflineMap => true;

  @override
  bool get requiresApiKey => false;

  /// 根据地图类型获取URL模板
  String _getUrlTemplateForMapType(MapType mapType) {
    switch (mapType) {
      case MapType.standard:
        return 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
      case MapType.satellite:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
      case MapType.terrain:
        return 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png';
      case MapType.hybrid:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
      default:
        return 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }

  /// 获取地图属性标注
  String _getAttributionForMapType(MapType mapType) {
    switch (mapType) {
      case MapType.standard:
        return '© OpenStreetMap contributors';
      case MapType.satellite:
        return '© Esri, Maxar, Earthstar Geographics, and the GIS User Community';
      case MapType.terrain:
        return '© OpenTopoMap (CC-BY-SA)';
      case MapType.hybrid:
        return '© Esri, Maxar, Earthstar Geographics, and the GIS User Community';
      default:
        return '© OpenStreetMap contributors';
    }
  }
}
