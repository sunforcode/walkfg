/// 装备详情页面
///
/// 显示装备清单的详细信息，包括分类和项目

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../model/equipment/equipment_model.dart';
import '../../../service/service_manager.dart';
import 'widgets/equipment_category_list.dart';
import 'widgets/equipment_summary_card.dart';
import '../common/loading_view.dart';
import '../common/error_view.dart';

/// 装备详情页面
class EquipmentDetailScreen extends ConsumerStatefulWidget {
  /// 装备清单ID
  final String equipmentId;

  /// 构造函数
  const EquipmentDetailScreen({
    super.key,
    required this.equipmentId,
  });

  @override
  ConsumerState<EquipmentDetailScreen> createState() => _EquipmentDetailScreenState();
}

class _EquipmentDetailScreenState extends ConsumerState<EquipmentDetailScreen> {
  bool _isLoading = true;
  String? _error;
  EquipmentListModel? _equipmentList;

  @override
  void initState() {
    super.initState();
    _loadEquipmentList();
  }

  /// 加载装备清单
  Future<void> _loadEquipmentList() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // 使用EquipmentService加载装备清单
      final equipmentService = ServiceLocator.instance.getEquipmentService();
      final equipmentList = await equipmentService.getEquipmentListById(widget.equipmentId);

      setState(() {
        _equipmentList = equipmentList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// 显示删除确认对话框
  void _showDeleteConfirmationDialog(EquipmentListModel equipmentList) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除装备清单'),
        content: Text('确定要删除"${equipmentList.name}"吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              // 删除装备清单
              final equipmentService = ServiceLocator.instance.getEquipmentService();
              await equipmentService.deleteEquipmentList(equipmentList.id);

              // 关闭对话框
              Navigator.of(context).pop();

              // 返回上一页
              Navigator.of(context).pop();

              // 显示提示
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('装备清单已删除')),
              );
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('装备详情')),
        body: const LoadingView(message: '加载装备清单...'),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('装备详情')),
        body: ErrorView(
          message: _error!,
          title: '加载失败',
          onRetry: _loadEquipmentList,
        ),
      );
    }

    if (_equipmentList == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('装备详情')),
        body: const Center(child: Text('装备清单不存在')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_equipmentList!.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: 实现编辑装备清单功能
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('编辑装备清单功能尚未实现')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmationDialog(_equipmentList!);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 装备清单摘要卡片
            EquipmentSummaryCard(equipmentList: _equipmentList!),

            const SizedBox(height: 16),

            // 装备清单描述
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '描述',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(_equipmentList!.description),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 装备分类标题
            Text(
              '装备分类',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '按类别查看装备项目',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),

            // 装备分类列表
            EquipmentCategoryList(equipments: _equipmentList!.equipments),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 实现导出装备清单功能
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('导出装备清单功能尚未实现')),
          );
        },
        child: const Icon(Icons.share),
      ),
    );
  }
}