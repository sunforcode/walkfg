import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/model/route/route_model.dart';
import 'package:walk/model/search/hot_search_model.dart';
import 'package:walk/service/route_service.dart';
import 'package:walk/service/search_history_service.dart';
import 'package:walk/service/recommendation_service.dart';
import 'package:walk/theme/tokens/tokens.dart';
import 'package:walk/ui/page/common/loading_indicator.dart';
import 'package:walk/ui/page/common/error_widget.dart';
import 'package:walk/ui/page/common/network_image_with_fallback.dart';

/// 导航页面
class NavigationScreen extends StatefulWidget {
  /// 构造函数
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  /// 搜索控制器
  final TextEditingController _searchController = TextEditingController();

  /// 当前搜索关键词
  String _currentKeyword = '';

  /// 是否正在搜索
  bool _isSearching = false;

  /// 搜索结果
  List<RouteModel> _searchResults = [];

  /// 最近搜索列表
  List<String> _recentSearches = [];

  /// 热门搜索列表
  List<HotSearchModel> _hotSearches = [];

  /// 是否正在加载
  bool _isLoading = true;

  /// 默认热门搜索词
  final List<String> _defaultHotSearches = [
    '北京周边',
    '徒步路线',
    '登山',
    '露营',
    '自驾游',
    '亲子游',
    '周末游',
  ];

  @override
  void initState() {
    super.initState();
    _loadSearchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 加载搜索相关数据
  Future<void> _loadSearchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final keywords = await SearchHistoryService.getSearchKeywords();
      final hotSearches = await RecommendationService.getHotSearches();

      setState(() {
        _recentSearches = keywords;
        _hotSearches = hotSearches.items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _recentSearches = [];
        _hotSearches = [];
        _isLoading = false;
      });
    }
  }

  /// 添加搜索历史
  Future<void> _addSearchHistory(String keyword) async {
    if (keyword.trim().isEmpty) return;

    await SearchHistoryService.addSearch(keyword);
    final keywords = await SearchHistoryService.getSearchKeywords();
    setState(() {
      _recentSearches = keywords;
    });
  }

  /// 清空搜索历史
  Future<void> _clearSearchHistory() async {
    await SearchHistoryService.clearSearchHistory();
    setState(() {
      _recentSearches = [];
    });
  }

  /// 执行搜索
  void _performSearch(String keyword) {
    if (keyword.trim().isEmpty) return;

    _addSearchHistory(keyword);
    _handleSearch(context, keyword);
  }

  /// 处理搜索
  void _handleSearch(BuildContext context, String keyword) {
    setState(() {
      _currentKeyword = keyword;
      _isSearching = true;
    });

    RouteService.searchRoutes(keyword).then((results) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }).catchError((error) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });

      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('搜索失败'),
          content: Text('无法完成搜索: ${error.toString()}'),
          actions: [
            CupertinoDialogAction(
              child: const Text('确定'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    });
  }

  /// 导航到路线详情
  void _navigateToRouteDetail(RouteModel route) {}

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('导航'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 搜索框
            _buildSearchBar(),
            
            // 内容区域
            Expanded(
              child: _currentKeyword.isEmpty
                  ? _buildSearchAndNavigationContent()
                  : _buildSearchResults(),
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
            _performSearch(value);
          }
        },
      ),
    );
  }

  /// 构建搜索和导航内容
  Widget _buildSearchAndNavigationContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 导航快捷入口
          _buildNavigationQuickAccess(),
          
          const SizedBox(height: 24),
          
          // 最近搜索
          if (_recentSearches.isNotEmpty) _buildRecentSearches(),
          
          // 热门搜索
          _buildHotSearches(),
          
          const SizedBox(height: 24),
          
          // 推荐路线
          _buildRecommendedRoutes(),
        ],
      ),
    );
  }

  /// 构建导航快捷入口
  Widget _buildNavigationQuickAccess() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  CupertinoIcons.location_north_line_fill,
                  size: 40,
                  color: CupertinoColors.white,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '开始导航',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '选择目的地，开启你的徒步之旅',
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildQuickAccessButton(
                icon: CupertinoIcons.map_fill,
                label: '附近路线',
                onTap: () {
                  // TODO: 实现附近路线功能
                  showCupertinoDialog(
                    context: context,
                    builder: (context) => CupertinoAlertDialog(
                      title: const Text('提示'),
                      content: const Text('附近路线功能正在开发中，敬请期待！'),
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
              const SizedBox(width: 12),
              _buildQuickAccessButton(
                icon: CupertinoIcons.star_fill,
                label: '收藏路线',
                onTap: () {
                  // TODO: 实现收藏路线功能
                  showCupertinoDialog(
                    context: context,
                    builder: (context) => CupertinoAlertDialog(
                      title: const Text('提示'),
                      content: const Text('收藏路线功能正在开发中，敬请期待！'),
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
              const SizedBox(width: 12),
              _buildQuickAccessButton(
                icon: CupertinoIcons.clock,
                label: '历史记录',
                onTap: () {
                  // TODO: 实现历史记录功能
                  showCupertinoDialog(
                    context: context,
                    builder: (context) => CupertinoAlertDialog(
                      title: const Text('提示'),
                      content: const Text('历史记录功能正在开发中，敬请期待！'),
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
        ],
      ),
    );
  }

  /// 构建快捷入口按钮
  Widget _buildQuickAccessButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: CupertinoColors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 28,
                color: CupertinoColors.white,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: CupertinoColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建最近搜索
  Widget _buildRecentSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '最近搜索',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (_recentSearches.isNotEmpty)
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Text('清空'),
                  onPressed: _clearSearchHistory,
                ),
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: _isLoading
              ? const Center(child: CupertinoActivityIndicator())
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _recentSearches.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        minSize: 30,
                        onPressed: () {
                          _performSearch(_recentSearches[index]);
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
          child: _isLoading
              ? const Center(child: CupertinoActivityIndicator())
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _hotSearches.isEmpty
                      ? _defaultHotSearches.map((search) {
                          return _buildSearchTag(search, null, false);
                        }).toList()
                      : _hotSearches.map((search) {
                          return _buildSearchTag(
                            search.keyword,
                            null,
                            true,
                          );
                        }).toList(),
                ),
        ),
      ],
    );
  }

  /// 构建搜索标签
  Widget _buildSearchTag(String keyword, String? tagColor, bool isHot) {
    Color backgroundColor = AppColors.primary.withValues(alpha: 0.1);
    Color textColor = AppColors.primary;

    if (tagColor != null) {
      try {
        final color = Color(int.parse(tagColor.replaceAll('#', '0xFF')));
        backgroundColor = color.withValues(alpha: 0.1);
        textColor = color;
      } catch (e) {
        // 解析失败，使用默认颜色
      }
    }

    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: backgroundColor,
      borderRadius: BorderRadius.circular(20),
      minSize: 0,
      onPressed: () {
        _performSearch(keyword);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            keyword,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
            ),
          ),
          if (isHot) ...[
            const SizedBox(width: 4),
            Icon(
              CupertinoIcons.flame_fill,
              size: 12,
              color: textColor,
            ),
          ],
        ],
      ),
    );
  }

  /// 构建推荐路线
  Widget _buildRecommendedRoutes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '推荐路线',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        FutureBuilder<List<RouteModel>>(
          future: RouteService.getRecommendedRoutes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: LoadingIndicator());
            }

            if (snapshot.hasError) {
              return ErrorMessageWidget(
                errorMessage: '无法加载推荐路线',
                onRetry: () => setState(() {}),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('暂无推荐路线'),
              );
            }

            final routes = snapshot.data!;

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: routes.length > 3 ? 3 : routes.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final route = routes[index];
                return _buildRouteItem(route);
              },
            );
          },
        ),
      ],
    );
  }

  /// 构建搜索结果
  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(child: LoadingIndicator());
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.search,
              size: 48,
              color: CupertinoColors.systemGrey,
            ),
            const SizedBox(height: 16),
            Text(
              '未找到与"$_currentKeyword"相关的路线',
              style: const TextStyle(
                color: CupertinoColors.systemGrey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '搜索结果: $_currentKeyword',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _searchResults.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final route = _searchResults[index];
              return _buildRouteItem(route);
            },
          ),
        ),
      ],
    );
  }

  /// 构建路线项
  Widget _buildRouteItem(RouteModel route) {
    return GestureDetector(
      onTap: () => _navigateToRouteDetail(route),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                height: 120,
                width: double.infinity,
                color: AppColors.primary.withValues(alpha: 0.1),
                child: route.coverUrl != null
                    ? NetworkImageWithFallback(
                        url: route.coverUrl!,
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                        borderRadius: 8,
                      )
                    : Container(
                        height: 80,
                        width: 80,
                        color: AppColors.primary.withValues(alpha: 0.1),
                        child: Center(
                          child: Icon(
                            CupertinoIcons.photo,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    route.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    route.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildInfoTag(
                        '${route.distance}km',
                        CupertinoIcons.arrow_right,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoTag(
                        '${route.elevationGain}m爬升',
                        CupertinoIcons.arrow_up,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoTag(
                        route.difficulty.name,
                        CupertinoIcons.flag,
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

  /// 构建信息标签
  Widget _buildInfoTag(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: AppColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
