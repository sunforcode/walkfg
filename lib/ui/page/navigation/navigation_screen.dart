import 'package:flutter/cupertino.dart';
import 'package:walk/model/route/route_model.dart';
import 'package:walk/model/search/hot_search_model.dart';
import 'package:walk/service/route_service.dart';
import 'package:walk/service/search_history_service.dart';
import 'package:walk/service/recommendation_service.dart';
import 'widgets/hot_searches_section.dart';
import 'widgets/nav_recommended_routes_section.dart';
import 'widgets/navigation_quick_access.dart';
import 'widgets/navigation_search_bar.dart';
import 'widgets/recent_searches_section.dart';
import 'widgets/search_results_section.dart';

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
            NavigationSearchBar(
              controller: _searchController,
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _performSearch(value);
                }
              },
            ),

            // 内容区域
            Expanded(
              child: _currentKeyword.isEmpty
                  ? _buildSearchAndNavigationContent()
                  : SearchResultsSection(
                      isSearching: _isSearching,
                      searchResults: _searchResults,
                      currentKeyword: _currentKeyword,
                      onRouteTap: _navigateToRouteDetail,
                    ),
            ),
          ],
        ),
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
          const NavigationQuickAccess(),

          const SizedBox(height: 24),

          // 最近搜索
          if (_recentSearches.isNotEmpty)
            RecentSearchesSection(
              recentSearches: _recentSearches,
              isLoading: _isLoading,
              onSearchTap: _performSearch,
              onClearPressed: _clearSearchHistory,
            ),

          // 热门搜索
          HotSearchesSection(
            hotSearches: _hotSearches,
            defaultHotSearches: _defaultHotSearches,
            isLoading: _isLoading,
            onSearchTap: _performSearch,
          ),

          const SizedBox(height: 24),

          // 推荐路线
          NavRecommendedRoutesSection(
            recommendedRoutesFuture: RouteService.getRecommendedRoutes(),
            onRouteTap: _navigateToRouteDetail,
            onRetry: () => setState(() {}),
          ),
        ],
      ),
    );
  }
}
