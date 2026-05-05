import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show FloatingActionButton;
import 'package:walk/model/equipment/equipment_list_model.dart';
import 'package:walk/model/equipment/equipment_list_status.dart';
import 'package:walk/service/equipment_service.dart';
import 'package:walk/ui/page/equipment/equipment_detail_screen.dart';
import 'package:walk/ui/page/equipment/equipment_create_screen.dart';
import 'package:walk/ui/page/equipment/equipment_template_screen.dart';
import 'package:walk/ui/page/equipment/equipment_inventory_screen.dart';
import 'package:walk/ui/widget/error_view.dart';
import 'package:walk/ui/widget/empty_view.dart';

/// iOS风格的装备列表页面
class EquipmentScreen extends StatefulWidget {
  /// 构造函数
  const EquipmentScreen({super.key});

  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> {
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
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final lists = await EquipmentService.getEquipmentLists();

      if (mounted) {
        setState(() {
          _equipmentLists = lists;
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

  /// 创建新装备清单
  Future<void> _createEquipmentList() async {
    final result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const EquipmentCreateScreen(),
      ),
    );

    if (result == true) {
      await _loadEquipmentLists();
    }
  }

  /// 从模板创建装备清单
  Future<void> _createFromTemplate() async {
    final result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const EquipmentTemplateScreen(),
      ),
    );

    if (result == true) {
      await _loadEquipmentLists();
    }
  }

  /// 查看用户装备库
  Future<void> _viewInventory() async {
    await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const EquipmentInventoryScreen(userId: 'user001'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('装备'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(CupertinoIcons.cube_box),
              SizedBox(width: 4),
              Text('装备库'),
            ],
          ),
          onPressed: _viewInventory,
        ),
      ),
      child: Stack(
        children: [
          SafeArea(
            child: _buildBody(),
          ),
          // 浮动创建按钮
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              backgroundColor: CupertinoColors.activeBlue,
              child: const Icon(CupertinoIcons.add),
              onPressed: _showCreateOptions,
            ),
          ),
        ],
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
        onRetry: _loadEquipmentLists,
      );
    }

    if (_equipmentLists.isEmpty) {
      return EmptyView(
        icon: CupertinoIcons.bag,
        title: '暂无装备清单',
        message: '点击右下角的"+"按钮创建装备清单',
        buttonText: '创建装备清单',
        onButtonPressed: _createEquipmentList,
      );
    }

    return _buildListView();
  }

  /// 构建列表视图
  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80), // 为浮动按钮留出空间
      itemCount: _equipmentLists.length,
      itemBuilder: (context, index) {
        final equipmentList = _equipmentLists[index];
        return _buildEquipmentListCard(equipmentList);
      },
    );
  }

  Widget _buildEquipmentListCard(EquipmentListModel equipmentList) {
    final hasDescription = equipmentList.description.trim().isNotEmpty;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => EquipmentDetailScreen(
                equipmentListId: equipmentList.id,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 左侧：名称 + 描述
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 装备包名称
                    Text(
                      equipmentList.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.black,
                      ),
                    ),
                    // 描述预览（如果有）
                    if (hasDescription)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          equipmentList.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.systemGrey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // 右侧：数量、重量、状态
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 物品数量和重量
                  Row(
                    children: [
                      _buildInfoChip('${equipmentList.totalItems}件'),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        '${(equipmentList.totalWeight / 1000).toStringAsFixed(1)}kg',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 状态徽章
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(equipmentList.status)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(equipmentList.status),
                          size: 12,
                          color: _getStatusColor(equipmentList.status),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          equipmentList.getStatusText(),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getStatusColor(equipmentList.status),
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

  Widget _buildInfoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: CupertinoColors.systemGrey,
        ),
      ),
    );
  }

  Color _getStatusColor(EquipmentListStatus status) {
    switch (status) {
      case EquipmentListStatus.planning:
        return CupertinoColors.systemBlue;
      case EquipmentListStatus.preparing:
        return CupertinoColors.systemOrange;
      case EquipmentListStatus.ready:
        return CupertinoColors.systemGreen;
      case EquipmentListStatus.inUse:
        return CupertinoColors.systemPurple;
      case EquipmentListStatus.completed:
        return CupertinoColors.systemGrey;
      case EquipmentListStatus.archived:
        return CupertinoColors.systemGrey2;
    }
  }

  IconData _getStatusIcon(EquipmentListStatus status) {
    switch (status) {
      case EquipmentListStatus.planning:
        return CupertinoIcons.doc_text;
      case EquipmentListStatus.preparing:
        return CupertinoIcons.bag_fill_badge_plus;
      case EquipmentListStatus.ready:
        return CupertinoIcons.checkmark_circle;
      case EquipmentListStatus.inUse:
        return CupertinoIcons.arrow_right_circle;
      case EquipmentListStatus.completed:
        return CupertinoIcons.flag;
      case EquipmentListStatus.archived:
        return CupertinoIcons.archivebox;
    }
  }

  void _showCreateOptions() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('创建装备清单'),
        message: const Text('选择创建方式'),
        actions: [
          CupertinoActionSheetAction(
            child: const Text('创建新清单'),
            onPressed: () {
              Navigator.pop(context);
              _createEquipmentList();
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('从模板创建'),
            onPressed: () {
              Navigator.pop(context);
              _createFromTemplate();
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
}
