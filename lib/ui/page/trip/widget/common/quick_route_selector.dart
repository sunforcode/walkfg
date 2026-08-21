import 'package:flutter/cupertino.dart';
import 'package:walk/model/route/route_model.dart';
import 'package:walk/theme/tokens/colors.dart';

/// 快速路线选择组件
class QuickRouteSelector extends StatefulWidget {
  final Function(RouteModel) onRouteSelected;
  final List<RouteModel> selectedRoutes;

  const QuickRouteSelector({
    super.key,
    required this.onRouteSelected,
    this.selectedRoutes = const [],
  });

  @override
  State<QuickRouteSelector> createState() => _QuickRouteSelectorState();
}

class _QuickRouteSelectorState extends State<QuickRouteSelector> {
  final TextEditingController _searchController = TextEditingController();
  List<RouteModel> _searchResults = [];
  bool _isSearching = false;
  bool _showResults = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _showResults = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _showResults = true;
    });

    // 模拟搜索延迟
    await Future.delayed(Duration(milliseconds: 300));

    // 模拟搜索结果
    final results = _getMockSearchResults(query);

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  List<RouteModel> _getMockSearchResults(String query) {
    // 模拟搜索结果
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 搜索框
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Icon(
                    CupertinoIcons.search,
                    color: AppColors.textHint,
                    size: 20,
                  ),
                ),
                Expanded(
                  child: CupertinoTextField(
                    controller: _searchController,
                    placeholder: '搜索路线名称或地区',
                    decoration: BoxDecoration(),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    onChanged: _performSearch,
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  CupertinoButton(
                    padding: EdgeInsets.only(right: 8),
                    onPressed: () {
                      _searchController.clear();
                      _performSearch('');
                    },
                    child: Icon(
                      CupertinoIcons.xmark_circle_fill,
                      color: AppColors.textHint,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),

          // 搜索结果
          if (_showResults) ...[
            SizedBox(height: 12),
            Container(
              constraints: BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: AppColors.bgBase,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.surfaceDivider,
                  width: 0.5,
                ),
              ),
              child: _isSearching
                  ? Container(
                      height: 100,
                      child: Center(
                        child: CupertinoActivityIndicator(),
                      ),
                    )
                  : _searchResults.isEmpty
                      ? Container(
                          height: 100,
                          child: Center(
                            child: Text(
                              '未找到相关路线',
                              style: TextStyle(
                                color: AppColors.textHint,
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: _searchResults.length,
                          separatorBuilder: (context, index) => Container(
                            height: 0.5,
                            color: AppColors.surfaceDivider,
                          ),
                          itemBuilder: (context, index) {
                            final route = _searchResults[index];
                            final isSelected = widget.selectedRoutes
                                .any((r) => r.id == route.id);

                            return CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed:
                                  isSelected ? null : () => _selectRoute(route),
                              child: Container(
                                padding: EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    // 路线图标
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.statusCompletedText
                                                .withValues(alpha: 0.1)
                                            : AppColors.interactiveAccent
                                                .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        isSelected
                                            ? CupertinoIcons.checkmark
                                            : CupertinoIcons.map,
                                        color: isSelected
                                            ? AppColors.statusCompletedText
                                            : AppColors.interactiveAccent,
                                        size: 20,
                                      ),
                                    ),

                                    SizedBox(width: 12),

                                    // 路线信息
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            route.name,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: isSelected
                                                  ? AppColors.textHint
                                                  : AppColors.textPrimary,
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Icon(
                                                CupertinoIcons.star_fill,
                                                size: 12,
                                                color: AppColors.statusPlanningText,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                route.rating.toStringAsFixed(1),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.textHint,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                route.difficulty.getName(),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.textHint,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // 添加按钮
                                    if (!isSelected)
                                      Icon(
                                        CupertinoIcons.add_circled,
                                        color: AppColors.interactiveAccent,
                                        size: 24,
                                      )
                                    else
                                      Text(
                                        '已添加',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.statusCompletedText,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],

          // 快速推荐
          if (!_showResults) ...[
            SizedBox(height: 16),
            Text(
              '推荐路线',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            _buildQuickRecommendations(),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickRecommendations() {
    final recommendations = _getMockSearchResults('');

    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recommendations.length,
        itemBuilder: (context, index) {
          final route = recommendations[index];
          final isSelected = widget.selectedRoutes.any((r) => r.id == route.id);

          return Container(
            width: 200,
            margin: EdgeInsets.only(right: 12),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: isSelected ? null : () => _selectRoute(route),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.surfaceCard
                      : AppColors.bgBase,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.statusCompletedText
                        : AppColors.surfaceDivider,
                    width: isSelected ? 2 : 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            route.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.textHint
                                  : AppColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            CupertinoIcons.checkmark_circle_fill,
                            color: AppColors.statusCompletedText,
                            size: 20,
                          ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.star_fill,
                          size: 12,
                          color: AppColors.statusPlanningText,
                        ),
                        SizedBox(width: 4),
                        Text(
                          route.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textHint,
                          ),
                        ),
                        Spacer(),
                        Text(
                          route.difficulty.getName(),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    if (!isSelected)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.interactiveAccent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '添加到行程',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.bgLight,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.statusCompletedText.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '已添加',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.statusCompletedText,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _selectRoute(RouteModel route) {
    widget.onRouteSelected(route);

    // 显示轻量级添加成功提示
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        content: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.checkmark_circle_fill,
                color: AppColors.statusCompletedText, size: 16),
            SizedBox(width: 8),
            Text('路线已添加', style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('知道了'),
          ),
        ],
      ),
    );

    // 清空搜索
    _searchController.clear();
    setState(() {
      _showResults = false;
      _searchResults = [];
    });
  }
}
