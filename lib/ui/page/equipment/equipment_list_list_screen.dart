import 'package:flutter/cupertino.dart';

import 'package:walk/model/equipment/equipment_enums.dart';
import 'package:walk/model/equipment/equipment_list_model.dart';
import 'package:walk/service/equipment_service.dart';
import 'package:walk/theme/tokens/colors.dart';
import 'package:walk/theme/tokens/radius.dart';
import 'package:walk/theme/tokens/spacing.dart';
import 'package:walk/theme/tokens/typography.dart';
import 'package:walk/ui/page/common/empty_content_widget.dart';
import 'package:walk/ui/page/common/error_widget.dart';
import 'package:walk/ui/page/common/loading_indicator.dart';
import 'package:walk/ui/page/common/utility_page_scaffold.dart';
import 'package:walk/ui/page/equipment/equipment_list_create_screen.dart';
import 'package:walk/ui/page/equipment/equipment_list_detail_screen.dart';

typedef EquipmentListsLoader = Future<EquipmentPageResult<EquipmentListModel>>
    Function({required int page});

/// 装备清单列表页面
///
/// 当 [pickMode] 为 true 时，点击清单卡片不再进入详情页，而是通过
/// `Navigator.pop` 将选中的 [EquipmentListModel] 返回给调用方（用于
/// "关联已有清单"场景，见 `TripEquipmentDisplayWidget`）。
class EquipmentListListScreen extends StatefulWidget {
  const EquipmentListListScreen({
    super.key,
    this.pickMode = false,
    this.listsLoader,
  });

  /// 是否为选择模式
  final bool pickMode;

  /// 可注入的分页加载入口；生产环境默认调用 [EquipmentService]。
  final EquipmentListsLoader? listsLoader;

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
  int _loadGeneration = 0;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<EquipmentPageResult<EquipmentListModel>> _loadPage(int page) {
    final loader = widget.listsLoader;
    if (loader != null) return loader(page: page);
    return EquipmentService.getEquipmentLists(page: page);
  }

  Future<void> _loadInitial() async {
    final generation = ++_loadGeneration;
    setState(() {
      _isLoading = true;
      _isLoadingMore = false;
      _errorMessage = null;
      _page = 0;
    });
    try {
      final result = await _loadPage(0);
      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        _lists
          ..clear()
          ..addAll(result.content);
        _hasMore = result.hasMore;
        _page = 0;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;
    final generation = _loadGeneration;
    setState(() => _isLoadingMore = true);
    try {
      final nextPage = _page + 1;
      final result = await _loadPage(nextPage);
      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        _lists.addAll(result.content);
        _hasMore = result.hasMore;
        _page = nextPage;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted || generation != _loadGeneration) return;
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
    return UtilityPageScaffold(
      title: widget.pickMode ? '选择装备清单' : '装备清单',
      trailing: widget.pickMode
          ? null
          : CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _openCreate,
              child: const Icon(CupertinoIcons.add),
            ),
      body: _buildBody(),
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
            padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
            sliver: SliverList.separated(
              itemCount: _lists.length + (_isLoadingMore ? 1 : 0),
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.listItemGap),
              itemBuilder: (context, index) {
                if (index >= _lists.length) {
                  return const Padding(
                    padding: AppSpacing.verticalLg,
                    child: Center(child: CupertinoActivityIndicator()),
                  );
                }
                final list = _lists[index];
                return _EquipmentListCard(
                  key: Key('equipment-list-card-${list.id}'),
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

  const _EquipmentListCard({
    super.key,
    required this.list,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
            _CardHeader(list: list),
            const SizedBox(height: AppSpacing.sm),
            _CardInfoChips(list: list),
          ],
        ),
      ),
    );
  }
}

/// Header row with list name and status badge.
class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.list});

  final EquipmentListModel list;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            list.name,
            style: AppTypography.cardTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _StatusBadge(status: list.status, statusName: list.statusName),
      ],
    );
  }
}

/// Status badge pill that maps [EquipmentListStatus] to AppColors badge tokens.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.statusName});

  final EquipmentListStatus status;
  final String statusName;

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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: AppRadius.borderFull,
      ),
      child: Text(
        statusName,
        style: AppTypography.micro.copyWith(
          color: _textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Row of info chips showing item count, person count, and total weight.
class _CardInfoChips extends StatelessWidget {
  const _CardInfoChips({required this.list});

  final EquipmentListModel list;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _InfoChip(CupertinoIcons.bag, '${list.itemCount} 件装备'),
        _InfoChip(CupertinoIcons.person_2, '${list.personCount} 人'),
        _InfoChip(CupertinoIcons.cube_box, list.totalWeightText),
      ],
    );
  }
}

/// Single info chip with icon and label.
class _InfoChip extends StatelessWidget {
  const _InfoChip(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.borderFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textWeak),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: AppTypography.micro),
        ],
      ),
    );
  }
}
