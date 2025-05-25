import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'error_widget.dart';
import 'empty_content_widget.dart';

/// 通用异步内容构建器组件
class AsyncContentBuilder<T> extends StatelessWidget {
  /// 异步数据源
  final Future<T> future;
  
  /// 内容构建器
  final Widget Function(BuildContext context, T data) builder;
  
  /// 加载状态构建器
  final Widget Function(BuildContext context)? loadingBuilder;
  
  /// 错误状态构建器
  final Widget Function(BuildContext context, String error)? errorBuilder;
  
  /// 空数据状态构建器
  final Widget Function(BuildContext context)? emptyBuilder;
  
  /// 判断数据是否为空的函数
  final bool Function(T data)? isEmpty;
  
  /// 重试回调
  final VoidCallback? onRetry;
  
  /// 构造函数
  const AsyncContentBuilder({
    super.key,
    required this.future,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.isEmpty,
    this.onRetry,
  });
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingBuilder?.call(context) ?? 
            const Center(child: CupertinoActivityIndicator());
        }
        
        if (snapshot.hasError) {
          return errorBuilder?.call(context, snapshot.error.toString()) ?? 
            ErrorMessageWidget(
              errorMessage: snapshot.error.toString(),
              onRetry: onRetry ?? () {},
              color: CupertinoColors.systemRed,
            );
        }
        
        final data = snapshot.data;
        if (data == null || (isEmpty != null && isEmpty!(data))) {
          return emptyBuilder?.call(context) ?? 
            const EmptyContentWidget(
              icon: CupertinoIcons.info,
              title: '暂无数据',
            );
        }
        
        return builder(context, data);
      },
    );
  }
}