import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/theme/app_colors.dart';

/// 行程标签页导航组件
class TripTabBar extends StatelessWidget {
  /// 标签页标题列表
  final List<String> tabTitles;
  
  /// 当前选中的标签页索引
  final int currentIndex;
  
  /// 标签页切换回调
  final ValueChanged<int> onTabChanged;
  
  /// 构造函数
  const TripTabBar({
    super.key,
    required this.tabTitles,
    required this.currentIndex,
    required this.onTabChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.systemGrey5,
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabTitles.length,
        itemBuilder: (context, index) {
          final isSelected = index == currentIndex;
          return CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => onTabChanged(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  tabTitles[index],
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : CupertinoColors.label,
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