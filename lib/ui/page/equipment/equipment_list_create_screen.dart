import 'package:flutter/cupertino.dart';

import 'package:walk/model/equipment/equipment_enums.dart';
import 'package:walk/model/equipment/equipment_list_model.dart';
import 'package:walk/service/equipment_service.dart';

/// 新建装备清单页面
///
/// 支持填写名称、选择清单类型（个人/团队）与人数。
/// 「模板装备」类型不在此处开放选择，该类型通常由"从模板创建"流程使用。
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
  final TextEditingController _personCountController =
      TextEditingController(text: '1');

  EquipmentListType _type = EquipmentListType.personal;

  bool _isSaving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _personCountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final personCount = int.tryParse(_personCountController.text.trim());

    if (name.isEmpty) {
      setState(() => _errorMessage = '请输入清单名称');
      return;
    }
    if (personCount == null || personCount <= 0) {
      setState(() => _errorMessage = '请输入有效的人数');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await EquipmentService.createEquipmentList(
        EquipmentListCreateRequestModel(
          name: name,
          type: _type,
          personCount: personCount,
          tripId: widget.tripId,
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('新建装备清单'),
        trailing: _isSaving
            ? const CupertinoActivityIndicator()
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _save,
                child: const Text('保存'),
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
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: CupertinoColors.systemRed,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            _buildFieldLabel('清单名称'),
            CupertinoTextField(
              controller: _nameController,
              placeholder: '例如：三日徒步装备清单',
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),
            _buildFieldLabel('清单类型'),
            CupertinoSlidingSegmentedControl<EquipmentListType>(
              groupValue: _type,
              children: const {
                EquipmentListType.personal: Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Text('个人装备'),
                ),
                EquipmentListType.team: Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Text('团队装备'),
                ),
              },
              onValueChanged: (value) {
                if (value != null) {
                  setState(() => _type = value);
                }
              },
            ),
            const SizedBox(height: 16),
            _buildFieldLabel('出行人数'),
            CupertinoTextField(
              controller: _personCountController,
              placeholder: '人数',
              keyboardType: TextInputType.number,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: CupertinoColors.systemGrey,
        ),
      ),
    );
  }
}
