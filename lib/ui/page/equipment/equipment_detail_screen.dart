import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/model/equipment/equipment_category.dart';
import 'package:walk/model/equipment/equipment_list_model.dart';
import 'package:walk/model/equipment/equipment_item_model.dart';
import 'package:walk/model/equipment/equipment_list_status.dart';
import 'package:walk/model/equipment/equipment_necessity.dart';
import 'package:walk/model/equipment/weight_unit.dart';
import 'package:walk/service/equipment_service.dart';
import 'package:walk/service/mock/mock_equipment_service.dart';
import 'package:walk/ui/widget/error_view.dart';
import 'package:walk/ui/widget/empty_view.dart';

/// 装备清单详情页面
class EquipmentDetailScreen extends StatefulWidget {
  /// 装备清单ID
  final String equipmentListId;

  /// 构造函数
  const EquipmentDetailScreen({
    super.key,
    required this.equipmentListId,
  });

  @override
  State<EquipmentDetailScreen> createState() => _EquipmentDetailScreenState();
}

class _EquipmentDetailScreenState extends State<EquipmentDetailScreen> {
  bool _isLoading = true;
  String? _error;
  late EquipmentService _equipmentService;
  EquipmentListModel? _equipmentList;
  EquipmentListStats? _stats;
  double _preparationProgress = 0;

  @override
  void initState() {
    super.initState();
    _equipmentService = MockEquipmentService();
    _loadEquipmentList();
  }

  /// 加载装备清单
  Future<void> _loadEquipmentList() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final equipmentList =
          await _equipmentService.getEquipmentListById(widget.equipmentListId);
      final stats =
          await _equipmentService.getEquipmentListStats(widget.equipmentListId);
      final progress = await _equipmentService
          .getEquipmentListPreparationProgress(widget.equipmentListId);

      if (mounted) {
        setState(() {
          _equipmentList = equipmentList;
          _stats = stats;
          _preparationProgress = progress;
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

  /// 更新装备准备状态
  Future<void> _updateEquipmentPreparedStatus(
      String itemId, bool prepared) async {
    try {
      final updatedList = await _equipmentService.updateEquipmentPreparedStatus(
        widget.equipmentListId,
        itemId,
        prepared,
      );

      if (mounted) {
        setState(() {
          _equipmentList = updatedList;
        });

        // 更新统计信息和准备进度
        _refreshStats();
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('更新装备状态失败', e.toString());
      }
    }
  }

  /// 更新装备清单状态
  Future<void> _updateEquipmentListStatus(EquipmentListStatus status) async {
    try {
      final updatedList = await _equipmentService.updateEquipmentListStatus(
        widget.equipmentListId,
        status,
      );

      if (mounted) {
        setState(() {
          _equipmentList = updatedList;
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('更新清单状态失败', e.toString());
      }
    }
  }

  /// 刷新统计信息
  Future<void> _refreshStats() async {
    try {
      final stats =
          await _equipmentService.getEquipmentListStats(widget.equipmentListId);
      final progress = await _equipmentService
          .getEquipmentListPreparationProgress(widget.equipmentListId);

      if (mounted) {
        setState(() {
          _stats = stats;
          _preparationProgress = progress;
        });
      }
    } catch (e) {
      // 忽略统计信息刷新错误
      print('刷新统计信息失败: $e');
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
        middle: Text(_equipmentList?.name ?? '装备清单详情'),
        trailing: _equipmentList != null
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.ellipsis),
                onPressed: _showMoreOptions,
              )
            : null,
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
        onRetry: _loadEquipmentList,
      );
    }

    if (_equipmentList == null) {
      return EmptyView(
        icon: CupertinoIcons.exclamationmark_circle,
        title: '装备清单不存在',
        message: '无法找到该装备清单',
        buttonText: '返回',
        onButtonPressed: () => Navigator.of(context).pop(),
      );
    }

    return Column(
      children: [
        // 进度指示器
        _buildProgressIndicator(),

        // 统计信息
        _buildStatsSection(),

        // 装备列表
        Expanded(
          child: _buildEquipmentList(),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: CupertinoColors.systemBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '准备进度',
                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '${_preparationProgress.toStringAsFixed(1)}%',
                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                      color: CupertinoColors.systemBlue,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _preparationProgress / 100,
              backgroundColor: CupertinoColors.systemGrey5,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressColor(_preparationProgress),
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getProgressText(_preparationProgress),
            style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                  color: CupertinoColors.systemGrey,
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    if (_stats == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      color: CupertinoColors.systemBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '装备统计',
            style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatItem(
                '总物品',
                '${_stats!.totalItems}',
                CupertinoIcons.bag,
              ),
              _buildStatItem(
                '必需品',
                '${_stats!.essentialItems}',
                CupertinoIcons.star_fill,
              ),
              _buildStatItem(
                '已准备',
                '${_stats!.preparedItems}',
                CupertinoIcons.checkmark_circle,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatItem(
                '总重量',
                '${(_stats!.totalWeight / 1000).toStringAsFixed(1)}kg',
                CupertinoIcons.arrow_down_circle,
              ),
              _buildStatItem(
                '基础重量',
                '${(_stats!.baseWeight / 1000).toStringAsFixed(1)}kg',
                CupertinoIcons.bag_fill,
              ),
              _buildStatItem(
                '人均/天',
                '${(_stats!.weightPerPersonPerDay / 1000).toStringAsFixed(1)}kg',
                CupertinoIcons.person,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Icon(
              icon,
              color: CupertinoColors.systemBlue,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: CupertinoColors.systemGrey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentList() {
    if (_equipmentList!.equipments.isEmpty) {
      return EmptyView(
        icon: CupertinoIcons.bag,
        title: '暂无装备',
        message: '该装备清单中还没有添加装备',
        buttonText: '添加装备',
        onButtonPressed: _addEquipment,
      );
    }

    // 按分类分组装备
    final groupedEquipments = <String, List<EquipmentItemModel>>{};

    for (final item in _equipmentList!.equipments) {
      final categoryName = getCategoryName(item.category);
      if (!groupedEquipments.containsKey(categoryName)) {
        groupedEquipments[categoryName] = [];
      }
      groupedEquipments[categoryName]!.add(item);
    }

    // 排序分类
    final sortedCategories = groupedEquipments.keys.toList()..sort();

    return ListView.builder(
      itemCount: sortedCategories.length,
      itemBuilder: (context, index) {
        final category = sortedCategories[index];
        final items = groupedEquipments[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: CupertinoColors.systemGrey6,
              child: Text(
                category,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ),
            ...items.map((item) => _buildEquipmentItem(item)).toList(),
          ],
        );
      },
    );
  }

  Widget _buildEquipmentItem(EquipmentItemModel item) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.systemGrey5,
            width: 0.5,
          ),
        ),
      ),
      child: CupertinoListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getNecessityColor(item.necessity).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getCategoryIcon(item.category),
            color: _getNecessityColor(item.necessity),
          ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${item.weight}${getWeightUnitName(item.weightUnit)} × ${item.quantity}',
          style: const TextStyle(
            color: CupertinoColors.systemGrey,
            fontSize: 12,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.price != null)
              Text(
                '¥${item.price!}',
                style: const TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 14,
                ),
              ),
            const SizedBox(width: 16),
            CupertinoSwitch(
              value: item.prepared,
              onChanged: (value) {
                _updateEquipmentPreparedStatus(item.id, value);
              },
            ),
          ],
        ),
        onTap: () => _showItemDetails(item),
      ),
    );
  }

  void _showItemDetails(EquipmentItemModel item) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(item.name),
        message: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.description != null && item.description!.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  item.description!,
                  style: const TextStyle(
                    color: CupertinoColors.black,
                    fontSize: 14,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildItemDetailRow('重量',
                      '${item.weight}${getWeightUnitName(item.weightUnit)} × ${item.quantity}'),
                  if (item.brand != null)
                    _buildItemDetailRow('品牌', item.brand!),
                  if (item.model != null)
                    _buildItemDetailRow('型号', item.model!),
                  if (item.price != null)
                    _buildItemDetailRow('价格', '¥${item.price!}'),
                  _buildItemDetailRow('必要性', getNecessityName(item.necessity)),
                  _buildItemDetailRow('状态', item.prepared ? '已准备' : '未准备'),
                  if (item.notes != null && item.notes!.isNotEmpty)
                    _buildItemDetailRow('备注', item.notes!),
                ],
              ),
            ),
          ],
        ),
        actions: [
          CupertinoActionSheetAction(
            child: Text(item.prepared ? '标记为未准备' : '标记为已准备'),
            onPressed: () {
              Navigator.pop(context);
              _updateEquipmentPreparedStatus(item.id, !item.prepared);
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('编辑装备'),
            onPressed: () {
              Navigator.pop(context);
              _editEquipment(item);
            },
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            child: const Text('删除装备'),
            onPressed: () {
              Navigator.pop(context);
              _confirmDeleteEquipment(item);
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

  Widget _buildItemDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(
                color: CupertinoColors.systemGrey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('更多选项'),
        message: const Text('选择操作'),
        actions: [
          CupertinoActionSheetAction(
            child: const Text('添加装备'),
            onPressed: () {
              Navigator.pop(context);
              _addEquipment();
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('更改状态'),
            onPressed: () {
              Navigator.pop(context);
              _showStatusChangeDialog();
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('编辑清单信息'),
            onPressed: () {
              Navigator.pop(context);
              _editEquipmentList();
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('导出清单'),
            onPressed: () {
              Navigator.pop(context);
              _exportEquipmentList();
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('创建副本'),
            onPressed: () {
              Navigator.pop(context);
              _cloneEquipmentList();
            },
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            child: const Text('删除清单'),
            onPressed: () {
              Navigator.pop(context);
              _confirmDeleteEquipmentList();
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

  void _showStatusChangeDialog() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('更改状态'),
        message: const Text('选择装备清单状态'),
        actions: EquipmentListStatus.values.map((status) {
          final isCurrentStatus = _equipmentList!.status == status;
          return CupertinoActionSheetAction(
            isDefaultAction: isCurrentStatus,
            child: Text(
              '${getListStatusName(status)}${isCurrentStatus ? ' (当前)' : ''}',
            ),
            onPressed: () {
              Navigator.pop(context);
              if (!isCurrentStatus) {
                _updateEquipmentListStatus(status);
              }
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

  void _addEquipment() {
    // TODO: 实现添加装备功能
    _showNotImplementedDialog('添加装备');
  }

  void _editEquipment(EquipmentItemModel item) {
    // TODO: 实现编辑装备功能
    _showNotImplementedDialog('编辑装备');
  }

  void _confirmDeleteEquipment(EquipmentItemModel item) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('删除装备'),
        content: Text('确定要删除"${item.name}"吗？此操作不可撤销。'),
        actions: [
          CupertinoDialogAction(
            child: const Text('取消'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('删除'),
            onPressed: () {
              Navigator.of(context).pop();
              _deleteEquipment(item.id);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEquipment(String itemId) async {
    try {
      final updatedList = await _equipmentService.removeEquipmentItem(
        widget.equipmentListId,
        itemId,
      );

      if (mounted) {
        setState(() {
          _equipmentList = updatedList;
        });

        // 更新统计信息和准备进度
        _refreshStats();
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('删除装备失败', e.toString());
      }
    }
  }

  void _editEquipmentList() {
    // TODO: 实现编辑装备清单功能
    _showNotImplementedDialog('编辑装备清单');
  }

  void _exportEquipmentList() {
    // TODO: 实现导出装备清单功能
    _showNotImplementedDialog('导出装备清单');
  }

  Future<void> _cloneEquipmentList() async {
    try {
      await _equipmentService.cloneEquipmentList(widget.equipmentListId);
      if (mounted) {
        _showSuccessDialog('复制成功', '已成功创建装备清单副本');
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('复制失败', e.toString());
      }
    }
  }

  void _confirmDeleteEquipmentList() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('删除装备清单'),
        content: Text('确定要删除"${_equipmentList!.name}"吗？此操作不可撤销。'),
        actions: [
          CupertinoDialogAction(
            child: const Text('取消'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('删除'),
            onPressed: () {
              Navigator.of(context).pop();
              _deleteEquipmentList();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEquipmentList() async {
    try {
      await _equipmentService.deleteEquipmentList(widget.equipmentListId);
      if (mounted) {
        Navigator.of(context).pop(true); // 返回上一页并传递删除成功的结果
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('删除失败', e.toString());
      }
    }
  }

  void _showSuccessDialog(String title, String message) {
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

  void _showNotImplementedDialog(String feature) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('功能未实现'),
        content: Text('$feature功能尚未实现'),
        actions: [
          CupertinoDialogAction(
            child: const Text('确定'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 30) {
      return CupertinoColors.systemRed;
    } else if (progress < 70) {
      return CupertinoColors.systemOrange;
    } else if (progress < 100) {
      return CupertinoColors.systemYellow;
    } else {
      return CupertinoColors.systemGreen;
    }
  }

  String _getProgressText(double progress) {
    if (progress < 30) {
      return '准备进度较低，请尽快准备装备';
    } else if (progress < 70) {
      return '准备进度一般，继续准备剩余装备';
    } else if (progress < 100) {
      return '准备进度良好，即将完成所有准备';
    } else {
      return '所有装备已准备完毕，可以出发了';
    }
  }

  Color _getNecessityColor(EquipmentNecessity necessity) {
    switch (necessity) {
      case EquipmentNecessity.essential:
        return CupertinoColors.systemRed;
      case EquipmentNecessity.recommended:
        return CupertinoColors.systemOrange;
      case EquipmentNecessity.optional:
        return CupertinoColors.systemBlue;
    }
  }

  IconData _getCategoryIcon(EquipmentCategory category) {
    switch (category) {
      case EquipmentCategory.shelter:
        return CupertinoIcons.house;
      case EquipmentCategory.backpack:
        return CupertinoIcons.bag;
      case EquipmentCategory.clothing:
        return CupertinoIcons.person_crop_circle;
      case EquipmentCategory.food:
        return CupertinoIcons.cart;
      case EquipmentCategory.navigation:
        return CupertinoIcons.map;
      case EquipmentCategory.electronics:
        return CupertinoIcons.device_laptop;
      case EquipmentCategory.firstAid:
        return CupertinoIcons.bandage;
      case EquipmentCategory.tools:
        return CupertinoIcons.hammer;
      case EquipmentCategory.personalCare:
        return CupertinoIcons.person;
      case EquipmentCategory.lighting:
        return CupertinoIcons.lightbulb;
      case EquipmentCategory.other:
        return CupertinoIcons.cube_box;
    }
  }
}
