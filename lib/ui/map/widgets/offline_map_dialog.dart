import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 离线地图下载对话框
class OfflineMapDownloadDialog extends StatelessWidget {
  /// 是否正在加载
  final bool isLoading;

  /// 下载进度
  final double progress;

  /// 取消回调
  final VoidCallback? onCancel;

  /// 下载回调
  final VoidCallback? onDownload;

  /// 构造函数
  const OfflineMapDownloadDialog({
    super.key,
    required this.isLoading,
    required this.progress,
    this.onCancel,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CupertinoAlertDialog(
        title: const Text('下载离线地图'),
        content: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text('下载当前显示区域的离线地图，以便在无网络环境下使用。'),
            ),
            if (isLoading)
              Column(
                children: [
                  const SizedBox(height: 16),
                  const CupertinoActivityIndicator(),
                  const SizedBox(height: 8),
                  Text('下载中... ${(progress * 100).toStringAsFixed(0)}%'),
                ],
              ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('取消'),
            onPressed: onCancel,
          ),
          if (!isLoading)
            CupertinoDialogAction(
              child: const Text('下载'),
              onPressed: onDownload,
            ),
        ],
      ),
    );
  }
}