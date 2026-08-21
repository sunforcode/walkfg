import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:walk/model/route/hitchhike_contact_model.dart';
import 'package:walk/theme/tokens/colors.dart';
import 'package:walk/utils/toast_utils.dart';

/// 拼车/包车联系方式组件 (PRD §3.3.9)
///
/// 段标题"🚗 拼车/包车"；横滑卡片：司机名 + 已认证徽标（绿底）、
/// 运营路线描述、元信息（地点·价格·"复制号码"）
class HitchhikeContactsWidget extends StatelessWidget {
  final List<HitchhikeContactModel> contacts;

  const HitchhikeContactsWidget({
    super.key,
    required this.contacts,
  });

  @override
  Widget build(BuildContext context) {
    if (contacts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(count: contacts.length),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: contacts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) =>
                _ContactCard(contact: contacts[index]),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
//  段标题："🚗 拼车/包车"
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final int count;
  const _SectionHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          '🚗 拼车/包车',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.sheetTextPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.badgeBlueBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count位',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.badgeBlueText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
//  联系人卡片：180px 宽，flat bg
// ---------------------------------------------------------------------------

class _ContactCard extends StatelessWidget {
  final HitchhikeContactModel contact;
  const _ContactCard({required this.contact});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.sheetCardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 司机名 + 已认证徽标
          _DriverRow(contact: contact),
          const SizedBox(height: 8),

          // 运营路线描述
          if (contact.route != null && contact.route!.isNotEmpty)
            Text(
              contact.route!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.sheetTextSecondary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          else if (contact.description != null)
            Text(
              contact.description!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.sheetTextSecondary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

          const Spacer(),

          // 地点 + 价格
          _MetaRow(contact: contact),

          const SizedBox(height: 8),

          // 复制号码按钮
          _CopyPhoneButton(phone: contact.phone),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  司机行：图标 + 名 + 认证徽标
// ---------------------------------------------------------------------------

class _DriverRow extends StatelessWidget {
  final HitchhikeContactModel contact;
  const _DriverRow({required this.contact});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          CupertinoIcons.person_circle_fill,
          size: 24,
          color: AppColors.sheetTextSecondary,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            contact.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.sheetTextPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (contact.isVerified) const _VerifiedBadge(),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
//  已认证徽标（绿底）
// ---------------------------------------------------------------------------

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.badgeVerifiedBg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CupertinoIcons.checkmark_seal,
              size: 10, color: AppColors.badgeVerifiedText),
          SizedBox(width: 2),
          Text(
            '已认证',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.badgeVerifiedText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  元信息行：地点 + 价格
// ---------------------------------------------------------------------------

class _MetaRow extends StatelessWidget {
  final HitchhikeContactModel contact;
  const _MetaRow({required this.contact});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (contact.location != null) ...[
          const Icon(CupertinoIcons.location,
              size: 11, color: AppColors.sheetTextWeak),
          const SizedBox(width: 2),
          Expanded(
            child: Text(
              contact.location!,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.sheetTextSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        if (contact.price != null) ...[
          if (contact.location != null) const SizedBox(width: 6),
          const Icon(CupertinoIcons.money_yen_circle,
              size: 11, color: AppColors.badgeRecommendedText),
          const SizedBox(width: 2),
          Text(
            '¥${contact.price!.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.badgeRecommendedText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
//  复制号码按钮 (PRD §3.3.9：复制号码到剪贴板，toast 提示"已复制")
// ---------------------------------------------------------------------------

class _CopyPhoneButton extends StatelessWidget {
  final String phone;
  const _CopyPhoneButton({required this.phone});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: phone));
        ToastUtils.showToast(context, '已复制');
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.badgeBlueBg,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.doc_on_clipboard,
                size: 11, color: AppColors.badgeBlueText),
            SizedBox(width: 4),
            Text(
              '复制号码',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.badgeBlueText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
