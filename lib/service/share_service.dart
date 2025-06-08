import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../model/trip/trip_model.dart';
import '../ui/widget/share_card_widget.dart';

/// 分享服务类
class ShareService {
  /// 分享行程卡片
  Future<void> shareTripCard({
    required BuildContext context,
    required TripModel trip,
    ShareType shareType = ShareType.image,
  }) async {
    try {
      switch (shareType) {
        case ShareType.image:
          await _shareAsImage(context, trip);
          break;
        case ShareType.text:
          await _shareAsText(trip);
          break;
        case ShareType.both:
          await _shareImageWithText(context, trip);
          break;
      }
    } catch (e) {
      print('分享失败: $e');
      // 可以显示错误提示
      _showErrorDialog(context, '分享失败，请稍后重试');
    }
  }

  /// 以图片形式分享
  Future<void> _shareAsImage(BuildContext context, TripModel trip) async {
    // 创建分享卡片组件
    final shareCard = ShareCardWidget(trip: trip);

    // 显示卡片预览对话框
    final shouldShare = await _showSharePreview(context, shareCard);
    if (!shouldShare) return;

    // 生成图片
    final imageBytes = await shareCard.generateShareImage();
    if (imageBytes == null) {
      throw Exception('生成分享图片失败');
    }

    // 保存到临时文件
    final tempDir = await getTemporaryDirectory();
    final file = File(
        '${tempDir.path}/trip_share_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(imageBytes);

    // 分享图片
    await Share.shareXFiles(
      [XFile(file.path)],
      text: _generateShareText(trip),
      subject: '我的徒步计划 - ${trip.name}',
    );

    // 清理临时文件
    try {
      await file.delete();
    } catch (e) {
      print('清理临时文件失败: $e');
    }
  }

  /// 以文本形式分享
  Future<void> _shareAsText(TripModel trip) async {
    final text = _generateDetailedShareText(trip);
    await Share.share(
      text,
      subject: '我的徒步计划 - ${trip.name}',
    );
  }

  /// 图片和文本一起分享
  Future<void> _shareImageWithText(BuildContext context, TripModel trip) async {
    final shareCard = ShareCardWidget(trip: trip);

    // 显示卡片预览
    final shouldShare = await _showSharePreview(context, shareCard);
    if (!shouldShare) return;

    // 生成图片
    final imageBytes = await shareCard.generateShareImage();
    if (imageBytes == null) {
      throw Exception('生成分享图片失败');
    }

    // 保存到临时文件
    final tempDir = await getTemporaryDirectory();
    final file = File(
        '${tempDir.path}/trip_share_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(imageBytes);

    // 分享图片和文本
    await Share.shareXFiles(
      [XFile(file.path)],
      text: _generateDetailedShareText(trip),
      subject: '我的徒步计划 - ${trip.name}',
    );

    // 清理临时文件
    try {
      await file.delete();
    } catch (e) {
      print('清理临时文件失败: $e');
    }
  }

  /// 显示分享预览对话框
  Future<bool> _showSharePreview(
      BuildContext context, ShareCardWidget shareCard) async {
    return await showCupertinoDialog<bool>(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('分享预览'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                Container(
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: SingleChildScrollView(
                    child: Transform.scale(
                      scale: 0.8,
                      child: shareCard,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '确定要分享这张卡片吗？',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text('取消'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text('分享'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// 生成简单的分享文本
  String _generateShareText(TripModel trip) {
    final duration = trip.endDate.difference(trip.startDate).inDays + 1;
    return '我计划进行一次徒步旅行：${trip.name}，时间：${_formatDate(trip.startDate)} - ${_formatDate(trip.endDate)}，共${duration}天。来自Walk徒步助手。';
  }

  /// 生成详细的分享文本
  String _generateDetailedShareText(TripModel trip) {
    final buffer = StringBuffer();
    final duration = trip.endDate.difference(trip.startDate).inDays + 1;

    buffer.writeln('🏔️ 我的徒步计划');
    buffer.writeln('');
    buffer.writeln('📍 行程名称：${trip.name}');
    buffer.writeln(
        '📅 出行时间：${_formatDate(trip.startDate)} - ${_formatDate(trip.endDate)}');
    buffer.writeln('⏰ 行程天数：${duration}天');
    buffer.writeln('👥 参与人数：${trip.participantCount}人');
    buffer.writeln('📊 行程状态：${trip.getStatusName()}');

    if (trip.routeIds.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('🗺️ 路线信息：');
      buffer.writeln('   已选择 ${trip.routeIds.length} 条路线');
    }

    if (trip.description.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('📝 行程描述：${trip.description}');
    }

    // 装备信息
    if (trip.hasEquipmentList()) {
      final equipmentList = trip.getEquipmentList();
      final totalWeight = equipmentList?.totalWeight ?? 0;
      buffer.writeln('');
      buffer.writeln('🎒 装备总重：${(totalWeight / 1000).toStringAsFixed(1)} kg');
    }

    // 预算信息
    if (trip.budget != null) {
      buffer.writeln('');
      buffer.writeln('💰 预算：${trip.budget!.toStringAsFixed(0)}元');
    }

    buffer.writeln('');
    buffer.writeln('📱 来自Walk - 徒步旅行助手');

    return buffer.toString();
  }

  /// 显示错误对话框
  void _showErrorDialog(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('分享失败'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('确定'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  /// 分享路线信息
  Future<void> shareRoute({
    required String routeName,
    required String routeDescription,
    double? distance,
    double? elevation,
    String? difficulty,
  }) async {
    final buffer = StringBuffer();

    buffer.writeln('🏔️ 推荐一条徒步路线');
    buffer.writeln('');
    buffer.writeln('📍 路线名称：$routeName');
    buffer.writeln('📝 路线描述：$routeDescription');

    if (distance != null) {
      buffer.writeln('📏 徒步距离：${distance.toStringAsFixed(1)} km');
    }
    if (elevation != null) {
      buffer.writeln('⛰️ 爬升高度：${elevation.toStringAsFixed(0)} m');
    }
    if (difficulty != null) {
      buffer.writeln('⭐ 难度等级：$difficulty');
    }

    buffer.writeln('');
    buffer.writeln('📱 来自Walk - 徒步旅行助手');

    await Share.share(
      buffer.toString(),
      subject: '徒步路线推荐 - $routeName',
    );
  }

  /// 分享装备清单
  Future<void> shareEquipmentList({
    required String listName,
    required List<String> equipmentItems,
    double? totalWeight,
  }) async {
    final buffer = StringBuffer();

    buffer.writeln('🎒 我的装备清单');
    buffer.writeln('');
    buffer.writeln('📝 清单名称：$listName');

    if (totalWeight != null) {
      buffer.writeln('⚖️ 总重量：${totalWeight.toStringAsFixed(1)} kg');
    }

    buffer.writeln('');
    buffer.writeln('📋 装备明细：');
    for (int i = 0; i < equipmentItems.length; i++) {
      buffer.writeln('${i + 1}. ${equipmentItems[i]}');
    }

    buffer.writeln('');
    buffer.writeln('📱 来自Walk - 徒步旅行助手');

    await Share.share(
      buffer.toString(),
      subject: '装备清单 - $listName',
    );
  }

  /// 创建自定义分享卡片
  Future<void> shareCustomCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Map<String, String> details,
    String? imagePath,
  }) async {
    try {
      final buffer = StringBuffer();

      buffer.writeln('📱 $title');
      if (subtitle.isNotEmpty) {
        buffer.writeln(subtitle);
      }
      buffer.writeln('');

      details.forEach((key, value) {
        buffer.writeln('$key：$value');
      });

      buffer.writeln('');
      buffer.writeln('📱 来自Walk - 徒步旅行助手');

      if (imagePath != null && File(imagePath).existsSync()) {
        await Share.shareXFiles(
          [XFile(imagePath)],
          text: buffer.toString(),
          subject: title,
        );
      } else {
        await Share.share(
          buffer.toString(),
          subject: title,
        );
      }
    } catch (e) {
      print('自定义分享失败: $e');
      _showErrorDialog(context, '分享失败，请稍后重试');
    }
  }

  /// 获取分享统计信息
  Map<String, int> getShareStats() {
    // 这里可以集成分析服务来跟踪分享统计
    return {
      'total_shares': 0,
      'image_shares': 0,
      'text_shares': 0,
      'route_shares': 0,
      'equipment_shares': 0,
    };
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}

/// 分享类型枚举
enum ShareType {
  image, // 仅图片
  text, // 仅文本
  both, // 图片和文本
}
