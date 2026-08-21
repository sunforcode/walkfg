import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../model/route/route_model.dart';
import '../../common/loading_indicator.dart';
import 'route_result_item.dart';

/// 搜索结果组件
class SearchResultsSection extends StatelessWidget {
  /// 是否正在搜索
  final bool isSearching;

  /// 搜索结果
  final List<RouteModel> searchResults;

  /// 当前搜索关键词
  final String currentKeyword;

  /// 点击路线的回调
  final ValueChanged<RouteModel> onRouteTap;

  /// 构造函数
  const SearchResultsSection({
    super.key,
    required this.isSearching,
    required this.searchResults,
    required this.currentKeyword,
    required this.onRouteTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isSearching) {
      return const Center(child: LoadingIndicator());
    }

    if (searchResults.isEmpty) {
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
              '未找到与"$currentKeyword"相关的路线',
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
            '搜索结果: $currentKeyword',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: searchResults.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final route = searchResults[index];
              return RouteResultItem(
                route: route,
                onTap: () => onRouteTap(route),
              );
            },
          ),
        ),
      ],
    );
  }
}
