import 'package:flutter/cupertino.dart';
import 'package:walk/model/user/user_model.dart';

/// 参与者管理组件
class TripParticipantsSummaryWidget extends StatelessWidget {
  final List<UserModel> participants;
  final int participantCount;
  final String organizerId;
  final Function() onManage;

  const TripParticipantsSummaryWidget({
    super.key,
    required this.participants,
    required this.participantCount,
    required this.organizerId,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    if (participants.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 统计信息
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: CupertinoIcons.person_2_fill,
                  title: '总人数',
                  value: '$participantCount人',
                  color: CupertinoColors.systemBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: CupertinoIcons.checkmark_circle_fill,
                  title: '已确认',
                  value: '${_getConfirmedCount()}人',
                  color: CupertinoColors.systemGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: CupertinoIcons.clock_fill,
                  title: '待确认',
                  value: '${_getPendingCount()}人',
                  color: CupertinoColors.systemOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 参与者列表
          const Text(
            '参与者列表',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 12),
          ..._buildParticipantItems(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(
            CupertinoIcons.person_2,
            size: 48,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无参与者',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '邀请朋友一起参加这次徒步之旅',
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.tertiaryLabel,
            ),
          ),
          const SizedBox(height: 16),
          CupertinoButton.filled(
            child: const Text('邀请参与者'),
            onPressed: onManage,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: CupertinoColors.secondaryLabel,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildParticipantItems() {
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

    return mockParticipants.map((participant) {
      final isConfirmed = participant['status'] == '已确认';
      final isOrganizer = participant['isOrganizer'] as bool;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
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
      );
    }).toList();
  }

  int _getConfirmedCount() {
    // 模拟确认人数
    return 2;
  }

  int _getPendingCount() {
    return participantCount - _getConfirmedCount();
  }
}
