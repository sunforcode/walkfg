import 'package:flutter/cupertino.dart';
import 'package:walk/model/user/user_model.dart';

class TripParticipantsWidget extends StatelessWidget {
  final List<UserModel> participants;

  const TripParticipantsWidget({
    super.key,
    required this.participants,
  });

  @override
  Widget build(BuildContext context) {
    if (participants.isEmpty) {
      return const Text(
        '暂无参与者',
        style: TextStyle(
          fontSize: 16,
          color: CupertinoColors.systemGrey,
        ),
      );
    }

    return Column(
      children: participants.map((participant) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              // 头像
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey5,
                  shape: BoxShape.circle,
                  image: participant.avatarUrl != null
                      ? DecorationImage(
                          image: NetworkImage(participant.avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
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

              const SizedBox(width: 12),

              // 参与者信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      participant.nickname.isNotEmpty
                          ? participant.nickname
                          : participant.username,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '完成路线: ${participant.completedRoutes}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ),

              // 装备清单数量
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: CupertinoColors.activeBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '装备清单: ${participant.equipmentLists}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.activeBlue,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
