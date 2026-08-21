import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../model/route/route_model.dart';
import '../../../service/route/current_route_selection_service.dart';
import '../../../service/route_service.dart';

/// Route picker for Walk v1.
class RouteDiscoveryScreen extends StatefulWidget {
  /// Constructor.
  const RouteDiscoveryScreen({
    super.key,
  });

  @override
  State<RouteDiscoveryScreen> createState() => _RouteDiscoveryScreenState();
}

class _RouteDiscoveryScreenState extends State<RouteDiscoveryScreen> {
  late Future<List<RouteModel>> _routesFuture;

  @override
  void initState() {
    super.initState();
    _routesFuture = _loadRoutes();
  }

  Future<List<RouteModel>> _loadRoutes() async {
    try {
      final routes = await RouteService.getPopularRoutes(limit: 12);
      if (routes.isNotEmpty) return routes;
    } catch (e) {
      debugPrint('RouteDiscoveryScreen: 热门路线加载失败，尝试全部路线: $e');
    }

    return RouteService.getRoutes(limit: 12);
  }

  Future<void> _selectRoute(RouteModel route) async {
    await CurrentRouteSelectionService.instance.setSelectedRoute(route);

    if (!mounted) return;
    Navigator.of(context).pop(route);
  }

  void _reload() {
    setState(() {
      _routesFuture = _loadRoutes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF07130F),
      navigationBar: CupertinoNavigationBar(
        middle: const Text('找路线'),
        previousPageTitle: '首页',
        backgroundColor: const Color(0xFF07130F).withValues(alpha: 0.92),
        border: null,
      ),
      child: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(
              child: _RoutePickerBackground(),
            ),
            FutureBuilder<List<RouteModel>>(
              future: _routesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CupertinoActivityIndicator(color: Colors.white),
                  );
                }

                if (snapshot.hasError) {
                  return _RoutePickerMessage(
                    icon: CupertinoIcons.exclamationmark_triangle,
                    title: '路线暂时没加载出来',
                    subtitle: '检查网络或稍后再试。',
                    actionLabel: '重试',
                    onAction: _reload,
                  );
                }

                final routes = snapshot.data ?? const <RouteModel>[];
                if (routes.isEmpty) {
                  return _RoutePickerMessage(
                    icon: CupertinoIcons.map,
                    title: '还没有可选路线',
                    subtitle: '第一版只展示少量经典路线，数据准备好后会出现在这里。',
                    actionLabel: '刷新',
                    onAction: _reload,
                  );
                }

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(22, 28, 22, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '这周去哪走？',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.74),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '选一条经典路线',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0,
                                height: 1.05,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '点选后直接回到首页，看轨迹和这周/下周天气。',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.58),
                                fontSize: 15,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, visualIndex) {
                          if (visualIndex.isOdd) {
                            return const SizedBox(height: 12);
                          }

                          final index = visualIndex ~/ 2;
                          final route = routes[index];
                          return Padding(
                            padding: EdgeInsets.fromLTRB(
                              18,
                              0,
                              18,
                              index == routes.length - 1 ? 28 : 0,
                            ),
                            child: _RouteChoiceCard(
                              route: route,
                              onTap: () => _selectRoute(route),
                            ),
                          );
                        },
                        childCount: routes.isEmpty ? 0 : routes.length * 2 - 1,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteChoiceCard extends StatelessWidget {
  final RouteModel route;
  final VoidCallback onTap;

  const _RouteChoiceCard({
    required this.route,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF112019).withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.24),
              blurRadius: 24,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _RouteThumb(route: route),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      route.region,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFFB6FF5C).withValues(alpha: 0.88),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      route.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                        height: 1.12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _RoutePill(
                          icon: CupertinoIcons.arrow_right_arrow_left,
                          label: '${route.distance.toStringAsFixed(1)} km',
                        ),
                        _RoutePill(
                          icon: CupertinoIcons.arrow_up_right,
                          label: '${route.elevationGain.toStringAsFixed(0)} m',
                        ),
                        _RoutePill(
                          icon: CupertinoIcons.chart_bar_alt_fill,
                          label: route.difficulty.getName(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFB6FF5C),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  CupertinoIcons.chevron_right,
                  color: Color(0xFF07130F),
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RouteThumb extends StatelessWidget {
  final RouteModel route;

  const _RouteThumb({required this.route});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 86,
        height: 108,
        child: route.coverUrl != null && route.coverUrl!.isNotEmpty
            ? Image.network(
                route.coverUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _RouteThumbFallback(),
              )
            : const _RouteThumbFallback(),
      ),
    );
  }
}

class _RouteThumbFallback extends StatelessWidget {
  const _RouteThumbFallback();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _MiniTerrainPainter(),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF263D30),
              Color(0xFF0D1A14),
            ],
          ),
        ),
        child: const Center(
          child: Icon(
            CupertinoIcons.map_fill,
            color: Color(0xFFB6FF5C),
            size: 28,
          ),
        ),
      ),
    );
  }
}

class _RoutePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _RoutePill({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.72),
            size: 13,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutePickerMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _RoutePickerMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFFB6FF5C), size: 42),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 15,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 22),
            CupertinoButton(
              color: const Color(0xFFB6FF5C),
              borderRadius: BorderRadius.circular(999),
              onPressed: onAction,
              child: Text(
                actionLabel,
                style: const TextStyle(
                  color: Color(0xFF07130F),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoutePickerBackground extends StatelessWidget {
  const _RoutePickerBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _MiniTerrainPainter(
        color: Colors.white.withValues(alpha: 0.06),
      ),
      child: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.05,
            colors: [
              Color(0xFF244132),
              Color(0xFF07130F),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniTerrainPainter extends CustomPainter {
  final Color color;

  const _MiniTerrainPainter({
    this.color = const Color(0x22FFFFFF),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 0; i < 9; i++) {
      final path = Path();
      final y = size.height * (0.16 + i * 0.1);
      path.moveTo(-10, y);
      path.cubicTo(
        size.width * 0.25,
        y - 18 + i * 2,
        size.width * 0.58,
        y + 22 - i,
        size.width + 10,
        y - 8,
      );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MiniTerrainPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
