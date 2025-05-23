import 'package:flutter/cupertino.dart';
import 'package:walk/model/user/user_model.dart';

class TripParticipantsWidget extends StatefulWidget {
  final List<UserModel> participants;

  const TripParticipantsWidget({
    super.key,
    required this.participants,
  });

  @override
  State<TripParticipantsWidget> createState() => _TripParticipantsWidgetState();
}

class _TripParticipantsWidgetState extends State<TripParticipantsWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.participants.isEmpty) {
      return const Text(
        '暂无参与者',
        style: TextStyle(
          fontSize: 16,
          color: CupertinoColors.systemGrey,
        ),
      );
    }

    return _buildParticipantsCard();
  }

  Widget _buildParticipantsCard() {
    // 计算组织者数量和普通参与者数量
    final count = widget.participants.length;

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
                          color: CupertinoColors.systemPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          CupertinoIcons.person_3_fill,
                          color: CupertinoColors.systemPurple,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          '行程参与者',
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
                          label: '总人数',
                          value: '${count}人',
                          icon: CupertinoIcons.person_2_fill,
                        ),
                      ),
                    ],
                  ),

                  if (!_isExpanded && widget.participants.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    // 简短预览
                    Row(
                      children: [
                        ...widget.participants
                            .take(3)
                            .map((p) => _buildAvatarCircle(p)),
                        if (widget.participants.length > 3) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemGrey5,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: CupertinoColors.systemGrey
                                      .withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '+${widget.participants.length - 3}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
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
                                  color: CupertinoColors.systemPurple
                                      .withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                CupertinoIcons.chevron_up,
                                size: 12,
                                color: CupertinoColors.systemPurple
                                    .withOpacity(0.8),
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

  Widget _buildAvatarCircle(UserModel participant) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey5,
          shape: BoxShape.circle,
          image: participant.avatarUrl != null
              ? DecorationImage(
                  image: NetworkImage(participant.avatarUrl!),
                  fit: BoxFit.cover,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: participant.avatarUrl == null
            ? Center(
                child: Text(
                  participant.nickname.isNotEmpty
                      ? participant.nickname.substring(0, 1)
                      : participant.username.substring(0, 1),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
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
            color: valueColor ?? CupertinoColors.systemPurple,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDetailedContent() {
    return [
      // 参与者列表
      ...widget.participants
          .map((participant) => _buildParticipantItem(participant))
          .toList(),
    ];
  }

  Widget _buildParticipantItem(UserModel participant) {
    final isLast = widget.participants.indexOf(participant) ==
        widget.participants.length - 1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          // 头像
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey5,
              shape: BoxShape.circle,
              image: participant.avatarUrl != null
                  ? DecorationImage(
                      image: NetworkImage(participant.avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.systemGrey.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: participant.avatarUrl == null
                ? Center(
                    child: Text(
                      participant.nickname.isNotEmpty
                          ? participant.nickname.substring(0, 1)
                          : participant.username.substring(0, 1),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
          ),

          const SizedBox(width: 16),

          // 参与者信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        participant.nickname.isNotEmpty
                            ? participant.nickname
                            : participant.username,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildParticipantInfoItem(
                      CupertinoIcons.map_fill,
                      '完成路线: ${participant.completedRoutes}',
                    ),
                    const SizedBox(width: 16),
                    _buildParticipantInfoItem(
                      CupertinoIcons.bag_fill,
                      '装备清单: ${participant.equipmentLists}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: CupertinoColors.systemPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 14,
            color: CupertinoColors.systemPurple,
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
}
