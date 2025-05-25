import 'package:flutter/widgets.dart';
import 'package:walk/model/model/map/map_bounds.dart';
import 'package:walk/model/model/map/map_data_model.dart';
import 'package:walk/ui/map/core/map_enum.dart';
import 'map_controller.dart';

/// 地图提供商抽象类
abstract class MapProvider {
  /// 创建地图控制器
  MapController createController(MapDataModel? mapData);

  /// 构建地图Widget
  Widget buildMap({
    required MapController controller,
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
  });

  /// 检查离线地图是否可用
  Future<bool> isOfflineMapAvailable(MapBoundsVO bounds, int zoom);

  /// 下载离线地图
  Future<void> downloadOfflineMap(MapBoundsVO bounds, int minZoom, int maxZoom,
      void Function(double) progressCallback);

  /// 获取提供商名称
  String get providerName;

  /// 获取提供商图标
  IconData get providerIcon;

  /// 是否支持离线地图
  bool get supportsOfflineMap;

  /// 是否需要API密钥
  bool get requiresApiKey;
}
