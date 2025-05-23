import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider, Colors;
import 'package:walk/model/trip/trip_day_plan_model.dart';

class TripItineraryWidget extends StatefulWidget {
  final List<TripDayPlanModel> itinerary;

  const TripItineraryWidget({
    super.key,
    required this.itinerary,
  });

  @override
  State<TripItineraryWidget> createState() => _TripItineraryWidgetState();
}

class _TripItineraryWidgetState extends State<TripItineraryWidget> {
  bool _isExpanded = false;
  List<bool> _dayExpanded = [];

  @override
  void initState() {
    super.initState();
    _initDayExpandedState();
  }

  @override
  void didUpdateWidget(TripItineraryWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itinerary != widget.itinerary) {
      _initDayExpandedState();
    }
  }

  void _initDayExpandedState() {
    _dayExpanded = List.generate(widget.itinerary.length, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itinerary.isEmpty) {
      return const Text(
        '暂无行程安排',
        style: TextStyle(
          fontSize: 16,
          color: CupertinoColors.systemGrey,
        ),
      );
    }

    return _buildItineraryCard();
  }

  Widget _buildItineraryCard() {
    // 计算总距离、总爬升和总时间
    double totalDistance = 0;
    int totalElevationGain = 0;
    double totalTime = 0;

    for (final day in widget.itinerary) {
      totalDistance += day.distance;
      totalElevationGain += day.elevationGain;
      totalTime += day.estimatedTime;
    }

    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题和展开/折叠按钮
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: _isExpanded
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      )
                    : BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题行
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: CupertinoColors.activeBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          CupertinoIcons.map_fill,
                          color: CupertinoColors.activeBlue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          '行程安排',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey6,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: CupertinoColors.systemGrey4,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          _isExpanded
                              ? CupertinoIcons.chevron_up
                              : CupertinoIcons.chevron_down,
                          color: CupertinoColors.systemGrey,
                          size: 16,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 关键数据行
                  Row(
                    children: [
                      Expanded(
                        child: _buildKeyMetric(
                          label: '总天数',
                          value: '${widget.itinerary.length}天',
                          icon: CupertinoIcons.calendar,
                        ),
                      ),
                      Expanded(
                        child: _buildKeyMetric(
                          label: '总距离',
                          value: '${totalDistance.toStringAsFixed(1)}km',
                          icon: CupertinoIcons.location_fill,
                        ),
                      ),
                      Expanded(
                        child: _buildKeyMetric(
                          label: '总爬升',
                          value: '${totalElevationGain}m',
                          icon: CupertinoIcons.arrow_up_right_square_fill,
                        ),
                      ),
                      Expanded(
                        child: _buildKeyMetric(
                          label: '总时间',
                          value: _formatTime(totalTime),
                          icon: CupertinoIcons.time_solid,
                        ),
                      ),
                    ],
                  ),

                  if (!_isExpanded && widget.itinerary.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    // 简短路线预览
                    Row(
                      children: [
                        ...widget.itinerary
                            .map((day) => _buildDayCircle(day))
                            .toList(),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // 展开的详细内容
          if (_isExpanded) ...[
            Container(
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  // 详细内容
                  _buildDetailedContentContainer(),

                  // 收起按钮
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isExpanded = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey6,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '点击收起详情',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: CupertinoColors.activeBlue
                                      .withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                CupertinoIcons.chevron_up,
                                size: 12,
                                color:
                                    CupertinoColors.activeBlue.withOpacity(0.8),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailedContentContainer() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: _buildDetailedContent(),
        ),
      ),
    );
  }

  Widget _buildDayCircle(TripDayPlanModel day) {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 2,
              color: day.day == 1
                  ? Colors.transparent
                  : CupertinoColors.activeBlue.withOpacity(0.3),
            ),
          ),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: CupertinoColors.activeBlue,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.activeBlue.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${day.day}',
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 2,
              color: day.day == widget.itinerary.length
                  ? Colors.transparent
                  : CupertinoColors.activeBlue.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetric({
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: CupertinoColors.systemGrey,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor ?? CupertinoColors.activeBlue,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDetailedContent() {
    return [
      // 每日行程
      ...List.generate(
        widget.itinerary.length,
        (index) => _buildDayItineraryCollapsible(
          widget.itinerary[index],
          index,
        ),
      ),
    ];
  }

  Widget _buildDayItineraryCollapsible(TripDayPlanModel day, int index) {
    final isLast = index == widget.itinerary.length - 1;

    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        border: !isLast
            ? Border(
                bottom: BorderSide(
                  color: CupertinoColors.systemGrey5,
                  width: 0.5,
                ),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 可点击的日期标题
          GestureDetector(
            onTap: () {
              setState(() {
                _dayExpanded[index] = !_dayExpanded[index];
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: CupertinoColors.activeBlue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.activeBlue.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          day.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${day.startPoint} → ${day.endPoint}',
                          style: TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.systemGrey.darkColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: CupertinoColors.systemGrey4,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      _dayExpanded[index]
                          ? CupertinoIcons.chevron_up
                          : CupertinoIcons.chevron_down,
                      size: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 展开时显示详情
          if (_dayExpanded[index]) ...[
            Container(
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              padding: const EdgeInsets.only(left: 28),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: CupertinoColors.activeBlue.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // 行程描述
                  Text(
                    day.description,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 行程数据
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.systemGrey.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildItineraryInfoItem(
                              CupertinoIcons.location,
                              '距离: ${day.distance.toStringAsFixed(1)}km',
                            ),
                            _buildItineraryInfoItem(
                              CupertinoIcons.arrow_up,
                              '爬升: ${day.elevationGain}m',
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildItineraryInfoItem(
                              CupertinoIcons.arrow_down,
                              '下降: ${day.elevationLoss}m',
                            ),
                            _buildItineraryInfoItem(
                              CupertinoIcons.time,
                              '预计时间: ${_formatTime(day.estimatedTime)}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 备注
                  if (day.notes != null && day.notes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemYellow.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: CupertinoColors.systemYellow.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color:
                                  CupertinoColors.systemYellow.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              CupertinoIcons.info_circle_fill,
                              size: 16,
                              color: CupertinoColors.systemYellow,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              day.notes!,
                              style: TextStyle(
                                fontSize: 14,
                                color: CupertinoColors.systemGrey.darkColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItineraryInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: CupertinoColors.activeBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 14,
            color: CupertinoColors.activeBlue,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: CupertinoColors.systemGrey.darkColor,
          ),
        ),
      ],
    );
  }

  String _formatTime(double hours) {
    final int wholeHours = hours.floor();
    final int minutes = ((hours - wholeHours) * 60).round();

    if (wholeHours > 0) {
      return '$wholeHours小时${minutes > 0 ? ' $minutes分钟' : ''}';
    } else {
      return '$minutes分钟';
    }
  }
}
