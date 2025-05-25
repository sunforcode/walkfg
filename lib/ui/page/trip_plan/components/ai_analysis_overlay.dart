import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/theme/theme/app_colors.dart';

/// AI分析悬浮层组件
class AIAnalysisOverlay extends StatelessWidget {
  /// 分析状态
  final String status;

  /// 分析进度 (0.0 - 1.0)
  final double progress;

  /// 分析步骤列表
  final List<String> steps;

  /// 构造函数
  const AIAnalysisOverlay({
    Key? key,
    required this.status,
    required this.progress,
    required this.steps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: CupertinoColors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // AI 思考动画
                const SizedBox(
                  width: 80,
                  height: 80,
                  child: CupertinoActivityIndicator(radius: 20),
                ),

                const SizedBox(height: 16),

                // 状态文本
                Text(
                  status,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // 步骤列表
                ...steps.map((step) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.circle_fill, size: 8),
                          const SizedBox(width: 8),
                          Text(step),
                        ],
                      ),
                    )),

                const SizedBox(height: 16),

                // 进度条
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: CupertinoColors.systemGrey5,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // 剩余时间
                Text(
                  '预计剩余时间: ${(30 * (1 - progress)).round()}秒',
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
