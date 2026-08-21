import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/theme/tokens/tokens.dart';

/// 最近搜索组件
class RecentSearchesSection extends StatelessWidget {
  /// 最近搜索列表
  final List<String> recentSearches;

  /// 是否正在加载
  final bool isLoading;

  /// 点击某个搜索词的回调
  final ValueChanged<String> onSearchTap;

  /// 清空搜索历史的回调
  final VoidCallback onClearPressed;

  /// 构造函数
  const RecentSearchesSection({
    super.key,
    required this.recentSearches,
    required this.isLoading,
    required this.onSearchTap,
    required this.onClearPressed,
  });

  @override
  Widget build(BuildContext context) {
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
              if (recentSearches.isNotEmpty)
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Text('清空'),
                  onPressed: onClearPressed,
                ),
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: isLoading
              ? const Center(child: CupertinoActivityIndicator())
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recentSearches.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        minimumSize: const Size.fromHeight(30),
                        onPressed: () {
                          onSearchTap(recentSearches[index]);
                        },
                        child: Text(
                          recentSearches[index],
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
}
