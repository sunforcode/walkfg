import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/theme/app_colors.dart';

/// 分类部分组件
class CategorySection extends StatelessWidget {
  /// 标题
  final String title;

  /// 项目列表
  final List<Map<String, dynamic>> items;

  /// 项目构建器
  final Widget Function(Map<String, dynamic>) itemBuilder;

  /// 构造函数
  const CategorySection({
    super.key,
    required this.title,
    required this.items,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              return itemBuilder(items[index]);
            },
          ),
        ),
      ],
    );
  }
}

/// 分类项组件
class CategoryItem extends StatelessWidget {
  /// 名称
  final String name;

  /// 图标
  final IconData icon;

  /// 点击回调
  final VoidCallback onTap;

  /// 背景颜色
  final Color? backgroundColor;

  /// 图标颜色
  final Color? iconColor;

  /// 构造函数
  const CategoryItem({
    super.key,
    required this.name,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      margin: const EdgeInsets.only(right: 16),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: backgroundColor ?? AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(
                fontSize: 12,
                color: CupertinoColors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}