import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/model/route/route_model.dart';
import 'package:walk/service/route_service.dart';
import 'package:walk/service/service_manager.dart';
import 'package:walk/theme/theme/app_colors.dart';
import 'package:walk/ui/page/common/network_image_with_fallback.dart';
import 'package:walk/ui/page/search/search_section.dart';
import 'package:walk/ui/page/route/route_list_screen.dart';
import 'package:walk/ui/page/common/loading_indicator.dart';
import 'package:walk/ui/page/common/error_widget.dart';

/// 路线搜索页面
class RouteSearchPage extends StatefulWidget {
  /// 构造函数
  const RouteSearchPage({super.key});

  @override
  State<RouteSearchPage> createState() => _RouteSearchPageState();
}

class _RouteSearchPageState extends State<RouteSearchPage> {
  /// 搜索控制器
  final TextEditingController _searchController = TextEditingController();

  /// 当前搜索关键词
  String _currentKeyword = '';

  /// 是否正在搜索
  bool _isSearching = false;

  /// 搜索结果
  List<RouteModel> _searchResults = [];

  /// 路线服务
  final RouteService _routeService = ServiceLocator.instance.getRouteService();

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 处理搜索
  void _handleSearch(BuildContext context, String keyword) {
    setState(() {
      _currentKeyword = keyword;
      _isSearching = true;
    });

    // 执行搜索
    _routeService.searchRoutes(keyword).then((results) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }).catchError((error) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });

      // 显示错误提示
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
  void _navigateToRouteDetail(RouteModel route) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => RouteListScreen(
          title: '搜索: $_currentKeyword',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('搜索路线'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 搜索部分
            SearchSection(
              searchController: _searchController,
              hotSearches: _defaultHotSearches,
              onSearch: _handleSearch,
            ),

            // 搜索结果
            Expanded(
              child: _currentKeyword.isEmpty
                  ? _buildRecommendedRoutes()
                  : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建推荐路线
  Widget _buildRecommendedRoutes() {
    return FutureBuilder<List<RouteModel>>(
      future: _routeService.getRecommendedRoutes(),
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
            Expanded(
              child: ListView.builder(
                itemCount: routes.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final route = routes[index];
                  return _buildRouteItem(route);
                },
              ),
            ),
          ],
        );
      },
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
            // 路线图片
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                height: 120,
                width: double.infinity,
                color: AppColors.primary.withOpacity(0.1),
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
                        color: AppColors.primary.withOpacity(0.1),
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

            // 路线信息
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
        color: AppColors.primary.withOpacity(0.1),
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
