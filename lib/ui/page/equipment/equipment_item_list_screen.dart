import 'package:flutter/cupertino.dart';

import 'package:walk/model/equipment/equipment_item_model.dart';
import 'package:walk/service/equipment_service.dart';
import 'package:walk/theme/tokens/colors.dart';
import 'package:walk/ui/page/common/empty_content_widget.dart';
import 'package:walk/ui/page/common/error_widget.dart';
import 'package:walk/ui/page/common/loading_indicator.dart';
import 'package:walk/ui/page/equipment/equipment_item_edit_screen.dart';

/// 装备单品列表页面
///
/// 分页展示当前用户创建的装备单品，支持新建、点击进入详情/编辑。
class EquipmentItemListScreen extends StatefulWidget {
  const EquipmentItemListScreen({super.key});

  @override
  State<EquipmentItemListScreen> createState() =>
      _EquipmentItemListScreenState();
}

class _EquipmentItemListScreenState extends State<EquipmentItemListScreen> {
  final List<EquipmentItemModel> _items = [];
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
      final result = await EquipmentService.getEquipmentItems(page: 0);
      if (!mounted) return;
      setState(() {
        _items
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
      final result = await EquipmentService.getEquipmentItems(page: nextPage);
      if (!mounted) return;
      setState(() {
        _items.addAll(result.content);
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
        builder: (_) => const EquipmentItemEditScreen(),
      ),
    );
    if (created == true) {
      _loadInitial();
    }
  }

  Future<void> _openEdit(EquipmentItemModel item) async {
    final changed = await Navigator.of(context).push<bool>(
      CupertinoPageRoute(
        builder: (_) => EquipmentItemEditScreen(item: item),
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
        middle: const Text('我的装备'),
        trailing: CupertinoButton(
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

    if (_items.isEmpty) {
      return Center(
        child: EmptyContentWidget(
          icon: CupertinoIcons.bag,
          title: '暂无装备',
          subtitle: '添加你的第一件装备，方便后续加入装备清单',
          actionText: '添加装备',
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
              itemCount: _items.length + (_hasMore ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index >= _items.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CupertinoActivityIndicator()),
                  );
                }
                final item = _items[index];
                return _EquipmentItemCard(
                  item: item,
                  onTap: () => _openEdit(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EquipmentItemCard extends StatelessWidget {
  final EquipmentItemModel item;
  final VoidCallback onTap;

  const _EquipmentItemCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgPanel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                CupertinoIcons.bag_fill,
                color: AppColors.textWeak,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.categoryName} · ${item.weightText} · 数量${item.quantity}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textWeak,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
