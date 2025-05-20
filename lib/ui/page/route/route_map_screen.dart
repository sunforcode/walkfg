import 'package:flutter/material.dart';
import '../../../model/route/route_model.dart';
import '../../../service/route_service.dart';
import '../../../service/service_manager.dart';

/// 路线地图屏幕
class RouteMapScreen extends StatefulWidget {
  /// 路线ID
  final String routeId;

  /// 构造函数
  const RouteMapScreen({super.key, required this.routeId});

  @override
  State<RouteMapScreen> createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  final _routeService = ServiceLocator.instance.getRouteService();
  RouteModel? _route;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRouteDetail();
  }

  Future<void> _loadRouteDetail() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final route = await _routeService.getRouteById(widget.routeId);

      setState(() {
        _route = route;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_route != null ? '${_route!.name} 地图' : '路线地图'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              '加载失败',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRouteDetail,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_route == null) {
      return const Center(
        child: Text('路线不存在'),
      );
    }

    // 这里应该显示地图，但由于没有实际的地图组件，我们使用一个占位符
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '${_route!.name} 地图',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '距离: ${_route!.distance} km',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '难度: ${_getDifficultyName(_route!.difficulty)}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          const Text(
            '地图功能尚未实现',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// 获取难度名称
  String _getDifficultyName(RouteDifficulty difficulty) {
    switch (difficulty) {
      case RouteDifficulty.easy:
        return '初级';
      case RouteDifficulty.medium:
        return '中级';
      case RouteDifficulty.hard:
        return '高级';
      case RouteDifficulty.extreme:
        return '专业级';
    }
  }
}
