import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../resource/services/route_service.dart';
import '../../../common/widgets/error_view.dart';
import '../../../common/widgets/empty_view.dart';
import '../../../common/widgets/loading_view.dart';
import '../../widgets/route/route_card.dart';

/// 路线列表屏幕
class RouteListScreen extends StatefulWidget {
  /// 构造函数
  const RouteListScreen({super.key});

  @override
  State<RouteListScreen> createState() => _RouteListScreenState();
}

class _RouteListScreenState extends State<RouteListScreen> {
  final _routeService = RouteService();
  List<Map<String, dynamic>> _routes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final routes = await _routeService.getRoutes();

      setState(() {
        _routes = routes;
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
        title: const Text('徒步路线'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: 实现搜索功能
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: 实现筛选功能
            },
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 实现添加路线功能
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingView(message: '加载路线列表...');
    }

    if (_error != null) {
      return ErrorView(
        message: _error!,
        title: '加载失败',
        onRetry: _loadRoutes,
      );
    }

    if (_routes.isEmpty) {
      return EmptyView(
        message: '点击右下角的按钮添加路线',
        title: '暂无路线',
        icon: Icons.hiking,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRoutes,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _routes.length,
        itemBuilder: (context, index) {
          final route = _routes[index];
          return RouteCard(route: route);
        },
      ),
    );
  }
}