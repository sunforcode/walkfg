import 'package:flutter/cupertino.dart';

import 'package:walk/model/equipment/equipment_list_model.dart';
import 'package:walk/model/trip/trip_model.dart';
import 'package:walk/service/equipment_service.dart';
import 'package:walk/ui/page/equipment/equipment_list_create_screen.dart';
import 'package:walk/ui/page/equipment/equipment_list_detail_screen.dart';
import 'package:walk/ui/page/equipment/equipment_list_list_screen.dart';

/// 行程关联装备清单展示组件
///
/// 严格对齐后端 `trip-equipment-link` change：
/// - 通过 [TripModel.equipmentListId]（后端 `GET /trips/{id}` 已解析）判断
///   该行程是否已关联装备清单，若有则展示清单摘要（类型/人数/重量/条目数），
///   点击进入 [EquipmentListDetailScreen]。
/// - 若行程存在多个关联清单，此处仅展示最近创建的一个（与后端摘要字段语义
///   一致），完整列表通过 `GET /trips/{id}/equipment-lists` 获取，入口为
///   "查看全部关联清单"。
/// - 未关联时提供"新建清单"（自动关联到当前行程）与"关联已有清单"两个入口。
class TripEquipmentDisplayWidget extends StatefulWidget {
  final TripModel trip;

  const TripEquipmentDisplayWidget({
    super.key,
    required this.trip,
  });

  @override
  State<TripEquipmentDisplayWidget> createState() =>
      _TripEquipmentDisplayWidgetState();
}

class _TripEquipmentDisplayWidgetState
    extends State<TripEquipmentDisplayWidget> {
  bool _isLoading = true;
  String? _errorMessage;
  EquipmentListModel? _list;
  int _linkedListCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant TripEquipmentDisplayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trip.id != widget.trip.id ||
        oldWidget.trip.equipmentListId != widget.trip.equipmentListId) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // 优先直接用行程详情已经解析好的 equipment_list_id 拉取摘要，
      // 避免多一次列表查询；同时查询关联清单总数用于展示“查看全部”。
      final pageResult = await EquipmentService.getEquipmentListsByTrip(
        widget.trip.id,
        page: 0,
        size: 20,
      );
      if (!mounted) return;
      final listId = widget.trip.equipmentListId;
      EquipmentListModel? matched;
      if (listId != null) {
        for (final item in pageResult.content) {
          if (item.id == listId) {
            matched = item;
            break;
          }
        }
      }
      matched ??= pageResult.content.isNotEmpty ? pageResult.content.first : null;
      setState(() {
        _list = matched;
        _linkedListCount = pageResult.totalElements;
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

  Future<void> _createList() async {
    final result = await Navigator.of(context).push<bool>(
      CupertinoPageRoute(
        builder: (context) =>
            EquipmentListCreateScreen(tripId: widget.trip.id),
      ),
    );
    if (result == true) {
      _loadData();
    }
  }

  Future<void> _linkExistingList() async {
    // 复用装备清单列表页选择一个清单，再通过更新接口关联到当前行程。
    final selected = await Navigator.of(context).push<EquipmentListModel>(
      CupertinoPageRoute(
        builder: (context) => const EquipmentListListScreen(pickMode: true),
      ),
    );
    if (selected == null) return;
    try {
      await EquipmentService.updateEquipmentList(
        selected.id,
        tripId: widget.trip.id,
      );
      if (!mounted) return;
      _loadData();
    } catch (e) {
      if (!mounted) return;
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('关联失败'),
          content: Text(e.toString()),
          actions: [
            CupertinoDialogAction(
              child: const Text('确定'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  void _openListDetail(String listId) async {
    final changed = await Navigator.of(context).push<bool>(
      CupertinoPageRoute(
        builder: (context) => EquipmentListDetailScreen(listId: listId),
      ),
    );
    if (changed == true) {
      _loadData();
    }
  }

  /// 查看该行程关联的全部装备清单（浏览模式，非选择模式）。
  ///
  /// 当前暂无专门展示"某行程关联的多个清单"的独立页面，复用装备清单
  /// 列表页的普通浏览模式，用户可从中查看/管理清单；后续如需按行程过滤
  /// 展示，可在此基础上扩展。
  void _viewAllLinkedLists() async {
    final changed = await Navigator.of(context).push<bool>(
      CupertinoPageRoute(
        builder: (context) => const EquipmentListListScreen(),
      ),
    );
    if (changed == true) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.bag,
                size: 20,
                color: CupertinoColors.systemPurple,
              ),
              const SizedBox(width: 8),
              const Text(
                '装备清单',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.label,
                ),
              ),
              const Spacer(),
              if (_linkedListCount > 1)
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _viewAllLinkedLists,
                  child: Text(
                    '查看全部($_linkedListCount)',
                    style: const TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.systemPurple,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CupertinoActivityIndicator(),
              ),
            )
          else if (_errorMessage != null)
            _buildErrorState()
          else if (_list != null)
            _buildListSummaryCard(_list!)
          else
            _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            _errorMessage!,
            style: const TextStyle(
              fontSize: 13,
              color: CupertinoColors.systemRed,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _loadData,
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildListSummaryCard(EquipmentListModel list) {
    return GestureDetector(
      onTap: () => _openListDetail(list.id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: CupertinoColors.separator,
            width: 0.5,
          ),
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
                      color: CupertinoColors.label,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    list.typeName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemPurple,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  CupertinoIcons.chevron_right,
                  size: 16,
                  color: CupertinoColors.tertiaryLabel,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: '总重量',
                    value: list.totalWeightText,
                    color: CupertinoColors.systemBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: '装备数',
                    value: '${list.itemCount}',
                    color: CupertinoColors.systemGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: '状态',
                    value: list.statusName,
                    color: CupertinoColors.systemOrange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.separator,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            CupertinoIcons.bag,
            size: 48,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无装备清单',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '制定装备清单，确保行程安全',
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.tertiaryLabel,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoButton(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: CupertinoColors.systemPurple,
                borderRadius: BorderRadius.circular(8),
                onPressed: _createList,
                child: const Text(
                  '新建清单',
                  style: TextStyle(fontSize: 14, color: CupertinoColors.white),
                ),
              ),
              const SizedBox(width: 12),
              CupertinoButton(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(8),
                onPressed: _linkExistingList,
                child: const Text(
                  '关联已有清单',
                  style: TextStyle(fontSize: 14, color: CupertinoColors.label),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
