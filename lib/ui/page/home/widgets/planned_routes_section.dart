import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../model/route_model.dart';
import '../../../../service/service_locator.dart';
import '../../route/cupertino_route_list_screen.dart';

/// 规划路线部分组件
class PlannedRoutesSection extends StatefulWidget {
  /// 构造函数
  const PlannedRoutesSection({super.key});

  @override
  State<PlannedRoutesSection> createState() => _PlannedRoutesSectionState();
}

class _PlannedRoutesSectionState extends State<PlannedRoutesSection> with AutomaticKeepAliveClientMixin {
  /// 规划路线列表Future
  late Future<List<PlannedRouteModel>> _plannedRoutesFuture;

  /// 蓝色系颜色列表
  final List<Color> _blueColors = [
    const Color(0xFF1976D2), // 深蓝色
    const Color(0xFF2196F3), // 蓝色
    const Color(0xFF42A5F5), // 浅蓝色
    const Color(0xFF64B5F6), // 更浅的蓝色
    const Color(0xFF0D47A1), // 深邃蓝色
    const Color(0xFF0288D1), // 亮蓝色
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _plannedRoutesFuture = _loadData();
  }

  /// 加载数据
  Future<List<PlannedRouteModel>> _loadData() async {
    final apiService = ServiceLocator.instance.getApiService();
    return apiService.getPlannedRoutes();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用super.build

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 规划路线标题
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '规划路线',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                // 查看全部规划路线
                _navigateToAllTrips(context);
              },
              child: const Text('查看全部'),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // 规划路线列表
        FutureBuilder<List<PlannedRouteModel>>(
          future: _plannedRoutesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingIndicator();
            }

            if (snapshot.hasError) {
              return _buildErrorWidget(snapshot.error.toString());
            }

            final plannedRoutes = snapshot.data;
            if (plannedRoutes == null || plannedRoutes.isEmpty) {
              return _buildEmptyWidget();
            }

            return _buildPlannedRoutesList(context, plannedRoutes);
          },
        ),
      ],
    );
  }

  /// 导航到所有行程页面
  void _navigateToAllTrips(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (context) => const RouteListScreen(),
      ),
    );
  }

  /// 导航到路线页面
  void _navigateToRoutes(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (context) => const RouteListScreen(),
      ),
    );
  }

  /// 构建加载指示器
  Widget _buildLoadingIndicator() {
    return SizedBox(
      height: 100,
      child: Center(
        child: CupertinoActivityIndicator(),
      ),
    );
  }

  /// 构建错误提示
  Widget _buildErrorWidget(String errorMessage) {
    final color = _blueColors[0];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.exclamationmark_circle,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(color: color.withOpacity(0.8)),
          ),
          const SizedBox(height: 8),
          CupertinoButton(
            onPressed: () {
              setState(() {
                _plannedRoutesFuture = _loadData();
              });
            },
            color: color,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            borderRadius: BorderRadius.circular(8),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  /// 构建空数据提示
  Widget _buildEmptyWidget() {
    final color = _blueColors[2];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.map,
            color: color,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无规划路线',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '开始规划你的徒步旅行吧！',
            style: TextStyle(
              color: color.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          CupertinoButton(
            onPressed: () {
              _navigateToRoutes(context);
            },
            color: color,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(CupertinoIcons.add, size: 16),
                SizedBox(width: 4),
                Text('创建路线'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建规划路线列表
  Widget _buildPlannedRoutesList(BuildContext context, List<PlannedRouteModel> plannedRoutes) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: plannedRoutes.length,
      itemBuilder: (context, index) {
        final route = plannedRoutes[index];
        final bool isCompleted = route.status == RouteStatus.completed;
        final cardColor = _blueColors[index % _blueColors.length];
        final statusColor = isCompleted ? Colors.grey : cardColor;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide.none, // 移除边框
          ),
          elevation: 3,
          shadowColor: statusColor.withOpacity(0.3),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              _showRouteDetails(context, route);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          route.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isCompleted ? Colors.grey : Colors.black87,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
                        ),
                        child: Text(
                          route.getStatusName(),
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.calendar,
                        size: 14,
                        color: statusColor.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        route.getFormattedDate(),
                        style: TextStyle(
                          color: statusColor.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        CupertinoIcons.time,
                        size: 14,
                        color: statusColor.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${route.days}天',
                        style: TextStyle(
                          color: statusColor.withOpacity(0.8),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        CupertinoIcons.chevron_right,
                        size: 16,
                        color: statusColor.withOpacity(0.7),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 显示路线详情
  void _showRouteDetails(BuildContext context, PlannedRouteModel route) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(route.name),
        content: Column(
          children: [
            const SizedBox(height: 10),
            Text('状态: ${route.getStatusName()}'),
            Text('开始日期: ${route.getFormattedDate()}'),
            Text('持续时间: ${route.days}天'),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('关闭'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            child: const Text('查看详情'),
            onPressed: () {
              Navigator.of(context).pop();
              // 导航到路线详情页
              Navigator.of(context, rootNavigator: true).push(
                CupertinoPageRoute(
                  builder: (context) => CupertinoPageScaffold(
                    navigationBar: CupertinoNavigationBar(
                      middle: Text(route.name),
                    ),
                    child: const SafeArea(
                      child: Center(
                        child: Text('路线详情页面正在开发中...'),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}