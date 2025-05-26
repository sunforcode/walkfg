import 'package:flutter/cupertino.dart';
import 'package:walk/model/equipment/equipment_list_model.dart';
import 'package:walk/model/equipment/equipment_list_type.dart';
import 'package:walk/model/equipment/equipment_list_status.dart';
import 'package:walk/service/equipment_service.dart';
import 'package:walk/service/mock/mock_equipment_service.dart';
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
  late EquipmentService _equipmentService;

  // 筛选条件
  EquipmentListType? _selectedType;
  EquipmentListStatus? _selectedStatus;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _equipmentService = MockEquipmentService();
    _loadEquipmentLists();
  }

  /// 加载装备清单列表
  Future<void> _loadEquipmentLists() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      List<EquipmentListModel> lists;

      // // 根据筛选条件加载数据
      // if (_searchQuery.isNotEmpty) {
      //   lists = await _equipmentService.searchEquipmentLists(_searchQuery);
      // } else if (_selectedType != null) {
      //   lists = await _equipmentService.getEquipmentListsByType(_selectedType!);
      // } else if (_selectedStatus != null) {
      //   lists =
      //       await _equipmentService.getEquipmentListsByStatus(_selectedStatus!);
      // } else {
      // }
      lists = await _equipmentService.getEquipmentLists();

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

  /// 搜索装备清单
  Future<void> _searchEquipmentLists(String query) async {
    setState(() {
      _searchQuery = query;
    });
    await _loadEquipmentLists();
  }

  /// 筛选装备清单
  Future<void> _filterEquipmentLists() async {
    await _loadEquipmentLists();
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
      // 如果创建成功，重新加载列表
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
      // 如果创建成功，重新加载列表
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
        middle: const Text('装备清单'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.search),
              onPressed: () {
                _showSearchDialog();
              },
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.slider_horizontal_3),
              onPressed: () {
                _showFilterDialog();
              },
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.ellipsis),
              onPressed: () {
                _showMoreOptions();
              },
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
                onPressed: _createEquipmentList,
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
        onRetry: _loadEquipmentLists,
      );
    }

    if (_equipmentLists.isEmpty) {
      return EmptyView(
        icon: CupertinoIcons.bag,
        title: '暂无装备清单',
        message: '点击右下角的按钮创建装备清单',
        buttonText: '创建装备清单',
        onButtonPressed: _createEquipmentList,
      );
    }

    return ListView.builder(
      itemCount: _equipmentLists.length,
      itemBuilder: (context, index) {
        final equipmentList = _equipmentLists[index];
        return _buildEquipmentListCard(equipmentList);
      },
    );
  }

  Widget _buildEquipmentListCard(EquipmentListModel equipmentList) {
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
          // 查看装备清单详情
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题和类别
              Row(
                children: [
                  Expanded(
                    child: Text(
                      equipmentList.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.black,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      equipmentList.getTypeText(),
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
                equipmentList.description,
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
                    '${equipmentList.totalItems}个物品',
                  ),

                  const SizedBox(width: 16),

                  // 创建时间
                  _buildInfoChip(
                    CupertinoIcons.time,
                    _getTimeAgo(equipmentList.createdAt ?? DateTime.now()),
                  ),

                  const Spacer(),

                  // 状态标记
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(equipmentList.status)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
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

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 30) {
      return '${difference.inDays ~/ 30}个月前';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
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

  void _showSearchDialog() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('搜索装备清单'),
        message: Column(
          children: [
            CupertinoSearchTextField(
              placeholder: '输入关键词搜索',
              onSubmitted: (value) {
                Navigator.pop(context);
                _searchEquipmentLists(value);
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
        title: const Text('筛选装备清单'),
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
            child: const Text('按状态筛选'),
            onPressed: () {
              Navigator.pop(context);
              _showStatusFilterDialog();
            },
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            child: const Text('清除筛选'),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedType = null;
                _selectedStatus = null;
                _searchQuery = '';
              });
              _loadEquipmentLists();
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
        message: const Text('选择装备清单类型'),
        actions: EquipmentListType.values.map((type) {
          return CupertinoActionSheetAction(
            child: Text(getListTypeName(type)),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedType = type;
                _selectedStatus = null;
              });
              _filterEquipmentLists();
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

  void _showStatusFilterDialog() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('按状态筛选'),
        message: const Text('选择装备清单状态'),
        actions: EquipmentListStatus.values.map((status) {
          return CupertinoActionSheetAction(
            child: Text(getListStatusName(status)),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedStatus = status;
                _selectedType = null;
              });
              _filterEquipmentLists();
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

  void _showMoreOptions() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('更多选项'),
        message: const Text('选择操作'),
        actions: [
          CupertinoActionSheetAction(
            child: const Text('从模板创建'),
            onPressed: () {
              Navigator.pop(context);
              _createFromTemplate();
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('查看我的装备库'),
            onPressed: () {
              Navigator.pop(context);
              _viewInventory();
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('刷新列表'),
            onPressed: () {
              Navigator.pop(context);
              _loadEquipmentLists();
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
