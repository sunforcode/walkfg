import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../model/route/route_model.dart';
import '../../../service/service_locator.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_content_widget.dart';
import 'trip_route_selection_screen.dart';
import 'my_trip_plans_screen.dart';

/// 行程规划首页
class TripPlanningScreen extends StatefulWidget {
  /// 构造函数
  const TripPlanningScreen({super.key});

  @override
  State<TripPlanningScreen> createState() => _TripPlanningScreenState();
}

class _TripPlanningScreenState extends State<TripPlanningScreen> {
  /// 当前选中的季节标签
  String _selectedSeasonTag = '当季热门';
  
  /// 季节标签列表
  final List<String> _seasonTags = ['当季热门', '新晋路线', '经典路线', '周末短途'];
  
  /// 热门路线Future
  late Future<List<RouteModel>> _popularRoutesFuture;
  
  /// 地区列表
  final List<String> _regions = ['川西', '新疆', '云南', '西藏', '浙江', '安徽', '更多'];
  
  /// 难度列表
  final List<String> _difficulties = ['初级', '中级', '高级', '专业级'];
  
  /// 时长列表
  final List<String> _durations = ['1-2天', '3-5天', '6-10天', '10天以上'];
  
  @override
  void initState() {
    super.initState();
    _loadPopularRoutes();
  }
  
  /// 加载热门路线
  void _loadPopularRoutes() {
    final apiService = ServiceLocator.instance.getApiService();
    _popularRoutesFuture = apiService.getPopularRoutes();
  }
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('行程规划'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                
                // 季节标签栏
                _buildSeasonTags(),
                
                const SizedBox(height: 24),
                
                // 热门路线列表
                _buildPopularRoutes(),
                
                const SizedBox(height: 32),
                
                // 按地区浏览
                _buildSectionTitle('按地区浏览'),
                const SizedBox(height: 12),
                _buildRegionTags(),
                
                const SizedBox(height: 24),
                
                // 按难度浏览
                _buildSectionTitle('按难度浏览'),
                const SizedBox(height: 12),
                _buildDifficultyTags(),
                
                const SizedBox(height: 24),
                
                // 按时长浏览
                _buildSectionTitle('按时长浏览'),
                const SizedBox(height: 12),
                _buildDurationTags(),
                
                const SizedBox(height: 24),
                
                // 搜索框
                _buildSearchBox(),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// 构建季节标签栏
  Widget _buildSeasonTags() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _seasonTags.length,
        itemBuilder: (context, index) {
          final tag = _seasonTags[index];
          final isSelected = tag == _selectedSeasonTag;
          
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                setState(() {
                  _selectedSeasonTag = tag;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : CupertinoColors.systemGrey4,
                  ),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: isSelected ? CupertinoColors.white : CupertinoColors.label,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  /// 构建热门路线列表
  Widget _buildPopularRoutes() {
    return FutureBuilder<List<RouteModel>>(
      future: _popularRoutesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: CupertinoActivityIndicator(),
            ),
          );
        }
        
        if (snapshot.hasError) {
          return SizedBox(
            height: 200,
            child: Center(
              child: Text(
                '加载失败: ${snapshot.error}',
                style: const TextStyle(color: CupertinoColors.systemRed),
              ),
            ),
          );
        }
        
        final routes = snapshot.data!;
        if (routes.isEmpty) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: Text('暂无热门路线'),
            ),
          );
        }
        
        return Column(
          children: routes.map((route) => _buildRouteCard(route)).toList(),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 路线图片
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 150,
                width: double.infinity,
                child: route.imageUrls.isNotEmpty
                    ? Image.network(
                        route.imageUrls.first,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.primary.withOpacity(0.2),
                          child: const Center(
                            child: Icon(
                              CupertinoIcons.photo,
                              size: 40,
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
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
              ),
            ),
            
            // 路线信息
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 路线名称
                  Text(
                    route.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // 路线信息
                  Row(
                    children: [
                      _buildInfoChip(
                        CupertinoIcons.clock,
                        '${route.durationDays}天',
                      ),
                      const SizedBox(width: 16),
                      _buildInfoChip(
                        CupertinoIcons.chart_bar,
                        route.getDifficultyName(),
                      ),
                      const SizedBox(width: 16),
                      _buildInfoChip(
                        CupertinoIcons.calendar,
                        route.bestSeason,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 规划按钮
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                      onPressed: () {
                        _startPlanning(route);
                      },
                      child: const Text('规划此行程'),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
          size: 16,
          color: AppColors.primary,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
  }
  
  /// 构建分区标题
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
  
  /// 构建地区标签
  Widget _buildRegionTags() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _regions.map((region) => _buildTag(region)).toList(),
    );
  }
  
  /// 构建难度标签
  Widget _buildDifficultyTags() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _difficulties.map((difficulty) => _buildTag(difficulty)).toList(),
    );
  }
  
  /// 构建时长标签
  Widget _buildDurationTags() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _durations.map((duration) => _buildTag(duration)).toList(),
    );
  }
  
  /// 构建标签
  Widget _buildTag(String tag) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        _navigateToRouteSelection(tag);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          tag,
          style: const TextStyle(
            color: CupertinoColors.label,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
  
  /// 构建搜索框
  Widget _buildSearchBox() {
    return CupertinoSearchTextField(
      placeholder: '搜索路线名称或地点...',
      onSubmitted: (value) {
        if (value.isNotEmpty) {
          _navigateToRouteSelection(value);
        }
      },
    );
  }
  
  /// 导航到路线详情页
  void _navigateToRouteDetail(RouteModel route) {
    // TODO: 实现导航到路线详情页
  }
  
  /// 开始规划行程
  void _startPlanning(RouteModel route) {
    // TODO: 实现开始规划行程
  }
  
  /// 导航到路线选择页面
  void _navigateToRouteSelection(String keyword) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => TripRouteSelectionScreen(keyword: keyword),
      ),
    );
  }
}