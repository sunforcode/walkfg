import 'package:flutter/cupertino.dart';

import 'package:walk/model/equipment/equipment_enums.dart';
import 'package:walk/model/equipment/equipment_list_model.dart';
import 'package:walk/service/equipment_service.dart';
import 'package:walk/ui/page/common/empty_content_widget.dart';
import 'package:walk/ui/page/common/error_widget.dart';
import 'package:walk/ui/page/common/loading_indicator.dart';
import 'package:walk/ui/page/equipment/equipment_list_create_screen.dart';
import 'package:walk/ui/page/equipment/equipment_list_detail_screen.dart';

/// 装备清单列表页面
///
/// 当 [pickMode] 为 true 时，点击清单卡片不再进入详情页，而是通过
/// `Navigator.pop` 将选中的 [EquipmentListModel] 返回给调用方（用于
/// "关联已有清单"场景，见 `TripEquipmentDisplayWidget`）。
class EquipmentListListScreen extends StatefulWidget {
  const EquipmentListListScreen({super.key, this.pickMode = false});

  /// 是否为选择模式
  final bool pickMode;

  @override
  State<EquipmentListListScreen> createState() =>
      _EquipmentListListScreenState();
}

class _EquipmentListListScreenState extends State<EquipmentListListScreen> {
  final List<EquipmentListModel> _lists = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _page = 0;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _page = 0;
    });
    try {
      final result = await EquipmentService.getEquipmentLists(page: 0);
      if (!mounted) return;
      setState(() {
        _lists
          ..clear()
          ..addAll(result.content);
        _hasMore = result.hasMore;
        _page = 0;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final nextPage = _page + 1;
      final result = await EquipmentService.getEquipmentLists(page: nextPage);
      if (!mounted) return;
      setState(() {
        _lists.addAll(result.content);
        _hasMore = result.hasMore;
        _page = nextPage;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _openCreate() async {
    final created = await Navigator.of(context).push<bool>(
      CupertinoPageRoute(
        builder: (_) => const EquipmentListCreateScreen(),
      ),
    );
    if (created == true) {
      _loadInitial();
    }
  }

  Future<void> _openDetail(EquipmentListModel list) async {
    if (widget.pickMode) {
      Navigator.of(context).pop(list);
      return;
    }
    final changed = await Navigator.of(context).push<bool>(
      CupertinoPageRoute(
        builder: (_) => EquipmentListDetailScreen(listId: list.id),
      ),
    );
    if (changed == true) {
      _loadInitial();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.pickMode ? '选择装备清单' : '装备清单'),
        trailing: widget.pickMode
            ? null
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _openCreate,
                child: const Icon(CupertinoIcons.add),
              ),
      ),
      child: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingIndicator();
    }

    if (_errorMessage != null) {
      return Center(
        child: ErrorMessageWidget(
          errorMessage: _errorMessage!,
          onRetry: _loadInitial,
        ),
      );
    }

    if (_lists.isEmpty) {
      return Center(
        child: EmptyContentWidget(
          icon: CupertinoIcons.list_bullet_below_rectangle,
          title: '暂无装备清单',
          subtitle: '创建一份清单，规划本次出行需要携带的装备',
          actionText: '新建清单',
          onAction: _openCreate,
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 200) {
          _loadMore();
        }
        return false;
      },
      child: CustomScrollView(
        slivers: [
          CupertinoSliverRefreshControl(onRefresh: _loadInitial),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList.separated(
              itemCount: _lists.length + (_hasMore ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index >= _lists.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CupertinoActivityIndicator()),
                  );
                }
                final list = _lists[index];
                return _EquipmentListCard(
                  list: list,
                  onTap: () => _openDetail(list),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EquipmentListCard extends StatelessWidget {
  final EquipmentListModel list;
  final VoidCallback onTap;

  const _EquipmentListCard({required this.list, required this.onTap});

  Color _statusColor(EquipmentListStatus status) {
    switch (status) {
      case EquipmentListStatus.planning:
        return CupertinoColors.activeOrange;
      case EquipmentListStatus.preparing:
        return CupertinoColors.activeBlue;
      case EquipmentListStatus.completed:
        return CupertinoColors.activeGreen;
      case EquipmentListStatus.archived:
        return CupertinoColors.systemGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(list.status);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CupertinoColors.systemGrey5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    list.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    list.statusName,
                    style: TextStyle(
                      fontSize: 11,
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInfoChip(CupertinoIcons.bag, '${list.itemCount} 件装备'),
                const SizedBox(width: 8),
                _buildInfoChip(CupertinoIcons.person_2, '${list.personCount} 人'),
                const SizedBox(width: 8),
                _buildInfoChip(
                    CupertinoIcons.cube_box, list.totalWeightText),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: CupertinoColors.systemGrey),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }
}
