import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../model/route/route_model.dart';
import '../../../service/service_manager.dart';
import '../../../theme/theme/app_colors.dart';
import '../../../theme/theme/app_color_palette.dart';
import '../../widgets/common/info_chip.dart';
import '../../widgets/common/network_image_with_fallback.dart';
import '../trip/trip_planning_detail_screen.dart';
import '../map/route_map_widget.dart';

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

  /// 当前地图类型
  MapType _currentMapType = MapType.standard;

  @override
  void initState() {
    super.initState();
    _loadRouteDetail();
  }

  /// 加载路线详情
  void _loadRouteDetail() {
    if (widget.route != null) {
      _routeFuture = Future.value(widget.route!);
    } else {
      final apiService = ServiceLocator.instance.getRouteService();
      _routeFuture = apiService.getRouteById(widget.routeId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('路线详情'),
      ),
      child: SafeArea(
        child: FutureBuilder<RouteModel>(
          future: _routeFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CupertinoActivityIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.exclamationmark_circle,
                      size: 50,
                      color: CupertinoColors.systemRed,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '加载失败',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(snapshot.error.toString()),
                    const SizedBox(height: 16),
                    CupertinoButton(
                      child: const Text('重试'),
                      onPressed: () {
                        setState(() {
                          _loadRouteDetail();
                        });
                      },
                    ),
                  ],
                ),
              );
            }

            final route = snapshot.data!;
            print(
                '路线详情页 - 加载路线: ${route.name}, 轨迹点数量: ${route.trackPoints?.length ?? 0}');
            return _buildRouteDetail(context, route);
          },
        ),
      ),
    );
  }

  /// 构建路线详情内容
  Widget _buildRouteDetail(BuildContext context, RouteModel route) {
    return CustomScrollView(
      slivers: [
        // 地图组件 - 放在页面顶部
        SliverToBoxAdapter(
          child: _buildMapSection(route),
        ),

        // 路线基本信息
        SliverToBoxAdapter(
          child: _buildBasicInfo(route),
        ),

        // 路线描述
        SliverToBoxAdapter(
          child: _buildDescription(route),
        ),

        // 路线详细信息
        SliverToBoxAdapter(
          child: _buildDetailedInfo(route),
        ),

        // 操作按钮
        SliverToBoxAdapter(
          child: _buildActionButtons(route),
        ),

        // 底部间距
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
      ],
    );
  }

  /// 构建地图部分
  Widget _buildMapSection(RouteModel route) {
    print('构建地图部分 - 轨迹点数量: ${route.trackPoints.length}');

    // 如果没有轨迹点，显示提示
    if (route.trackPoints.isEmpty) {
      print('路线没有轨迹点数据，显示提示信息');
      return Container(
        height: MediaQuery.of(context).size.height * 0.3,
        color: CupertinoColors.systemGrey6,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.map,
                size: 48,
                color: CupertinoColors.systemGrey,
              ),
              const SizedBox(height: 16),
              Text(
                '该路线暂无轨迹数据',
                style: TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 显示地图
    print('显示地图，轨迹点数量: ${route.trackPoints.length}');
    return RouteMapWidget(
      route: route,
      height: MediaQuery.of(context).size.height * 0.3,
      showCurrentLocation: false,
      showMapTypeToolbar: true,
      mapType: _currentMapType,
      onMapTypeChanged: (mapType) {
        setState(() {
          _currentMapType = mapType;
        });
      },
    );
  }

  /// 构建封面图片
  Widget _buildCoverImage(RouteModel route) {
    final imageUrl = route.imageUrls.isNotEmpty ? route.imageUrls.first : null;

    return Container(
      height: 200,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 图片
          imageUrl != null
              ? NetworkImageWithFallback(
                  url: imageUrl,
                  fit: BoxFit.cover,
                  fallbackColor: AppColors.primary,
                  fallbackIcon: CupertinoIcons.map,
                )
              : Container(
                  color: AppColors.primary.withOpacity(0.2),
                  child: const Center(
                    child: Icon(
                      CupertinoIcons.map,
                      size: 64,
                      color: AppColors.primary,
                    ),
                  ),
                ),

          // 难度标签
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getDifficultyColor(route.difficulty),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                route.getDifficultyName(),
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // 季节标签
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBlue.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                route.bestSeason,
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建基本信息
  Widget _buildBasicInfo(RouteModel route) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 路线名称
          Text(
            route.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // 路线基本信息
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(
                CupertinoIcons.arrow_right_arrow_left,
                '距离',
                '${route.distance} km',
              ),
              _buildInfoItem(
                CupertinoIcons.time,
                '时长',
                route.duration,
              ),
              _buildInfoItem(
                CupertinoIcons.arrow_up_right,
                '海拔增益',
                '${route.elevationGain} m',
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建描述信息
  Widget _buildDescription(RouteModel route) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '路线描述',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            route.description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建详细信息
  Widget _buildDetailedInfo(RouteModel route) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '详细信息',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // 详细信息表格
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: CupertinoColors.systemGrey5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildInfoRow('最高点', '${route.highestPoint} m'),
                _buildDivider(),
                _buildInfoRow('最低点', '${route.lowestPoint} m'),
                _buildDivider(),
                _buildInfoRow('累计上升', '${route.elevationGain} m'),
                _buildDivider(),
                _buildInfoRow('累计下降', '${route.elevationLoss} m'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButtons(RouteModel route) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            CupertinoIcons.map,
            '查看地图',
            AppColorPalette.blueColors[0],
            () {
              // 导航到地图页面
              showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: const Text('提示'),
                  content: const Text('地图功能正在开发中'),
                  actions: [
                    CupertinoDialogAction(
                      child: const Text('确定'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              );
            },
          ),
          _buildActionButton(
            CupertinoIcons.calendar_badge_plus,
            '规划行程',
            AppColorPalette.blueColors[2],
            () {
              // 导航到行程规划页面
              _startPlanning(route);
            },
          ),
          _buildActionButton(
            CupertinoIcons.heart,
            '收藏',
            AppColorPalette.blueColors[4],
            () {
              // 收藏功能
              showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: const Text('提示'),
                  content: const Text('收藏功能正在开发中'),
                  actions: [
                    CupertinoDialogAction(
                      child: const Text('确定'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 开始规划行程
  void _startPlanning(RouteModel route) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => TripPlanningDetailScreen(route: route),
      ),
    );
  }

  /// 构建信息项
  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: CupertinoColors.systemGrey.resolveFrom(context),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: CupertinoColors.systemGrey.resolveFrom(context),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建分隔线
  Widget _buildDivider() {
    return Container(
      height: 1,
      color: CupertinoColors.systemGrey5,
    );
  }

  /// 构建操作按钮
  Widget _buildActionButton(
      IconData icon, String label, Color color, VoidCallback onPressed) {
    return CupertinoButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// 获取难度对应的颜色
  Color _getDifficultyColor(RouteDifficulty difficulty) {
    switch (difficulty) {
      case RouteDifficulty.easy:
        return CupertinoColors.systemGreen;
      case RouteDifficulty.medium:
        return CupertinoColors.systemOrange;
      case RouteDifficulty.hard:
        return CupertinoColors.systemRed;
      case RouteDifficulty.extreme:
        return CupertinoColors.systemPurple;
    }
  }
}
