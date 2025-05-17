import 'package:flutter/material.dart';
import '../../../resource/services/route_service.dart';
import '../../../common/widgets/loading_view.dart';
import '../../../common/widgets/error_view.dart';

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
  final _routeService = RouteService();
  Map<String, dynamic>? _route;
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

      final route = await _routeService.getRouteDetail(widget.routeId);

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
        title: Text(_route != null ? '${_route!['name']} 地图' : '路线地图'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingView(message: '加载地图...');
    }

    if (_error != null) {
      return ErrorView(
        message: _error!,
        title: '加载失败',
        onRetry: _loadRouteDetail,
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
            '${_route!['name']} 地图',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '距离: ${_route!['distance']} km',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '难度: ${_route!['difficulty']}',
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
}