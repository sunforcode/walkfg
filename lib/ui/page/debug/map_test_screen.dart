import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:walk/model/map/map_data_model.dart';
import 'package:walk/model/map/marker_point_model.dart';
import 'package:walk/model/map/track_point_model.dart';
import 'package:walk/model/route/route_model.dart';
import 'package:walk/model/route/segment_model.dart';
import 'package:walk/service/kml_cache_service.dart';
import 'package:walk/service/route_service.dart';
import 'package:walk/ui/map/map_widget.dart';
import 'package:walk/ui/map/utils/map_data_helper.dart';
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

  /// 是否使用 3D 模式（Mapbox），默认 false（2D flutter_map）
  bool _is3DMode = false;

  /// 信息面板是否展开
  bool _infoExpanded = false;

  /// 分段面板是否展开
  bool _segmentsExpanded = false;

  /// 2D 地图控制器（用于外部缩放）
  MapController? _map2DController;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _dataFuture = _loadCompleteData();
  }

  /// 固定加载的五台山路线 ID
  static const String _wutaiRouteId = 'route_1778383536408_P4gA3V5H';

  Future<_MapTestData> _loadCompleteData() async {
    _routeId = _wutaiRouteId;

    final routeDetail = await RouteService.getRouteDetail(_wutaiRouteId);

    return await _loadTrackDataForRoute(routeDetail);
  }

  Future<_MapTestData> _loadTrackDataForRoute(RouteModel route) async {
    try {
      if (route.kmlUrl != null && route.kmlUrl!.isNotEmpty) {
        try {
          final mapData = await KmlCacheService.instance.getMapData(
            route.kmlUrl!,
            routeId: route.id,
          );

          if (mapData.trackPoints.isNotEmpty) {
            return _MapTestData(
              route: route,
              trackPoints: mapData.trackPoints,
              mapData: mapData,
              dataSource: 'KML (${route.kmlUrl})',
            );
          }
        } catch (e) {
          debugPrint('MapTestScreen: KML缓存/网络加载失败: $e');
        }
      }

      if (route.trackPoints.isNotEmpty) {
        return _MapTestData(
          route: route,
          trackPoints: route.trackPoints,
          dataSource: 'API (trackPoints)',
        );
      }

      throw Exception('没有可用的轨迹数据: KML URL为空且API返回的trackPoints为空');
    } catch (e) {
      debugPrint('MapTestScreen: 轨迹数据加载失败: $e');
      rethrow;
    }
  }

  /// 获取分段数据（使用统一优先级逻辑）
  List<SegmentModel> _getSegments(_MapTestData data) {
    return MapDataHelper.resolveSegments(data.route, data.mapData);
  }

  /// 获取标记点数据（使用统一优先级逻辑）
  List<MarkerPointModel> _getMarkers(_MapTestData data) {
    return MapDataHelper.resolveMarkers(data.route);
  }

  /// 根据序号生成固定颜色（黄金角旋转，各段颜色均匀分布）
  static Color _segmentColor(int seq, bool isSelected) {
    final h = (seq * 137.508) % 360;
    return HSVColor.fromAHSV(
      isSelected ? 0.5 : 1.0,
      h,
      0.75,
      0.85,
    ).toColor();
  }

  void _handleSegmentTap(SegmentModel segment) {
    setState(() {
      if (_selectedSegmentId == segment.id) {
        _selectedSegmentId = null;
      } else {
        _selectedSegmentId = segment.id;
      }
    });
  }

  void _reloadData() async {
    // 清除旧 KML 缓存，确保重新从后台加载
    await KmlCacheService.instance.clearAllCache();
    setState(() {
      _selectedSegmentId = null;
      _routeId = null;
      _map2DController = null;
      _loadData();
    });
  }

  void _toggle3DMode() {
    setState(() {
      _is3DMode = !_is3DMode;
    });
  }

  /// 放大地图
  void _zoomIn() {
    final ctrl = _map2DController;
    if (ctrl == null) return;
    final current = ctrl.camera.zoom;
    ctrl.move(ctrl.camera.center, (current + 1).clamp(3.0, 18.0));
  }

  /// 缩小地图
  void _zoomOut() {
    final ctrl = _map2DController;
    if (ctrl == null) return;
    final current = ctrl.camera.zoom;
    ctrl.move(ctrl.camera.center, (current - 1).clamp(3.0, 18.0));
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('地图测试'),
        backgroundColor: CupertinoColors.systemBackground,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 2D/3D 切换按钮
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size(52, 44),
              onPressed: _toggle3DMode,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _is3DMode
                      ? CupertinoColors.systemBlue
                      : CupertinoColors.systemGrey5,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _is3DMode ? '3D' : '2D',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _is3DMode
                        ? CupertinoColors.white
                        : CupertinoColors.label,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            // 设置按钮
            CupertinoButton(
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
          ],
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

    final markers = _getMarkers(data);

    return Stack(
      children: [
        // 根据模式切换 2D / 3D 地图（全屏）
        Positioned.fill(
          child: _is3DMode
              ? UnifiedMapWidget(
                  mapMode: MapMode.map3d,
                  trackPoints: data.trackPoints,
                  markers: markers,
                  segments: segments,
                  selectedSegmentId: _selectedSegmentId,
                )
              : _build2DMap(data, markers),
        ),

        // 左上角：信息按钮（折叠时只显示小图标）
        Positioned(
          top: 12,
          left: 12,
          child: _buildInfoToggle(data),
        ),

        // 右侧：缩放按钮（仅 2D 模式，3D 模式由 MapboxMapWidget 内部提供）
        if (!_is3DMode)
          Positioned(
            right: 12,
            bottom: segmentsWithSelection.isNotEmpty ? 80 : 40,
            child: _buildZoomButtons(),
          ),

        // 底部：分段按钮（2D 和 3D 都显示）
        if (segmentsWithSelection.isNotEmpty)
          Positioned(
            bottom: 12,
            left: 12,
            right: _is3DMode ? 60 : 12, // 3D 模式右侧留出缩放按钮的空间
            child: _buildSegmentsToggle(data, segmentsWithSelection),
          ),
      ],
    );
  }

  Widget _build2DMap(_MapTestData data, List<MarkerPointModel> markers) {
    final segments = _getSegments(data);

    return UnifiedMapWidget(
      mapMode: MapMode.map2d,
      trackPoints: data.trackPoints,
      markers: markers,
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
      onControllerReady: (controller) {
        _map2DController = controller;
      },
    );
  }

  /// 放大/缩小按钮组
  Widget _buildZoomButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildZoomButton(
          icon: CupertinoIcons.plus,
          onPressed: _zoomIn,
        ),
        const SizedBox(height: 4),
        _buildZoomButton(
          icon: CupertinoIcons.minus,
          onPressed: _zoomOut,
        ),
      ],
    );
  }

  Widget _buildZoomButton({required IconData icon, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: CupertinoColors.label),
      ),
    );
  }

  /// 左上角信息按钮 + 展开面板
  Widget _buildInfoToggle(_MapTestData data) {
    if (!_infoExpanded) {
      // 折叠态：小圆形按钮
      return GestureDetector(
        onTap: () => setState(() => _infoExpanded = true),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.black.withValues(alpha: 0.15),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            CupertinoIcons.info_circle,
            size: 20,
            color: CupertinoColors.systemBlue,
          ),
        ),
      );
    }

    // 展开态：完整面板
    return GestureDetector(
      onTap: () => setState(() => _infoExpanded = false),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withValues(alpha: 0.12),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(CupertinoIcons.map_fill, color: CupertinoColors.systemBlue, size: 16),
                const SizedBox(width: 6),
                Text(
                  data.route.name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                const Icon(CupertinoIcons.chevron_up, size: 12, color: CupertinoColors.secondaryLabel),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '数据: ${data.dataSource.contains('KML') ? 'KML' : 'API'}  ID: ${_routeId ?? '-'}',
              style: TextStyle(fontSize: 10, color: CupertinoColors.secondaryLabel),
            ),
            if (data.route.segmentSchemes.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                '方案: ${data.route.segmentSchemes.map((s) => s.label).join(' / ')}',
                style: TextStyle(fontSize: 10, color: CupertinoColors.secondaryLabel),
              ),
            ],
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _buildInfoChip('轨迹点', '${data.trackPoints.length}'),
                _buildInfoChip('标记点', '${_getMarkers(data).length}'),
                _buildInfoChip('分段', '${_getSegments(data).length}'),
                _buildInfoChip('距离', '${data.route.distance.toStringAsFixed(1)}km'),
                _buildInfoChip('爬升', '${data.route.elevationGain.toStringAsFixed(0)}m'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey5,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: CupertinoColors.secondaryLabel)),
          const SizedBox(width: 3),
          Text(value, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  /// 底部分段按钮 + 展开列表
  Widget _buildSegmentsToggle(_MapTestData data, List<SegmentModel> segments) {
    if (!_segmentsExpanded) {
      // 折叠态：小胶囊按钮
      return Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onTap: () => setState(() => _segmentsExpanded = true),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.black.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 各段颜色小点预览（最多5个）
                ...segments.take(5).map((s) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 3),
                  decoration: BoxDecoration(
                    color: _segmentColor(s.sequenceNumber, false),
                    shape: BoxShape.circle,
                  ),
                )),
                if (segments.length > 5)
                  Text('...', style: TextStyle(fontSize: 10, color: CupertinoColors.secondaryLabel)),
                const SizedBox(width: 4),
                Text(
                  '${segments.length}段',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 4),
                const Icon(CupertinoIcons.chevron_up, size: 12, color: CupertinoColors.secondaryLabel),
              ],
            ),
          ),
        ),
      );
    }

    // 展开态：完整分段列表
    return GestureDetector(
      onTap: () {
        setState(() => _segmentsExpanded = false);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withValues(alpha: 0.12),
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
                const Text('路线分段', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const Spacer(),
                const Icon(CupertinoIcons.chevron_down, size: 12, color: CupertinoColors.secondaryLabel),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: segments.map((segment) {
                final isSelected = segment.isSelected;
                final segColor = _segmentColor(segment.sequenceNumber, false);
                return GestureDetector(
                  onTap: () {
                    _handleSegmentTap(segment);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? segColor.withValues(alpha: 0.2)
                          : CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? segColor : CupertinoColors.separator,
                        width: isSelected ? 1.5 : 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 序号色块
                        Container(
                          width: 14,
                          height: 14,
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            color: segColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${segment.sequenceNumber}',
                              style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: CupertinoColors.white,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          segment.name,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: CupertinoColors.label,
                          ),
                        ),
                        if (segment.distance != null) ...[
                          const SizedBox(width: 4),
                          Text(
                            '${segment.distance!.toStringAsFixed(1)}k',
                            style: TextStyle(fontSize: 10, color: CupertinoColors.secondaryLabel),
                          ),
                        ],
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
