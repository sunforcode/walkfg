import 'package:flutter/cupertino.dart';
import 'package:walk/model/trip/trip_model.dart';

/// 参与者展示组件
class TripParticipantsDisplayWidget extends StatelessWidget {
  final TripModel trip;

  const TripParticipantsDisplayWidget({
    super.key,
    required this.trip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CupertinoColors.separator,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: CupertinoColors.separator,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  '👥 参与者',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
                const Spacer(),
                Text(
                  '共${trip.participantCount}人',
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),

          // 参与者列表
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (trip.participants.isNotEmpty)
                  ..._buildParticipantsList()
                else
                  _buildEmptyState(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildParticipantsList() {
    // 模拟参与者数据
    final mockParticipants = [
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
    ];

    return mockParticipants.asMap().entries.map((entry) {
      final index = entry.key;
      final participant = entry.value;
      final isLast = index == mockParticipants.length - 1;
      final isConfirmed = participant['status'] == '已确认';
      final isOrganizer = participant['isOrganizer'] as bool;

      return Column(
        children: [
          Row(
            children: [
              // 头像
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isOrganizer
                      ? CupertinoColors.systemBlue.withOpacity(0.2)
                      : CupertinoColors.systemGrey6,
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
                        Text(
                          participant['experience'] as String,
                          style: const TextStyle(
                            fontSize: 13,
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '加入: ${participant['joinDate']}',
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
          if (!isLast) const SizedBox(height: 16),
        ],
      );
    }).toList();
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
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
}