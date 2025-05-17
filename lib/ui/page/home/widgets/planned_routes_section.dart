import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../model/route_model.dart';
import '../../../../service/service_locator.dart';

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
            TextButton(
              onPressed: () {
                // 查看全部规划路线
                context.go('/trips');
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

  /// 构建加载指示器
  Widget _buildLoadingIndicator() {
    return SizedBox(
      height: 100,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(_blueColors[0]),
        ),
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
            Icons.error_outline,
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
          TextButton(
            onPressed: () {
              setState(() {
                _plannedRoutesFuture = _loadData();
              });
            },
            style: TextButton.styleFrom(
              foregroundColor: color,
              backgroundColor: color.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
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
            Icons.hiking,
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
          ElevatedButton.icon(
            onPressed: () {
              context.go('/routes');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text('创建路线'),
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
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Row(
              children: [
                Text(
                  route.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.grey : Colors.black87,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(width: 8),
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
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
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
                    Icons.access_time,
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
                ],
              ),
            ),
            trailing: Container(
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_forward_ios, size: 16, color: statusColor),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('查看${route.name}')),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}