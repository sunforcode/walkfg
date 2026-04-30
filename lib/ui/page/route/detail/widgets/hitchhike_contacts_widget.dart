import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:walk/model/route/hitchhike_contact_model.dart';

/// 搭车联系方式Widget（横向滑动）
class HitchhikeContactsWidget extends StatelessWidget {
  final List<HitchhikeContactModel> contacts;

  const HitchhikeContactsWidget({
    super.key,
    required this.contacts,
  });

  @override
  Widget build(BuildContext context) {
    if (contacts.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              const Icon(
                CupertinoIcons.car,
                size: 16,
                color: CupertinoColors.systemPurple,
              ),
              const SizedBox(width: 6),
              const Text(
                '搭车联系',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.label,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${contacts.length}个',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemPurple,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 横向列表
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: contacts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) => _buildCard(context, contacts[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, HitchhikeContactModel contact) {
    return Container(
      width: 210,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头像图标 + 名称 + 认证
          Row(
            children: [
              const Icon(
                CupertinoIcons.person_circle_fill,
                size: 28,
                color: CupertinoColors.systemPurple,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  contact.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.checkmark_seal,
                        size: 10, color: CupertinoColors.systemGreen),
                    SizedBox(width: 2),
                    Text(
                      '已认证',
                      style: TextStyle(
                        fontSize: 10,
                        color: CupertinoColors.systemGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 描述
          if (contact.description != null)
            Text(
              contact.description!,
              style: const TextStyle(
                fontSize: 12,
                color: CupertinoColors.secondaryLabel,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

          const Spacer(),

          // 电话 + 复制
          Row(
            children: [
              const Icon(CupertinoIcons.phone,
                  size: 13, color: CupertinoColors.systemBlue),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  contact.phone,
                  style: const TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.systemBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 0,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: contact.phone));
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '复制',
                    style: TextStyle(
                      fontSize: 11,
                      color: CupertinoColors.systemBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // 位置 + 价格
          Row(
            children: [
              if (contact.location != null) ...[
                const Icon(CupertinoIcons.location,
                    size: 11, color: CupertinoColors.systemGrey),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    contact.location!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: CupertinoColors.secondaryLabel,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              if (contact.price != null) ...[
                const Icon(CupertinoIcons.money_yen_circle,
                    size: 11, color: CupertinoColors.systemOrange),
                const SizedBox(width: 2),
                Text(
                  '¥${contact.price!.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: CupertinoColors.systemOrange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
