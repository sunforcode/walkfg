import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/service/route_service.dart';
import '../../../model/route/route_model.dart';
import '../../../model/trip/recommended_route_model.dart';
import '../../../service/service_manager.dart';
import '../../../service/trip_service.dart';
import '../../../common/utils/trip_utils.dart';
import '../../widgets/common/loading_indicator.dart';
import 'trip/search_section.dart';
import 'trip/category_section.dart';
import 'trip/route_list_section.dart';
import '../route/cupertino_route_detail_screen.dart';
import 'route_list_screen.dart';

/// 行程规划首页
class TripPlanningHomeScreen extends StatefulWidget {
  /// 构造函数
  const TripPlanningHomeScreen({super.key});

  @override
  State<TripPlanningHomeScreen> createState() => _TripPlanningHomeScreenState();
}

class _TripPlanningHomeScreenState extends State<TripPlanningHomeScreen> {
  /// 行程服务
  late RouteService _tripService;

  /// 搜索控制器
  final TextEditingController _searchController = TextEditingController();

  /// 地区列表
  final List<Map<String, dynamic>> _regions = [
    {'name': '川西', 'icon': CupertinoIcons.map_pin},
    {'name': '新疆', 'icon': CupertinoIcons.sun_max},
    {'name': '云南', 'icon': CupertinoIcons.tree},
    {'name': '西藏', 'icon': CupertinoIcons.snow},
    {'name': '浙江', 'icon': CupertinoIcons.placemark},
    {'name': '安徽', 'icon': CupertinoIcons.hare},
    {'name': '更多', 'icon': CupertinoIcons.ellipsis},
  ];

  /// 难度列表
  final List<Map<String, dynamic>> _difficulties = [
    {
      'name': '初级',
      'difficulty': RouteDifficulty.easy,
      'icon': CupertinoIcons.person_crop_circle
    },
    {
      'name': '中级',
      'difficulty': RouteDifficulty.medium,
      'icon': CupertinoIcons.person_2_fill
    },
    {
      'name': '高级',
      'difficulty': RouteDifficulty.hard,
      'icon': CupertinoIcons.person_3_fill
    },
    {
      'name': '专业级',
      'difficulty': RouteDifficulty.extreme,
      'icon': CupertinoIcons.sportscourt
    },
  ];

  /// 时长列表
  final List<Map<String, dynamic>> _durations = [
    {'label': '1-2天', 'min': 1, 'max': 2, 'icon': CupertinoIcons.clock},
    {'label': '3-5天', 'min': 3, 'max': 5, 'icon': CupertinoIcons.calendar},
    {
      'label': '6-10天',
      'min': 6,
      'max': 10,
      'icon': CupertinoIcons.calendar_badge_plus
    },
    {
      'label': '10天以上',
      'min': 10,
      'max': 100,
      'icon': CupertinoIcons.calendar_circle
    },
  ];

  /// 推荐路线Future
  late Future<RecommendedRouteListModel> _recommendedRoutesFuture;

  /// 是否正在加载
  bool _isLoading = true;

  /// 精选路线
  RecommendedRouteModel? _featuredRoutes;

  /// 热门路线
  RecommendedRouteModel? _popularRoutes;

  /// 季节推荐路线
  RecommendedRouteModel? _seasonalRoutes;

  @override
  void initState() {
    super.initState();
    _tripService = ServiceLocator.instance.getRouteService();
    _loadData();
  }

  /// 加载数据
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 加载推荐路线
      _recommendedRoutesFuture =
          ServiceLocator.instance.getTripService().getRecommendedRoutes();
      final recommendedRoutes = await _recommendedRoutesFuture;

      // 获取不同类型的推荐路线
      _featuredRoutes =
          recommendedRoutes.getByType(RecommendedRouteType.featured);
      _popularRoutes =
          recommendedRoutes.getByType(RecommendedRouteType.popular);
      _seasonalRoutes =
          recommendedRoutes.getByType(RecommendedRouteType.seasonal);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('行程规划'),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: LoadingIndicator())
            : CustomScrollView(
                slivers: [
                  // 搜索部分
                  SliverToBoxAdapter(
                    child: SearchSection(
                      searchController: _searchController,
                      onSearch: _navigateToSearchResults,
                    ),
                  ),
                  // 分类浏览标题
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text(
                        '分类浏览',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),

                  // 分类部分
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        // 按地区浏览
                        CategorySection(
                          title: '按地区浏览',
                          items: _regions,
                          itemBuilder: (item) => CategoryItem(
                            name: item['name'],
                            icon: item['icon'],
                            onTap: () {
                              if (item['name'] == '更多') {
                                // 显示更多地区
                              } else {
                                _navigateToRegionRoutes(context, item['name']);
                              }
                            },
                          ),
                        ),
                        // 按难度浏览
                        CategorySection(
                          title: '按难度浏览',
                          items: _difficulties,
                          itemBuilder: (item) => CategoryItem(
                            name: item['name'],
                            icon: item['icon'],
                            backgroundColor:
                                TripUtils.getDifficultyColor(item['difficulty'])
                                    .withOpacity(0.1),
                            iconColor: TripUtils.getDifficultyColor(
                                item['difficulty']),
                            onTap: () => _navigateToDifficultyRoutes(
                                context, item['difficulty']),
                          ),
                        ),

                        // 按时长浏览
                        CategorySection(
                          title: '按时长浏览',
                          items: _durations,
                          itemBuilder: (item) => CategoryItem(
                            name: item['label'],
                            icon: item['icon'],
                            onTap: () => _navigateToDurationRoutes(
                              context,
                              item['min'],
                              item['max'],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 路线列表部分
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        // 精选路线
                        if (_featuredRoutes != null)
                          RouteListSection(
                            title: _featuredRoutes!.title,
                            routesFuture: Future.value(_featuredRoutes!.routes),
                            displayType: RouteDisplayType.featured,
                            onViewAll: () => _navigateToAllRoutes(
                              context,
                              _featuredRoutes!.title,
                              Future.value(_featuredRoutes!.routes),
                            ),
                            onRouteTap: _navigateToRouteDetail,
                          ),

                        // 热门路线
                        if (_popularRoutes != null)
                          RouteListSection(
                            title: _popularRoutes!.title,
                            routesFuture: Future.value(_popularRoutes!.routes),
                            displayType: RouteDisplayType.horizontal,
                            onViewAll: () => _navigateToAllRoutes(
                              context,
                              _popularRoutes!.title,
                              Future.value(_popularRoutes!.routes),
                            ),
                            onRouteTap: _navigateToRouteDetail,
                          ),
                        // 季节推荐
                        if (_seasonalRoutes != null)
                          RouteListSection(
                            title: _seasonalRoutes!.title,
                            routesFuture: Future.value(_seasonalRoutes!.routes),
                            displayType: RouteDisplayType.horizontal,
                            onViewAll: () => _navigateToAllRoutes(
                              context,
                              _seasonalRoutes!.title,
                              Future.value(_seasonalRoutes!.routes),
                            ),
                            onRouteTap: _navigateToRouteDetail,
                          ),
                        // 底部间距
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// 导航到搜索结果页面
  void _navigateToSearchResults(BuildContext context, String query) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => RouteListScreen(
          title: '搜索结果: $query',
          routesFuture: _tripService.searchRoutes(query),
        ),
      ),
    );
  }

  /// 导航到所有路线页面
  void _navigateToAllRoutes(BuildContext context, String title,
      Future<List<RouteModel>> routesFuture) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => RouteListScreen(
          title: title,
          routesFuture: routesFuture,
        ),
      ),
    );
  }

  /// 导航到地区路线页面
  void _navigateToRegionRoutes(BuildContext context, String region) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => RouteListScreen(
          title: '$region 地区路线',
          routesFuture: _tripService.getRoutesByRegion(region),
        ),
      ),
    );
  }

  /// 导航到难度路线页面
  void _navigateToDifficultyRoutes(
      BuildContext context, RouteDifficulty difficulty) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => RouteListScreen(
          title: '${TripUtils.getDifficultyName(difficulty)} 难度路线',
          routesFuture: _tripService.getRoutesByDifficulty(difficulty),
        ),
      ),
    );
  }

  /// 导航到时长路线页面
  void _navigateToDurationRoutes(
      BuildContext context, int minDays, int maxDays) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => RouteListScreen(
          title: '$minDays-$maxDays 天路线',
          routesFuture: _tripService.getRoutesByDuration(minDays, maxDays),
        ),
      ),
    );
  }

  /// 导航到路线详情页面
  void _navigateToRouteDetail(BuildContext context, RouteModel route) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => RouteDetailScreen(
          routeId: route.id,
          route: route,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
