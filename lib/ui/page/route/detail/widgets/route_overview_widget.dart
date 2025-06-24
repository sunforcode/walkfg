import 'package:flutter/cupertino.dart';
import '../../../../../model/route/route_model.dart';

/// 路线概览组件
class RouteOverviewWidget extends StatelessWidget {
  /// 路线数据
  final RouteModel route;

  const RouteOverviewWidget({
    super.key,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题区域（路线名称 + 地区评分）
        _buildTitleSection(),

        const SizedBox(height: 12),

        // 标签云（紧贴标题下方）
        _buildTagsSection(),

        const SizedBox(height: 16),

        // 轨迹基本信息（文字版）
        _buildTrackBasicInfo(),
        const SizedBox(height: 16),

        // 整合描述（路线简介 + 实用信息 + 安全提醒）
        _buildIntegratedDescription(),
      ],
    );
  }

  /// 构建标题部分（现在只显示地区和评分，不显示路线名称）
  Widget _buildTitleSection() {
    return Row(
      children: [
        Icon(
          CupertinoIcons.location,
          size: 16,
          color: CupertinoColors.systemGrey,
        ),
        const SizedBox(width: 4),
        Text(
          route.region,
          style: const TextStyle(
            fontSize: 16,
            color: CupertinoColors.systemGrey,
          ),
        ),
        const SizedBox(width: 16),
        Icon(
          CupertinoIcons.star_fill,
          size: 16,
          color: CupertinoColors.systemYellow,
        ),
        const SizedBox(width: 4),
        Text(
          route.rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.label,
          ),
        ),
        Text(
          ' (${route.ratings?.ratingCount ?? 'null'})',
          style: const TextStyle(
            fontSize: 14,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
  }

  /// 构建标签部分（精简版）
  Widget _buildTagsSection() {
    final displayTags = _getDisplayTags();

    if (displayTags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: displayTags
          .map((tagInfo) => _buildTag(
                tagInfo['text'],
                tagInfo['color'],
                tagInfo['backgroundColor'],
              ))
          .toList(),
    );
  }

  /// 获取要显示的标签（最多6个，优先级排序）
  List<Map<String, dynamic>> _getDisplayTags() {
    final tags = <Map<String, dynamic>>[];

    // 1. 最佳季节（最高优先级，带emoji）
    if (route.weatherInfo?.bestSeasons != null &&
        !route.weatherInfo!.bestSeasons.isEmpty) {
      for (final season in route.weatherInfo!.bestSeasons.take(2)) {
        final emoji = _getSeasonEmoji(season);
        tags.add({
          'text': '$emoji$season',
          'color': CupertinoColors.systemGreen,
          'backgroundColor': CupertinoColors.systemGreen.withOpacity(0.1),
        });
      }
    }

    // 2. 特色标签（高优先级）
    final featureTags = route.tags?.take(2) ?? [];
    for (final tag in featureTags) {
      tags.add({
        'text': tag,
        'color': CupertinoColors.systemOrange,
        'backgroundColor': CupertinoColors.systemOrange.withOpacity(0.1),
      });
    }

    // 3. 路线标签（补充，最多2个）
    final remainingSlots = 6 - tags.length;
    if (remainingSlots > 0) {
      final routeTags = route.tags?.take(remainingSlots) ?? [];
      for (final tag in routeTags) {
        tags.add({
          'text': tag,
          'color': CupertinoColors.activeBlue,
          'backgroundColor': CupertinoColors.activeBlue.withOpacity(0.1),
        });
      }
    }

    return tags.take(6).toList();
  }

  /// 获取季节emoji
  String _getSeasonEmoji(String season) {
    switch (season) {
      case '春季':
        return '🌸';
      case '夏季':
        return '☀️';
      case '秋季':
        return '🍂';
      case '冬季':
        return '❄️';
      default:
        return '🌿';
    }
  }

  /// 构建标签
  Widget _buildTag(String text, Color textColor, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: textColor.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 构建轨迹基本信息（文字版）
  Widget _buildTrackBasicInfo() {
    final track = route.defaultMap;

    // 调试信息
    print('Route defaultMap: $track');

    if (track == null) {
      // 回退方案：使用route对象的计算属性
      return Text(
        '距离 ${route.distance.toStringAsFixed(1)}km · '
        '用时 ${route.duration} · '
        '爬升 ${route.elevationGain.toInt()}m · '
        '下降 ${route.elevationLoss.toInt()}m',
        style: const TextStyle(
          fontSize: 14,
          color: CupertinoColors.secondaryLabel,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    return Text(
      '距离 ${track.distance.toStringAsFixed(1)}km · '
      '用时 ${track.getEstimatedTimeText()} · '
      '爬升 ${track.elevationGain.toInt()}m · '
      '下降 ${track.elevationLoss.toInt()}m',
      style: const TextStyle(
        fontSize: 14,
        color: CupertinoColors.secondaryLabel,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// 构建整合描述
  Widget _buildIntegratedDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '路线描述',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.label,
          ),
        ),
        const SizedBox(height: 8),

        // 路线简介段落
        Text(
          route.description,
          style: const TextStyle(
            fontSize: 14,
            color: CupertinoColors.secondaryLabel,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 12),

        // 实用信息段落（自然语言描述）
        Text(
          _buildPracticalInfoText(),
          style: const TextStyle(
            fontSize: 14,
            color: CupertinoColors.secondaryLabel,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  /// 构建实用信息文本
  String _buildPracticalInfoText() {
    final buffer = StringBuffer();

    // 行程安排信息
    if (route.dailyPlans != null) {
      final totalTime =
          route.dailyPlans!.fold(0.0, (sum, plan) => sum + plan.estimatedTime);
      final avgTimePerDay = totalTime / route.dailyPlans!.length;

      buffer.write('行程安排：从${route.defaultMap?.startPoint}出发，');
      buffer.write('平均每天徒步${avgTimePerDay.toStringAsFixed(1)}小时，');

      if (route.dailyPlans!.length > 1) {
        buffer.write(
            '${route.dailyPlans!.length}天行程最终在${route.defaultMap?.endPoint}结束。');
      } else {
        buffer.write('当天在${route.defaultMap?.endPoint}结束。');
      }
    }

    // 住宿信息
    final accommodations = route.dailyPlans ??
        []
            .where((plan) =>
                plan.accommodation != null && plan.accommodation!.isNotEmpty)
            .map((plan) => plan.accommodation!)
            .toSet()
            .toList();

    if (accommodations.isNotEmpty) {
      buffer.write('沿途有${accommodations.join('、')}等住宿点，建议提前预订。');
    }

    return buffer.toString();
  }
}
