import 'package:flutter/cupertino.dart';
import '../../../model/route/route_model.dart';
import '../../../service/recommendation_service.dart';
import '../common/error_widget.dart';
import '../common/empty_content_widget.dart';
import 'detail/route_detail_screen.dart';
import 'widgets/route_discovery_constants.dart';
import 'widgets/route_map_view.dart';
import 'widgets/route_filter_section.dart';
import 'widgets/route_card.dart';
import 'widgets/route_list_card.dart';

/// 路线发现页面
///
/// 提供路线浏览、搜索、筛选等功能，包含地图视图和列表视图
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
  String _selectedFilter = RouteDiscoveryConstants.defaultFilter;

  /// 地图展开状态
  bool _isMapExpanded = false;

  /// 地图高度动画
  late Animation<double> _mapHeightAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadRoutes();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// 初始化动画
  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: RouteDiscoveryConstants.animationDuration,
    );

    _mapHeightAnimation = Tween<double>(
      begin: RouteDiscoveryConstants.mapCollapsedHeight,
      end: RouteDiscoveryConstants.mapExpandedHeight,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  /// 加载路线数据
  void _loadRoutes() {
    try {
      // 加载热门路线
      _popularRoutesFuture = _loadPopularRoutes();

      // 加载当季路线
      _seasonalRoutesFuture = _loadSeasonalRoutes();

      // 加载全部路线
      _allRoutesFuture = _loadAllRoutes();
    } catch (e) {
      // 统一错误处理
      _handleLoadError(e);
    }
  }

  /// 加载热门路线
  Future<List<RouteModel>> _loadPopularRoutes() async {
    try {
      return await RecommendationService.getPersonalizedRecommendations();
    } catch (e) {
      throw Exception('加载热门路线失败: $e');
    }
  }

  /// 加载当季路线
  Future<List<RouteModel>> _loadSeasonalRoutes() async {
    try {
      return await RecommendationService.getSeasonalRecommendations();
    } catch (e) {
      throw Exception('加载当季路线失败: $e');
    }
  }

  /// 加载全部路线
  Future<List<RouteModel>> _loadAllRoutes() async {
    try {
      return await RecommendationService.getPersonalizedRecommendations();
    } catch (e) {
      throw Exception('加载全部路线失败: $e');
    }
  }

  /// 处理加载错误
  void _handleLoadError(dynamic error) {
    // TODO: 添加错误日志记录
    // TODO: 显示用户友好的错误提示
    debugPrint('路线加载失败: $error');
  }

  /// 处理过滤器选择
  void _onFilterSelected(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    // TODO: 根据过滤器重新加载数据
  }

  /// 处理地图展开/收起
  void _onMapToggle() {
    setState(() {
      _isMapExpanded = !_isMapExpanded;
      if (_isMapExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: _buildNavigationBar(),
      child: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 地图视图
            SliverToBoxAdapter(
              child: RouteMapView(
                isExpanded: _isMapExpanded,
                animation: _mapHeightAnimation,
                onToggle: _onMapToggle,
              ),
            ),

            // 过滤器
            SliverToBoxAdapter(
              child: RouteFilterSection(
                filters: RouteDiscoveryConstants.filters,
                selectedFilter: _selectedFilter,
                onFilterSelected: _onFilterSelected,
              ),
            ),

            // 热门路线
            _buildSectionTitle(
              RouteDiscoveryConstants.popularRoutesTitle,
              RouteDiscoveryConstants.popularRoutesSubtitle,
            ),
            SliverToBoxAdapter(
              child: _buildHorizontalRouteList(_popularRoutesFuture),
            ),

            // 当季路线
            _buildSectionTitle(
              RouteDiscoveryConstants.seasonalRoutesTitle,
              RouteDiscoveryConstants.seasonalRoutesSubtitle,
            ),
            SliverToBoxAdapter(
              child: _buildHorizontalRouteList(_seasonalRoutesFuture),
            ),

            // 全部路线
            _buildSectionTitle(
              RouteDiscoveryConstants.allRoutesTitle,
              RouteDiscoveryConstants.allRoutesSubtitle,
            ),
            SliverToBoxAdapter(
              child: _buildAllRoutesList(),
            ),

            // 底部间距
            const SliverToBoxAdapter(
              child: SizedBox(height: RouteDiscoveryConstants.bottomSpacing),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建导航栏
  CupertinoNavigationBar _buildNavigationBar() {
    return CupertinoNavigationBar(
      middle: const Text(
        RouteDiscoveryConstants.pageTitle,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: CupertinoColors.systemGroupedBackground.withOpacity(0.9),
      border: null,
    );
  }

  /// 构建分区标题
  Widget _buildSectionTitle(String title, String subtitle) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          RouteDiscoveryConstants.horizontalPadding,
          RouteDiscoveryConstants.sectionTopPadding,
          RouteDiscoveryConstants.horizontalPadding,
          RouteDiscoveryConstants.sectionBottomPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: RouteDiscoveryConstants.sectionTitleFontSize,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.label,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Row(
                    children: [
                      Text(
                        RouteDiscoveryConstants.viewAllText,
                        style: TextStyle(
                          fontSize: RouteDiscoveryConstants.viewAllFontSize,
                          color: CupertinoColors.activeBlue,
                        ),
                      ),
                      Icon(
                        CupertinoIcons.chevron_right,
                        size: RouteDiscoveryConstants.viewAllIconSize,
                        color: CupertinoColors.activeBlue,
                      ),
                    ],
                  ),
                  onPressed: _onViewAllPressed,
                ),
              ],
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: RouteDiscoveryConstants.sectionSubtitleFontSize,
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
      height: RouteDiscoveryConstants.horizontalListHeight,
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
              padding: const EdgeInsets.symmetric(
                horizontal: RouteDiscoveryConstants.horizontalPadding,
              ),
              child: ErrorMessageWidget(
                errorMessage: RouteDiscoveryConstants.loadErrorMessage,
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
              padding: EdgeInsets.symmetric(
                horizontal: RouteDiscoveryConstants.horizontalPadding,
              ),
              child: EmptyContentWidget(
                icon: CupertinoIcons.map,
                title: RouteDiscoveryConstants.emptyRoutesTitle,
                subtitle: RouteDiscoveryConstants.emptyRoutesSubtitle,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: RouteDiscoveryConstants.horizontalPadding,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: routes.length,
            itemBuilder: (context, index) {
              final route = routes[index];
              return RouteCard(
                route: route,
                onTap: () => _navigateToRouteDetail(route),
              );
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
            height: RouteDiscoveryConstants.loadingHeight,
            child: Center(
              child: CupertinoActivityIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: RouteDiscoveryConstants.horizontalPadding,
            ),
            child: ErrorMessageWidget(
              errorMessage: RouteDiscoveryConstants.loadErrorMessage,
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
            padding: EdgeInsets.symmetric(
              horizontal: RouteDiscoveryConstants.horizontalPadding,
            ),
            child: EmptyContentWidget(
              icon: CupertinoIcons.map,
              title: RouteDiscoveryConstants.emptyRoutesTitle,
              subtitle: RouteDiscoveryConstants.emptyRoutesSubtitle,
            ),
          );
        }

        // 只显示前6个路线
        final displayRoutes =
            routes.length > RouteDiscoveryConstants.maxDisplayRoutes
                ? routes.sublist(0, RouteDiscoveryConstants.maxDisplayRoutes)
                : routes;

        return Column(
          children: [
            // 路线列表
            ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: RouteDiscoveryConstants.horizontalPadding,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayRoutes.length,
              itemBuilder: (context, index) {
                final route = displayRoutes[index];
                return RouteListCard(
                  route: route,
                  onTap: () => _navigateToRouteDetail(route),
                );
              },
            ),

            // 查看更多按钮
            if (routes.length > RouteDiscoveryConstants.maxDisplayRoutes)
              Padding(
                padding: const EdgeInsets.all(
                    RouteDiscoveryConstants.horizontalPadding),
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  color: CupertinoColors.activeBlue,
                  borderRadius: BorderRadius.circular(
                    RouteDiscoveryConstants.buttonBorderRadius,
                  ),
                  child: const SizedBox(
                    height: RouteDiscoveryConstants.buttonHeight,
                    child: Center(
                      child: Text(
                        RouteDiscoveryConstants.viewMoreText,
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  onPressed: _onViewMorePressed,
                ),
              ),
          ],
        );
      },
    );
  }

  /// 处理查看全部按钮点击
  void _onViewAllPressed() {
    // TODO: 实现查看全部功能
    debugPrint('查看全部路线');
  }

  /// 处理查看更多按钮点击
  void _onViewMorePressed() {
    // TODO: 实现查看更多功能
    debugPrint('查看更多路线');
  }
}
