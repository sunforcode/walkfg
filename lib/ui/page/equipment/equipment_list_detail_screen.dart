import 'package:flutter/cupertino.dart';

import 'package:walk/model/equipment/equipment_enums.dart';
import 'package:walk/model/equipment/equipment_item_model.dart';
import 'package:walk/model/equipment/equipment_list_item_model.dart';
import 'package:walk/model/equipment/equipment_list_model.dart';
import 'package:walk/service/equipment_service.dart';
import 'package:walk/theme/tokens/colors.dart';
import 'package:walk/theme/tokens/radius.dart';
import 'package:walk/theme/tokens/spacing.dart';
import 'package:walk/theme/tokens/typography.dart';
import 'package:walk/ui/page/common/error_widget.dart';
import 'package:walk/ui/page/common/loading_indicator.dart';
import 'package:walk/ui/page/common/utility_page_scaffold.dart';
import 'package:walk/ui/page/equipment/equipment_item_picker_screen.dart';

/// 装备清单详情加载依赖，默认保持现有 [EquipmentService] 调用链。
class EquipmentListDetailDependencies {
  final Future<EquipmentListModel> Function(String listId)? loadList;
  final Future<List<EquipmentListItemModel>> Function(String listId)?
      loadRelations;
  final Future<EquipmentItemModel> Function(String itemId)? loadItem;
  final Future<Map<String, dynamic>> Function(String listId)? loadWeightStats;

  const EquipmentListDetailDependencies({
    this.loadList,
    this.loadRelations,
    this.loadItem,
    this.loadWeightStats,
  });
}

/// 装备清单详情：展示清单元数据、状态切换、清单内装备（含移除）与重量统计。
class EquipmentListDetailScreen extends StatefulWidget {
  final String listId;
  final EquipmentListDetailDependencies dependencies;

  const EquipmentListDetailScreen({
    super.key,
    required this.listId,
    this.dependencies = const EquipmentListDetailDependencies(),
  });

  @override
  State<EquipmentListDetailScreen> createState() =>
      _EquipmentListDetailScreenState();
}

/// 清单条目 + 对应装备详情的组合展示模型
class _ListItemWithDetail {
  final EquipmentListItemModel relation;
  final EquipmentItemModel? item;

  const _ListItemWithDetail({required this.relation, this.item});
}

class _EquipmentListDetailScreenState extends State<EquipmentListDetailScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  bool _hasChanged = false;

  EquipmentListModel? _list;
  List<_ListItemWithDetail> _items = [];
  Map<String, dynamic>? _weightStats;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final loadList =
          widget.dependencies.loadList ?? EquipmentService.getEquipmentListById;
      final loadRelations = widget.dependencies.loadRelations ??
          EquipmentService.getEquipmentListItems;
      final loadItem =
          widget.dependencies.loadItem ?? EquipmentService.getEquipmentItemById;
      final loadWeightStats = widget.dependencies.loadWeightStats ??
          EquipmentService.getEquipmentListWeightStats;
      final list = await loadList(widget.listId);
      final relations = await loadRelations(widget.listId);

      final itemsWithDetail = await Future.wait(relations.map((relation) async {
        try {
          final item = await loadItem(relation.equipmentItemId);
          return _ListItemWithDetail(relation: relation, item: item);
        } catch (_) {
          return _ListItemWithDetail(relation: relation, item: null);
        }
      }));

      Map<String, dynamic>? weightStats;
      try {
        weightStats = await loadWeightStats(widget.listId);
      } catch (_) {
        weightStats = null;
      }

      if (!mounted) return;
      setState(() {
        _list = list;
        _items = itemsWithDetail;
        _weightStats = weightStats;
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

  Future<void> _addItem() async {
    final picked = await Navigator.of(context).push<EquipmentItemModel>(
      CupertinoPageRoute(builder: (_) => const EquipmentItemPickerScreen()),
    );
    if (picked == null) return;
    try {
      await EquipmentService.addEquipmentToList(
        widget.listId,
        equipmentItemId: picked.id,
        quantity: 1,
      );
      _hasChanged = true;
      _loadAll();
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString());
    }
  }

  Future<void> _removeItem(_ListItemWithDetail entry) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('移除装备'),
        content: Text('确定要从清单中移除"${entry.item?.name ?? '该装备'}"吗？'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('移除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await EquipmentService.removeEquipmentFromList(
        widget.listId,
        entry.relation.equipmentItemId,
      );
      _hasChanged = true;
      _loadAll();
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString());
    }
  }

  Future<void> _changeStatus() async {
    final list = _list;
    if (list == null) return;
    final selected = await showCupertinoModalPopup<EquipmentListStatus>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('切换清单状态'),
        actions: writableEquipmentListStatuses
            .map(
              (status) => CupertinoActionSheetAction(
                onPressed: () => Navigator.of(context).pop(status),
                child: Text(status.displayName),
              ),
            )
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
      ),
    );
    if (selected == null || selected == list.status) return;
    try {
      await EquipmentService.updateEquipmentListStatus(widget.listId, selected);
      _hasChanged = true;
      _loadAll();
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString());
    }
  }

  Future<void> _deleteList() async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('删除清单'),
        content: const Text('确定要删除该装备清单吗？此操作不可撤销。'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await EquipmentService.deleteEquipmentList(widget.listId);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('操作失败'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('好的'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: UtilityPageScaffold(
        title: _list?.name ?? '清单详情',
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(_hasChanged),
          child: const Icon(CupertinoIcons.back),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _list == null ? null : _addItem,
          child: const Icon(CupertinoIcons.add),
        ),
        body: _buildBody(),
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
          onRetry: _loadAll,
        ),
      );
    }
    final list = _list;
    if (list == null) {
      return const SizedBox.shrink();
    }

    return CustomScrollView(
      slivers: [
        CupertinoSliverRefreshControl(onRefresh: _loadAll),
        SliverToBoxAdapter(child: _buildHeaderCard(list)),
        SliverToBoxAdapter(child: _buildWeightStatsCard()),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            AppSpacing.sm,
            AppSpacing.pageHorizontal,
            AppSpacing.lg,
          ),
          sliver: SliverToBoxAdapter(
            child: Text(
              '清单内装备 (${_items.length})',
              style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        if (_items.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
              child: Center(
                child: Text(
                  '暂无装备，点击右上角"+"添加',
                  style: AppTypography.bodySm,
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageHorizontal,
              0,
              AppSpacing.pageHorizontal,
              AppSpacing.pageVertical,
            ),
            sliver: SliverList.separated(
              itemCount: _items.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.listItemGap),
              itemBuilder: (context, index) {
                final entry = _items[index];
                return _ListItemCard(
                  entry: entry,
                  onRemove: () => _removeItem(entry),
                );
              },
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            0,
            AppSpacing.pageHorizontal,
            AppSpacing.xxl,
          ),
          sliver: SliverToBoxAdapter(
            child: CupertinoButton(
              color: AppColors.statusCancelledBg,
              onPressed: _deleteList,
              child: Text(
                '删除清单',
                style: AppTypography.button.copyWith(
                  color: AppColors.statusCancelledText,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCard(EquipmentListModel list) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
      child: Container(
        padding: AppSpacing.component,
        decoration: BoxDecoration(
          color: AppColors.bgPanel,
          borderRadius: AppRadius.borderPanel,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    list.name,
                    style: AppTypography.cardTitle,
                  ),
                ),
                _StatusBadge(
                  status: list.status,
                  onTap: _changeStatus,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.lg,
              runSpacing: AppSpacing.sm,
              children: [
                _buildStat(CupertinoIcons.bag, '${list.itemCount} 件装备'),
                _buildStat(CupertinoIcons.person_2, '${list.personCount} 人'),
                _buildStat(CupertinoIcons.cube_box, list.totalWeightText),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textWeak),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: AppTypography.label),
      ],
    );
  }

  Widget _buildWeightStatsCard() {
    final stats = _weightStats;
    if (stats == null) return const SizedBox.shrink();

    final totalWeight = (stats['totalWeight'] as num?)?.toDouble();
    final totalQuantity = (stats['totalQuantity'] as num?)?.toInt();
    final categoryStats = stats['categoryStats'];

    if (totalWeight == null && totalQuantity == null && categoryStats == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        0,
        AppSpacing.pageHorizontal,
        AppSpacing.lg,
      ),
      child: Container(
        padding: AppSpacing.component,
        decoration: const BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: AppRadius.borderPanel,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '重量统计',
              style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                if (totalWeight != null)
                  Expanded(
                    child: _buildStatColumn(
                      '总重量',
                      totalWeight >= 1000
                          ? '${(totalWeight / 1000).toStringAsFixed(1)}kg'
                          : '${totalWeight.toStringAsFixed(0)}g',
                    ),
                  ),
                if (totalQuantity != null)
                  Expanded(
                    child: _buildStatColumn('总数量', '$totalQuantity'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppTypography.metricValue),
        const SizedBox(height: AppSpacing.xs),
        Text(label, style: AppTypography.metricUnit),
      ],
    );
  }
}

/// Status badge with dropdown indicator, tappable to change status.
class _StatusBadge extends StatelessWidget {
  final EquipmentListStatus status;
  final VoidCallback onTap;

  const _StatusBadge({required this.status, required this.onTap});

  Color get _bgColor {
    switch (status) {
      case EquipmentListStatus.planning:
        return AppColors.statusPlanningBg;
      case EquipmentListStatus.preparing:
        return AppColors.statusPreparingBg;
      case EquipmentListStatus.completed:
        return AppColors.statusCompletedBg;
      case EquipmentListStatus.archived:
        return AppColors.surfaceCard;
    }
  }

  Color get _textColor {
    switch (status) {
      case EquipmentListStatus.planning:
        return AppColors.statusPlanningText;
      case EquipmentListStatus.preparing:
        return AppColors.statusPreparingText;
      case EquipmentListStatus.completed:
        return AppColors.statusCompletedText;
      case EquipmentListStatus.archived:
        return AppColors.textWeak;
    }
  }

  String get _statusName {
    switch (status) {
      case EquipmentListStatus.planning:
        return '计划中';
      case EquipmentListStatus.preparing:
        return '准备中';
      case EquipmentListStatus.completed:
        return '已完成';
      case EquipmentListStatus.archived:
        return '已归档';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: AppRadius.borderFull,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _statusName,
              style: AppTypography.label.copyWith(
                color: _textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(
              CupertinoIcons.chevron_down,
              size: 12,
              color: _textColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _ListItemCard extends StatelessWidget {
  final _ListItemWithDetail entry;
  final VoidCallback onRemove;

  const _ListItemCard({required this.entry, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final item = entry.item;
    return Container(
      padding: AppSpacing.component,
      decoration: BoxDecoration(
        color: AppColors.bgPanel,
        borderRadius: AppRadius.borderPanel,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item?.name ?? '未知装备',
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item != null
                      ? '${item.categoryName} · ${item.weightText} · 数量${entry.relation.quantity}'
                      : '数量${entry.relation.quantity}',
                  style: AppTypography.label,
                ),
                if (entry.relation.notes != null &&
                    entry.relation.notes!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    entry.relation.notes!,
                    style: AppTypography.label.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onRemove,
            child: const Icon(
              CupertinoIcons.minus_circle,
              color: AppColors.statusCancelledText,
            ),
          ),
        ],
      ),
    );
  }
}
