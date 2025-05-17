import 'package:flutter/material.dart';

/// 加载视图组件
class LoadingView extends StatelessWidget {
  /// 加载提示信息
  final String message;
  
  /// 构造函数
  const LoadingView({
    super.key,
    this.message = '加载中...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}