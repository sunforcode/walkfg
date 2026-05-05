import 'package:flutter/cupertino.dart';
import '../../../model/route/route_model.dart';
import '../../../service/route_service.dart';
import '../common/error_widget.dart';
import '../common/empty_content_widget.dart';
import 'detail/route_detail_screen.dart';
import 'widgets/route_discovery_constants.dart';
import 'widgets/route_filter_section.dart';
import 'widgets/route_list_card.dart';

/// 路线发现页面
///
/// 提供路线浏览、搜索、筛选等功能
class RouteDiscoveryScreen extends StatefulWidget {
  /// 构造函数
  const RouteDiscoveryScreen({
    super.key,
  });

  @override
  State<RouteDiscoveryScreen> createState() => _RouteDiscoveryScreenState();
}

class _RouteDiscoveryScreenState extends State<RouteDiscoveryScreen> {
  /// 热门路线Future
  late Future<List<RouteModel>> _popularRoutesFuture;

  /// 当季路线Future
  late Future<List<RouteModel>> _seasonalRoutesFuture;

  /// 全部路线Future
  late Future<List<RouteModel>> _allRoutesFuture;

  /// 滚动控制器
  final ScrollController _scrollController = ScrollController();

  /// 当前选中的过滤器
  String _selectedFilter = RouteDiscoveryConstants.defaultFilter;

  /// 搜索控制器
  final TextEditingController _searchController = TextEditingController();

  /// 是否显示搜索框
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
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
      return await RouteService.getPopularRoutes(limit: 10);
    } catch (e) {
      throw Exception('加载热门路线失败: $e');
    }
  }

  /// 加载当季路线
  Future<List<RouteModel>> _loadSeasonalRoutes() async {
    try {
      return await RouteService.getSeasonalRoutes(limit: 10);
    } catch (e) {
      throw Exception('加载当季路线失败: $e');
    }
  }

  /// 加载全部路线（支持过滤）
  Future<List<RouteModel>> _loadAllRoutes() async {
    try {
      return await RouteService.getRoutesByCategory(
        _selectedFilter,
        limit: 20,
      );
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
    // 根据过滤器重新加载全部路线数据
    _reloadAllRoutes();
  }

  /// 重新加载全部路线（用于过滤后刷新）
  void _reloadAllRoutes() {
    setState(() {
      _allRoutesFuture = _loadAllRoutes();
    });
  }

  /// 处理搜索
  void _onSearch(String query) {
    // TODO: 实现搜索功能
    debugPrint('搜索: $query');
  }

  /// 切换搜索状态
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
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
            // 搜索框（如果显示）
            if (_isSearching)
              SliverToBoxAdapter(
                child: _buildSearchBar(),
              ),

            // 过滤器
            SliverToBoxAdapter(
              child: RouteFilterSection(
                filters: RouteDiscoveryConstants.filters,
                selectedFilter: _selectedFilter,
                onFilterSelected: _onFilterSelected,
              ),
            ),

            // 推荐路线区域（合并热门、当季）
            SliverToBoxAdapter(
              child: _buildFeaturedSection(),
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
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: _toggleSearch,
        child: Icon(
          _isSearching ? CupertinoIcons.xmark_circle_fill : CupertinoIcons.search,
          color: CupertinoColors.label,
        ),
      ),
      backgroundColor: CupertinoColors.systemGroupedBackground.withValues(alpha: 0.9),
      border: null,
    );
  }

  /// 构建搜索框
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: RouteDiscoveryConstants.horizontalPadding,
        vertical: 8,
      ),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey4.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CupertinoTextField(
          controller: _searchController,
          placeholder: '搜索路线...',
          placeholderStyle: TextStyle(
            color: CupertinoColors.systemGrey,
            fontSize: 16,
          ),
          style: const TextStyle(
            fontSize: 16,
            color: CupertinoColors.label,
          ),
          prefix: const Padding(
            padding: EdgeInsets.only(left: 12),
            child: Icon(
              CupertinoIcons.search,
              size: 18,
              color: CupertinoColors.systemGrey,
            ),
          ),
          decoration: const BoxDecoration(
            border: null,
          ),
          onSubmitted: _onSearch,
          onChanged: _onSearch,
        ),
      ),
    );
  }

  /// 构建推荐路线区域（合并热门、当季）
  Widget _buildFeaturedSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: RouteDiscoveryConstants.horizontalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题区域
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '为你推荐',
                      style: TextStyle(
                        fontSize: RouteDiscoveryConstants.sectionTitleFontSize,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.label,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '精选热门和当季路线',
                      style: TextStyle(
                        fontSize: RouteDiscoveryConstants.sectionSubtitleFontSize,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
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
          ),

          // 推荐路线网格
          _buildFeaturedGrid(),
        ],
      ),
    );
  }

  /// 构建推荐路线网格
  Widget _buildFeaturedGrid() {
    return FutureBuilder<List<RouteModel>>(
      future: _popularRoutesFuture,
      builder: (context, popularSnapshot) {
        if (popularSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        }

        if (popularSnapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
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

        final popularRoutes = popularSnapshot.data ?? [];

        return FutureBuilder<List<RouteModel>>(
          future: _seasonalRoutesFuture,
          builder: (context, seasonalSnapshot) {
            if (seasonalSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CupertinoActivityIndicator(),
              );
            }

            if (seasonalSnapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
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

            final seasonalRoutes = seasonalSnapshot.data ?? [];

            // 合并热门和当季路线，去重
            final allFeatured = <RouteModel>{};
            allFeatured.addAll(popularRoutes.take(3));
            allFeatured.addAll(seasonalRoutes.take(3));

            if (allFeatured.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: EmptyContentWidget(
                  icon: CupertinoIcons.map,
                  title: RouteDiscoveryConstants.emptyRoutesTitle,
                  subtitle: RouteDiscoveryConstants.emptyRoutesSubtitle,
                ),
              );
            }

            // 构建网格
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: allFeatured.length,
              itemBuilder: (context, index) {
                final route = allFeatured.elementAt(index);
                return _buildFeaturedCard(route);
              },
            );
          },
        );
      },
    );
  }

  /// 构建推荐卡片
  Widget _buildFeaturedCard(RouteModel route) {
    return GestureDetector(
      onTap: () => _navigateToRouteDetail(route),
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey4.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片区域
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 背景图片
                    route.coverUrl != null
                        ? Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(route.coverUrl!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : Container(
                            color: CupertinoColors.systemGrey5,
                            child: Icon(
                              CupertinoIcons.photo,
                              size: 32,
                              color: CupertinoColors.systemGrey2,
                            ),
                          ),

                    // 渐变遮罩
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            CupertinoColors.white.withValues(alpha: 0),
                            CupertinoColors.black.withValues(alpha: 0.3),
                          ],
                        ),
                      ),
                    ),

                    // 难度标签
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.chart_bar_alt_fill,
                              size: 12,
                              color: _getDifficultyColor(route.difficulty.index),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getDifficultyText(route.difficulty.index),
                              style: TextStyle(
                                fontSize: 12,
                                color: _getDifficultyColor(route.difficulty.index),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 信息区域
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 路线名称
                    Text(
                      route.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.label,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // 位置
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.location_solid,
                          size: 12,
                          color: CupertinoColors.systemGrey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            route.region,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // 距离和时间
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.arrow_right_arrow_left,
                          size: 12,
                          color: CupertinoColors.systemGrey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${route.distance} km',
                          style: const TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          CupertinoIcons.time,
                          size: 12,
                          color: CupertinoColors.systemGrey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          route.duration,
                          style: const TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 获取难度颜色
  Color _getDifficultyColor(int index) {
    switch (index) {
      case 0:
        return CupertinoColors.systemGreen;
      case 1:
        return CupertinoColors.systemOrange;
      case 2:
        return CupertinoColors.systemRed;
      case 3:
        return CupertinoColors.systemPurple;
      default:
        return CupertinoColors.activeBlue;
    }
  }

  /// 获取难度文本
  String _getDifficultyText(int index) {
    switch (index) {
      case 0:
        return '简单';
      case 1:
        return '中等';
      case 2:
        return '困难';
      case 3:
        return '极难';
      default:
        return '中等';
    }
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
