import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../resource/services/route_service.dart';
import '../../../common/widgets/error_view.dart';
import '../../../common/widgets/empty_view.dart';
import '../../../common/widgets/loading_view.dart';
import '../../../common/widgets/info_card.dart';
import '../../../common/widgets/info_item.dart';
import '../../widgets/route/route_info_header.dart';
import '../../widgets/route/route_action_buttons.dart';

/// 路线详情屏幕
class RouteDetailScreen extends StatefulWidget {
  /// 路线ID
  final String routeId;

  /// 构造函数
  const RouteDetailScreen({super.key, required this.routeId});

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingView(message: '加载路线详情...');
    }

    if (_error != null) {
      return ErrorView(
        message: _error!,
        title: '加载失败',
        onRetry: _loadRouteDetail,
      );
    }

    if (_route == null) {
      return EmptyView(
        message: '未找到该路线信息',
        title: '路线不存在',
        icon: Icons.hiking,
        actionText: '返回路线列表',
        onAction: () => context.go('/routes'),
      );
    }

    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 路线基本信息
              RouteInfoHeader(route: _route!),

              // 路线描述
              _buildDescriptionCard(),

              // 路线详情
              _buildDetailsCard(),

              // 操作按钮
              RouteActionButtons(
                routeId: widget.routeId,
              ),

              // 底部间距
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(_route!['name'] as String),
        background: Container(
          color: Colors.grey[300],
          child: Center(
            child: Icon(
              Icons.landscape,
              size: 64,
              color: Colors.grey[600],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite_border),
          onPressed: () {
            // TODO: 实现收藏功能
          },
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            // TODO: 实现分享功能
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionCard() {
    return InfoCard(
      title: '路线描述',
      icon: Icons.description,
      child: Text(_route!['description'] as String),
    );
  }

  Widget _buildDetailsCard() {
    return InfoCard(
      title: '路线详情',
      icon: Icons.info_outline,
      child: Column(
        children: [
          InfoItem(label: '累计上升', value: '${_route!['elevation_gain']} m'),
          InfoItem(label: '累计下降', value: '${_route!['elevation_loss']} m'),
          InfoItem(label: '最高点', value: '${_route!['highest_point']} m'),
          InfoItem(label: '最低点', value: '${_route!['lowest_point']} m'),
          InfoItem(label: '地形类型', value: (_route!['terrain_types'] as List).join(', ')),
          InfoItem(label: '适宜季节', value: (_route!['seasons'] as List).join(', ')),
          InfoItem(label: '水源', value: (_route!['water_sources'] as List).join(', ')),
          InfoItem(label: '营地', value: (_route!['camping_sites'] as List).join(', ')),
        ],
      ),
    );
  }
}