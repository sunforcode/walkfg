import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../model/trip/hot_search_model.dart';
import '../../../../service/search_history_service.dart';
import '../../../../service/service_manager.dart';
import '../../../../theme/theme/app_colors.dart';

/// 搜索部分组件
class SearchSection extends StatefulWidget {
  /// 搜索控制器
  final TextEditingController searchController;

  /// 最近搜索列表
  final List<String>? recentSearches;

  /// 热门搜索列表
  final List<String>? hotSearches;

  /// 搜索回调
  final Function(BuildContext, String) onSearch;

  /// 构造函数
  const SearchSection({
    super.key,
    required this.searchController,
    this.recentSearches,
    this.hotSearches,
    required this.onSearch,
  });

  @override
  State<SearchSection> createState() => _SearchSectionState();
}

class _SearchSectionState extends State<SearchSection> {
  /// 搜索历史服务
  late final SearchHistoryService _searchHistoryService;

  /// 最近搜索列表
  List<String> _recentSearches = [];

  /// 热门搜索列表
  List<HotSearchModel> _hotSearches = [];

  /// 是否正在加载
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchHistoryService = ServiceLocator.instance.getSearchHistoryService();
    _loadData();
  }

  /// 加载数据
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 加载搜索历史
      final keywords = await _searchHistoryService.getSearchKeywords();

      // 加载热门搜索
      final tripService = ServiceLocator.instance.getRecommendationService();
      final hotSearches = await tripService.getHotSearches();

      setState(() {
        _recentSearches = keywords;
        _hotSearches = hotSearches.items;
        _isLoading = false;
      });
    } catch (e) {
      // 如果加载失败，使用传入的默认值
      setState(() {
        _recentSearches = widget.recentSearches ?? [];
        _hotSearches = [];
        _isLoading = false;
      });
    }
  }

  /// 添加搜索历史
  Future<void> _addSearchHistory(String keyword) async {
    if (keyword.trim().isEmpty) return;

    await _searchHistoryService.addSearch(keyword);

    // 重新加载搜索历史
    final keywords = await _searchHistoryService.getSearchKeywords();
    setState(() {
      _recentSearches = keywords;
    });
  }

  /// 清空搜索历史
  Future<void> _clearSearchHistory() async {
    await _searchHistoryService.clearSearchHistory();
    setState(() {
      _recentSearches = [];
    });
  }

  /// 执行搜索
  void _performSearch(String keyword) {
    if (keyword.trim().isEmpty) return;

    // 添加到搜索历史
    _addSearchHistory(keyword);

    // 调用搜索回调
    widget.onSearch(context, keyword);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 搜索框
        _buildSearchBar(context),

        // 最近搜索
        if (_recentSearches.isNotEmpty) _buildRecentSearches(context),

        // 热门搜索
        _buildHotSearches(context),
      ],
    );
  }

  /// 构建搜索栏
  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: CupertinoSearchTextField(
        controller: widget.searchController,
        placeholder: '搜索路线名称或地点...',
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            _performSearch(value);
          }
        },
      ),
    );
  }

  /// 构建最近搜索
  Widget _buildRecentSearches(BuildContext context) {
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
                        color: AppColors.primary.withOpacity(0.1),
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
  Widget _buildHotSearches(BuildContext context) {
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
                      ? (widget.hotSearches ?? []).map((search) {
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
    Color backgroundColor = AppColors.primary.withOpacity(0.1);
    Color textColor = AppColors.primary;

    // 如果有自定义颜色，使用自定义颜色
    if (tagColor != null) {
      try {
        final color = Color(int.parse(tagColor.replaceAll('#', '0xFF')));
        backgroundColor = color.withOpacity(0.1);
        textColor = color;
      } catch (e) {
        // 如果解析失败，使用默认颜色
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
}
