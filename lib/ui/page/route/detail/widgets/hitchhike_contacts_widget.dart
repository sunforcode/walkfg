import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:walk/model/route/hitchhike_contact_model.dart';

/// 搭车联系方式Widget
class HitchhikeContactsWidget extends StatefulWidget {
  final List<HitchhikeContactModel> contacts;

  const HitchhikeContactsWidget({
    super.key,
    required this.contacts,
  });

  @override
  State<HitchhikeContactsWidget> createState() =>
      _HitchhikeContactsWidgetState();
}

class _HitchhikeContactsWidgetState extends State<HitchhikeContactsWidget> {
  bool _showAll = false;
  static const int _maxDisplayCount = 3;

  @override
  Widget build(BuildContext context) {
    if (widget.contacts.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayContacts = _showAll
        ? widget.contacts
        : widget.contacts.take(_maxDisplayCount).toList();
    final hasMore = widget.contacts.length > _maxDisplayCount;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              const Icon(
                CupertinoIcons.car,
                size: 20,
                color: CupertinoColors.systemPurple,
              ),
              const SizedBox(width: 8),
              const Text(
                '搭车联系方式',
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
                  '${widget.contacts.length}个',
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

          // 联系方式列表
          ...displayContacts.map((contact) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildContactCard(contact),
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
                      '查看更多联系方式',
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemPurple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${widget.contacts.length - _maxDisplayCount}个)',
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
        ],
      ),
    );
  }

  /// 构建联系方式卡片
  Widget _buildContactCard(HitchhikeContactModel contact) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              const Icon(
                CupertinoIcons.person_circle,
                size: 20,
                color: CupertinoColors.systemPurple,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  contact.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.checkmark_seal,
                      size: 12,
                      color: CupertinoColors.systemGreen,
                    ),
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

          if (contact.description != null) ...[
            const SizedBox(height: 8),
            Text(
              contact.description!,
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
          ],

          const SizedBox(height: 12),

          // 联系信息
          Row(
            children: [
              // 电话号码
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.phone,
                      size: 14,
                      color: CupertinoColors.systemBlue,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        contact.phone,
                        style: const TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.systemBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 复制按钮
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minSize: 0,
                onPressed: () => _copyPhone(contact.phone),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '复制',
                    style: TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 位置和价格信息
          Row(
            children: [
              if (contact.location != null) ...[
                const Icon(
                  CupertinoIcons.location,
                  size: 14,
                  color: CupertinoColors.systemGrey,
                ),
                const SizedBox(width: 4),
                Text(
                  contact.location!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.label,
                  ),
                ),
              ],
              if (contact.location != null && contact.price != null)
                const SizedBox(width: 16),
              if (contact.price != null) ...[
                const Icon(
                  CupertinoIcons.money_yen_circle,
                  size: 14,
                  color: CupertinoColors.systemOrange,
                ),
                const SizedBox(width: 4),
                Text(
                  '¥${contact.price!.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemOrange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),

          // 提醒信息
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CupertinoColors.systemYellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  CupertinoIcons.exclamationmark_triangle,
                  size: 14,
                  color: CupertinoColors.systemYellow,
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '请注意安全，建议多人同行，提前确认价格和路线',
                    style: TextStyle(
                      fontSize: 11,
                      color: CupertinoColors.label,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 复制电话号码
  void _copyPhone(String phone) {
    Clipboard.setData(ClipboardData(text: phone));
    // 这里可以添加Toast提示
  }
}
