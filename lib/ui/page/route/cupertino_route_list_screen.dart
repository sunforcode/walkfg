import 'package:flutter/cupertino.dart';

/// iOS风格的路线列表页面
class RouteListScreen extends StatefulWidget {
  /// 构造函数
  const RouteListScreen({super.key});

  @override
  State<RouteListScreen> createState() => _RouteListScreenState();
}

class _RouteListScreenState extends State<RouteListScreen> {
  bool _isLoading = true;
  String? _error;
  final List<Map<String, dynamic>> _routes = [];

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    // 模拟加载数据
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        // 添加一些模拟数据
        _routes.addAll([
          {
            'id': '1',
            'name': '黄山主峰徒步路线',
            'distance': 15.5,
            'duration': '6小时',
            'difficulty': 3,
            'bestSeason': '春季最佳',
            'imageUrl': 'https://images.unsplash.com/photo-1454496522488-7a8e488e8606',
          },
          {
            'id': '2',
            'name': '莫干山竹海徒步',
            'distance': 8.2,
            'duration': '3小时',
            'difficulty': 2,
            'bestSeason': '四季皆宜',
            'imageUrl': 'https://images.unsplash.com/photo-1486870591958-9b9d0690cb7a',
          },
          {
            'id': '3',
            'name': '庐山三日穿越',
            'distance': 32,
            'duration': '3天',
            'difficulty': 4,
            'bestSeason': '秋季最佳',
            'imageUrl': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b',
          },
        ]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('徒步路线'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.search),
              onPressed: () {
                // 搜索功能
                showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: const Text('提示'),
                    content: const Text('搜索功能尚未实现'),
                    actions: [
                      CupertinoDialogAction(
                        child: const Text('确定'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                );
              },
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.slider_horizontal_3),
              onPressed: () {
                // 筛选功能
                showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: const Text('提示'),
                    content: const Text('筛选功能尚未实现'),
                    actions: [
                      CupertinoDialogAction(
                        child: const Text('确定'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CupertinoActivityIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_circle,
              size: 50,
              color: CupertinoColors.systemRed,
            ),
            const SizedBox(height: 16),
            Text(
              '加载失败',
              style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
            ),
            const SizedBox(height: 8),
            Text(_error!),
            const SizedBox(height: 16),
            CupertinoButton(
              child: const Text('重试'),
              onPressed: _loadRoutes,
            ),
          ],
        ),
      );
    }

    if (_routes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.map,
              size: 50,
              color: CupertinoColors.systemBlue,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无路线',
              style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
            ),
            const SizedBox(height: 8),
            const Text('点击右下角的按钮添加路线'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _routes.length,
      itemBuilder: (context, index) {
        final route = _routes[index];
        return _buildRouteCard(route);
      },
    );
  }

  Widget _buildRouteCard(Map<String, dynamic> route) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 路线图片
            SizedBox(
              height: 150,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 图片
                  Image.network(
                    route['imageUrl'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: CupertinoColors.systemBlue.withOpacity(0.2),
                      child: const Center(
                        child: Icon(
                          CupertinoIcons.photo,
                          size: 40,
                          color: CupertinoColors.systemBlue,
                        ),
                      ),
                    ),
                  ),
                  
                  // 季节标签
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        route['bestSeason'],
                        style: const TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // 路线信息
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 路线名称
                  Text(
                    route['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // 路线详情
                  Row(
                    children: [
                      _buildInfoChip(
                        CupertinoIcons.arrow_right_arrow_left,
                        '${route['distance']} km',
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        CupertinoIcons.time,
                        route['duration'],
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        CupertinoIcons.chart_bar,
                        _getDifficultyText(route['difficulty']),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: CupertinoColors.systemBlue,
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
  
  String _getDifficultyText(int difficulty) {
    switch (difficulty) {
      case 1:
        return '简单';
      case 2:
        return '初级';
      case 3:
        return '中级';
      case 4:
        return '高级';
      case 5:
        return '专业';
      default:
        return '未知';
    }
  }
}