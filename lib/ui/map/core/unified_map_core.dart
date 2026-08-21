import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:walk/ui/map/core/map_enum.dart';

/// 统一地图核心配置
class UnifiedMapConfig {
  /// 地图类型
  final MapType mapType;

  /// 地图提供商
  final MapProviderType mapProvider;

  /// 最小缩放级别
  final double minZoom;

  /// 最大缩放级别
  final double maxZoom;

  /// 初始缩放级别
  final double initialZoom;

  /// 是否启用交互
  final bool enableInteraction;

  /// 地图边距
  final EdgeInsets padding;

  /// 初始中心点
  final LatLng? initialCenter;

  /// 初始边界
  final LatLngBounds? initialBounds;

  /// 是否启用3D模式
  final bool enable3D;

  /// 3D倾斜角度
  final double pitch;

  /// 3D旋转角度
  final double bearing;

  const UnifiedMapConfig({
    this.mapType = MapType.standard,
    this.mapProvider = MapProviderType.osm,
    this.minZoom = 3.0,
    this.maxZoom = 18.0,
    this.initialZoom = 10.0,
    this.enableInteraction = true,
    this.padding = EdgeInsets.zero,
    this.initialCenter,
    this.initialBounds,
    this.enable3D = false,
    this.pitch = 0.0,
    this.bearing = 0.0,
  });

  UnifiedMapConfig copyWith({
    MapType? mapType,
    MapProviderType? mapProvider,
    double? minZoom,
    double? maxZoom,
    double? initialZoom,
    bool? enableInteraction,
    EdgeInsets? padding,
    LatLng? initialCenter,
    LatLngBounds? initialBounds,
  }) {
    return UnifiedMapConfig(
      mapType: mapType ?? this.mapType,
      mapProvider: mapProvider ?? this.mapProvider,
      minZoom: minZoom ?? this.minZoom,
      maxZoom: maxZoom ?? this.maxZoom,
      initialZoom: initialZoom ?? this.initialZoom,
      enableInteraction: enableInteraction ?? this.enableInteraction,
      padding: padding ?? this.padding,
      initialCenter: initialCenter ?? this.initialCenter,
      initialBounds: initialBounds ?? this.initialBounds,
    );
  }
}

/// 统一地图事件
class UnifiedMapEvents {
  /// 地图点击
  final void Function(LatLng position)? onTap;

  /// 地图长按
  final void Function(LatLng position)? onLongPress;

  /// 地图移动
  final void Function(LatLng center, double zoom)? onMove;

  /// 地图准备就绪
  final VoidCallback? onReady;

  const UnifiedMapEvents({
    this.onTap,
    this.onLongPress,
    this.onMove,
    this.onReady,
  });
}

/// 统一地图核心 - 项目中唯一的 FlutterMap 封装
///
/// 职责：
/// 1. 作为项目中唯一的 FlutterMap 实例管理者
/// 2. 统一处理地图配置和初始化
/// 3. 统一管理 MapController
/// 4. 提供标准的地图事件接口
/// 5. 支持图层叠加
class UnifiedMapCore extends StatefulWidget {
  /// 地图配置
  final UnifiedMapConfig config;

  /// 事件回调
  final UnifiedMapEvents events;

  /// 地图图层（子组件）
  final List<Widget> layers;

  /// 地图控制器创建回调
  final void Function(MapController controller)? onControllerCreated;

  const UnifiedMapCore({
    super.key,
    this.config = const UnifiedMapConfig(),
    this.events = const UnifiedMapEvents(),
    this.layers = const [],
    this.onControllerCreated,
  });

  @override
  State<UnifiedMapCore> createState() => _UnifiedMapCoreState();
}

class _UnifiedMapCoreState extends State<UnifiedMapCore> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    // 通知外部控制器已创建
    widget.onControllerCreated?.call(_mapController);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMap();
    });
  }

  /// 初始化地图
  void _initializeMap() {
    // 设置初始位置
    if (widget.config.initialBounds != null) {
      _mapController.fitBounds(
        widget.config.initialBounds!,
        options: FitBoundsOptions(
          padding: widget.config.padding,
          maxZoom: widget.config.maxZoom,
        ),
      );
    } else if (widget.config.initialCenter != null) {
      _mapController.move(
        widget.config.initialCenter!,
        widget.config.initialZoom,
      );
    }

    widget.events.onReady?.call();
  }

  /// 获取瓦片URL
  String _getTileUrl() {
    switch (widget.config.mapProvider) {
      case MapProviderType.osm:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
      case MapProviderType.amap:
        switch (widget.config.mapType) {
          case MapType.amapSatellite:
            return 'https://webst01.is.autonavi.com/appmaptile?style=6&x={x}&y={y}&z={z}';
          case MapType.amapNight:
            return 'https://webst01.is.autonavi.com/appmaptile?style=3&x={x}&y={y}&z={z}';
          default:
            return 'https://webrd01.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}';
        }
      case MapProviderType.google:
        switch (widget.config.mapType) {
          case MapType.googleSatellite:
            return 'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}';
          case MapType.googleTerrain:
            return 'https://mt1.google.com/vt/lyrs=p&x={x}&y={y}&z={z}';
          default:
            return 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}';
        }
      default:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter:
            widget.config.initialCenter ?? const LatLng(39.9042, 116.4074),
        initialZoom: widget.config.initialZoom,
        minZoom: widget.config.minZoom,
        maxZoom: widget.config.maxZoom,
        interactionOptions: InteractionOptions(
          flags: widget.config.enableInteraction
              ? InteractiveFlag.all
              : InteractiveFlag.none,
        ),
        onTap: (tapPosition, point) {
          widget.events.onTap?.call(point);
        },
        onLongPress: (tapPosition, point) {
          widget.events.onLongPress?.call(point);
        },
        onPositionChanged: (position, hasGesture) {
          widget.events.onMove?.call(
            position.center!,
            position.zoom!,
          );
        },
      ),
      children: [
        // 瓦片层（始终是第一层）
        TileLayer(
          urlTemplate: _getTileUrl(),
          userAgentPackageName: 'com.example.walk',
          tileProvider: CancellableNetworkTileProvider(),
          maxZoom: widget.config.maxZoom,
          minZoom: widget.config.minZoom,
          fallbackUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),

        // 用户自定义图层
        ...widget.layers,
      ],
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}

/// 地图控制器管理器 - 提供统一的控制器访问接口
class MapControllerManager {
  static final Map<String, MapController> _controllers = {};

  /// 注册地图控制器
  static void register(String id, MapController controller) {
    _controllers[id] = controller;
  }

  /// 获取地图控制器
  static MapController? get(String id) {
    return _controllers[id];
  }

  /// 移除地图控制器
  static void unregister(String id) {
    _controllers.remove(id);
  }

  /// 清理所有控制器
  static void clear() {
    _controllers.clear();
  }
}
