import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 筛选标签组组件
class FilterTagGroup extends StatelessWidget {
  /// 标签列表
  final List<String> tags;

  /// 标签点击回调
  final ValueChanged<String> onTagTap;

  /// 标题
  final String title;

  /// 构造函数
  const FilterTagGroup({
    super.key,
    required this.tags,
    required this.onTagTap,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: tags.map((tag) => _buildTag(tag)).toList(),
        ),
      ],
    );
  }

  /// 构建标签
  Widget _buildTag(String tag) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => onTagTap(tag),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          tag,
          style: const TextStyle(
            color: CupertinoColors.label,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}