import 'package:flutter/cupertino.dart';
import 'package:walk/model/equipment/equipment_template_model.dart';
import 'package:walk/model/equipment/equipment_list_type.dart';
import 'package:walk/service/equipment_service.dart';
import 'package:walk/service/mock/mock_equipment_service.dart';
import 'package:walk/ui/widget/error_view.dart';
import 'package:walk/ui/widget/empty_view.dart';

/// 装备模板页面
class EquipmentTemplateScreen extends StatefulWidget {
  /// 构造函数
  const EquipmentTemplateScreen({super.key});

  @override
  State<EquipmentTemplateScreen> createState() => _EquipmentTemplateScreenState();
}

class _EquipmentTemplateScreenState extends State<EquipmentTemplateScreen> {
  bool _isLoading = true;
  String? _error;
  List<EquipmentTemplateModel> _templates = [];
  late EquipmentService _equipmentService;
  EquipmentListType? _selectedType;

  @override
  void initState() {
    super.initState();
    _equipmentService = MockEquipmentService();
    _loadTemplates();
  }

  /// 加载装备模板
  Future<void> _loadTemplates() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      List<EquipmentTemplateModel> templates;
      
      if (_selectedType != null) {
        templates = await _equipmentService.getEquipmentTemplatesByType(_selectedType!);
      } else {
        templates = await _equipmentService.getEquipmentTemplates();
      }
      
      if (mounted) {
        setState(() {
          _templates = templates;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  /// 筛选模板
  Future<void> _filterTemplates(EquipmentListType? type) async {
    setState(() {
      _selectedType = type;
    });
    await _loadTemplates();
  }

  /// 从模板创建装备清单
  Future<void> _createFromTemplate(EquipmentTemplateModel template) async {
    // 显示创建对话框
    final result = await showCupertinoDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _CreateFromTemplateDialog(template: template),
    );
    
    if (result != null) {
      try {
        await _equipmentService.createEquipmentListFromTemplate(
          template.id,
          name: result['name'],
          description: result['description'],
          tripDays: result['tripDays'],
          personCount: result['personCount'],
        );
        
        if (mounted) {
          // 返回上一页并传递创建成功的结果
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          _showErrorDialog('创建失败', e.toString());
        }
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
        middle: const Text('装备模板'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.slider_horizontal_3),
          onPressed: _showFilterDialog,
        ),
      ),
      child: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CupertinoActivityIndicator(),
      );
    }

    if (_error != null) {
      return ErrorView(
        error: _error!,
        onRetry: _loadTemplates,
      );
    }

    if (_templates.isEmpty) {
      return EmptyView(
        icon: CupertinoIcons.doc_text,
        title: '暂无装备模板',
        message: _selectedType != null 
            ? '当前筛选条件下没有找到装备模板' 
            : '系统中暂无装备模板',
        buttonText: '清除筛选',
        onButtonPressed: () {
          _filterTemplates(null);
        },
      );
    }

    return ListView.builder(
      itemCount: _templates.length,
      itemBuilder: (context, index) {
        final template = _templates[index];
        return _buildTemplateCard(template);
      },
    );
  }

  Widget _buildTemplateCard(EquipmentTemplateModel template) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          _createFromTemplate(template);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题和类别
              Row(
                children: [
                  Expanded(
                    child: Text(
                      template.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.black,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      getListTypeName(template.type),
                      style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // 描述
              Text(
                template.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.systemGrey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // 底部信息
              Row(
                children: [
                  // 物品数量
                  _buildInfoChip(
                    CupertinoIcons.list_bullet,
                    '${template.equipments.length}个物品',
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // 使用次数
                  _buildInfoChip(
                    CupertinoIcons.chart_bar,
                    '${template.usageCount}次使用',
                  ),
                  
                  const Spacer(),
                  
                  // 评分
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemYellow.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          CupertinoIcons.star_fill,
                          size: 12,
                          color: CupertinoColors.systemYellow,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          template.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.systemYellow,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
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
    );
  }
  
  void _showFilterDialog() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('筛选装备模板'),
        message: const Text('选择筛选条件'),
        actions: [
          CupertinoActionSheetAction(
            child: const Text('按类型筛选'),
            onPressed: () {
              Navigator.pop(context);
              _showTypeFilterDialog();
            },
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            child: const Text('清除筛选'),
            onPressed: () {
              Navigator.pop(context);
              _filterTemplates(null);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('取消'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
  
  void _showTypeFilterDialog() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('按类型筛选'),
        message: const Text('选择装备模板类型'),
        actions: EquipmentListType.values.map((type) {
          return CupertinoActionSheetAction(
            child: Text(getListTypeName(type)),
            onPressed: () {
              Navigator.pop(context);
              _filterTemplates(type);
            },
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          child: const Text('取消'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

/// 从模板创建装备清单对话框
class _CreateFromTemplateDialog extends StatefulWidget {
  /// 模板
  final EquipmentTemplateModel template;
  
  /// 构造函数
  const _CreateFromTemplateDialog({
    required this.template,
  });
  
  @override
  State<_CreateFromTemplateDialog> createState() => _CreateFromTemplateDialogState();
}

class _CreateFromTemplateDialogState extends State<_CreateFromTemplateDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _tripDays = 1;
  int _personCount = 1;
  
  @override
  void initState() {
    super.initState();
    _nameController.text = widget.template.name;
    _descriptionController.text = widget.template.description;
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text('从模板创建'),
      content: Column(
        children: [
          const SizedBox(height: 8),
          CupertinoTextField(
            controller: _nameController,
            placeholder: '装备清单名称',
            padding: const EdgeInsets.all(8),
          ),
          const SizedBox(height: 8),
          CupertinoTextField(
            controller: _descriptionController,
            placeholder: '装备清单描述',
            padding: const EdgeInsets.all(8),
            maxLines: 2,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('行程天数'),
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
                  Text('$_tripDays'),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('人数'),
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
                  Text('$_personCount'),
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
        ],
      ),
      actions: [
        CupertinoDialogAction(
          child: const Text('取消'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        CupertinoDialogAction(
          child: const Text('创建'),
          onPressed: () {
            if (_nameController.text.isEmpty) {
              return;
            }
            
            Navigator.of(context).pop({
              'name': _nameController.text,
              'description': _descriptionController.text,
              'tripDays': _tripDays,
              'personCount': _personCount,
            });
          },
        ),
      ],
    );
  }
}