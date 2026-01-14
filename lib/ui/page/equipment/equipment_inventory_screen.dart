import 'package:flutter/cupertino.dart';
import 'package:walk/model/equipment/equipment_condition.dart';
import 'package:walk/model/equipment/equipment_item_model.dart';
import 'package:walk/model/equipment/equipment_category.dart';
import 'package:walk/model/equipment/user_equipment_inventory_model.dart';
import 'package:walk/model/equipment/weight_unit.dart';
import 'package:walk/service/equipment_service.dart';
import 'package:walk/ui/widget/error_view.dart';
import 'package:walk/ui/widget/empty_view.dart';

/// 用户装备库页面
class EquipmentInventoryScreen extends StatefulWidget {
  /// 用户ID
  final String userId;

  /// 构造函数
  const EquipmentInventoryScreen({
    super.key,
    required this.userId,
  });

  @override
  State<EquipmentInventoryScreen> createState() =>
      _EquipmentInventoryScreenState();
}

class _EquipmentInventoryScreenState extends State<EquipmentInventoryScreen> {
  bool _isLoading = true;
  String? _error;
  UserEquipmentInventoryModel? _inventory;
  EquipmentCategory? _selectedCategory;
  String _searchQuery = '';
  List<EquipmentItemModel> _displayedItems = [];

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  /// 加载用户装备库
  Future<void> _loadInventory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final inventory =
          await EquipmentService.getUserEquipmentInventory(widget.userId);

      if (mounted) {
        setState(() {
          _inventory = inventory;
          _isLoading = false;
        });

        // 应用筛选
        _applyFilters();
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

  /// 搜索装备
  Future<void> _searchEquipment(String query) async {
    setState(() {
      _searchQuery = query;
    });
    _applyFilters();
  }

  /// 按分类筛选装备
  void _filterByCategory(EquipmentCategory? category) {
    setState(() {
      _selectedCategory = category;
    });
    _applyFilters();
  }

  /// 应用筛选条件
  void _applyFilters() {
    if (_inventory == null) return;

    List<EquipmentItemModel> items = _inventory!.equipments;

    // 应用搜索
    if (_searchQuery.isNotEmpty) {
      items = items.where((item) {
        return item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (item.description
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false) ||
            (item.brand?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                false) ||
            (item.model?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                false);
      }).toList();
    }

    // 应用分类筛选
    if (_selectedCategory != null) {
      items =
          items.where((item) => item.category == _selectedCategory).toList();
    }

    setState(() {
      _displayedItems = items;
    });
  }

  /// 添加装备
  void _addEquipment() {
    // TODO: 实现添加装备功能
    _showNotImplementedDialog('添加装备');
  }

  /// 编辑装备
  void _editEquipment(EquipmentItemModel item) {
    // TODO: 实现编辑装备功能
    _showNotImplementedDialog('编辑装备');
  }

  /// 删除装备
  Future<void> _deleteEquipment(String itemId) async {
    try {
      await EquipmentService.removeEquipmentFromInventory(
          widget.userId, itemId);
      await _loadInventory();
    } catch (e) {
      if (mounted) {
        _showErrorDialog('删除失败', e.toString());
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

  /// 显示未实现功能对话框
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('我的装备库'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.search),
              onPressed: _showSearchDialog,
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.slider_horizontal_3),
              onPressed: _showFilterDialog,
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            _buildBody(),
            Positioned(
              right: 16,
              bottom: 16,
              child: CupertinoButton(
                padding: const EdgeInsets.all(16),
                color: CupertinoColors.activeBlue,
                borderRadius: BorderRadius.circular(30),
                child: const Icon(
                  CupertinoIcons.add,
                  color: CupertinoColors.white,
                ),
                onPressed: _addEquipment,
              ),
            ),
          ],
        ),
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
        onRetry: _loadInventory,
      );
    }

    if (_inventory == null) {
      return EmptyView(
        icon: CupertinoIcons.exclamationmark_circle,
        title: '装备库不存在',
        message: '无法找到该用户的装备库',
        buttonText: '返回',
        onButtonPressed: () => Navigator.of(context).pop(),
      );
    }

    if (_inventory!.equipments.isEmpty) {
      return EmptyView(
        icon: CupertinoIcons.bag,
        title: '暂无装备',
        message: '您的装备库中还没有添加装备',
        buttonText: '添加装备',
        onButtonPressed: _addEquipment,
      );
    }

    // 应用筛选
    if (_displayedItems.isEmpty) {
      _applyFilters();
    }

    if (_displayedItems.isEmpty) {
      return EmptyView(
        icon: CupertinoIcons.search,
        title: '未找到装备',
        message: '当前筛选条件下没有找到装备',
        buttonText: '清除筛选',
        onButtonPressed: () {
          setState(() {
            _searchQuery = '';
            _selectedCategory = null;
          });
          _applyFilters();
        },
      );
    }

    // 按分类分组装备
    final groupedEquipments = <String, List<EquipmentItemModel>>{};

    for (final item in _displayedItems) {
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
            color: _getConditionColor(item.condition).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getCategoryIcon(item.category),
            color: _getConditionColor(item.condition),
          ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${item.brand ?? ''} ${item.model ?? ''}'.trim(),
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
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(
                CupertinoIcons.ellipsis,
                size: 20,
              ),
              onPressed: () => _showItemOptions(item),
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
                  _buildItemDetailRow('状态', getConditionName(item.condition)),
                  _buildItemDetailRow('使用次数', '${item.usageCount}次'),
                  if (item.notes != null && item.notes!.isNotEmpty)
                    _buildItemDetailRow('备注', item.notes!),
                ],
              ),
            ),
          ],
        ),
        actions: [
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

  void _showItemOptions(EquipmentItemModel item) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(item.name),
        actions: [
          CupertinoActionSheetAction(
            child: const Text('查看详情'),
            onPressed: () {
              Navigator.pop(context);
              _showItemDetails(item);
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

  void _showSearchDialog() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('搜索装备'),
        message: Column(
          children: [
            CupertinoSearchTextField(
              placeholder: '输入关键词搜索',
              onSubmitted: (value) {
                Navigator.pop(context);
                _searchEquipment(value);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
        actions: [
          CupertinoActionSheetAction(
            child: const Text('取消'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('筛选装备'),
        message: const Text('选择筛选条件'),
        actions: [
          CupertinoActionSheetAction(
            child: const Text('按分类筛选'),
            onPressed: () {
              Navigator.pop(context);
              _showCategoryFilterDialog();
            },
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            child: const Text('清除筛选'),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _searchQuery = '';
                _selectedCategory = null;
              });
              _applyFilters();
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

  void _showCategoryFilterDialog() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('按分类筛选'),
        message: const Text('选择装备分类'),
        actions: EquipmentCategory.values.map((category) {
          return CupertinoActionSheetAction(
            child: Text(getCategoryName(category)),
            onPressed: () {
              Navigator.pop(context);
              _filterByCategory(category);
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

  Color _getConditionColor(EquipmentCondition condition) {
    switch (condition) {
      case EquipmentCondition.nnew:
        return CupertinoColors.systemGreen;
      case EquipmentCondition.good:
        return CupertinoColors.systemBlue;
      case EquipmentCondition.fair:
        return CupertinoColors.systemYellow;
      case EquipmentCondition.poor:
        return CupertinoColors.systemOrange;
      case EquipmentCondition.damaged:
        return CupertinoColors.systemRed;
    }
  }
}
