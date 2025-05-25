import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/theme/theme/app_colors.dart';
import '../unified_map_widget.dart';

/// 地图类型工具栏
class MapTypeToolbar extends StatelessWidget {
  /// 地图类型
  final MapType mapType;

  /// 地图提供商
  final MapProvider mapProvider;

  /// 是否显示地图类型选择器
  final bool showMapTypeSelector;

  /// 是否显示地图提供商选择器
  final bool showMapProviderSelector;

  /// 地图类型变更回调
  final ValueChanged<MapType>? onMapTypeChanged;

  /// 地图提供商变更回调
  final ValueChanged<MapProvider>? onMapProviderChanged;

  /// 地图类型选择器切换回调
  final VoidCallback? onMapTypeSelectorToggle;

  /// 地图提供商选择器切换回调
  final VoidCallback? onMapProviderSelectorToggle;

  /// 构造函数
  const MapTypeToolbar({
    super.key,
    required this.mapType,
    required this.mapProvider,
    required this.showMapTypeSelector,
    required this.showMapProviderSelector,
    this.onMapTypeChanged,
    this.onMapProviderChanged,
    this.onMapTypeSelectorToggle,
    this.onMapProviderSelectorToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      right: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 地图类型按钮
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                CupertinoIcons.map,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            onPressed: onMapTypeSelectorToggle,
          ),

          // 地图类型选择器
          if (showMapTypeSelector)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      '地图类型',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  _buildMapTypeOption(MapType.standard, '标准'),
                  _buildMapTypeOption(MapType.satellite, '卫星'),
                  _buildMapTypeOption(MapType.hybrid, '混合'),
                  _buildMapTypeOption(MapType.terrain, '地形'),
                  const Divider(),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.globe,
                          color: AppColors.primary,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '更多地图源',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    onPressed: onMapProviderSelectorToggle,
                  ),
                ],
              ),
            ),

          // 地图提供商选择器
          if (showMapProviderSelector)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      '地图提供商',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  _buildMapProviderOption(MapProvider.apple, '苹果地图'),
                  _buildMapProviderOption(MapProvider.amap, '高德地图'),
                  _buildMapProviderOption(MapProvider.tianditu, '天地图'),
                  _buildMapProviderOption(MapProvider.osm, 'OpenStreetMap'),
                  _buildMapProviderOption(MapProvider.google, '谷歌地图'),
                  const Divider(),
                  if (mapProvider == MapProvider.amap)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            '高德地图样式',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        _buildMapTypeOption(MapType.amapStandard, '标准'),
                        _buildMapTypeOption(MapType.amapSatellite, '卫星'),
                        _buildMapTypeOption(MapType.amapNight, '夜间'),
                      ],
                    ),
                  if (mapProvider == MapProvider.tianditu)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            '天地图样式',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        _buildMapTypeOption(MapType.tiandituVector, '矢量'),
                        _buildMapTypeOption(MapType.tiandituSatellite, '卫星'),
                        _buildMapTypeOption(MapType.tiandituTerrain, '地形'),
                      ],
                    ),
                  if (mapProvider == MapProvider.osm)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'OpenStreetMap样式',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        _buildMapTypeOption(MapType.osmStandard, '标准'),
                        _buildMapTypeOption(MapType.osmHumanitarian, '人道主义'),
                      ],
                    ),
                  if (mapProvider == MapProvider.google)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            '谷歌地图样式',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        _buildMapTypeOption(MapType.googleStandard, '标准'),
                        _buildMapTypeOption(MapType.googleSatellite, '卫星'),
                        _buildMapTypeOption(MapType.googleTerrain, '地形'),
                      ],
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 构建地图类型选项
  Widget _buildMapTypeOption(MapType type, String label) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            mapType == type
                ? CupertinoIcons.checkmark_circle_fill
                : CupertinoIcons.circle,
            color: mapType == type
                ? AppColors.primary
                : CupertinoColors.systemGrey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: mapType == type
                  ? AppColors.primary
                  : CupertinoColors.label,
              fontSize: 14,
            ),
          ),
        ],
      ),
      onPressed: () {
        if (onMapTypeChanged != null) {
          onMapTypeChanged!(type);
        }
      },
    );
  }

  /// 构建地图提供商选项
  Widget _buildMapProviderOption(MapProvider provider, String label) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            mapProvider == provider
                ? CupertinoIcons.checkmark_circle_fill
                : CupertinoIcons.circle,
            color: mapProvider == provider
                ? AppColors.primary
                : CupertinoColors.systemGrey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: mapProvider == provider
                  ? AppColors.primary
                  : CupertinoColors.label,
              fontSize: 14,
            ),
          ),
        ],
      ),
      onPressed: () {
        if (onMapProviderChanged != null) {
          onMapProviderChanged!(provider);
        }
      },
    );
  }
}

/// 增强工具栏
class EnhancedToolbar extends StatelessWidget {
  /// 是否显示轨迹渲染模式选择器
  final bool showTrackRenderModeSelector;

  /// 是否显示公里标记
  final bool showKilometerMarkers;

  /// 是否显示兴趣点
  final bool showPointsOfInterest;

  /// 是否显示海拔图表
  final bool showElevationChart;

  /// 是否支持离线地图
  final bool supportOfflineMap;

  /// 是否正在加载离线地图
  final bool isLoadingOfflineMap;

  /// 轨迹渲染模式选择器切换回调
  final VoidCallback? onTrackRenderModeSelectorToggle;

  /// 公里标记显示状态变更回调
  final ValueChanged<bool>? onKilometerMarkersToggle;

  /// 兴趣点显示状态变更回调
  final ValueChanged<bool>? onPointsOfInterestToggle;

  /// 海拔图表显示状态变更回调
  final ValueChanged<bool>? onElevationChartToggle;

  /// 离线地图下载回调
  final VoidCallback? onOfflineMapDownload;

  /// 构造函数
  const EnhancedToolbar({
    super.key,
    required this.showTrackRenderModeSelector,
    required this.showKilometerMarkers,
    required this.showPointsOfInterest,
    required this.showElevationChart,
    required this.supportOfflineMap,
    required this.isLoadingOfflineMap,
    this.onTrackRenderModeSelectorToggle,
    this.onKilometerMarkersToggle,
    this.onPointsOfInterestToggle,
    this.onElevationChartToggle,
    this.onOfflineMapDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 10,
      left: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // 轨迹渲染模式
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.color_filter,
                    color: showTrackRenderModeSelector
                        ? AppColors.primary
                        : CupertinoColors.systemGrey,
                    size: 24,
                  ),
                  const Text(
                    '渲染模式',
                    style: TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
              onPressed: onTrackRenderModeSelectorToggle,
            ),

            // 公里标记
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.location,
                    color: showKilometerMarkers
                        ? AppColors.primary
                        : CupertinoColors.systemGrey,
                    size: 24,
                  ),
                  const Text(
                    '公里标记',
                    style: TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
              onPressed: () {
                if (onKilometerMarkersToggle != null) {
                  onKilometerMarkersToggle!(!showKilometerMarkers);
                }
              },
            ),

            // 兴趣点
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.map_pin,
                    color: showPointsOfInterest
                        ? AppColors.primary
                        : CupertinoColors.systemGrey,
                    size: 24,
                  ),
                  const Text(
                    '兴趣点',
                    style: TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
              onPressed: () {
                if (onPointsOfInterestToggle != null) {
                  onPointsOfInterestToggle!(!showPointsOfInterest);
                }
              },
            ),

            // 海拔图表
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.chart_bar,
                    color: showElevationChart
                        ? AppColors.primary
                        : CupertinoColors.systemGrey,
                    size: 24,
                  ),
                  const Text(
                    '海拔图表',
                    style: TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
              onPressed: () {
                if (onElevationChartToggle != null) {
                  onElevationChartToggle!(!showElevationChart);
                }
              },
            ),

            // 离线地图
            if (supportOfflineMap)
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.cloud_download,
                      color: isLoadingOfflineMap
                          ? AppColors.primary
                          : CupertinoColors.systemGrey,
                      size: 24,
                    ),
                    const Text(
                      '离线地图',
                      style: TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
                onPressed: onOfflineMapDownload,
              ),
          ],
        ),
      ),
    );
  }
}