import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/ui/page/common/network_image_with_fallback.dart';
import '../../../model/route/route_model.dart';
import '../../../service/service_manager.dart';
import '../common/error_widget.dart';
import '../common/empty_content_widget.dart';
import 'route_detail_screen.dart';

/// 路线发现页面
class RouteDiscoveryScreen extends StatefulWidget {
  /// 构造函数
  const RouteDiscoveryScreen({
    super.key,
  });

  @override
  State<RouteDiscoveryScreen> createState() => _RouteDiscoveryScreenState();
}

class _RouteDiscoveryScreenState extends State<RouteDiscoveryScreen>
    with SingleTickerProviderStateMixin {
  /// 推荐路线Future
  late Future<List<RouteModel>> _recommendedRoutesFuture;

  /// 热门路线Future
  late Future<List<RouteModel>> _popularRoutesFuture;

  /// 当季路线Future
  late Future<List<RouteModel>> _seasonalRoutesFuture;

  /// 全部路线Future
  late Future<List<RouteModel>> _allRoutesFuture;

  /// 动画控制器
  late AnimationController _animationController;

  /// 滚动控制器
  final ScrollController _scrollController = ScrollController();

  /// 当前选中的过滤器
  String _selectedFilter = '全部';

  /// 过滤器列表
  final List<String> _filters = [
    '全部',
    '徒步',
    '骑行',
    '露营',
    '攀岩',
    '城市',
    '山地',
    '海滨'
  ];

  /// 地图展开状态
  bool _isMapExpanded = false;

  /// 地图高度动画
  late Animation<double> _mapHeightAnimation;

  @override
  void initState() {
    super.initState();
    _loadRoutes();

    // 初始化动画控制器
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // 初始化地图高度动画
    _mapHeightAnimation = Tween<double>(
      begin: 200.0,
      end: 400.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// 加载路线
  void _loadRoutes() {
    final apiService = ServiceLocator.instance.getRecommendationService();

    // 加载推荐路线
    _recommendedRoutesFuture =
        apiService.getRecommendedRoutes().then((recommendedRoutes) {
      // 获取第一个推荐分类的路线
      if (recommendedRoutes.items.isNotEmpty) {
        return recommendedRoutes.items.first.routes;
      }
      return <RouteModel>[];
    });

    // 加载热门路线
    _popularRoutesFuture =
        apiService.getRecommendedRoutes().then((recommendedRoutes) {
      print("获取到了");
      // 获取第二个推荐分类的路线，如果没有则返回空列表

      print(recommendedRoutes.items[0].routes);
      return recommendedRoutes.items[0].routes;
    });

    // 加载当季路线
    _seasonalRoutesFuture =
        apiService.getRecommendedRoutes().then((recommendedRoutes) {
      // 获取第三个推荐分类的路线，如果没有则返回空列表
      return recommendedRoutes.items[0].routes;
    });

    // 加载全部路线
    _allRoutesFuture =
        apiService.getRecommendedRoutes().then((recommendedRoutes) {
      // 合并所有分类的路线
      List<RouteModel> allRoutes = [];
      for (var item in recommendedRoutes.items) {
        allRoutes.addAll(item.routes);
      }
      return allRoutes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          '探索路线',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor:
            CupertinoColors.systemGroupedBackground.withOpacity(0.9),
        border: null,
      ),
      child: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 地图视图
            SliverToBoxAdapter(
              child: _buildMapView(),
            ),

            // 过滤器
            SliverToBoxAdapter(
              child: _buildFilterSection(),
            ),

            // 热门路线
            _buildSectionTitle('热门路线', '大家都在走的路线'),
            SliverToBoxAdapter(
              child: _buildHorizontalRouteList(_popularRoutesFuture),
            ),

            // 当季路线
            _buildSectionTitle('当季精选', '适合当前季节的最佳路线'),
            SliverToBoxAdapter(
              child: _buildHorizontalRouteList(_seasonalRoutesFuture),
            ),

            // 全部路线
            _buildSectionTitle('全部路线', '发现更多精彩路线'),
            SliverToBoxAdapter(
              child: _buildAllRoutesList(),
            ),

            // 底部间距
            const SliverToBoxAdapter(
              child: SizedBox(height: 30),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建地图视图
  Widget _buildMapView() {
    return AnimatedBuilder(
      animation: _mapHeightAnimation,
      builder: (context, child) {
        return Column(
          children: [
            Container(
              height: _isMapExpanded ? _mapHeightAnimation.value : 200,
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.systemGrey4.withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // 这里应该集成实际的地图组件，如 Apple Maps
                  // 目前使用占位符
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      color: const Color(0xFFE5E5EA),
                      child: Center(
                        child: Icon(
                          CupertinoIcons.map,
                          size: 48,
                          color: CupertinoColors.systemGrey.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),

                  // 地图上的路线标记点（示例）
                  Positioned(
                    top: 60,
                    left: 100,
                    child:
                        _buildMapMarker('黄山徒步', CupertinoColors.activeOrange),
                  ),
                  Positioned(
                    top: 120,
                    left: 180,
                    child: _buildMapMarker('莫干山骑行', CupertinoColors.activeBlue),
                  ),
                  Positioned(
                    top: 80,
                    right: 70,
                    child:
                        _buildMapMarker('千岛湖环湖', CupertinoColors.activeGreen),
                  ),

                  // 搜索栏
                  Positioned(
                    top: 10,
                    left: 10,
                    right: 10,
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: CupertinoColors.systemGrey4.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.search,
                            color: CupertinoColors.systemGrey,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '搜索路线、地点或关键词',
                              style: TextStyle(
                                color: CupertinoColors.systemGrey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 展开/收起按钮
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isMapExpanded = !_isMapExpanded;
                          if (_isMapExpanded) {
                            _animationController.forward();
                          } else {
                            _animationController.reverse();
                          }
                        });
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  CupertinoColors.systemGrey4.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isMapExpanded
                              ? CupertinoIcons.chevron_up
                              : CupertinoIcons.chevron_down,
                          color: CupertinoColors.activeBlue,
                          size: 16,
                        ),
                      ),
                    ),
                  ),

                  // 定位按钮
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: CupertinoColors.systemGrey4.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Icon(
                        CupertinoIcons.location,
                        color: CupertinoColors.activeBlue,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 地图下方的快捷操作栏
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickActionButton(
                    icon: CupertinoIcons.location_circle,
                    label: '附近路线',
                    color: CupertinoColors.activeBlue,
                    onTap: () {
                      // 查看附近路线
                    },
                  ),
                  _buildQuickActionButton(
                    icon: CupertinoIcons.star,
                    label: '精选路线',
                    color: CupertinoColors.activeOrange,
                    onTap: () {
                      // 查看精选路线
                    },
                  ),
                  _buildQuickActionButton(
                    icon: CupertinoIcons.heart,
                    label: '收藏路线',
                    color: CupertinoColors.systemRed,
                    onTap: () {
                      // 查看收藏路线
                    },
                  ),
                  _buildQuickActionButton(
                    icon: CupertinoIcons.clock,
                    label: '历史记录',
                    color: CupertinoColors.systemGrey,
                    onTap: () {
                      // 查看历史记录
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// 构建地图标记
  Widget _buildMapMarker(String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建快捷操作按钮
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.systemGrey4.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: CupertinoColors.label,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建过滤器部分
  Widget _buildFilterSection() {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = filter == _selectedFilter;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = filter;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? CupertinoColors.activeBlue
                    : CupertinoColors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.systemGrey4.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected
                      ? CupertinoColors.white
                      : CupertinoColors.label,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 构建分区标题
  Widget _buildSectionTitle(String title, String subtitle) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.label,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Row(
                    children: [
                      Text(
                        '查看全部',
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.activeBlue,
                        ),
                      ),
                      Icon(
                        CupertinoIcons.chevron_right,
                        size: 14,
                        color: CupertinoColors.activeBlue,
                      ),
                    ],
                  ),
                  onPressed: () {
                    // 查看全部功能
                  },
                ),
              ],
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建水平路线列表
  Widget _buildHorizontalRouteList(Future<List<RouteModel>> routesFuture) {
    return SizedBox(
      height: 280,
      child: FutureBuilder<List<RouteModel>>(
        future: routesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ErrorMessageWidget(
                errorMessage: '加载失败，请稍后再试',
                onRetry: () {
                  setState(() {
                    _loadRoutes();
                  });
                },
              ),
            );
          }

          final routes = snapshot.data;
          if (routes == null || routes.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: EmptyContentWidget(
                icon: CupertinoIcons.map,
                title: '暂无路线',
                subtitle: '敬请期待更多精彩路线',
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: routes.length,
            itemBuilder: (context, index) {
              final route = routes[index];
              return _buildRouteCard(route);
            },
          );
        },
      ),
    );
  }

  /// 构建全部路线列表
  Widget _buildAllRoutesList() {
    return FutureBuilder<List<RouteModel>>(
      future: _allRoutesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: CupertinoActivityIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ErrorMessageWidget(
              errorMessage: '加载失败，请稍后再试',
              onRetry: () {
                setState(() {
                  _loadRoutes();
                });
              },
            ),
          );
        }

        final routes = snapshot.data;
        if (routes == null || routes.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: EmptyContentWidget(
              icon: CupertinoIcons.map,
              title: '暂无路线',
              subtitle: '敬请期待更多精彩路线',
            ),
          );
        }

        // 只显示前6个路线
        final displayRoutes = routes.length > 6 ? routes.sublist(0, 6) : routes;

        return Column(
          children: [
            // 路线列表
            ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayRoutes.length,
              itemBuilder: (context, index) {
                final route = displayRoutes[index];
                return _buildListRouteCard(route);
              },
            ),

            // 查看更多按钮
            if (routes.length > 6)
              Padding(
                padding: const EdgeInsets.all(16),
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  color: CupertinoColors.activeBlue,
                  borderRadius: BorderRadius.circular(10),
                  child: const SizedBox(
                    height: 44,
                    child: Center(
                      child: Text(
                        '查看更多路线',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  onPressed: () {
                    // 查看更多路线
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  /// 构建路线卡片
  Widget _buildRouteCard(RouteModel route) {
    return GestureDetector(
      onTap: () => _navigateToRouteDetail(route),
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 16, bottom: 4),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey4.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 路线图片
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: route.coverUrl != null
                      ? NetworkImageWithFallback(
                          url: route.coverUrl!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 150,
                          width: double.infinity,
                          color: CupertinoColors.systemGrey5,
                          child: Icon(
                            CupertinoIcons.photo,
                            size: 48,
                            color: CupertinoColors.systemGrey2,
                          ),
                        ),
                ),

                // 收藏按钮
                Positioned(
                  top: 8,
                  right: 8,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: CupertinoColors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.heart,
                        size: 18,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    onPressed: () {
                      // 收藏功能
                    },
                  ),
                ),

                // 难度标签
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.chart_bar_alt_fill,
                          size: 12,
                          color: CupertinoColors.activeBlue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '中等难度',
                          style: TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.activeBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 路线信息
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    route.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.label,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.location_solid,
                        size: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        route.region,
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoChip(
                        CupertinoIcons.arrow_right_arrow_left,
                        '${route.distance} km',
                      ),
                      _buildInfoChip(
                        CupertinoIcons.time,
                        route.duration,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建列表式路线卡片
  Widget _buildListRouteCard(RouteModel route) {
    return GestureDetector(
      onTap: () => _navigateToRouteDetail(route),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey4.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 路线图片
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
              child: route.coverUrl != null
                  ? NetworkImageWithFallback(
                      url: route.coverUrl!,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 100,
                      width: 100,
                      color: CupertinoColors.systemGrey5,
                      child: Icon(
                        CupertinoIcons.photo,
                        size: 32,
                        color: CupertinoColors.systemGrey2,
                      ),
                    ),
            ),

            // 路线信息
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      route.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.label,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.location_solid,
                          size: 14,
                          color: CupertinoColors.systemGrey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          route.region,
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildInfoChip(
                          CupertinoIcons.arrow_right_arrow_left,
                          '${route.distance} km',
                        ),
                        const SizedBox(width: 12),
                        _buildInfoChip(
                          CupertinoIcons.time,
                          route.duration,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 收藏按钮
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(
                CupertinoIcons.heart,
                size: 22,
                color: CupertinoColors.systemGrey,
              ),
              onPressed: () {
                // 收藏功能
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 构建信息标签
  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: CupertinoColors.systemGrey,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
  }

  /// 导航到路线详情页面
  void _navigateToRouteDetail(RouteModel route) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => RouteDetailScreen(
          routeId: route.id,
        ),
      ),
    );
  }
}
