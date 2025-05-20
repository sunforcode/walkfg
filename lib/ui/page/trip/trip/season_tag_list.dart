import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/theme/app_colors.dart';

/// 季节标签列表组件
class SeasonTagList extends StatelessWidget {
  /// 标签列表
  final List<String> tags;

  /// 当前选中的标签
  final String selectedTag;

  /// 标签点击回调
  final ValueChanged<String> onTagSelected;

  /// 构造函数
  const SeasonTagList({
    super.key,
    required this.tags,
    required this.selectedTag,
    required this.onTagSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tags.length,
        itemBuilder: (context, index) {
          final tag = tags[index];
          final isSelected = tag == selectedTag;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => onTagSelected(tag),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : CupertinoColors.systemGrey4,
                  ),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: isSelected
                        ? CupertinoColors.white
                        : CupertinoColors.label,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}