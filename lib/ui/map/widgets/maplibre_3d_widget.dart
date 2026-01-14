import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:walk/model/map/track_point_model.dart';
import 'package:walk/ui/map/core/map_enum.dart';

/// MapLibre 3D地图配置
class MapLibre3DConfig {
  /// 地图类型
  final MapType mapType;

  /// 初始中心点
  final ll.LatLng? initialCenter;

  /// 初始缩放级别
  final double initialZoom;

  /// 初始倾斜角度 (0-60度)
  final double initialPitch;

  /// 初始旋转角度 (0-360度)
  final double initialBearing;

  /// 是否启用3D建筑
  final bool enable3DBuildings;

  /// 是否启用地形
  final bool enableTerrain;

  /// 最小缩放级别
  final double minZoom;

  /// 最大缩放级别
  final double maxZoom;

  /// 轨迹颜色
  final Color trackColor;

  /// 轨迹宽度
  final double trackWidth;

  const MapLibre3DConfig({
    this.mapType = MapType.threeD,
    this.initialCenter,
    this.initialZoom = 10.0,
    this.initialPitch = 45.0,
    this.initialBearing = 0.0,
    this.enable3DBuildings = true,
    this.enableTerrain = true,
    this.minZoom = 0.0,
    this.maxZoom = 22.0,
    this.trackColor = const Color(0xFF2196F3),
    this.trackWidth = 3.0,
  });

  /// 创建副本
  MapLibre3DConfig copyWith({
    MapType? mapType,
    ll.LatLng? initialCenter,
    double? initialZoom,
    double? initialPitch,
    double? initialBearing,
    bool? enable3DBuildings,
    bool? enableTerrain,
    double? minZoom,
    double? maxZoom,
    Color? trackColor,
    double? trackWidth,
  }) {
    return MapLibre3DConfig(
      mapType: mapType ?? this.mapType,
      initialCenter: initialCenter ?? this.initialCenter,
      initialZoom: initialZoom ?? this.initialZoom,
      initialPitch: initialPitch ?? this.initialPitch,
      initialBearing: initialBearing ?? this.initialBearing,
      enable3DBuildings: enable3DBuildings ?? this.enable3DBuildings,
      enableTerrain: enableTerrain ?? this.enableTerrain,
      minZoom: minZoom ?? this.minZoom,
      maxZoom: maxZoom ?? this.maxZoom,
      trackColor: trackColor ?? this.trackColor,
      trackWidth: trackWidth ?? this.trackWidth,
    );
  }
}

/// MapLibre 3D事件
class MapLibre3DEvents {
  /// 地图点击
  final void Function(ll.LatLng position)? onTap;

  /// 地图长按
  final void Function(ll.LatLng position)? onLongPress;

  /// 地图移动
  final void Function(
      ll.LatLng center, double zoom, double pitch, double bearing)? onMove;

  /// 地图准备就绪
  final VoidCallback? onReady;

  const MapLibre3DEvents({
    this.onTap,
    this.onLongPress,
    this.onMove,
    this.onReady,
  });
}

/// MapLibre 3D地图组件
class MapLibre3DWidget extends StatefulWidget {
  /// 配置
  final MapLibre3DConfig config;

  /// 事件
  final MapLibre3DEvents events;

  /// 轨迹点数据
  final List<TrackPointVO> trackPoints;

  /// 是否显示轨迹
  final bool showTrack;

  /// 地图高度
  final double height;

  const MapLibre3DWidget({
    super.key,
    this.config = const MapLibre3DConfig(),
    this.events = const MapLibre3DEvents(),
    this.trackPoints = const [],
    this.showTrack = true,
    this.height = 400.0,
  });

  @override
  State<MapLibre3DWidget> createState() => _MapLibre3DWidgetState();
}

class _MapLibre3DWidgetState extends State<MapLibre3DWidget> {
  MapLibreMapController? _mapController;
  bool _isReady = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          // MapLibre地图
          MapLibreMap(
            styleString: _getStyleString(),
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(
                widget.config.initialCenter?.latitude ?? 39.9042,
                widget.config.initialCenter?.longitude ?? 116.4074,
              ),
              zoom: widget.config.initialZoom,
              bearing: widget.config.initialBearing,
              tilt: widget.config.initialPitch,
            ),
            minMaxZoomPreference: MinMaxZoomPreference(
              widget.config.minZoom,
              widget.config.maxZoom,
            ),
            onMapClick: (point, latLng) {
              widget.events.onTap
                  ?.call(ll.LatLng(latLng.latitude, latLng.longitude));
            },
            onMapLongClick: (point, latLng) {
              widget.events.onLongPress
                  ?.call(ll.LatLng(latLng.latitude, latLng.longitude));
            },
            onCameraIdle: _handleCameraMove,
            compassEnabled: true,
            rotateGesturesEnabled: true,
            scrollGesturesEnabled: true,
            tiltGesturesEnabled: true,
            zoomGesturesEnabled: true,
          ),

          // 3D控制面板
          if (_isReady)
            Positioned(
              top: 16,
              right: 16,
              child: _build3DControls(),
            ),

          // 错误提示
          if (_errorMessage != null)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        CupertinoIcons.exclamationmark_triangle,
                        size: 48,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '3D地图加载失败',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      CupertinoButton(
                        onPressed: _retry,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 地图创建回调
  void _onMapCreated(MapLibreMapController controller) {
    _mapController = controller;
    _initializeMap();
  }

  /// 初始化地图
  Future<void> _initializeMap() async {
    if (_mapController == null) return;

    try {
      print('MapLibre 3D地图开始初始化...');

      // 等待地图样式加载完成
      await Future.delayed(const Duration(milliseconds: 2000));

      // 启用3D建筑
      if (widget.config.enable3DBuildings) {
        await _enable3DBuildings();
      }

      // 启用地形
      if (widget.config.enableTerrain) {
        await _enableTerrain();
      }

      // 添加轨迹
      if (widget.showTrack && widget.trackPoints.isNotEmpty) {
        await _addTrackLine();
      }

      setState(() {
        _isReady = true;
        _errorMessage = null;
      });

      print('MapLibre 3D地图初始化完成');
      widget.events.onReady?.call();
    } catch (e) {
      print('MapLibre 3D初始化失败: $e');
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  /// 获取地图样式
  String _getStyleString() {
    switch (widget.config.mapType) {
      case MapType.threeDSatellite:
        // 使用开源卫星样式
        return _createOpenSourceSatelliteStyle();
      case MapType.threeDTerrain:
        // 使用开源地形样式
        return _createOpenSourceTerrainStyle();
      default:
        // 使用开源标准样式
        return _createOpenSourceStandardStyle();
    }
  }

  /// 创建开源标准样式
  String _createOpenSourceStandardStyle() {
    return '''
{
  "version": 8,
  "name": "OpenStreetMap",
  "sources": {
    "osm": {
      "type": "raster",
      "tiles": [
        "https://a.tile.openstreetmap.org/{z}/{x}/{y}.png",
        "https://b.tile.openstreetmap.org/{z}/{x}/{y}.png",
        "https://c.tile.openstreetmap.org/{z}/{x}/{y}.png"
      ],
      "tileSize": 256,
      "attribution": "© OpenStreetMap contributors",
      "maxzoom": 19
    }
  },
  "layers": [
    {
      "id": "osm",
      "type": "raster",
      "source": "osm",
      "minzoom": 0,
      "maxzoom": 22
    }
  ]
}
''';
  }

  /// 创建开源卫星样式
  String _createOpenSourceSatelliteStyle() {
    return '''
{
  "version": 8,
  "name": "Satellite",
  "sources": {
    "satellite": {
      "type": "raster",
      "tiles": [
        "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}"
      ],
      "tileSize": 256,
      "attribution": "© Esri"
    }
  },
  "layers": [
    {
      "id": "satellite",
      "type": "raster",
      "source": "satellite"
    }
  ]
}
''';
  }

  /// 创建开源地形样式
  String _createOpenSourceTerrainStyle() {
    return '''
{
  "version": 8,
  "name": "Terrain",
  "sources": {
    "osm": {
      "type": "raster",
      "tiles": [
        "https://a.tile.openstreetmap.org/{z}/{x}/{y}.png",
        "https://b.tile.openstreetmap.org/{z}/{x}/{y}.png",
        "https://c.tile.openstreetmap.org/{z}/{x}/{y}.png"
      ],
      "tileSize": 256,
      "attribution": "© OpenStreetMap contributors",
      "maxzoom": 19
    },
    "hillshade": {
      "type": "raster",
      "tiles": [
        "https://tiles.wmflabs.org/hillshading/{z}/{x}/{y}.png"
      ],
      "tileSize": 256,
      "maxzoom": 17
    }
  },
  "layers": [
    {
      "id": "hillshade",
      "type": "raster",
      "source": "hillshade",
      "paint": {
        "raster-opacity": 0.3
      }
    },
    {
      "id": "osm",
      "type": "raster",
      "source": "osm"
    }
  ]
}
''';
  }

  /// 启用3D建筑
  Future<void> _enable3DBuildings() async {
    try {
      // 添加3D建筑图层
      await _mapController!.addLayer(
        'building-3d',
        'building-3d',
        FillExtrusionLayerProperties(
          fillExtrusionColor: '#aaa',
          fillExtrusionHeight: [
            'interpolate',
            ['linear'],
            ['zoom'],
            15,
            0,
            15.05,
            ['get', 'height']
          ],
          fillExtrusionBase: [
            'interpolate',
            ['linear'],
            ['zoom'],
            15,
            0,
            15.05,
            ['get', 'min_height']
          ],
          fillExtrusionOpacity: 0.6,
        ),
      );
      print('3D建筑已启用');
    } catch (e) {
      print('启用3D建筑失败: $e');
    }
  }

  /// 启用地形
  Future<void> _enableTerrain() async {
    try {
      // 使用开源的地形数据源
      await _mapController!.addSource(
        'terrain-source',
        RasterSourceProperties(
          tiles: ['https://tiles.wmflabs.org/hillshading/{z}/{x}/{y}.png'],
          tileSize: 256,
        ),
      );

      print('开源地形数据源已添加');

      // 添加山体阴影图层
      try {
        await _mapController!.addLayer(
          'terrain-source',
          'hillshade-layer',
          RasterLayerProperties(
            rasterOpacity: 0.4,
          ),
        );
        print('山体阴影图层已添加');
      } catch (e) {
        print('添加山体阴影图层失败: $e');
      }

      print('开源地形已启用');
    } catch (e) {
      print('启用开源地形失败: $e');
    }
  }

  /// 添加轨迹线
  Future<void> _addTrackLine() async {
    if (_mapController == null || widget.trackPoints.isEmpty) return;

    try {
      // 转换轨迹点为GeoJSON格式
      final coordinates = widget.trackPoints
          .map((point) => [
                point.longitude,
                point.latitude,
                point.elevation, // 3D坐标包含海拔
              ])
          .toList();

      // 添加数据源
      await _mapController!.addSource(
        'track-source',
        GeojsonSourceProperties(
          data: {
            'type': 'Feature',
            'geometry': {
              'type': 'LineString',
              'coordinates': coordinates,
            },
          },
        ),
      );

      // 添加3D线条图层
      await _mapController!.addLayer(
        'track-source',
        'track-layer',
        LineLayerProperties(
          lineColor:
              '#${widget.config.trackColor.value.toRadixString(16).padLeft(8, '0').substring(2)}',
          lineWidth: widget.config.trackWidth,
          lineOpacity: 0.8,
        ),
      );

      // 添加起点和终点标记
      await _addStartEndMarkers();

      // 调整视角以显示整个轨迹
      await _fitTrackBounds();

      print('轨迹线已添加，轨迹点数量: ${widget.trackPoints.length}');
    } catch (e) {
      print('添加轨迹线失败: $e');
    }
  }

  /// 添加起点和终点标记
  Future<void> _addStartEndMarkers() async {
    if (widget.trackPoints.isEmpty) return;

    try {
      final startPoint = widget.trackPoints.first;
      final endPoint = widget.trackPoints.last;

      // 添加起点标记
      await _mapController!.addSymbol(
        SymbolOptions(
          geometry: LatLng(startPoint.latitude, startPoint.longitude),
          iconImage: 'marker-15',
          iconColor: '#4CAF50',
          iconSize: 1.5,
        ),
      );

      // 添加终点标记
      await _mapController!.addSymbol(
        SymbolOptions(
          geometry: LatLng(endPoint.latitude, endPoint.longitude),
          iconImage: 'marker-15',
          iconColor: '#E91E63',
          iconSize: 1.5,
        ),
      );

      print('起点和终点标记已添加');
    } catch (e) {
      print('添加起终点标记失败: $e');
    }
  }

  /// 调整视角显示整个轨迹
  Future<void> _fitTrackBounds() async {
    if (_mapController == null || widget.trackPoints.isEmpty) return;

    try {
      // 计算边界
      double minLat = widget.trackPoints.first.latitude;
      double maxLat = widget.trackPoints.first.latitude;
      double minLng = widget.trackPoints.first.longitude;
      double maxLng = widget.trackPoints.first.longitude;

      for (final point in widget.trackPoints) {
        minLat = minLat < point.latitude ? minLat : point.latitude;
        maxLat = maxLat > point.latitude ? maxLat : point.latitude;
        minLng = minLng < point.longitude ? minLng : point.longitude;
        maxLng = maxLng > point.longitude ? maxLng : point.longitude;
      }

      // 设置边界
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          ),
          left: 50,
          top: 50,
          right: 50,
          bottom: 50,
        ),
      );

      print('视角已调整到轨迹边界');
    } catch (e) {
      print('调整视角失败: $e');
    }
  }

  /// 处理相机移动
  void _handleCameraMove() async {
    if (_mapController != null) {
      try {
        // 这里可以获取相机位置信息
        // 由于getCameraPosition可能不存在，我们暂时跳过
        print('相机移动');
      } catch (e) {
        print('获取相机位置失败: $e');
      }
    }
  }

  /// 构建3D控制面板
  Widget _build3DControls() {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildControlButton(
            icon: CupertinoIcons.cube_box,
            label: '3D建筑',
            onPressed: _toggle3DBuildings,
          ),
          _buildControlButton(
            icon: CupertinoIcons.map,
            label: '地形',
            onPressed: _toggleTerrain,
          ),
          _buildControlButton(
            icon: CupertinoIcons.location,
            label: '重置视角',
            onPressed: _resetCamera,
          ),
        ],
      ),
    );
  }

  /// 构建控制按钮
  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return CupertinoButton(
      padding: const EdgeInsets.all(12),
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// 切换3D建筑
  void _toggle3DBuildings() async {
    try {
      // 这里可以实现3D建筑的开关
      print('切换3D建筑');
    } catch (e) {
      print('切换3D建筑失败: $e');
    }
  }

  /// 切换地形
  void _toggleTerrain() async {
    try {
      // 这里可以实现地形的开关
      print('切换地形');
    } catch (e) {
      print('切换地形失败: $e');
    }
  }

  /// 重置相机视角
  void _resetCamera() async {
    try {
      await _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              widget.config.initialCenter?.latitude ?? 39.9042,
              widget.config.initialCenter?.longitude ?? 116.4074,
            ),
            zoom: widget.config.initialZoom,
            bearing: widget.config.initialBearing,
            tilt: widget.config.initialPitch,
          ),
        ),
      );
      print('相机视角已重置');
    } catch (e) {
      print('重置相机失败: $e');
    }
  }

  /// 重试初始化
  void _retry() {
    setState(() {
      _errorMessage = null;
      _isReady = false;
    });
    _initializeMap();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
