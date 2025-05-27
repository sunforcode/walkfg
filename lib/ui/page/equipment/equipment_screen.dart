import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show FloatingActionButton;
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

  // 视图模式
  bool _isListView = true;

  // 快速筛选标签选择
  int _selectedQuickFilterIndex = 0;
  final List<String> _quickFilters = ['全部', '进行中', '已完成', '已归档'];
  final List<EquipmentListStatus?> _quickFilterStatuses = [
    null, // 全部
    EquipmentListStatus.preparing, // 进行中
    EquipmentListStatus.completed, // 已完成
    EquipmentListStatus.archived, // 已归档
  ];

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

      // 根据筛选条件加载数据
      if (_searchQuery.isNotEmpty) {
        lists = await _equipmentService.searchEquipmentLists(_searchQuery);
      } else if (_selectedType != null) {
        lists = await _equipmentService.getEquipmentListsByType(_selectedType!);
      } else if (_selectedStatus != null) {
        lists =
            await _equipmentService.getEquipmentListsByStatus(_selectedStatus!);
      } else {
        lists = await _equipmentService.getEquipmentLists();
      }

      // 应用快速筛选
      if (_selectedQuickFilterIndex > 0) {
        final status = _quickFilterStatuses[_selectedQuickFilterIndex];
        if (status == EquipmentListStatus.preparing) {
          // "进行中"包括：计划中、准备中、准备就绪、使用中
          lists = lists
              .where((list) =>
                  list.status == EquipmentListStatus.planning ||
                  list.status == EquipmentListStatus.preparing ||
                  list.status == EquipmentListStatus.ready ||
                  list.status == EquipmentListStatus.inUse)
              .toList();
        } else if (status != null) {
          lists = lists.where((list) => list.status == status).toList();
        }
      }

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
      // 重置其他筛选条件
      _selectedType = null;
      _selectedStatus = null;
      _selectedQuickFilterIndex = 0;
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

  /// 切换视图模式
  void _toggleViewMode() {
    setState(() {
      _isListView = !_isListView;
    });
  }

  /// 应用快速筛选
  void _applyQuickFilter(int index) {
    if (_selectedQuickFilterIndex == index) return;

    setState(() {
      _selectedQuickFilterIndex = index;
      // 重置其他筛选条件
      _selectedType = null;
      _selectedStatus = null;
      _searchQuery = '';
    });

    _loadEquipmentLists();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('装备清单'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.ellipsis_vertical),
          onPressed: _showMoreOptions,
        ),
      ),
      child: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // 搜索栏和快捷操作区域
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Column(
                    children: [
                      // 搜索栏
                      CupertinoSearchTextField(
                        placeholder: '搜索装备清单',
                        onSubmitted: _searchEquipmentLists,
                        onSuffixTap: () {
                          if (_searchQuery.isNotEmpty) {
                            setState(() {
                              _searchQuery = '';
                            });
                            _loadEquipmentLists();
                          }
                        },
                      ),

                      const SizedBox(height: 12),

                      // 快速筛选标签
                      SizedBox(
                        height: 32,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _quickFilters.length,
                          itemBuilder: (context, index) {
                            final isSelected =
                                _selectedQuickFilterIndex == index;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: CupertinoButton(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                color: isSelected
                                    ? CupertinoColors.systemBlue
                                    : CupertinoColors.systemGrey6,
                                borderRadius: BorderRadius.circular(16),
                                minSize: 0,
                                child: Text(
                                  _quickFilters[index],
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isSelected
                                        ? CupertinoColors.white
                                        : CupertinoColors.systemGrey,
                                  ),
                                ),
                                onPressed: () => _applyQuickFilter(index),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 快捷操作按钮
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 我的装备库
                          _buildQuickActionButton(
                            icon: CupertinoIcons.cube_box,
                            label: '我的装备库',
                            onPressed: _viewInventory,
                          ),

                          // 饮食偏好
                          _buildQuickActionButton(
                            icon: CupertinoIcons.flame,
                            label: '饮食偏好',
                            onPressed: () {
                              // 占位功能
                              _showPlaceholderDialog('饮食偏好功能尚未实现');
                            },
                          ),

                          // 行程规划
                          _buildQuickActionButton(
                            icon: CupertinoIcons.map,
                            label: '行程规划',
                            onPressed: () {
                              // 占位功能
                              _showPlaceholderDialog('行程规划功能尚未实现');
                            },
                          ),

                          // 筛选
                          _buildQuickActionButton(
                            icon: CupertinoIcons.slider_horizontal_3,
                            label: '筛选',
                            onPressed: _showFilterDialog,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 列表信息和视图切换
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 显示装备清单数量
                      Text(
                        '共 ${_equipmentLists.length} 个清单',
                        style: const TextStyle(
                          color: CupertinoColors.systemGrey,
                          fontSize: 14,
                        ),
                      ),

                      // 视图切换按钮
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Row(
                          children: [
                            Icon(
                              _isListView
                                  ? CupertinoIcons.square_grid_2x2
                                  : CupertinoIcons.list_bullet,
                              color: CupertinoColors.systemBlue,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _isListView ? '网格视图' : '列表视图',
                              style: const TextStyle(
                                fontSize: 14,
                                color: CupertinoColors.systemBlue,
                              ),
                            ),
                          ],
                        ),
                        onPressed: _toggleViewMode,
                      ),
                    ],
                  ),
                ),

                // 主体内容
                Expanded(
                  child: _buildBody(),
                ),
              ],
            ),
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

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: CupertinoColors.systemBlue,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.systemBlue,
            ),
            textAlign: TextAlign.center,
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

    // 根据视图模式选择不同的展示方式
    return _isListView ? _buildListView() : _buildGridView();
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

  /// 构建网格视图
  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 80), // 为浮动按钮留出空间
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _equipmentLists.length,
      itemBuilder: (context, index) {
        return _buildEquipmentGridCard(_equipmentLists[index]);
      },
    );
  }

  /// 构建网格卡片
  Widget _buildEquipmentGridCard(EquipmentListModel equipmentList) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => EquipmentDetailScreen(
              equipmentListId: equipmentList.id,
            ),
          ),
        );
      },
      onLongPress: () => _showItemActions(equipmentList),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 状态指示器和分享按钮
            Stack(
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: _getStatusColor(equipmentList.status),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    minSize: 0,
                    child: Icon(
                      CupertinoIcons.share,
                      color: CupertinoColors.systemBlue,
                      size: 20,
                    ),
                    onPressed: () {
                      _showPlaceholderDialog('分享功能尚未实现');
                    },
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  Text(
                    equipmentList.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // 描述
                  Text(
                    equipmentList.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // 进度指示器
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '准备进度',
                            style: TextStyle(
                              fontSize: 11,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                          Text(
                            '${equipmentList.preparationPercentage.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _getProgressColor(
                                  equipmentList.preparationPercentage),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 4,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey6,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor:
                              equipmentList.preparationPercentage / 100,
                          child: Container(
                            decoration: BoxDecoration(
                              color: _getProgressColor(
                                  equipmentList.preparationPercentage),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 物品数量和重量
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniInfoChip(
                        CupertinoIcons.list_bullet,
                        '${equipmentList.totalItems}项',
                      ),
                      _buildMiniInfoChip(
                        CupertinoIcons.arrow_up_bin,
                        '${(equipmentList.totalWeight / 1000).toStringAsFixed(1)}kg',
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // 状态标签
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(equipmentList.status)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(equipmentList.status),
                          size: 10,
                          color: _getStatusColor(equipmentList.status),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          equipmentList.getStatusText(),
                          style: TextStyle(
                            fontSize: 10,
                            color: _getStatusColor(equipmentList.status),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
        onLongPress: () => _showItemActions(equipmentList),
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
                      color: _getTypeColor(equipmentList.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      equipmentList.getTypeText(),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getTypeColor(equipmentList.type),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 分享按钮
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minSize: 0,
                    child: Icon(
                      CupertinoIcons.share,
                      color: CupertinoColors.systemBlue,
                      size: 20,
                    ),
                    onPressed: () {
                      _showPlaceholderDialog('分享功能尚未实现');
                    },
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

              // 进度条
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '准备进度: ${equipmentList.preparedItems}/${equipmentList.totalItems}',
                        style: TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                      Text(
                        '${equipmentList.preparationPercentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getProgressColor(
                              equipmentList.preparationPercentage),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 4,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: equipmentList.preparationPercentage / 100,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _getProgressColor(
                              equipmentList.preparationPercentage),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ],
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

                  // 总重量
                  _buildInfoChip(
                    CupertinoIcons.arrow_up_bin,
                    '${(equipmentList.totalWeight / 1000).toStringAsFixed(1)}kg',
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

  Widget _buildMiniInfoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(
          icon,
          size: 12,
          color: CupertinoColors.systemGrey,
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
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

  Color _getTypeColor(EquipmentListType type) {
    switch (type) {
      case EquipmentListType.mountaineering:
        return CupertinoColors.systemIndigo;
      case EquipmentListType.longHike:
        return CupertinoColors.systemGreen;
      case EquipmentListType.trekking:
        return CupertinoColors.systemOrange;
      case EquipmentListType.camping:
        return CupertinoColors.systemYellow;
      case EquipmentListType.shortHike:
        return CupertinoColors.activeGreen;
      case EquipmentListType.custom:
        return CupertinoColors.systemGrey;
    }
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 100) {
      return CupertinoColors.systemGreen;
    } else if (percentage >= 75) {
      return CupertinoColors.activeBlue;
    } else if (percentage >= 50) {
      return CupertinoColors.systemOrange;
    } else if (percentage >= 25) {
      return CupertinoColors.systemYellow;
    } else {
      return CupertinoColors.systemRed;
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

  void _showItemActions(EquipmentListModel equipmentList) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(equipmentList.name),
        message: const Text('选择操作'),
        actions: [
          CupertinoActionSheetAction(
            child: const Text('查看详情'),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => EquipmentDetailScreen(
                    equipmentListId: equipmentList.id,
                  ),
                ),
              );
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('复制清单'),
            onPressed: () {
              Navigator.pop(context);
              _showPlaceholderDialog('复制清单功能尚未实现');
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('分享清单'),
            onPressed: () {
              Navigator.pop(context);
              _showPlaceholderDialog('分享清单功能尚未实现');
            },
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            child: const Text('删除清单'),
            onPressed: () {
              Navigator.pop(context);
              _showPlaceholderDialog('删除清单功能尚未实现');
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
                _selectedQuickFilterIndex = 0;
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
                _selectedQuickFilterIndex = 0;
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
                _selectedQuickFilterIndex = 0;
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
            child: const Text('刷新列表'),
            onPressed: () {
              Navigator.pop(context);
              _loadEquipmentLists();
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
            child: const Text('装备商城'),
            onPressed: () {
              Navigator.pop(context);
              _showPlaceholderDialog('装备商城功能尚未实现');
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('天气预报'),
            onPressed: () {
              Navigator.pop(context);
              _showPlaceholderDialog('天气预报功能尚未实现');
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

  void _showPlaceholderDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('功能开发中'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('确定'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
