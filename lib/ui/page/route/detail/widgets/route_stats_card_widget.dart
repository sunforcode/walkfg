import 'package:flutter/cupertino.dart';
import 'package:walk/model/route/route_enums.dart';
import 'package:walk/model/route/route_model.dart';
import 'package:walk/theme/tokens/colors.dart';

/// 段 1：路线统计卡片 (PRD §3.3.1)
///
/// 路线名 22px/800 居中 → 区域+难度徽标 13px → 距离 32px/800 → 三指标行
class RouteStatsCardWidget extends StatelessWidget {
  final RouteModel route;
  final double? height;

  const RouteStatsCardWidget({
    super.key,
    required this.route,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final track = route.defaultMap;
    final distance = track?.distance ?? route.distance;
    final duration = track?.getEstimatedTimeText() ?? route.durationText;
    final elevGain = track?.elevationGain.toInt() ?? route.elevationGain.toInt();
    final elevLoss = track?.elevationLoss.toInt() ?? route.elevationLoss.toInt();

    return SizedBox(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 路线名 (PRD: 22px/800 居中)
          _RouteName(name: route.name),

          const SizedBox(height: 6),

          // 区域 + 难度徽标 (PRD: 13px 居中，难度橙底徽标)
          _RegionBadge(region: route.region, difficulty: route.difficulty),

          const SizedBox(height: 20),

          // 距离 (PRD: 32px/800 居中，km 单位 14px/400 灰色)
          _DistanceRow(distance: distance),

          const SizedBox(height: 24),

          // 三指标行 (PRD: 18px/700 + 11px 标签，gap 24px)
          _MetricsRow(
            duration: duration,
            elevationGain: elevGain,
            elevationLoss: elevLoss,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  子组件拆分
// ---------------------------------------------------------------------------

/// 路线名称
class _RouteName extends StatelessWidget {
  final String name;
  const _RouteName({required this.name});

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.sheetTextPrimary,
        height: 1.2,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// 区域 + 难度徽标
class _RegionBadge extends StatelessWidget {
  final String region;
  final RouteDifficulty difficulty;
  const _RegionBadge({required this.region, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          CupertinoIcons.location_solid,
          size: 12,
          color: AppColors.sheetTextSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          region,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.sheetTextSecondary,
          ),
        ),
        const SizedBox(width: 10),
        _DifficultyPill(difficulty: difficulty),
      ],
    );
  }
}

/// 难度徽标 (圆角药丸，难度色底)
class _DifficultyPill extends StatelessWidget {
  final RouteDifficulty difficulty;
  const _DifficultyPill({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final color = difficulty.getColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        difficulty.getName(),
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// 距离主数字 + 单位
class _DistanceRow extends StatelessWidget {
  final double distance;
  const _DistanceRow({required this.distance});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          distance.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppColors.sheetTextPrimary,
          ),
        ),
        const SizedBox(width: 4),
        const Text(
          'km',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.sheetTextSecondary,
          ),
        ),
      ],
    );
  }
}

/// 用时 / 爬升 / 下降 三指标
class _MetricsRow extends StatelessWidget {
  final String duration;
  final int elevationGain;
  final int elevationLoss;

  const _MetricsRow({
    required this.duration,
    required this.elevationGain,
    required this.elevationLoss,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _MetricItem(label: '用时', value: duration),
        _MetricItem(label: '爬升', value: '$elevationGain m'),
        _MetricItem(label: '下降', value: '$elevationLoss m'),
      ],
    );
  }
}

/// 单个指标：值 + 标签
class _MetricItem extends StatelessWidget {
  final String label;
  final String value;

  const _MetricItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.sheetTextPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: AppColors.sheetTextWeak,
          ),
        ),
      ],
    );
  }
}
