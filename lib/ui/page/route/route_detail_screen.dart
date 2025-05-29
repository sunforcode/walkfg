import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:walk/model/route/route_enums.dart';
import 'package:walk/model/route/route_ratings.dart';
import 'package:walk/model/route/track_model.dart';
import 'package:walk/ui/map/core/map_enum.dart';
import 'package:walk/ui/page/common/error_view.dart';
import 'package:walk/ui/page/common/loading_view.dart';
import 'package:walk/ui/page/trip/trip_detail_screen.dart';
import '../../../model/route/route_model.dart';
import '../../../model/map/map_bounds.dart';
import '../../../model/map/track_point_model.dart';
import '../../../service/service_manager.dart';
import '../../../service/map_service.dart';
import '../../../ui/map/utils/kml_parser.dart';
import 'widgets/route_detail_content.dart';
import 'widgets/track_selector_widget.dart';
import 'widgets/elevation_profile_widget.dart';
import 'widgets/daily_itinerary_list_widget.dart';
import 'widgets/seasonal_equipment_widget.dart';
import 'widgets/map_resources_widget.dart';
import 'widgets/related_routes_widget.dart';
import 'widgets/related_trips_widget.dart';
import 'widgets/route_overview_widget.dart';
import 'widgets/route_gallery_widget.dart';
import 'widgets/route_map_placeholder_widget.dart';
import 'my_favorite_routes_screen.dart';

/// iOS风格的路线详情页面
class RouteDetailScreen extends StatefulWidget {
  /// 路线ID
  final String routeId;

  /// 路线数据（可选，如果提供则不需要加载）
  final RouteModel? route;

  /// 构造函数
  const RouteDetailScreen({
    super.key,
    required this.routeId,
    this.route,
  });

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  late Future<RouteModel> _routeFuture;
  late MapService _mapService;
  late ScrollController _scrollController;
  bool _isFavorite = false;
  bool _showElevationProfile = false; // 控制海拔剖面图显示
  bool _isMapFloating = false; // 控制地图是否悬浮

  /// KML轨迹点
  List<TrackPointVO> _kmlTrackPoints = [];

  /// KML路标点
  List<TrackPointVO> _kmlWaypoints = [];

  /// 可用轨迹列表
  List<TrackModel> _availableTracks = [];

  /// 当前选中的轨迹索引
  int _selectedTrackIndex = 0;

  @override
  void initState() {
    super.initState();
    _mapService = ServiceLocator.instance.getMapService();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadRouteDetail();
    _loadKmlData(); // 加载KML数据
    _initializeTracks(); // 初始化轨迹数据
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// 监听滚动事件
  void _onScroll() {
    const threshold = 200.0; // 滚动阈值
    final shouldFloat = _scrollController.offset > threshold;

    if (shouldFloat != _isMapFloating) {
      setState(() {
        _isMapFloating = shouldFloat;
      });
    }
  }

  /// 加载路线详情
  void _loadRouteDetail() {
    if (widget.route != null) {
      _routeFuture = Future.value(widget.route!);
    } else {
      final apiService = ServiceLocator.instance.getRouteService();
      _routeFuture = apiService.getRouteById(widget.routeId);
    }

    // 检查路线是否已收藏
    _checkIfFavorite();
  }

  /// 初始化轨迹数据
  void _initializeTracks() {
    final now = DateTime.now();

    // 模拟多条轨迹数据
    _availableTracks = [
      TrackModel(
        id: 'track_1',
        name: '推荐路线',
        description: '经典路线，风景优美，补给充足',
        distance: 58.5,
        difficulty: RouteDifficulty.medium,
        trackType: TrackType.recommended,
        isRecommended: true,
        elevationGain: 2400,
        elevationLoss: 2400,
        estimatedTime: 32.0, // 4天 * 8小时
        createdAt: now,
        updatedAt: now,
        createdBy: 'system',
        rating: 4.8,
        tags: ['经典', '风景优美'],
      ),
      TrackModel(
        id: 'track_2',
        name: '挑战路线',
        description: '更具挑战性，适合有经验的徒步者',
        distance: 62.3,
        difficulty: RouteDifficulty.hard,
        trackType: TrackType.challenge,
        isChallenge: true,
        elevationGain: 2800,
        elevationLoss: 2800,
        estimatedTime: 36.0, // 4.5天 * 8小时
        createdAt: now,
        updatedAt: now,
        createdBy: 'system',
        rating: 4.6,
        tags: ['挑战', '高难度'],
      ),
      TrackModel(
        id: 'track_3',
        name: '冬季路线',
        description: '冬季专用路线，避开危险路段',
        distance: 55.2,
        difficulty: RouteDifficulty.medium,
        trackType: TrackType.seasonal,
        isSeasonal: true,
        suitableSeasons: ['冬季'],
        elevationGain: 2200,
        elevationLoss: 2200,
        estimatedTime: 30.0,
        createdAt: now,
        updatedAt: now,
        createdBy: 'system',
        rating: 4.4,
        tags: ['冬季', '安全'],
      ),
      TrackModel(
        id: 'track_4',
        name: '快速路线',
        description: '距离较短，适合时间有限的徒步者',
        distance: 52.8,
        difficulty: RouteDifficulty.easy,
        trackType: TrackType.fast,
        elevationGain: 2000,
        elevationLoss: 2000,
        estimatedTime: 24.0, // 3天 * 8小时
        createdAt: now,
        updatedAt: now,
        createdBy: 'system',
        rating: 4.2,
        tags: ['快速', '短途'],
      ),
    ];
  }

  /// 从KML文件加载轨迹数据
  Future<void> _loadKmlData() async {
    try {
      print('开始加载KML文件: assets/maps/wutai.kml');

      // 解析KML文件
      final mapData = await KmlParser.parseFromAsset('assets/maps/wutai.kml');

      print(
          'KML解析成功，轨迹点数量: ${mapData.trackPoints.length}，路标点数量: ${mapData.waypoints.length}');
      if (mapData.trackPoints.isNotEmpty) {
        print('第一个轨迹点: ${mapData.trackPoints.first}');
        print('最后一个轨迹点: ${mapData.trackPoints.last}');
      }

      if (mapData.waypoints.isNotEmpty) {
        print('第一个路标点: ${mapData.waypoints.first}');
      }

      // 设置KML轨迹点和路标点
      setState(() {
        _kmlTrackPoints = mapData.trackPoints;
        _kmlWaypoints = mapData.waypoints;
      });

      print('设置KML轨迹点，数量: ${_kmlTrackPoints.length}');
      print('设置KML路标点，数量: ${_kmlWaypoints.length}');
    } catch (e) {
      print('KML解析失败: $e');
      print('错误堆栈: ${StackTrace.current}');

      // 尝试创建一些测试轨迹点
      setState(() {
        _kmlTrackPoints = [
          TrackPointVO(
            latitude: 39.9042,
            longitude: 116.4074,
            elevation: 100,
            name: '测试点1',
          ),
          TrackPointVO(
            latitude: 39.9142,
            longitude: 116.4174,
            elevation: 110,
            name: '测试点2',
          ),
          TrackPointVO(
            latitude: 39.9242,
            longitude: 116.4274,
            elevation: 120,
            name: '测试点3',
          ),
        ];

        _kmlWaypoints = [
          TrackPointVO(
            latitude: 39.9042,
            longitude: 116.4074,
            elevation: 100,
            name: '起点',
            type: '起点',
          ),
          TrackPointVO(
            latitude: 39.9242,
            longitude: 116.4274,
            elevation: 120,
            name: '终点',
            type: '终点',
          ),
        ];
      });

      print('创建测试轨迹点，数量: ${_kmlTrackPoints.length}');
      print('创建测试路标点，数量: ${_kmlWaypoints.length}');
    }
  }

  /// 检查路线是否已收藏
  void _checkIfFavorite() {
    final apiService = ServiceLocator.instance.getRouteService();
    apiService.checkIfFavorite(widget.routeId).then((isFavorite) {
      setState(() {
        _isFavorite = isFavorite;
      });
    });
  }

  /// 开始规划行程
  void _startPlanning(RouteModel route) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => TripDetailScreen(
          routeId: route.regionId,
        ),
      ),
    );
  }

  /// 处理收藏操作
  void _handleFavorite() {
    final apiService = ServiceLocator.instance.getRouteService();

    if (_isFavorite) {
      // 如果已收藏，则取消收藏
      apiService.removeFavorite(widget.routeId).then((_) {
        setState(() {
          _isFavorite = false;
        });
        _showToast('已取消收藏');
      });
    } else {
      // 如果未收藏，则添加收藏
      apiService.addFavorite(widget.routeId).then((_) {
        setState(() {
          _isFavorite = true;
        });
        _showToast('已添加到收藏');

        // 导航到收藏路线页面
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => const MyFavoriteRoutesScreen(),
          ),
        );
      });
    }
  }

  /// 处理轨迹选择
  void _handleTrackSelection(int index) {
    setState(() {
      _selectedTrackIndex = index;
    });

    // 这里可以加载对应轨迹的数据
    print('选择轨迹: ${_availableTracks[index].name}');
  }

  /// 处理海拔剖面图点击
  void _handleElevationProfileTap(double percentage) {
    print('点击海拔剖面图位置: ${(percentage * 100).toStringAsFixed(1)}%');
    // 这里可以在地图上定位到对应位置
  }

  /// 切换海拔剖面图显示
  void _toggleElevationProfile() {
    setState(() {
      _showElevationProfile = !_showElevationProfile;
    });
  }

  /// 处理日程点击
  void _handleDayTap(int dayIndex) {
    print('点击第${dayIndex + 1}天');
    // 这里可以在地图上高亮显示对应天的路线
  }

  /// 处理地图点击
  void _handleMapTap() {
    _showFeatureInDevelopmentDialog();
  }

  /// 处理图片点击
  void _handleImageTap(int index) {
    // 这里可以打开图片预览
    print('点击图片: $index');
  }

  /// 处理离线地图下载
  void _handleDownloadOfflineMap(
      MapBoundsVO bounds, MapType mapType, MapProviderType mapProvider) {
    // _mapService.downloadOfflineMap(
    //   bounds,
    //   mapType,
    //   mapProvider,
    //   (message) => _showToast(message),
    //   (error) => _showToast(error),
    // );
  }

  /// 显示提示信息
  void _showToast(String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 100,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey.withOpacity(0.8),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  /// 显示功能开发中对话框
  void _showFeatureInDevelopmentDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('提示'),
        content: const Text('该功能正在开发中'),
        actions: [
          CupertinoDialogAction(
            child: const Text('确定'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  /// 构建海拔剖面图切换按钮
  Widget _buildElevationToggleButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: _toggleElevationProfile,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: CupertinoColors.separator,
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.chart_bar,
                size: 14,
                color: CupertinoColors.systemGrey,
              ),
              const SizedBox(width: 6),
              Text(
                _showElevationProfile ? '隐藏海拔图' : '查看海拔图',
                style: const TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                _showElevationProfile
                    ? CupertinoIcons.chevron_up
                    : CupertinoIcons.chevron_down,
                size: 12,
                color: CupertinoColors.systemGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建地图左侧信息框
  Widget _buildMapInfoCard(TrackModel currentTrack) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 路线名称
          Text(
            currentTrack.name,
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          // 距离
          Row(
            children: [
              Icon(
                CupertinoIcons.location,
                size: 12,
                color: CupertinoColors.white.withOpacity(0.8),
              ),
              const SizedBox(width: 4),
              Text(
                '${currentTrack.distance.toStringAsFixed(1)}km',
                style: TextStyle(
                  color: CupertinoColors.white.withOpacity(0.9),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // 爬升
          Row(
            children: [
              Icon(
                CupertinoIcons.arrow_up,
                size: 12,
                color: CupertinoColors.white.withOpacity(0.8),
              ),
              const SizedBox(width: 4),
              Text(
                '${currentTrack.elevationGain}m',
                style: TextStyle(
                  color: CupertinoColors.white.withOpacity(0.9),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // 难度
          Row(
            children: [
              Icon(
                CupertinoIcons.chart_bar,
                size: 12,
                color: CupertinoColors.white.withOpacity(0.8),
              ),
              const SizedBox(width: 4),
              Text(
                currentTrack.getDifficultyName(),
                style: TextStyle(
                  color: CupertinoColors.white.withOpacity(0.9),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建地图右下角功能按钮
  Widget _buildMapFunctionButtons() {
    return Column(
      children: [
        // 查看海拔图按钮
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _toggleElevationProfile,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: CupertinoColors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              CupertinoIcons.chart_bar,
              size: 20,
              color: _showElevationProfile
                  ? CupertinoColors.activeBlue
                  : CupertinoColors.white,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // 切换轨迹按钮
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _showTrackSelector(),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: CupertinoColors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              CupertinoIcons.map,
              size: 20,
              color: CupertinoColors.white,
            ),
          ),
        ),
      ],
    );
  }

  /// 显示轨迹选择器
  void _showTrackSelector() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('选择轨迹'),
        message: const Text('选择不同的轨迹来查看路线信息'),
        actions: _availableTracks.asMap().entries.map((entry) {
          final index = entry.key;
          final track = entry.value;
          final isSelected = index == _selectedTrackIndex;

          return CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              _handleTrackSelection(index);
            },
            child: Row(
              children: [
                // 选中状态指示器
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? CupertinoColors.activeBlue
                        : CupertinoColors.systemGrey5,
                  ),
                  child: isSelected
                      ? const Icon(
                          CupertinoIcons.check_mark,
                          size: 12,
                          color: CupertinoColors.white,
                        )
                      : null,
                ),

                const SizedBox(width: 12),

                // 轨迹信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: CupertinoColors.label,
                        ),
                      ),
                      Text(
                        '${track.distance.toStringAsFixed(1)}km · ${track.getDifficultyName()}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.secondaryLabel,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
      ),
    );
  }

  /// 构建详细地图参数信息
  Widget _buildDetailedMapInfo(TrackModel currentTrack) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '路线详细信息',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 12),

          // 第一行：距离和爬升
          Row(
            children: [
              Expanded(
                child: _buildDetailInfoItem(
                  icon: CupertinoIcons.location,
                  label: '总距离',
                  value: '${currentTrack.distance.toStringAsFixed(1)} km',
                  color: CupertinoColors.systemBlue,
                ),
              ),
              Expanded(
                child: _buildDetailInfoItem(
                  icon: CupertinoIcons.arrow_up,
                  label: '总爬升',
                  value: '${currentTrack.elevationGain} m',
                  color: CupertinoColors.systemGreen,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 第二行：下降和耗时
          Row(
            children: [
              Expanded(
                child: _buildDetailInfoItem(
                  icon: CupertinoIcons.arrow_down,
                  label: '总下降',
                  value: '${currentTrack.elevationLoss} m',
                  color: CupertinoColors.systemOrange,
                ),
              ),
              Expanded(
                child: _buildDetailInfoItem(
                  icon: CupertinoIcons.time,
                  label: '预计耗时',
                  value: currentTrack.getEstimatedTimeText(),
                  color: CupertinoColors.systemPurple,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 第三行：最高海拔和难度
          Row(
            children: [
              Expanded(
                child: _buildDetailInfoItem(
                  icon: CupertinoIcons.triangle,
                  label: '最高海拔',
                  value: '${_getMaxElevation()} m',
                  color: CupertinoColors.systemTeal,
                ),
              ),
              Expanded(
                child: _buildDetailInfoItem(
                  icon: CupertinoIcons.chart_bar,
                  label: '难度等级',
                  value: currentTrack.getDifficultyName(),
                  color: CupertinoColors.systemRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建详细信息项
  Widget _buildDetailInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 获取最高海拔
  int _getMaxElevation() {
    if (_kmlTrackPoints.isEmpty) return 0;
    return _kmlTrackPoints
        .map((point) => point.elevation?.toInt() ?? 0)
        .reduce((a, b) => a > b ? a : b);
  }

  /// 构建操作按钮
  Widget _buildActionButtons(RouteModel route) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: CupertinoButton.filled(
              child: const Text('规划行程'),
              onPressed: () => _startPlanning(route),
            ),
          ),
          const SizedBox(width: 12),
          CupertinoButton(
            color: _isFavorite
                ? CupertinoColors.systemRed
                : CupertinoColors.systemGrey,
            child: Icon(
                _isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart),
            onPressed: _handleFavorite,
          ),
          const SizedBox(width: 8),
          CupertinoButton(
            color: CupertinoColors.systemBlue,
            child: const Icon(CupertinoIcons.map),
            onPressed: _showFeatureInDevelopmentDialog,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _mapService,
      child: CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('路线详情'),
        ),
        child: SafeArea(
          child: FutureBuilder<RouteModel>(
            future: _routeFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingView();
              }

              if (snapshot.hasError) {
                return ErrorView(
                  message: snapshot.error.toString(),
                  onRetry: () {
                    setState(() {
                      _loadRouteDetail();
                    });
                  },
                );
              }

              final route = snapshot.data!;
              final currentTrack = _availableTracks[_selectedTrackIndex];

              return Stack(
                children: [
                  // 主要内容
                  CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      // 地图区域（最上面）- 包含右下角功能按钮
                      SliverToBoxAdapter(
                        child: Stack(
                          children: [
                            RouteMapPlaceholderWidget(
                              route: route,
                              trackPoints: _kmlTrackPoints,
                              waypoints: _kmlWaypoints,
                              height: 300,
                              onMapTap: _handleMapTap,
                            ),
                            // 右下角功能按钮
                            Positioned(
                              bottom: 16,
                              right: 16,
                              child: _buildMapFunctionButtons(),
                            ),
                          ],
                        ),
                      ),

                      // 路线概览（包含标题、标签、简介）
                      SliverToBoxAdapter(
                        child: RouteOverviewWidget(route: route),
                      ),

                      // 详细地图参数信息
                      SliverToBoxAdapter(
                        child: _buildDetailedMapInfo(currentTrack),
                      ),

                      // 海拔剖面图（可切换显示）
                      if (_showElevationProfile)
                        SliverToBoxAdapter(
                          child: ElevationProfileWidget(
                            trackPoints: _kmlTrackPoints,
                            totalDistance: currentTrack.distance,
                            elevationGain:
                                currentTrack.elevationGain.toDouble(),
                            onTap: _handleElevationProfileTap,
                          ),
                        ),

                      // 每日行程列表（直接展示）
                      SliverToBoxAdapter(
                        child: DailyItineraryListWidget(
                          dailyPlans: route.dailyPlans,
                          onDayTap: _handleDayTap,
                        ),
                      ),

                      // 当季出行装备推荐
                      SliverToBoxAdapter(
                        child: SeasonalEquipmentWidget(
                          currentSeason: _getCurrentSeason(),
                          difficulty: currentTrack.getDifficultyName(),
                        ),
                      ),

                      // 地图水源补给点详解
                      SliverToBoxAdapter(
                        child: MapResourcesWidget(
                          waterSources: _getWaterSources(route),
                          supplyPoints: _getSupplyPoints(route),
                        ),
                      ),

                      // 相关路线推荐
                      SliverToBoxAdapter(
                        child: RelatedRoutesWidget(
                          relatedRoutes: _getRelatedRoutes(route),
                          onRouteTap: _handleRelatedRouteTap,
                        ),
                      ),

                      // 相关行程推荐
                      SliverToBoxAdapter(
                        child: RelatedTripsWidget(
                          routeId: route.id,
                          relatedTrips: _getRelatedTrips(route),
                          onTripTap: _handleRelatedTripTap,
                        ),
                      ),

                      // 路线图片推荐（小型版本）
                      SliverToBoxAdapter(
                        child: RouteGalleryWidget(
                          imageUrls: route.imageUrls,
                          onImageTap: _handleImageTap,
                        ),
                      ),
                      // 操作按钮
                      SliverToBoxAdapter(
                        child: _buildActionButtons(route),
                      ),
                    ],
                  ),
                  // 悬浮地图
                  if (_isMapFloating) ...[
                    _buildFloatingMap(route),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// 构建悬浮地图
  Widget _buildFloatingMap(RouteModel route) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 300, // 保持原有地图大小
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            RouteMapPlaceholderWidget(
              route: route,
              trackPoints: _kmlTrackPoints,
              waypoints: _kmlWaypoints,
              height: 300,
              onMapTap: _handleFloatingMapTap,
            ),

            // 右下角功能按钮
            Positioned(
              bottom: 16,
              right: 16,
              child: _buildMapFunctionButtons(),
            ),

            // 关闭按钮 - 移到左上角
            Positioned(
              top: 16,
              left: 16,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() {
                    _isMapFloating = false;
                  });
                  // 滚动回顶部
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: CupertinoColors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    CupertinoIcons.xmark,
                    size: 16,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 获取当前季节
  String _getCurrentSeason() {
    final now = DateTime.now();
    final month = now.month;

    if (month >= 3 && month <= 5) {
      return '春季';
    } else if (month >= 6 && month <= 8) {
      return '夏季';
    } else if (month >= 9 && month <= 11) {
      return '秋季';
    } else {
      return '冬季';
    }
  }

  /// 获取水源点数据
  List<Map<String, dynamic>> _getWaterSources(RouteModel route) {
    // 模拟水源点数据
    return [
      {
        'name': '云谷寺水源',
        'distance': 0.0,
        'location': '云谷寺入口处',
        'quality': '优',
        'availability': '全年',
        'treatment': '可直接饮用',
        'notes': '水质清澈，流量充足',
      },
      {
        'name': '白鹅岭山泉',
        'distance': 8.5,
        'location': '白鹅岭观景台附近',
        'quality': '良',
        'availability': '全年',
        'treatment': '建议过滤后饮用',
        'notes': '山泉水，需要简单过滤',
      },
      {
        'name': '光明顶水站',
        'distance': 12.3,
        'location': '光明顶气象站',
        'quality': '优',
        'availability': '全年',
        'treatment': '可直接饮用',
        'notes': '人工水源，水质有保障',
      },
    ];
  }

  /// 获取补给点数据
  List<Map<String, dynamic>> _getSupplyPoints(RouteModel route) {
    // 模拟补给点数据
    return [
      {
        'name': '云谷寺商店',
        'distance': 0.0,
        'location': '云谷寺索道站',
        'type': '综合商店',
        'status': '营业',
        'hours': '6:00-18:00',
        'items': ['食物', '饮料', '登山用品', '雨具'],
        'notes': '价格适中，商品齐全',
      },
      {
        'name': '北海宾馆小卖部',
        'distance': 10.2,
        'location': '北海宾馆内',
        'type': '小卖部',
        'status': '营业',
        'hours': '7:00-21:00',
        'items': ['方便面', '饮料', '零食'],
        'notes': '山上价格较高',
      },
      {
        'name': '白云宾馆商店',
        'distance': 14.8,
        'location': '白云宾馆一楼',
        'type': '综合商店',
        'status': '营业',
        'hours': '6:30-20:30',
        'items': ['热食', '饮料', '纪念品', '药品'],
        'notes': '提供热食，可刷卡支付',
      },
    ];
  }

  /// 获取相关路线
  List<RouteModel> _getRelatedRoutes(RouteModel currentRoute) {
    // 模拟相关路线数据
    return [
      RouteModel(
        id: 'related_1',
        name: '黄山西海大峡谷环线',
        description: '探索黄山最壮观的峡谷景观，体验惊险刺激的栈道徒步。',
        regionId: 'huangshan',
        ratings: RouteRatingsVO(
          ratingCount: 189,
          overall: 4.7,
          scenery: 4.8,
          difficulty: 4.6,
          experience: 4.7,
          facilities: 4.5,
        ),
        tags: ['峡谷', '栈道', '刺激'],
        difficulty: RouteDifficulty.medium,
        imageUrls: [],
        mapDataId: 'map_1',
        createdBy: 'system',
        popularity: 189,
        bestSeason: ['春季', '秋季'],
        dailyPlans: [],
      ),
      RouteModel(
        id: 'related_2',
        name: '天都峰攀登路线',
        description: '挑战黄山最险峻的山峰，体验极限攀登的乐趣。',
        regionId: 'huangshan',
        ratings: RouteRatingsVO(
          ratingCount: 156,
          overall: 4.5,
          scenery: 4.8,
          difficulty: 4.9,
          experience: 4.6,
          facilities: 4.2,
        ),
        tags: ['攀登', '挑战', '险峻'],
        difficulty: RouteDifficulty.hard,
        imageUrls: [],
        mapDataId: 'map_2',
        createdBy: 'system',
        popularity: 156,
        bestSeason: ['春季', '夏季', '秋季'],
        dailyPlans: [],
      ),
    ];
  }

  /// 处理相关路线点击
  void _handleRelatedRouteTap(RouteModel route) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => RouteDetailScreen(
          routeId: route.id,
          route: route,
        ),
      ),
    );
  }

  /// 获取相关行程
  List<Map<String, dynamic>> _getRelatedTrips(RouteModel route) {
    // 模拟相关行程数据
    return [
      {
        'id': 'trip_1',
        'title': '黄山4天3夜深度游',
        'authorName': '山野行者',
        'startDate': '2024-04-15',
        'days': 4,
        'participantCount': 6,
        'budget': 1200,
        'status': 'recruiting',
        'highlights': ['日出云海', '温泉体验', '摄影创作'],
        'description': '专业向导带队，深度体验黄山四季美景，包含温泉住宿和专业摄影指导。适合摄影爱好者和深度游客。',
      },
      {
        'id': 'trip_2',
        'title': '黄山轻松徒步周末行',
        'authorName': '户外小白',
        'startDate': '2024-03-20',
        'days': 2,
        'participantCount': 4,
        'budget': 600,
        'status': 'confirmed',
        'highlights': ['轻松徒步', '风景摄影'],
        'description': '适合新手的轻松路线，周末两天一夜，体验黄山经典景色。',
      },
      {
        'id': 'trip_3',
        'title': '黄山挑战极限穿越',
        'authorName': '极限挑战者',
        'startDate': '2024-05-01',
        'days': 5,
        'participantCount': 8,
        'budget': 2000,
        'status': 'planning',
        'highlights': ['极限挑战', '野外露营', '技能提升'],
        'description': '高强度徒步路线，包含野外生存技能培训和极限挑战项目。仅限有经验的户外爱好者参加。',
      },
    ];
  }

  /// 处理相关行程点击
  void _handleRelatedTripTap(Map<String, dynamic> trip) {
    // 这里可以导航到行程详情页面
    print('点击行程: ${trip['title']}');
    _showFeatureInDevelopmentDialog();
  }

  /// 处理悬浮地图点击
  void _handleFloatingMapTap() {
    // 滚动回顶部显示完整地图
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    setState(() {
      _isMapFloating = false;
    });
  }
}
