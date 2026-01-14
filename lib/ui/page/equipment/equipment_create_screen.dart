import 'package:flutter/cupertino.dart';
import 'package:walk/model/equipment/equipment_list_model.dart';
import 'package:walk/model/equipment/equipment_list_type.dart';
import 'package:walk/model/equipment/equipment_list_status.dart';
import 'package:walk/model/equipment/equipment_season.dart';
import 'package:walk/service/equipment_service.dart';

/// 创建装备清单页面
class EquipmentCreateScreen extends StatefulWidget {
  /// 构造函数
  const EquipmentCreateScreen({super.key});

  @override
  State<EquipmentCreateScreen> createState() => _EquipmentCreateScreenState();
}

class _EquipmentCreateScreenState extends State<EquipmentCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  EquipmentListType _selectedType = EquipmentListType.shortHike;
  int _tripDays = 1;
  int _personCount = 1;
  final List<SeasonSuitability> _selectedSeasons = [SeasonSuitability.spring];
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// 创建装备清单
  Future<void> _createEquipmentList() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      // 创建装备清单模型
      final equipmentList = EquipmentListModel(
        id: '', // ID会由服务生成
        name: _nameController.text,
        description: _descriptionController.text,
        type: _selectedType,
        tripDays: _tripDays,
        personCount: _personCount,
        seasons: _selectedSeasons,
        equipments: [], // 初始为空
        tags: [], // 初始为空
        creatorId: 'user001', // 当前用户ID
        creatorName: '当前用户', // 当前用户名
        isOfficial: false,
        isTemplate: false,
        status: EquipmentListStatus.planning,
        totalWeight: 0, // 初始为0
        baseWeight: 0, // 初始为0
        consumableWeight: 0, // 初始为0
        wornWeight: 0, // 初始为0
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 调用服务创建装备清单
      await EquipmentService.createEquipmentList(equipmentList);

      if (mounted) {
        // 返回上一页并传递创建成功的结果
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('创建失败', e.toString());
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  /// 显示错误对话框
  void _showErrorDialog(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('确定'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('创建装备清单'),
        trailing: _isCreating
            ? const CupertinoActivityIndicator()
            : CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Text('创建'),
                onPressed: _createEquipmentList,
              ),
      ),
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 名称输入
              CupertinoFormSection(
                header: const Text('基本信息'),
                children: [
                  CupertinoTextFormFieldRow(
                    controller: _nameController,
                    prefix: const Text('名称'),
                    placeholder: '输入装备清单名称',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入名称';
                      }
                      return null;
                    },
                  ),
                  CupertinoTextFormFieldRow(
                    controller: _descriptionController,
                    prefix: const Text('描述'),
                    placeholder: '输入装备清单描述',
                    maxLines: 3,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 类型选择
              CupertinoFormSection(
                header: const Text('类型设置'),
                children: [
                  GestureDetector(
                    onTap: _showTypePickerDialog,
                    child: CupertinoFormRow(
                      prefix: const Text('类型'),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(getListTypeName(_selectedType)),
                          const CupertinoListTileChevron(),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _showSeasonPickerDialog,
                    child: CupertinoFormRow(
                      prefix: const Text('季节'),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_getSelectedSeasonsText()),
                          const CupertinoListTileChevron(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 行程设置
              CupertinoFormSection(
                header: const Text('行程设置'),
                children: [
                  CupertinoFormRow(
                    prefix: const Text('行程天数'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$_tripDays 天'),
                        Row(
                          children: [
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              child: const Icon(CupertinoIcons.minus_circle),
                              onPressed: _tripDays > 1
                                  ? () {
                                      setState(() {
                                        _tripDays--;
                                      });
                                    }
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              child: const Icon(CupertinoIcons.plus_circle),
                              onPressed: () {
                                setState(() {
                                  _tripDays++;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  CupertinoFormRow(
                    prefix: const Text('人数'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$_personCount 人'),
                        Row(
                          children: [
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              child: const Icon(CupertinoIcons.minus_circle),
                              onPressed: _personCount > 1
                                  ? () {
                                      setState(() {
                                        _personCount--;
                                      });
                                    }
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              child: const Icon(CupertinoIcons.plus_circle),
                              onPressed: () {
                                setState(() {
                                  _personCount++;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // 创建按钮
              CupertinoButton.filled(
                onPressed: _isCreating ? null : _createEquipmentList,
                child: _isCreating
                    ? const CupertinoActivityIndicator()
                    : const Text('创建装备清单'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 显示类型选择器对话框
  void _showTypePickerDialog() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('选择装备清单类型'),
        message: const Text('根据行程类型选择合适的装备清单类型'),
        actions: EquipmentListType.values.map((type) {
          return CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedType = type;
              });
            },
            child: Text(getListTypeName(type)),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('取消'),
        ),
      ),
    );
  }

  /// 显示季节选择器对话框
  void _showSeasonPickerDialog() {
    final selectedSeasons = List<SeasonSuitability>.from(_selectedSeasons);

    showCupertinoModalPopup(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return CupertinoActionSheet(
            title: const Text('选择适用季节'),
            message: const Text('可以选择多个季节'),
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  // 确认选择
                  Navigator.pop(context);
                  this.setState(() {
                    _selectedSeasons.clear();
                    _selectedSeasons.addAll(selectedSeasons);
                  });
                },
                isDefaultAction: true,
                child: const Text('确定'),
              ),
              ...SeasonSuitability.values.map((season) {
                final isSelected = selectedSeasons.contains(season);
                return CupertinoActionSheetAction(
                  onPressed: () {
                    setState(() {
                      if (isSelected) {
                        if (selectedSeasons.length > 1) {
                          selectedSeasons.remove(season);
                        }
                      } else {
                        selectedSeasons.add(season);
                      }
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(getSeasonName(season)),
                      if (isSelected)
                        const Icon(
                          CupertinoIcons.check_mark,
                          color: CupertinoColors.activeBlue,
                        ),
                    ],
                  ),
                );
              }).toList(),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('取消'),
            ),
          );
        },
      ),
    );
  }

  /// 获取已选择季节的文本
  String _getSelectedSeasonsText() {
    if (_selectedSeasons.isEmpty) {
      return '请选择季节';
    }

    return _selectedSeasons.map((season) => getSeasonName(season)).join('、');
  }
}
