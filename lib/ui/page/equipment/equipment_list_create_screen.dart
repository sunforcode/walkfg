import 'package:flutter/cupertino.dart';

import 'package:walk/model/equipment/equipment_enums.dart';
import 'package:walk/model/equipment/equipment_list_model.dart';
import 'package:walk/service/equipment_service.dart';
import 'package:walk/theme/tokens/colors.dart';
import 'package:walk/utils/toast_utils.dart';

/// 新建装备清单页面
///
/// 对齐 PRD P10：填写名称、选择类型（个人/团队）、人数步进器、模板快选芯片。
/// v1 模板芯片点击后弹出 Toast "即将上线"，不执行实际模板逻辑。
///
/// 若传入 [tripId]，创建的清单会自动关联到该行程（用于从行程详情页发起创建）。
class EquipmentListCreateScreen extends StatefulWidget {
  const EquipmentListCreateScreen({super.key, this.tripId});

  /// 关联的行程ID（可选）
  final String? tripId;

  @override
  State<EquipmentListCreateScreen> createState() =>
      _EquipmentListCreateScreenState();
}

class _EquipmentListCreateScreenState
    extends State<EquipmentListCreateScreen> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();

  EquipmentListType _type = EquipmentListType.personal;
  int _personCount = 1;
  final Set<String> _selectedTemplates = {};

  bool _isSaving = false;
  bool _nameHasError = false;

  bool get _canSave =>
      _nameController.text.trim().isNotEmpty && !_isSaving;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onNameChanged);
    _nameFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    if (_nameHasError) {
      setState(() {
        _nameHasError = false;
      });
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() => _nameHasError = true);
      return;
    }

    setState(() {
      _isSaving = true;
      _nameHasError = false;
    });

    try {
      await EquipmentService.createEquipmentList(
        EquipmentListCreateRequestModel(
          name: name,
          type: _type,
          personCount: _type == EquipmentListType.personal ? 1 : _personCount,
          tripId: widget.tripId,
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ToastUtils.showToast(context, '创建失败，请重试');
    }
  }

  void _onTypeChanged(EquipmentListType newType) {
    setState(() {
      _type = newType;
      if (newType == EquipmentListType.personal) {
        _personCount = 1;
      }
    });
  }

  void _onIncrement() {
    if (_personCount >= 20) return;
    setState(() => _personCount++);
  }

  void _onDecrement() {
    if (_personCount <= 1) return;
    setState(() => _personCount--);
  }

  void _onTemplateChipTapped(String id) {
    setState(() {
      if (_selectedTemplates.contains(id)) {
        _selectedTemplates.remove(id);
      } else {
        _selectedTemplates.add(id);
      }
    });
    // v1: 提示"即将上线"
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('提示'),
        content: const Text('模板功能即将上线'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.bgBase,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.bgBase.withValues(alpha: 0.8),
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: Text(
            '取消',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
          ),
        ),
        middle: Text(
          '新建装备清单',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: _buildNavSaveButton(),
      ),
      child: Column(
        children: [
          Expanded(
            child: SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const SizedBox(height: 20),
                  _NameInputSection(
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    hasError: _nameHasError,
                    isEnabled: !_isSaving,
                  ),
                  const SizedBox(height: 20),
                  _TypeSegmentSection(
                    type: _type,
                    onTypeChanged: _onTypeChanged,
                    isEnabled: !_isSaving,
                  ),
                  const SizedBox(height: 20),
                  _PersonCountSection(
                    personCount: _personCount,
                    isPersonal: _type == EquipmentListType.personal,
                    onIncrement: _onIncrement,
                    onDecrement: _onDecrement,
                    isEnabled: !_isSaving,
                  ),
                  const SizedBox(height: 24),
                  _TemplateChipSection(
                    selectedTemplates: _selectedTemplates,
                    onChipTapped: _onTemplateChipTapped,
                    isEnabled: !_isSaving,
                  ),
                  // Bottom padding to avoid overlap with fixed button
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          _BottomCreateButton(
            isEnabled: _canSave,
            isSaving: _isSaving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }

  Widget _buildNavSaveButton() {
    final enabled = _canSave;
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: enabled ? _save : null,
      child: Text(
        '保存',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: enabled
              ? AppColors.interactiveAccent
              : AppColors.textHint,
        ),
      ),
    );
  }
}

// ============================================================
// Private widgets — split from main tree per architecture rule
// ============================================================

/// Name input section with label, text field, and error hint
class _NameInputSection extends StatelessWidget {
  const _NameInputSection({
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.isEnabled,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(text: '清单名称'),
        const SizedBox(height: 8),
        CupertinoTextField(
          controller: controller,
          focusNode: focusNode,
          enabled: isEnabled,
          placeholder: '例如：三日徒步装备',
          maxLength: 30,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
          placeholderStyle: TextStyle(
            fontSize: 16,
            color: AppColors.textDim,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            border: Border.all(
              color: hasError
                  ? AppColors.semanticErrorBorder
                  : (focusNode.hasFocus
                      ? AppColors.interactiveAccentFocus
                      : AppColors.surfaceCardHover),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            '请输入清单名称',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.semanticErrorText,
            ),
          ),
        ],
      ],
    );
  }
}

/// Type segmented control (个人 / 团队)
class _TypeSegmentSection extends StatelessWidget {
  const _TypeSegmentSection({
    required this.type,
    required this.onTypeChanged,
    required this.isEnabled,
  });

  final EquipmentListType type;
  final ValueChanged<EquipmentListType> onTypeChanged;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(text: '清单类型'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _SegmentItem(
                label: '个人',
                isSelected: type == EquipmentListType.personal,
                onTap: isEnabled
                    ? () => onTypeChanged(EquipmentListType.personal)
                    : null,
              ),
              const SizedBox(width: 3),
              _SegmentItem(
                label: '团队',
                isSelected: type == EquipmentListType.team,
                onTap: isEnabled
                    ? () => onTypeChanged(EquipmentListType.team)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Single segment item within the segmented control
class _SegmentItem extends StatelessWidget {
  const _SegmentItem({
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.interactiveAccentBg
                : const Color(0x00000000),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              color: isSelected
                  ? AppColors.interactiveAccent.withValues(alpha: 0.9)
                  : AppColors.textSubtitle.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}

/// Person count stepper section
class _PersonCountSection extends StatelessWidget {
  const _PersonCountSection({
    required this.personCount,
    required this.isPersonal,
    required this.onIncrement,
    required this.onDecrement,
    required this.isEnabled,
  });

  final int personCount;
  final bool isPersonal;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final dimmed = isPersonal || !isEnabled;
    return Opacity(
      opacity: dimmed ? 0.5 : 1.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(text: '出行人数'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '人数',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
                Row(
                  children: [
                    _StepperButton(
                      icon: '−',
                      onPressed: (dimmed || personCount <= 1)
                          ? null
                          : onDecrement,
                      isDisabled: personCount <= 1,
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 24,
                      child: Text(
                        '$personCount',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    _StepperButton(
                      icon: '+',
                      onPressed: (dimmed || personCount >= 20)
                          ? null
                          : onIncrement,
                      isDisabled: personCount >= 20,
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
}

/// Single +/− stepper button
class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    this.onPressed,
    required this.isDisabled,
  });

  final String icon;
  final VoidCallback? onPressed;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDisabled ? 0.4 : 1.0,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.surfaceCardBorder, // rgba(255,255,255,.06)
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            icon,
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textBody,
            ),
          ),
        ),
      ),
    );
  }
}

/// Template chip selection section
class _TemplateChipSection extends StatelessWidget {
  const _TemplateChipSection({
    required this.selectedTemplates,
    required this.onChipTapped,
    required this.isEnabled,
  });

  final Set<String> selectedTemplates;
  final ValueChanged<String> onChipTapped;
  final bool isEnabled;

  static const List<_TemplateChip> _chips = [
    _TemplateChip(id: 'day-hike', label: '一日轻装'),
    _TemplateChip(id: 'three-day-backpack', label: '三日重装'),
    _TemplateChip(id: 'five-day-trek', label: '五日穿越'),
    _TemplateChip(id: 'snow-mountain', label: '雪山攀登'),
    _TemplateChip(id: 'desert-hike', label: '沙漠徒步'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(text: '从模板创建（可选）'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _chips.map((chip) {
            final selected = selectedTemplates.contains(chip.id);
            return _TemplateChipWidget(
              label: chip.label,
              isSelected: selected,
              isEnabled: isEnabled,
              onTap: isEnabled ? () => onChipTapped(chip.id) : null,
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Single template chip
class _TemplateChipWidget extends StatelessWidget {
  const _TemplateChipWidget({
    required this.label,
    required this.isSelected,
    required this.isEnabled,
    this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.interactiveAccent.withValues(alpha: 0.08)
              : AppColors.surfaceCard,
          border: Border.all(
            color: isSelected
                ? AppColors.interactiveAccentFocus
                : AppColors.surfaceCardHover,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isSelected
                ? AppColors.interactiveAccent.withValues(alpha: 0.8)
                : AppColors.textBody.withValues(alpha: 0.55),
          ),
        ),
      ),
    );
  }
}

/// Bottom fixed "创建清单" button
class _BottomCreateButton extends StatelessWidget {
  const _BottomCreateButton({
    required this.isEnabled,
    required this.isSaving,
    required this.onPressed,
  });

  final bool isEnabled;
  final bool isSaving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      decoration: BoxDecoration(
        color: AppColors.bgBase,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 0.5,
          ),
        ),
      ),
      child: GestureDetector(
        onTap: isEnabled ? onPressed : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: isEnabled ? AppColors.gradientCta : null,
            color: isEnabled ? null : AppColors.surfaceCardHover,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            isSaving ? '创建中...' : '创建清单',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: isEnabled
              ? AppColors.textPrimary
              : AppColors.textHint,
            ),
          ),
        ),
      ),
    );
  }
}

/// Reusable section label
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: AppColors.textSubtitle,
        ),
      ),
    );
  }
}

/// Data holder for a template chip
class _TemplateChip {
  const _TemplateChip({required this.id, required this.label});

  final String id;
  final String label;
}
