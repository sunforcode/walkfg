import 'package:flutter/cupertino.dart';
import 'package:walk/model/route/route_model.dart';
import 'package:walk/service/route_service.dart';
import 'package:walk/theme/tokens/colors.dart';
import 'package:walk/theme/tokens/radius.dart';
import 'package:walk/theme/tokens/shadows.dart';
import 'package:walk/theme/tokens/spacing.dart';
import 'package:walk/theme/tokens/typography.dart';
import 'package:walk/ui/page/common/empty_content_widget.dart';
import 'package:walk/ui/page/common/error_widget.dart';
import 'package:walk/ui/page/common/loading_indicator.dart';
import 'package:walk/ui/page/common/network_image_with_fallback.dart';
import 'package:walk/ui/page/common/utility_page_scaffold.dart';
import 'package:walk/ui/page/search/search_section.dart';

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
    RouteService.searchRoutes(keyword).then((results) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }).catchError((error) {
      if (!context.mounted) return;
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
  void _navigateToRouteDetail(RouteModel route) {}

  @override
  Widget build(BuildContext context) {
    return UtilityPageScaffold(
      title: '搜索路线',
      body: Column(
        children: [
          SearchSection(
            searchController: _searchController,
            hotSearches: _defaultHotSearches,
            onSearch: _handleSearch,
          ),
          Expanded(
            child: _currentKeyword.isEmpty
                ? _buildRecommendedRoutes()
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  /// 构建推荐路线
  Widget _buildRecommendedRoutes() {
    return FutureBuilder<List<RouteModel>>(
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
            child: EmptyContentWidget(
              icon: CupertinoIcons.map,
              title: '暂无推荐路线',
            ),
          );
        }

        final routes = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                AppSpacing.pageVertical,
                AppSpacing.pageHorizontal,
                AppSpacing.sm,
              ),
              child: const Text(
                '推荐路线',
                style: AppTypography.sectionTitle,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: routes.length,
                padding: AppSpacing.allLg,
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
        child: EmptyContentWidget(
          icon: CupertinoIcons.search,
          title: '未找到相关路线',
          subtitle: '没有与“$_currentKeyword”匹配的路线',
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            AppSpacing.pageVertical,
            AppSpacing.pageHorizontal,
            AppSpacing.sm,
          ),
          child: Text(
            '搜索结果: $_currentKeyword',
            style: AppTypography.sectionTitle,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _searchResults.length,
            padding: AppSpacing.allLg,
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
        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          border: Border.all(color: AppColors.border),
          borderRadius: AppRadius.borderControl,
          boxShadow: AppShadows.panel,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 路线图片
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: AppRadius.radiusControl,
              ),
              child: Container(
                height: 120,
                width: double.infinity,
                color: AppColors.interactiveAccent.withValues(alpha: 0.1),
                child: route.coverUrl != null
                    ? NetworkImageWithFallback(
                        url: route.coverUrl!,
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                        borderRadius: AppRadius.small,
                      )
                    : Container(
                        height: 80,
                        width: 80,
                        color:
                            AppColors.interactiveAccent.withValues(alpha: 0.1),
                        child: Center(
                          child: Icon(
                            CupertinoIcons.photo,
                            size: 40,
                            color: AppColors.interactiveAccent,
                          ),
                        ),
                      ),
              ),
            ),

            // 路线信息
            Padding(
              padding: AppSpacing.allMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    route.name,
                    style: AppTypography.cardTitle,
                  ),
                  AppSpacing.gapVerticalXs,
                  Text(
                    route.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySm,
                  ),
                  AppSpacing.gapVerticalSm,
                  Row(
                    children: [
                      _buildInfoTag(
                        '${route.distance}km',
                        CupertinoIcons.arrow_right,
                      ),
                      AppSpacing.gapSm,
                      _buildInfoTag(
                        '${route.elevationGain}m爬升',
                        CupertinoIcons.arrow_up,
                      ),
                      AppSpacing.gapSm,
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: const BoxDecoration(
        color: AppColors.interactiveAccentBg,
        borderRadius: AppRadius.borderSmall,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: AppColors.interactiveAccent,
          ),
          AppSpacing.gapXs,
          Text(
            text,
            style: AppTypography.withColor(
              AppTypography.label,
              AppColors.interactiveAccent,
            ),
          ),
        ],
      ),
    );
  }
}
