import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 行程规划卡片组件
class TripPlanCard extends StatelessWidget {
  /// 卡片标题
  final String title;
  
  /// 卡片内容
  final Widget content;
  
  /// 编辑按钮回调
  final VoidCallback? onEdit;
  
  /// 构造函数
  const TripPlanCard({
    Key? key,
    required this.title,
    required this.content,
    this.onEdit,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (onEdit != null)
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Row(
                      children: [
                        Text('编辑', style: TextStyle(fontSize: 14)),
                        Icon(CupertinoIcons.chevron_right, size: 14),
                      ],
                    ),
                    onPressed: onEdit,
                  ),
              ],
            ),
          ),
          
          // 分割线
          const Divider(height: 1),
          
          // 内容区域
          Padding(
            padding: const EdgeInsets.all(16),
            child: content,
          ),
        ],
      ),
    );
  }
}