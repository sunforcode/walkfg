import 'package:flutter/cupertino.dart';
import 'package:walk/model/map/map_data_model.dart';
import 'package:walk/model/map/track_point_model.dart';
import 'package:walk/model/route/route_model.dart';
import 'package:walk/model/route/segment_model.dart';
import 'package:walk/service/kml_cache_service.dart';
import 'package:walk/service/route_service.dart';
import 'package:walk/ui/map/map_widget.dart';
import 'package:walk/ui/page/common/error_view.dart';
import 'package:walk/ui/page/common/loading_view.dart';

class _MapTestData {
  final RouteModel route;
  final List<TrackPointVO> trackPoints;
  final MapDataModel? mapData;
  final String dataSource;

  _MapTestData({
    required this.route,
    required this.trackPoints,
    this.mapData,
    required this.dataSource,
  });
}

class MapTestScreen extends StatefulWidget {
  const MapTestScreen({super.key});

  @override
  State<MapTestScreen> createState() => _MapTestScreenState();
}

class _MapTestScreenState extends State<MapTestScreen> {
  late Future<_MapTestData> _dataFuture;
  String? _selectedSegmentId;
  String? _routeId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _dataFuture = _loadCompleteData();
  }

  Future<_MapTestData> _loadCompleteData() async {
    final popularRoutes = await RouteService.getPopularRoutes(limit: 5);
    if (popularRoutes.isEmpty) {
      throw Exception('没有推荐路线');
    }

    final firstRoute = popularRoutes.first;
    _routeId = firstRoute.id;
    print('MapTestScreen: 使用第一个推荐路线: ${firstRoute.name} (ID: ${firstRoute.id})');

    final routeDetail = await RouteService.getRouteDetail(firstRoute.id);
    print('MapTestScreen: 路线详情加载成功: ${routeDetail.name}');
    
    return await _loadTrackDataForRoute(routeDetail);
  }

  Future<_MapTestData> _loadTrackDataForRoute(RouteModel route) async {
    try {
      if (route.kmlUrl != null && route.kmlUrl!.isNotEmpty) {
        try {
          print('MapTestScreen: 通过 KmlCacheService 加载 KML 数据, kmlUrl: ${route.kmlUrl}');
          final mapData = await KmlCacheService.instance.getMapData(
            route.kmlUrl!,
            routeId: route.id,
          );
          print('MapTestScreen: KML数据加载成功: 轨迹点${mapData.trackPoints.length}个, 路标点${mapData.waypoints.length}个, 分段${mapData.segments.length}个');

          if (mapData.trackPoints.isNotEmpty) {
            return _MapTestData(
              route: route,
              trackPoints: mapData.trackPoints,
              mapData: mapData,
              dataSource: 'KML (${route.kmlUrl})',
            );
          }
        } catch (e) {
          print('MapTestScreen: KML缓存/网络加载失败: $e');
        }
      }

      if (route.trackPoints.isNotEmpty) {
        print('MapTestScreen: 使用 API 返回的 trackPoints，数量: ${route.trackPoints.length}');
        return _MapTestData(
          route: route,
          trackPoints: route.trackPoints,
          dataSource: 'API (trackPoints)',
        );
      }

      throw Exception('没有可用的轨迹数据: KML URL为空且API返回的trackPoints为空');
    } catch (e) {
      print('MapTestScreen: 轨迹数据加载失败: $e');
      rethrow;
    }
  }

  List<SegmentModel> _getSegments(_MapTestData data) {
    if (data.route.segments?.isNotEmpty ?? false) {
      print('MapTestScreen: 使用 route.segments，数量: ${data.route.segments!.length}');
      return data.route.segments!;
    }

    if (data.mapData?.segments.isNotEmpty ?? false) {
      print('MapTestScreen: 使用 mapData.segments，数量: ${data.mapData!.segments.length}');
      return data.mapData!.segments;
    }

    print('MapTestScreen: 没有可用的分段数据，返回空列表');
    return [];
  }

  void _handleSegmentTap(SegmentModel segment) {
    print('MapTestScreen: 点击分段: ${segment.name}');
    setState(() {
      if (_selectedSegmentId == segment.id) {
        _selectedSegmentId = null;
      } else {
        _selectedSegmentId = segment.id;
      }
    });
  }

  void _reloadData() {
    setState(() {
      _selectedSegmentId = null;
      _routeId = null;
      _routeName = null;
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('地图测试'),
        backgroundColor: CupertinoColors.systemBackground,
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: const Size(44, 44),
          onPressed: () {
            showCupertinoModalPopup(
              context: context,
              builder: (context) => CupertinoActionSheet(
                title: const Text('地图设置'),
                actions: [
                  CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.pop(context);
                      _reloadData();
                    },
                    child: const Text('重新加载数据'),
                  ),
                ],
                cancelButton: CupertinoActionSheetAction(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
              ),
            );
          },
          child: const Icon(CupertinoIcons.settings),
        ),
      ),
      child: SafeArea(
        child: FutureBuilder<_MapTestData>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: LoadingView(),
              );
            }

            if (snapshot.hasError) {
              return ErrorView(
                message: '地图数据加载失败: ${snapshot.error}',
                onRetry: _reloadData,
              );
            }

            final data = snapshot.data!;
            return _buildMapContent(data);
          },
        ),
      ),
    );
  }

  Widget _buildMapContent(_MapTestData data) {
    final segments = _getSegments(data);
    final segmentsWithSelection = segments.map((s) {
      return s.copyWith(isSelected: _selectedSegmentId == s.id);
    }).toList();

    print('MapTestScreen: 构建地图，trackPoints数量: ${data.trackPoints.length}');
    print('MapTestScreen: 构建地图，markers数量: ${data.route.markerPoints?.length ?? 0}');
    print('MapTestScreen: 构建地图，segments数量: ${segments.length}');

    return Stack(
      children: [
        Positioned.fill(
          child: _build2DMap(data),
        ),
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: _buildInfoPanel(data),
        ),
        if (segmentsWithSelection.isNotEmpty)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _buildSegmentsWidget(data, segmentsWithSelection),
          ),
      ],
    );
  }

  Widget _build2DMap(_MapTestData data) {
    final segments = _getSegments(data);

    return MapWidget(
      trackPoints: data.trackPoints,
      markers: data.route.markerPoints ?? [],
      days: data.route.dailyPlans?.length,
      segments: segments,
      selectedSegmentId: _selectedSegmentId,
      config: MapWidgetConfig(
        height: double.infinity,
        enabledFeatures: {
          MapFeature.track,
          MapFeature.startEndMarkers,
          MapFeature.poiMarkers,
          MapFeature.elevationChart,
          MapFeature.mapControls,
          MapFeature.routeInfo,
        },
      ),
      routeName: data.route.name,
      routeDistance: data.route.distance,
      routeElevationGain: data.route.elevationGain,
      routeDifficulty: data.route.difficulty.getName(),
    );
  }

  Widget _buildInfoPanel(_MapTestData data) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.map_fill,
                color: CupertinoColors.systemBlue,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                data.route.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                data.dataSource.contains('KML') 
                    ? CupertinoIcons.cloud_download 
                    : CupertinoIcons.info_circle,
                color: CupertinoColors.systemGreen,
                size: 12,
              ),
              const SizedBox(width: 4),
              Text(
                '数据来源: ${data.dataSource}',
                style: TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
            ],
          ),
          if (_routeId != null) ...[
            const SizedBox(height: 4),
            Text(
              '路线ID: $_routeId',
              style: TextStyle(
                fontSize: 11,
                color: CupertinoColors.secondaryLabel.withValues(alpha: 0.8),
              ),
            ),
          ],
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildInfoChip('轨迹点', '${data.trackPoints.length}'),
              _buildInfoChip('标记点', '${data.route.markerPoints?.length ?? 0}'),
              _buildInfoChip('距离', '${data.route.distance.toStringAsFixed(1)}km'),
              _buildInfoChip('爬升', '${data.route.elevationGain.toStringAsFixed(0)}m'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey5,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentsWidget(_MapTestData data, List<SegmentModel> segments) {
    if (segments.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        if (_selectedSegmentId != null) {
          setState(() {
            _selectedSegmentId = null;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '路线分段',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: segments.map((segment) {
                final isSelected = segment.isSelected;
                return GestureDetector(
                  onTap: () => _handleSegmentTap(segment),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? CupertinoColors.systemBlue
                          : CupertinoColors.systemGrey5,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: CupertinoColors.systemBlue, width: 1)
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          segment.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? CupertinoColors.white
                                : CupertinoColors.label,
                          ),
                        ),
                        if (segment.distance != null)
                          Text(
                            '${segment.distance!.toStringAsFixed(1)}km',
                            style: TextStyle(
                              fontSize: 10,
                              color: isSelected
                                  ? CupertinoColors.white.withValues(alpha: 0.8)
                                  : CupertinoColors.secondaryLabel,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
