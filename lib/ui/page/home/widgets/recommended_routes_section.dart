import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../model/route_model.dart';
import '../../../../service/service_locator.dart';

/// 当季推荐路线部分组件
class RecommendedRoutesSection extends StatefulWidget {
  /// 构造函数
  const RecommendedRoutesSection({super.key});

  @override
  State<RecommendedRoutesSection> createState() => _RecommendedRoutesSectionState();
}

class _RecommendedRoutesSectionState extends State<RecommendedRoutesSection> with AutomaticKeepAliveClientMixin {
  /// 推荐路线列表Future
  late Future<List<RouteModel>> _recommendedRoutesFuture;

  /// 蓝色系颜色列表
  final List<Color> _blueColors = [
    const Color(0xFF1976D2), // 深蓝色
    const Color(0xFF2196F3), // 蓝色
    const Color(0xFF42A5F5), // 浅蓝色
    const Color(0xFF64B5F6), // 更浅的蓝色
    const Color(0xFF0D47A1), // 深邃蓝色
    const Color(0xFF0288D1), // 亮蓝色
  ];

  /// 真实图片URL列表
  final List<String> _realImageUrls = [
    'https://images.unsplash.com/photo-1454496522488-7a8e488e8606?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80', // 山峰
    'https://images.unsplash.com/photo-1486870591958-9b9d0690cb7a?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80', // 竹林
    'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80', // 山脉
    'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80', // 森林
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _recommendedRoutesFuture = _loadData();
  }

  /// 加载数据
  Future<List<RouteModel>> _loadData() async {
    final apiService = ServiceLocator.instance.getApiService();
    // 获取当季推荐路线，限制3条
    return apiService.getRecommendedRoutes(limit: 3);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用super.build

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 当季推荐路线标题
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '当季推荐徒步路线',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // 查看全部推荐路线
                context.go('/routes?filter=recommended');
              },
              child: const Text('查看全部'),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 当季推荐路线横向列表
        FutureBuilder<List<RouteModel>>(
          future: _recommendedRoutesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingIndicator();
            }

            if (snapshot.hasError) {
              return _buildErrorWidget(snapshot.error.toString());
            }

            final recommendedRoutes = snapshot.data;
            if (recommendedRoutes == null || recommendedRoutes.isEmpty) {
              return _buildEmptyWidget();
            }

            return SizedBox(
              height: 260, // 增加高度以容纳所有内容
              child: _buildRecommendedRoutes(context, recommendedRoutes),
            );
          },
        ),
      ],
    );
  }

  /// 构建加载指示器
  Widget _buildLoadingIndicator() {
    return SizedBox(
      height: 180,
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
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
                _recommendedRoutesFuture = _loadData();
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
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.landscape,
            color: color,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无推荐路线',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '敬请期待更多精彩路线',
            style: TextStyle(
              color: color.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建推荐路线
  Widget _buildRecommendedRoutes(BuildContext context, List<RouteModel> recommendedRoutes) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: recommendedRoutes.length,
      itemBuilder: (context, index) {
        final route = recommendedRoutes[index];
        final cardColor = _blueColors[index % _blueColors.length];
        final imageUrl = _realImageUrls[index % _realImageUrls.length];

        return Container(
          width: 280,
          margin: const EdgeInsets.only(right: 16),
          child: Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide.none, // 移除边框
            ),
            elevation: 4,
            shadowColor: cardColor.withOpacity(0.4),
            child: InkWell(
              onTap: () {
                // 导航到路线详情页
                context.go('/routes/${route.id}');
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 路线图片
                  Stack(
                    children: [
                      ShaderMask(
                        shaderCallback: (rect) {
                          return LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                            stops: const [0.7, 1.0],
                          ).createShader(rect);
                        },
                        blendMode: BlendMode.darken,
                        child: Image.network(
                          imageUrl,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 160,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  cardColor.withOpacity(0.8),
                                  cardColor.withOpacity(0.5),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.landscape,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            route.bestSeason,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 路线信息
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          route.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildRouteInfoChip(
                              context,
                              Icons.straighten,
                              '${route.distance} km',
                              cardColor,
                            ),
                            const SizedBox(width: 8),
                            _buildRouteInfoChip(
                              context,
                              Icons.timer,
                              route.duration,
                              cardColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 构建路线信息标签
  Widget _buildRouteInfoChip(BuildContext context, IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
