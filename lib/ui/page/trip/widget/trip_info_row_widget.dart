import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/theme/theme/app_colors.dart';

/// 行程信息行组件
///
/// 用于显示行程的基本信息，支持查看和编辑模式
class TripInfoRowWidget extends StatelessWidget {
  /// 标签
  final String label;

  /// 值
  final String value;

  /// 图标
  final IconData icon;

  /// 颜色
  final Color color;

  /// 是否处于编辑模式
  final bool isEditing;

  /// 值变更回调
  final ValueChanged<String>? onChanged;

  /// 点击回调（用于日期选择等）
  final VoidCallback? onTap;

  /// 构造函数
  const TripInfoRowWidget({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.isEditing = false,
    this.onChanged,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              if (isEditing && onChanged != null)
                CupertinoTextField(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: CupertinoColors.systemGrey4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  controller: TextEditingController(text: value),
                  onChanged: onChanged,
                )
              else if (isEditing && onTap != null)
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: CupertinoColors.systemGrey4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(value),
                        const Icon(
                          CupertinoIcons.chevron_down,
                          size: 16,
                          color: CupertinoColors.systemGrey,
                        ),
                      ],
                    ),
                  ),
                )
              else
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
