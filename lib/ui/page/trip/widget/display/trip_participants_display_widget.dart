import 'package:flutter/cupertino.dart';
import 'package:walk/model/trip/trip_model.dart';

/// 参与者展示组件
class TripParticipantsDisplayWidget extends StatefulWidget {
  final TripModel trip;

  const TripParticipantsDisplayWidget({
    super.key,
    required this.trip,
  });

  @override
  State<TripParticipantsDisplayWidget> createState() =>
      _TripParticipantsDisplayWidgetState();
}

class _TripParticipantsDisplayWidgetState
    extends State<TripParticipantsDisplayWidget> {
  bool _showAll = false;
  static const int _maxDisplayCount = 3;

  @override
  Widget build(BuildContext context) {
    // 模拟参与者数据
    final mockParticipants = _getMockParticipants();
    final displayParticipants = _showAll
        ? mockParticipants
        : mockParticipants.take(_maxDisplayCount).toList();
    final hasMore = mockParticipants.length > _maxDisplayCount;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              const Icon(
                CupertinoIcons.person_2,
                size: 20,
                color: CupertinoColors.systemPurple,
              ),
              const SizedBox(width: 8),
              const Text(
                '参与者',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.label,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.trip.participantCount}人',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemPurple,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 参与者列表
          if (mockParticipants.isNotEmpty) ...[
            ...displayParticipants.map((participant) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildParticipantCard(participant),
              );
            }).toList(),

            // 更多按钮
            if (hasMore && !_showAll)
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() {
                    _showAll = true;
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: CupertinoColors.separator,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '查看更多参与者',
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.systemPurple,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${mockParticipants.length - _maxDisplayCount}人)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        CupertinoIcons.chevron_down,
                        size: 16,
                        color: CupertinoColors.systemPurple,
                      ),
                    ],
                  ),
                ),
              ),
          ] else
            _buildEmptyState(),
        ],
      ),
    );
  }

  /// 构建参与者卡片
  Widget _buildParticipantCard(Map<String, dynamic> participant) {
    final isConfirmed = participant['status'] == '已确认';
    final isOrganizer = participant['isOrganizer'] as bool;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.separator,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          // 头像
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isOrganizer
                  ? CupertinoColors.systemBlue.withOpacity(0.2)
                  : CupertinoColors.systemGrey5,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Text(
                participant['avatar'] as String,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      participant['name'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.label,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isOrganizer)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemBlue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '组织者',
                          style: TextStyle(
                            fontSize: 10,
                            color: CupertinoColors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.star,
                      size: 12,
                      color: CupertinoColors.systemYellow,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      participant['experience'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      CupertinoIcons.calendar,
                      size: 12,
                      color: CupertinoColors.systemGrey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      participant['joinDate'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.tertiaryLabel,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 状态
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: isConfirmed
                  ? CupertinoColors.systemGreen.withOpacity(0.1)
                  : CupertinoColors.systemOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isConfirmed
                      ? CupertinoIcons.checkmark_circle_fill
                      : CupertinoIcons.clock_fill,
                  size: 12,
                  color: isConfirmed
                      ? CupertinoColors.systemGreen
                      : CupertinoColors.systemOrange,
                ),
                const SizedBox(width: 4),
                Text(
                  participant['status'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isConfirmed
                        ? CupertinoColors.systemGreen
                        : CupertinoColors.systemOrange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.separator,
          width: 0.5,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            CupertinoIcons.person_2,
            size: 48,
            color: CupertinoColors.systemGrey,
          ),
          SizedBox(height: 16),
          Text(
            '暂无参与者信息',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '邀请朋友一起参加这次徒步之旅',
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.tertiaryLabel,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMockParticipants() {
    return [
      {
        'name': '张三',
        'avatar': '👨‍💼',
        'role': '组织者',
        'status': '已确认',
        'joinDate': '2024-12-01',
        'experience': '资深驴友',
        'isOrganizer': true,
      },
      {
        'name': '李四',
        'avatar': '👩‍💻',
        'role': '参与者',
        'status': '已确认',
        'joinDate': '2024-12-02',
        'experience': '新手',
        'isOrganizer': false,
      },
      {
        'name': '王五',
        'avatar': '👨‍🎓',
        'role': '参与者',
        'status': '待确认',
        'joinDate': '2024-12-03',
        'experience': '有经验',
        'isOrganizer': false,
      },
      {
        'name': '赵六',
        'avatar': '👩‍🔬',
        'role': '参与者',
        'status': '已确认',
        'joinDate': '2024-12-04',
        'experience': '资深驴友',
        'isOrganizer': false,
      },
      {
        'name': '钱七',
        'avatar': '👨‍🎨',
        'role': '参与者',
        'status': '待确认',
        'joinDate': '2024-12-05',
        'experience': '新手',
        'isOrganizer': false,
      },
    ];
  }
}
