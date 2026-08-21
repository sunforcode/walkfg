import 'package:flutter/cupertino.dart';
import 'package:walk/model/route/route_model.dart';
import 'package:walk/theme/tokens/colors.dart';

/// 段 2：路线概览 (PRD §3.3.2)
///
/// 段标题"📍 路线概览"；评分行；标签行；描述（3行折叠/展开）；
/// 实用信息（交通·信号）；指标摘要
class RouteOverviewWidget extends StatefulWidget {
  final RouteModel route;

  const RouteOverviewWidget({super.key, required this.route});

  @override
  State<RouteOverviewWidget> createState() => _RouteOverviewWidgetState();
}

class _RouteOverviewWidgetState extends State<RouteOverviewWidget> {
  bool _descriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 段标题 "📍 路线概览"
        const _SectionTitle(),

        const SizedBox(height: 12),

        // 评分行 (⭐ + 评分值 + 评价人数)
        _RatingRow(rating: widget.route.rating, reviewCount: widget.route.ratings?.ratingCount ?? 0),

        const SizedBox(height: 10),

        // 标签行 (圆角药丸, 12px, rgba(0,0,0,.05)底, #555字)
        _TagChips(tags: widget.route.tags),

        const SizedBox(height: 12),

        // 指标摘要行 (距离·用时·爬升·下降)
        _MetricsSummary(route: widget.route),

        // 路线描述 (14px, #555, 行高1.7, 超3行截断+展开)
        if (widget.route.description.isNotEmpty) ...[
          const SizedBox(height: 12),
          _DescriptionBlock(
            text: widget.route.description,
            expanded: _descriptionExpanded,
            onToggle: () => setState(() => _descriptionExpanded = !_descriptionExpanded),
          ),
        ],

        // 实用信息行 (交通 + 信号)
        if (_hasPracticalInfo()) ...[
          const SizedBox(height: 12),
          _PracticalInfoRow(route: widget.route),
        ],
      ],
    );
  }

  bool _hasPracticalInfo() {
    final r = widget.route;
    return (r.trafficInfo != null && r.trafficInfo!.isNotEmpty) ||
        (r.signalInfo != null && r.signalInfo!.isNotEmpty);
  }
}

// ---------------------------------------------------------------------------
//  段标题 "📍 路线概览"
// ---------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  const _SectionTitle();

  @override
  Widget build(BuildContext context) {
    return const Text(
      '📍 路线概览',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.sheetTextPrimary,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  评分行: ⭐ 4.8 (128)
// ---------------------------------------------------------------------------

class _RatingRow extends StatelessWidget {
  final double rating;
  final int reviewCount;

  const _RatingRow({required this.rating, required this.reviewCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('⭐', style: TextStyle(fontSize: 14)),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.sheetTextPrimary,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '($reviewCount)',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.sheetTextSecondary,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
//  标签行: 圆角药丸 12px, rgba(0,0,0,.05) 底, #555 字
// ---------------------------------------------------------------------------

class _TagChips extends StatelessWidget {
  final List<String> tags;
  const _TagChips({required this.tags});

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.take(6).map((tag) => _TagPill(text: tag)).toList(),
    );
  }
}

class _TagPill extends StatelessWidget {
  final String text;
  const _TagPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.sheetTagBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.sheetTextTag,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  指标摘要行: 距离 · 用时 · 爬升 · 下降
// ---------------------------------------------------------------------------

class _MetricsSummary extends StatelessWidget {
  final RouteModel route;
  const _MetricsSummary({required this.route});

  @override
  Widget build(BuildContext context) {
    final parts = <String>[
      '${route.distance.toStringAsFixed(1)}km',
      route.durationText,
      '↑${route.elevationGain.toInt()}m',
      '↓${route.elevationLoss.toInt()}m',
    ];

    return Text(
      parts.join(' · '),
      style: const TextStyle(
        fontSize: 13,
        color: AppColors.sheetTextSecondary,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  描述折叠/展开 (PRD: 14px, #555, 行高1.7, 超3行截断+"展开")
// ---------------------------------------------------------------------------

class _DescriptionBlock extends StatelessWidget {
  final String text;
  final bool expanded;
  final VoidCallback onToggle;

  const _DescriptionBlock({
    required this.text,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          firstChild: _CollapsedText(text: text, onExpand: onToggle),
          secondChild: _ExpandedText(text: text, onCollapse: onToggle),
          crossFadeState:
              expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
          sizeCurve: Curves.easeOut,
        ),
      ],
    );
  }
}

/// 折叠态：最多 3 行，尾部"展开"按钮
class _CollapsedText extends StatelessWidget {
  final String text;
  final VoidCallback onExpand;
  const _CollapsedText({required this.text, required this.onExpand});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.sheetTextTag,
            height: 1.7,
          ),
        ),
        // 仅当文本可能超3行时才显示"展开"
        if (text.length > 80)
          GestureDetector(
            onTap: onExpand,
            child: const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                '展开',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.brandStart,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// 展开态：全文 + "收起"
class _ExpandedText extends StatelessWidget {
  final String text;
  final VoidCallback onCollapse;
  const _ExpandedText({required this.text, required this.onCollapse});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.sheetTextTag,
            height: 1.7,
          ),
        ),
        GestureDetector(
          onTap: onCollapse,
          child: const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              '收起',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.brandStart,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
//  实用信息行: 交通信息 · 信号信息
// ---------------------------------------------------------------------------

class _PracticalInfoRow extends StatelessWidget {
  final RouteModel route;
  const _PracticalInfoRow({required this.route});

  @override
  Widget build(BuildContext context) {
    final items = <_InfoItem>[];

    if (route.trafficInfo != null && route.trafficInfo!.isNotEmpty) {
      items.add(_InfoItem(icon: CupertinoIcons.bus, text: route.trafficInfo!));
    }
    if (route.signalInfo != null && route.signalInfo!.isNotEmpty) {
      items.add(_InfoItem(icon: CupertinoIcons.antenna_radiowaves_left_right, text: route.signalInfo!));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Row(
      children: items
          .expand((item) => [
                _InfoChip(item: item),
                const SizedBox(width: 10),
              ])
          .toList()
        ..removeLast(),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String text;
  const _InfoItem({required this.icon, required this.text});
}

class _InfoChip extends StatelessWidget {
  final _InfoItem item;
  const _InfoChip({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(item.icon, size: 14, color: AppColors.sheetTextSecondary),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            item.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.sheetTextSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
