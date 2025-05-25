import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/theme/theme/app_colors.dart';

/// 行程卡片模板
/// 
/// 提供统一的卡片样式，包括标题栏、内容区域和底部按钮
class TripCardTemplate extends StatelessWidget {
  /// 卡片标题
  final String title;
  
  /// 标题图标
  final IconData icon;
  
  /// 卡片内容
  final Widget content;
  
  /// 按钮文本
  final String? buttonText;
  
  /// 按钮点击回调
  final VoidCallback? onButtonPressed;
  
  /// 警告文本
  final String? warningText;
  
  /// 信息文本
  final String? infoText;
  
  /// 是否使用主色调标题栏
  final bool usePrimaryHeader;
  
  /// 右侧操作按钮
  final Widget? actionButton;
  
  /// 构造函数
  const TripCardTemplate({
    Key? key,
    required this.title,
    required this.icon,
    required this.content,
    this.buttonText,
    this.onButtonPressed,
    this.warningText,
    this.infoText,
    this.usePrimaryHeader = false,
    this.actionButton,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // 根据usePrimaryHeader确定颜色
    final Color headerColor = usePrimaryHeader 
        ? AppColors.primary 
        : AppColors.primary.withOpacity(0.1);
    
    final Color headerTextColor = usePrimaryHeader 
        ? CupertinoColors.white 
        : AppColors.primary;
    
    final Color iconBackgroundColor = usePrimaryHeader 
        ? CupertinoColors.white 
        : AppColors.primary;
    
    final Color iconColor = usePrimaryHeader 
        ? AppColors.primary 
        : CupertinoColors.white;
    
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey5.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 卡片标题
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: headerTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                if (actionButton != null) actionButton!,
              ],
            ),
          ),

          // 卡片内容
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                content,
                
                // 警告文本
                if (warningText != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemYellow.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          CupertinoIcons.exclamationmark_triangle,
                          color: CupertinoColors.systemYellow,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            warningText!,
                            style: const TextStyle(
                              color: CupertinoColors.systemYellow,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // 信息文本
                if (infoText != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          CupertinoIcons.info_circle,
                          color: CupertinoColors.systemBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            infoText!,
                            style: const TextStyle(
                              color: CupertinoColors.systemBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // 按钮
                if (buttonText != null && onButtonPressed != null) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            CupertinoIcons.arrow_right,
                            color: CupertinoColors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            buttonText!,
                            style: const TextStyle(
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      onPressed: onButtonPressed,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}