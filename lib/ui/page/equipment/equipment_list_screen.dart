/// 装备列表页面
///
/// 显示所有装备清单，支持筛选和搜索

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../model/equipment/equipment_model.dart';
import '../../../state/equipment/equipment_providers.dart';
import '../../widgets/equipment/equipment_list_card.dart';
import '../../../common/widgets/loading_view.dart';
import '../../../common/widgets/error_view.dart';
import '../../../common/widgets/empty_view.dart';

/// 装备列表页面
class EquipmentListScreen extends ConsumerStatefulWidget {
  /// 构造函数
  const EquipmentListScreen({super.key});

  @override
  ConsumerState<EquipmentListScreen> createState() => _EquipmentListScreenState();
}

class _EquipmentListScreenState extends ConsumerState<EquipmentListScreen> {
  bool _isLoading = true;
  String? _error;
  List<EquipmentListModel> _equipmentLists = [];

  @override
  void initState() {
    super.initState();
    _loadEquipmentLists();
  }

  /// 加载装备清单列表
  Future<void> _loadEquipmentLists() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // 从状态管理器加载装备清单列表
      await ref.read(equipmentListsProvider.notifier).loadEquipmentLists();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// 打开筛选对话框
  void _openFilterDialog() {
    final currentFilter = ref.read(equipmentFilterProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('筛选装备清单'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TODO: 实现筛选选项
            const Text('筛选功能尚未实现'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // TODO: 应用筛选
              Navigator.of(context).pop();
            },
            child: const Text('应用'),
          ),
        ],
      ),
    );
  }

  /// 打开装备详情页面
  void _openEquipmentDetail(EquipmentListModel equipmentList) {
    // 设置选中的装备清单
    ref.read(selectedEquipmentListProvider.notifier).state = equipmentList;

    // 导航到装备详情页面
    context.go('/equipment/${equipmentList.id}');
  }

  @override
  Widget build(BuildContext context) {
    // 从状态管理器获取装备清单列表
    final equipmentLists = ref.watch(equipmentListsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('装备清单'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _openFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: 实现搜索功能
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('搜索功能尚未实现')),
              );
            },
          ),
        ],
      ),
      body: _buildBody(equipmentLists),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 实现创建装备清单功能
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('创建装备清单功能尚未实现')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 构建页面主体
  Widget _buildBody(List<EquipmentListModel> equipmentLists) {
    if (_isLoading) {
      return const LoadingView(message: '加载装备清单...');
    }

    if (_error != null) {
      return ErrorView(
        message: _error!,
        title: '加载失败',
        onRetry: _loadEquipmentLists,
      );
    }

    if (equipmentLists.isEmpty) {
      return EmptyView(
        message: '点击右下角的按钮创建装备清单',
        title: '暂无装备清单',
        icon: Icons.inventory_2,
        actionText: '创建装备清单',
        onAction: () {
          // TODO: 实现创建装备清单功能
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('创建装备清单功能尚未实现')),
          );
        },
      );
    }

    return _buildEquipmentList(equipmentLists);
  }

  /// 构建装备清单列表
  Widget _buildEquipmentList(List<EquipmentListModel> equipmentLists) {
    return RefreshIndicator(
      onRefresh: _loadEquipmentLists,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: equipmentLists.length,
        itemBuilder: (context, index) {
          final equipmentList = equipmentLists[index];
          return EquipmentListCard(
            equipmentList: equipmentList,
            onTap: () => _openEquipmentDetail(equipmentList),
          );
        },
      ),
    );
  }
}
