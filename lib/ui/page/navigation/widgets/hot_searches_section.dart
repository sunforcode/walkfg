import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/theme/tokens/tokens.dart';

import '../../../../model/search/hot_search_model.dart';

/// 热门搜索组件
class HotSearchesSection extends StatelessWidget {
  /// 热门搜索列表
  final List<HotSearchModel> hotSearches;

  /// 默认热门搜索词（当热门搜索列表为空时使用）
  final List<String> defaultHotSearches;

  /// 是否正在加载
  final bool isLoading;

  /// 点击某个搜索词的回调
  final ValueChanged<String> onSearchTap;

  /// 构造函数
  const HotSearchesSection({
    super.key,
    required this.hotSearches,
    required this.defaultHotSearches,
    required this.isLoading,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
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
          child: isLoading
              ? const Center(child: CupertinoActivityIndicator())
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: hotSearches.isEmpty
                      ? defaultHotSearches.map((search) {
                          return _buildSearchTag(search, null, false);
                        }).toList()
                      : hotSearches.map((search) {
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
        onSearchTap(keyword);
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
