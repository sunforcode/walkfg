import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../model/route/route_model.dart';
import '../../../service/service_locator.dart';
import '../../../service/trip_service.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/empty_content_widget.dart';
import '../../theme/app_colors.dart';
import '../route/cupertino_route_detail_screen.dart';
import 'trip_route_selection_screen.dart';
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
  late TripService _tripService;

  /// 搜索控制器
  final TextEditingController _searchController = TextEditingController();

  /// 最近搜索列表
  final List<String> _recentSearches = ['黄山', '莫干山', '四姑娘山', '腾格里沙漠'];

  /// 热门搜索列表
  final List<String> _hotSearches = [
    '贡嘎大环线',
    '雨崩徒步',
    '丙察察线',
    '南迦巴瓦',
    '毕棚沟',
    '鳌太穿越'
  ];

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

  /// 精选路线Future
  late Future<List<RouteModel>> _featuredRoutesFuture;

  /// 热门路线Future
  late Future<List<RouteModel>> _popularRoutesFuture;

  /// 季节推荐路线Future
  late Future<List<RouteModel>> _seasonalRoutesFuture;

  @override
  void initState() {
    super.initState();
    _tripService = ServiceLocator.instance.getTripService();
    _loadData();
  }

  /// 加载数据
  void _loadData() {
    _featuredRoutesFuture = _tripService.getPopularRoutes();
    _popularRoutesFuture = _tripService.getPopularRoutes();
    _seasonalRoutesFuture = _tripService.getSeasonalRoutes();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('行程规划'),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 搜索框
            SliverToBoxAdapter(
              child: _buildSearchBar(),
            ),
            // 最近搜索
            SliverToBoxAdapter(
              child: _buildRecentSearches(),
            ),

            // 热门搜索
            SliverToBoxAdapter(
              child: _buildHotSearches(),
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

            // 按地区浏览
            SliverToBoxAdapter(
              child: _buildCategorySection('按地区浏览', _buildRegionItems()),
            ),

            // 按难度浏览
            SliverToBoxAdapter(
              child: _buildCategorySection('按难度浏览', _buildDifficultyItems()),
            ),
            // 按时长浏览
            SliverToBoxAdapter(
              child: _buildCategorySection('按时长浏览', _buildDurationItems()),
            ),

            // 精选路线标题
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '精选路线',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text('查看全部'),
                      onPressed: () {
                        _navigateToAllRoutes(
                            context, '精选路线', _featuredRoutesFuture);
                      },
                    ),
                  ],
                ),
              ),
            ),

            // 精选路线列表
            SliverToBoxAdapter(
              child: _buildFeaturedRoutes(),
            ),

            // 热门路线标题
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '热门路线',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text('查看全部'),
                      onPressed: () {
                        _navigateToAllRoutes(
                            context, '热门路线', _popularRoutesFuture);
                      },
                    ),
                  ],
                ),
              ),
            ),

            // 热门路线列表
            SliverToBoxAdapter(
              child: _buildPopularRoutes(),
            ),

            // 季节推荐标题
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '本季推荐',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text('查看全部'),
                      onPressed: () {
                        _navigateToAllRoutes(
                            context, '本季推荐', _seasonalRoutesFuture);
                      },
                    ),
                  ],
                ),
              ),
            ),

            // 季节推荐列表
            SliverToBoxAdapter(
              child: _buildSeasonalRoutes(),
            ),

            // 底部间距
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建搜索栏
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: CupertinoSearchTextField(
        controller: _searchController,
        placeholder: '搜索路线名称或地点...',
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            _navigateToSearchResults(context, value);
          }
        },
      ),
    );
  }

  /// 构建最近搜索
  Widget _buildRecentSearches() {
    if (_recentSearches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            '最近搜索',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _recentSearches.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  minSize: 30,
                  onPressed: () {
                    _navigateToSearchResults(context, _recentSearches[index]);
                  },
                  child: Text(
                    _recentSearches[index],
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 构建热门搜索
  Widget _buildHotSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '热门搜索',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _hotSearches.map((search) {
              return CupertinoButton(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                minSize: 0,
                onPressed: () {
                  _navigateToSearchResults(context, search);
                },
                child: Text(
                  search,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// 构建分类部分
  Widget _buildCategorySection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        content,
      ],
    );
  }

  /// 构建地区项
  Widget _buildRegionItems() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _regions.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final region = _regions[index];
          return Container(
            width: 70,
            margin: const EdgeInsets.only(right: 16),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                if (region['name'] == '更多') {
                  // 显示更多地区
                } else {
                  _navigateToRegionRoutes(context, region['name']);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      region['icon'],
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    region['name'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 构建难度项
  Widget _buildDifficultyItems() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _difficulties.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final difficulty = _difficulties[index];
          return Container(
            width: 70,
            margin: const EdgeInsets.only(right: 16),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                _navigateToDifficultyRoutes(context, difficulty['difficulty']);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(difficulty['difficulty'])
                          .withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      difficulty['icon'],
                      color: _getDifficultyColor(difficulty['difficulty']),
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    difficulty['name'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 构建时长项
  Widget _buildDurationItems() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _durations.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final duration = _durations[index];
          return Container(
            width: 70,
            margin: const EdgeInsets.only(right: 16),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                _navigateToDurationRoutes(
                  context,
                  duration['min'],
                  duration['max'],
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      duration['icon'],
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    duration['label'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 构建精选路线
  Widget _buildFeaturedRoutes() {
    return SizedBox(
      height: 280,
      child: FutureBuilder<List<RouteModel>>(
        future: _featuredRoutesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('加载失败: ${snapshot.error}'),
            );
          }

          final routes = snapshot.data;
          if (routes == null || routes.isEmpty) {
            return const Center(
              child: Text('暂无路线'),
            );
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: routes.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final route = routes[index];
              return _buildFeaturedRouteCard(context, route);
            },
          );
        },
      ),
    );
  }

  /// 构建精选路线卡片
  Widget _buildFeaturedRouteCard(BuildContext context, RouteModel route) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          _navigateToRouteDetail(context, route);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 路线图片
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 180,
                width: double.infinity,
                color: AppColors.primary.withOpacity(0.1),
                child: route.imageUrls.isNotEmpty
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            route.imageUrls[0],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Center(
                              child: Icon(
                                CupertinoIcons.photo,
                                size: 40,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getDifficultyColor(route.difficulty)
                                    .withOpacity(0.8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getDifficultyName(route.difficulty),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Icon(
                          CupertinoIcons.photo,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 8),

            // 路线名称
            Text(
              route.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // 路线信息
            Row(
              children: [
                Icon(
                  CupertinoIcons.star_fill,
                  size: 14,
                  color: Colors.amber,
                ),
                const SizedBox(width: 4),
                Text(
                  route.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${route.durationDays}天',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  route.region,
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // 最佳季节
            Text(
              '最佳季节: ${route.bestSeasons.join(", ")}',
              style: const TextStyle(
                fontSize: 12,
                color: CupertinoColors.systemGrey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建热门路线
  Widget _buildPopularRoutes() {
    return SizedBox(
      height: 120,
      child: FutureBuilder<List<RouteModel>>(
        future: _popularRoutesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('加载失败: ${snapshot.error}'),
            );
          }

          final routes = snapshot.data;
          if (routes == null || routes.isEmpty) {
            return const Center(
              child: Text('暂无路线'),
            );
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: routes.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final route = routes[index];
              return _buildHorizontalRouteCard(context, route);
            },
          );
        },
      ),
    );
  }

  /// 构建季节推荐路线
  Widget _buildSeasonalRoutes() {
    return SizedBox(
      height: 120,
      child: FutureBuilder<List<RouteModel>>(
        future: _seasonalRoutesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('加载失败: ${snapshot.error}'),
            );
          }

          final routes = snapshot.data;
          if (routes == null || routes.isEmpty) {
            return const Center(
              child: Text('暂无路线'),
            );
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: routes.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final route = routes[index];
              return _buildHorizontalRouteCard(context, route);
            },
          );
        },
      ),
    );
  }

  /// 构建水平路线卡片
  Widget _buildHorizontalRouteCard(BuildContext context, RouteModel route) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          _navigateToRouteDetail(context, route);
        },
        child: Row(
          children: [
            // 路线图片
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 80,
                width: 80,
                color: AppColors.primary.withOpacity(0.1),
                child: route.imageUrls.isNotEmpty
                    ? Image.network(
                        route.imageUrls[0],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(
                            CupertinoIcons.photo,
                            size: 24,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          CupertinoIcons.photo,
                          size: 24,
                          color: AppColors.primary,
                        ),
                      ),
              ),
            ),

            const SizedBox(width: 8),

            // 路线信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 路线名称
                  Text(
                    route.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // 评分
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.star_fill,
                        size: 12,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        route.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // 时长和难度
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(route.difficulty)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getDifficultyName(route.difficulty),
                          style: TextStyle(
                            fontSize: 10,
                            color: _getDifficultyColor(route.difficulty),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${route.durationDays}天',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                          ),
                        ),
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

  /// 获取难度名称
  String _getDifficultyName(RouteDifficulty difficulty) {
    switch (difficulty) {
      case RouteDifficulty.easy:
        return '初级';
      case RouteDifficulty.medium:
        return '中级';
      case RouteDifficulty.hard:
        return '高级';
      case RouteDifficulty.extreme:
        return '专业级';
    }
  }

  /// 获取难度颜色
  Color _getDifficultyColor(RouteDifficulty difficulty) {
    switch (difficulty) {
      case RouteDifficulty.easy:
        return Colors.green;
      case RouteDifficulty.medium:
        return Colors.orange;
      case RouteDifficulty.hard:
        return Colors.red;
      case RouteDifficulty.extreme:
        return Colors.purple;
    }
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
          title: '${_getDifficultyName(difficulty)} 难度路线',
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
