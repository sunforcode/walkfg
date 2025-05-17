import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../model/route/route_model.dart';
import '../../../service/service_locator.dart';
import '../../theme/app_colors.dart';
import 'trip_planning_detail_screen.dart';

/// 路线选择页面
class TripRouteSelectionScreen extends StatefulWidget {
  /// 搜索关键词
  final String keyword;

  /// 构造函数
  const TripRouteSelectionScreen({
    super.key,
    required this.keyword,
  });

  @override
  State<TripRouteSelectionScreen> createState() =>
      _TripRouteSelectionScreenState();
}

class _TripRouteSelectionScreenState extends State<TripRouteSelectionScreen> {
  /// 路线列表Future
  late Future<List<RouteModel>> _routesFuture;

  /// 难度筛选
  String? _difficultyFilter;

  /// 时长筛选
  String? _durationFilter;

  /// 季节筛选
  String? _seasonFilter;

  /// 难度选项
  final List<String> _difficultyOptions = ['全部', '初级', '中级', '高级', '专业级'];

  /// 时长选项
  final List<String> _durationOptions = [
    '全部',
    '1-2天',
    '3-5天',
    '6-10天',
    '10天以上'
  ];

  /// 季节选项
  final List<String> _seasonOptions = ['全部', '春季', '夏季', '秋季', '冬季', '四季皆宜'];

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  /// 加载路线
  void _loadRoutes() {
    final apiService = ServiceLocator.instance.getApiService();

    // 创建筛选条件
    Map<String, dynamic> filters = {};
    if (_difficultyFilter != '全部') {
      filters['difficulty'] = _getDifficultyFromName(_difficultyFilter!);
    }
    if (_durationFilter != '全部') {
      filters['duration'] = _durationFilter;
    }
    if (_seasonFilter != '全部') {
      filters['season'] = _seasonFilter;
    }

    // 确保keyword不为null
    final keyword = widget.keyword ?? "";
    _routesFuture = apiService.searchRoutes(keyword, filters: filters);
  }

  /// 根据难度名称获取难度枚举
  RouteDifficulty? _getDifficultyFromName(String name) {
    switch (name) {
      case '初级':
        return RouteDifficulty.easy;
      case '中级':
        return RouteDifficulty.medium;
      case '高级':
        return RouteDifficulty.hard;
      case '专业级':
        return RouteDifficulty.extreme;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('${widget.keyword}路线'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 筛选条件栏
            _buildFilterBar(),

            // 路线列表
            Expanded(
              child: _buildRouteList(),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建筛选条件栏
  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.systemGrey5,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildFilterButton(
              '难度', _difficultyFilter ?? '全部', _difficultyOptions),
          _buildFilterButton('时长', _durationFilter ?? '全部', _durationOptions),
          _buildFilterButton('季节', _seasonFilter ?? '全部', _seasonOptions),
        ],
      ),
    );
  }

  /// 构建筛选按钮
  Widget _buildFilterButton(String label, String value, List<String> options) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        _showFilterOptions(label, options);
      },
      child: Row(
        children: [
          Text(
            '$label: $value',
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            CupertinoIcons.chevron_down,
            size: 14,
            color: CupertinoColors.systemGrey,
          ),
        ],
      ),
    );
  }

  /// 显示筛选选项
  void _showFilterOptions(String label, List<String> options) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text('选择$label'),
        actions: options.map((option) {
          return CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                if (label == '难度') {
                  _difficultyFilter = option == '全部' ? null : option;
                } else if (label == '时长') {
                  _durationFilter = option == '全部' ? null : option;
                } else if (label == '季节') {
                  _seasonFilter = option == '全部' ? null : option;
                }
                _loadRoutes();
              });
            },
            child: Text(option),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.of(context).pop();
          },
          isDestructiveAction: true,
          child: const Text('取消'),
        ),
      ),
    );
  }

  /// 构建路线列表
  Widget _buildRouteList() {
    return FutureBuilder<List<RouteModel>>(
      future: _routesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              '加载失败: ${snapshot.error}',
              style: const TextStyle(color: CupertinoColors.systemRed),
            ),
          );
        }

        final routes = snapshot.data!;
        if (routes.isEmpty) {
          return const Center(
            child: Text('没有找到符合条件的路线'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: routes.length,
          itemBuilder: (context, index) {
            final route = routes[index];
            return _buildRouteCard(route);
          },
        );
      },
    );
  }

  /// 构建路线卡片
  Widget _buildRouteCard(RouteModel route) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
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
          _navigateToRouteDetail(route);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 路线图片
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: route.imageUrls.isNotEmpty
                      ? Image.network(
                          route.imageUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: AppColors.primary.withOpacity(0.2),
                            child: const Center(
                              child: Icon(
                                CupertinoIcons.photo,
                                size: 24,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: AppColors.primary.withOpacity(0.2),
                          child: const Center(
                            child: Icon(
                              CupertinoIcons.photo,
                              size: 24,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                ),
              ),

              const SizedBox(width: 16),

              // 路线信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 路线名称
                    Text(
                      route.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // 路线信息
                    Row(
                      children: [
                        _buildInfoChip(
                          CupertinoIcons.clock,
                          '${route.durationDays}天',
                        ),
                        const SizedBox(width: 12),
                        _buildInfoChip(
                          CupertinoIcons.chart_bar,
                          route.getDifficultyName(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // 最佳季节
                    Row(
                      children: [
                        _buildInfoChip(
                          CupertinoIcons.calendar,
                          route.bestSeason,
                        ),
                        const Spacer(),
                        // 评分
                        Row(
                          children: [
                            const Icon(
                              CupertinoIcons.star_fill,
                              size: 14,
                              color: CupertinoColors.systemYellow,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              route.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // 查看详情按钮
              CupertinoButton(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
                minSize: 0,
                onPressed: () {
                  _startPlanning(route);
                },
                child: const Text(
                  '规划',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建信息标签
  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: AppColors.primary,
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

  /// 导航到路线详情页
  void _navigateToRouteDetail(RouteModel route) {
    // TODO: 实现导航到路线详情页
  }

  /// 开始规划行程
  void _startPlanning(RouteModel route) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => TripPlanningDetailScreen(route: route),
      ),
    );
  }
}
