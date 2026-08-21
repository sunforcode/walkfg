import 'package:flutter/cupertino.dart';

import 'package:walk/model/equipment/equipment_enums.dart';
import 'package:walk/model/equipment/equipment_item_model.dart';
import 'package:walk/service/equipment_service.dart';

/// 装备单品创建/编辑页面
///
/// 若传入 [item] 则为编辑模式，否则为创建模式。
/// 只暴露后端真正支持持久化的字段：name/category/weight/weightUnit/quantity。
/// 不提供 description 输入框，因为后端 `EquipmentCreateRequest.description`
/// 不会被保存（详见 [EquipmentItemUpsertRequest] 类注释）。
class EquipmentItemEditScreen extends StatefulWidget {
  final EquipmentItemModel? item;

  const EquipmentItemEditScreen({super.key, this.item});

  @override
  State<EquipmentItemEditScreen> createState() =>
      _EquipmentItemEditScreenState();
}

class _EquipmentItemEditScreenState extends State<EquipmentItemEditScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _weightController;
  late final TextEditingController _quantityController;
  late EquipmentCategory _category;
  late EquipmentWeightUnit _weightUnit;

  bool _isSaving = false;
  bool _isDeleting = false;
  String? _errorMessage;

  bool get _isEditMode => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameController = TextEditingController(text: item?.name ?? '');
    _weightController = TextEditingController(
      text: item != null ? _formatWeightForInput(item.weight) : '',
    );
    _quantityController =
        TextEditingController(text: (item?.quantity ?? 1).toString());
    _category = item?.category ?? EquipmentCategory.other;
    _weightUnit = item?.weightUnit ?? EquipmentWeightUnit.gram;
  }

  String _formatWeightForInput(double weight) {
    if (weight == weight.roundToDouble()) {
      return weight.toInt().toString();
    }
    return weight.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = '请输入装备名称');
      return;
    }
    final weight = double.tryParse(_weightController.text.trim());
    if (weight == null || weight <= 0) {
      setState(() => _errorMessage = '请输入有效的重量');
      return;
    }
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 1;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final request = EquipmentItemUpsertRequest(
      name: name,
      category: _category,
      weight: weight,
      weightUnit: _weightUnit,
      quantity: quantity < 1 ? 1 : quantity,
    );

    try {
      if (_isEditMode) {
        await EquipmentService.updateEquipmentItem(widget.item!.id, request);
      } else {
        await EquipmentService.createEquipmentItem(request);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _delete() async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('删除装备'),
        content: const Text('确定要删除这件装备吗？此操作不可撤销。'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isDeleting = true);
    try {
      await EquipmentService.deleteEquipmentItem(widget.item!.id);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isDeleting = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_isEditMode ? '编辑装备' : '新增装备'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const CupertinoActivityIndicator()
              : const Text('保存'),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: CupertinoColors.systemRed),
                ),
              ),
              const SizedBox(height: 16),
            ],
            _buildSectionLabel('装备名称'),
            _buildTextField(_nameController, placeholder: '例如：双人帐篷'),
            const SizedBox(height: 20),
            _buildSectionLabel('分类'),
            _buildCategoryPicker(),
            const SizedBox(height: 20),
            _buildSectionLabel('重量'),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _weightController,
                    placeholder: '重量',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildWeightUnitPicker(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionLabel('数量'),
            _buildTextField(
              _quantityController,
              placeholder: '数量',
              keyboardType: TextInputType.number,
            ),
            if (_isEditMode) ...[
              const SizedBox(height: 32),
              CupertinoButton(
                color: CupertinoColors.systemRed.withValues(alpha: 0.1),
                onPressed: _isDeleting ? null : _delete,
                child: _isDeleting
                    ? const CupertinoActivityIndicator()
                    : const Text(
                        '删除装备',
                        style: TextStyle(color: CupertinoColors.systemRed),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          color: CupertinoColors.systemGrey,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    required String placeholder,
    TextInputType? keyboardType,
  }) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      keyboardType: keyboardType,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildCategoryPicker() {
    return GestureDetector(
      onTap: () => _showPicker<EquipmentCategory>(
        values: EquipmentCategory.values,
        current: _category,
        labelBuilder: (c) => c.displayName,
        onSelected: (value) => setState(() => _category = value),
      ),
      child: _buildPickerField(_category.displayName),
    );
  }

  Widget _buildWeightUnitPicker() {
    return GestureDetector(
      onTap: () => _showPicker<EquipmentWeightUnit>(
        values: EquipmentWeightUnit.values,
        current: _weightUnit,
        labelBuilder: (u) => u.shortLabel,
        onSelected: (value) => setState(() => _weightUnit = value),
      ),
      child: _buildPickerField(_weightUnit.shortLabel),
    );
  }

  Widget _buildPickerField(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text),
          const Icon(
            CupertinoIcons.chevron_down,
            size: 16,
            color: CupertinoColors.systemGrey,
          ),
        ],
      ),
    );
  }

  void _showPicker<T>({
    required List<T> values,
    required T current,
    required String Function(T) labelBuilder,
    required ValueChanged<T> onSelected,
  }) {
    var selected = current;
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => Container(
        height: 260,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CupertinoButton(
                  onPressed: () {
                    onSelected(selected);
                    Navigator.of(context).pop();
                  },
                  child: const Text('确定'),
                ),
              ],
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 36,
                scrollController: FixedExtentScrollController(
                  initialItem: values.indexOf(current),
                ),
                onSelectedItemChanged: (index) {
                  selected = values[index];
                },
                children: values
                    .map((v) => Center(child: Text(labelBuilder(v))))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
