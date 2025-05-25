import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:walk/model/model/map/map_data_model.dart';
import 'package:walk/ui/map/core/map_controller.dart';
import 'package:walk/ui/map/core/map_enum.dart';
import 'package:walk/ui/map/core/map_provider.dart';
import 'package:walk/ui/map/core/map_state.dart';
import 'map_toolbar.dart';
import 'map_loading.dart';

/// 主地图容器
class MapContainer extends StatefulWidget {
  /// 地图数据
  final MapDataModel? mapData;

  /// 地图提供商
  final MapProvider mapProvider;

  /// 初始地图类型
  final MapType initialMapType;

  /// 是否显示工具栏
  final bool showToolbar;

  /// 是否显示用户位置
  final bool showUserLocation;

  /// 是否显示比例尺
  final bool showScale;

  /// 是否显示指南针
  final bool showCompass;

  /// 是否显示地图类型选择器
  final bool showMapTypeSelector;

  /// 地图创建回调
  final void Function(MapController)? onMapControllerCreated;

  /// 地图点击回调
  final void Function(double, double)? onMapTap;

  /// 构造函数
  const MapContainer({
    Key? key,
    this.mapData,
    required this.mapProvider,
    this.initialMapType = MapType.standard,
    this.showToolbar = true,
    this.showUserLocation = true,
    this.showScale = true,
    this.showCompass = true,
    this.showMapTypeSelector = true,
    this.onMapControllerCreated,
    this.onMapTap,
  }) : super(key: key);

  @override
  State<MapContainer> createState() => _MapContainerState();
}

class _MapContainerState extends State<MapContainer> {
  late MapController _mapController;
  late MapState _mapState;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _mapController = widget.mapProvider.createController(widget.mapData);
    _mapState = MapState(
      mapController: _mapController,
      initialMapType: widget.initialMapType,
    );
  }

  @override
  void didUpdateWidget(MapContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 如果地图数据发生变化，更新控制器
    if (widget.mapData != oldWidget.mapData) {
      _mapController.setMapData(widget.mapData);
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _mapState,
      child: Stack(
        children: [
          // 地图
          widget.mapProvider.buildMap(
            controller: _mapController,
            context: context,
            mapType: _mapState.currentMapType,
            showUserLocation: widget.showUserLocation,
            showScale: widget.showScale,
            showCompass: widget.showCompass,
            showMapTypeSelector: widget.showMapTypeSelector,
            onMapCreated: _onMapCreated,
            onMapTypeChanged: _onMapTypeChanged,
            onTap: widget.onMapTap,
          ),

          // 加载指示器
          if (!_isMapReady) const MapLoading(),

          // 工具栏
          if (widget.showToolbar && _isMapReady)
            Positioned(
              top: 16,
              right: 16,
              child: MapToolbar(
                mapState: _mapState,
                showMapTypeSelector: widget.showMapTypeSelector,
              ),
            ),
        ],
      ),
    );
  }

  void _onMapCreated() {
    setState(() {
      _isMapReady = true;
    });

    if (widget.onMapControllerCreated != null) {
      widget.onMapControllerCreated!(_mapController);
    }

    // 如果有地图数据，显示整个轨迹
    if (widget.mapData != null) {
      _mapController.showEntireTrack();
      _mapController.showTrack(useElevationGradient: true);
    }
  }

  void _onMapTypeChanged(MapType mapType) {
    _mapState.setMapType(mapType);
  }
}
