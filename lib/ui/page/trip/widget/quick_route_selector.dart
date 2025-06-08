import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/model/route/route_enums.dart';
import 'package:walk/model/route/route_model.dart';
import 'package:walk/model/route/route_ratings.dart';

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
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Icon(
                    CupertinoIcons.search,
                    color: CupertinoColors.systemGrey,
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
                      color: CupertinoColors.systemGrey,
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
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: CupertinoColors.separator,
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
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: _searchResults.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: CupertinoColors.separator,
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
                                            ? CupertinoColors.systemGreen
                                                .withOpacity(0.1)
                                            : CupertinoColors.systemBlue
                                                .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        isSelected
                                            ? CupertinoIcons.checkmark
                                            : CupertinoIcons.map,
                                        color: isSelected
                                            ? CupertinoColors.systemGreen
                                            : CupertinoColors.systemBlue,
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
                                                  ? CupertinoColors.systemGrey
                                                  : CupertinoColors.label,
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Icon(
                                                CupertinoIcons.star_fill,
                                                size: 12,
                                                color: CupertinoColors
                                                    .systemYellow,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                route.rating.toStringAsFixed(1),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: CupertinoColors
                                                      .systemGrey,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                route.difficulty.getName(),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: CupertinoColors
                                                      .systemGrey,
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
                                        color: CupertinoColors.systemBlue,
                                        size: 24,
                                      )
                                    else
                                      Text(
                                        '已添加',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: CupertinoColors.systemGreen,
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
                color: CupertinoColors.label,
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
                      ? CupertinoColors.systemGrey6
                      : CupertinoColors.systemBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? CupertinoColors.systemGreen
                        : CupertinoColors.separator,
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
                                  ? CupertinoColors.systemGrey
                                  : CupertinoColors.label,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            CupertinoIcons.checkmark_circle_fill,
                            color: CupertinoColors.systemGreen,
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
                          color: CupertinoColors.systemYellow,
                        ),
                        SizedBox(width: 4),
                        Text(
                          route.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        Spacer(),
                        Text(
                          route.difficulty.getName(),
                          style: TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.systemGrey,
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
                          color: CupertinoColors.systemBlue,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '添加到行程',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: CupertinoColors.white,
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
                          color: CupertinoColors.systemGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '已添加',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: CupertinoColors.systemGreen,
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.checkmark_circle_fill,
                color: CupertinoColors.systemGreen, size: 16),
            SizedBox(width: 8),
            Text('路线已添加', style: TextStyle(fontSize: 14)),
          ],
        ),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: 100, left: 20, right: 20),
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
