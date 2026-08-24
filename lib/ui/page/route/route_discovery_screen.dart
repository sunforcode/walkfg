import 'package:flutter/cupertino.dart';

import '../../../model/route/route_model.dart';
import '../../../service/route/current_route_selection_service.dart';
import '../../../service/route_service.dart';
import '../../../theme/tokens/colors.dart';
import '../../../theme/tokens/motion.dart';
import '../../../theme/tokens/radius.dart';
import '../../../theme/tokens/spacing.dart';
import '../../../theme/tokens/typography.dart';
import '../common/immersive_components.dart';
import '../common/immersive_page_scaffold.dart';
import '../common/network_image_with_fallback.dart';

typedef RouteDiscoveryLoader = Future<List<RouteModel>> Function({
  required int page,
  required int size,
});
typedef RouteSelectionSaver = Future<void> Function(RouteModel route);

/// 沉浸式路线发现页。
///
/// 加载入口可注入以固定页面状态契约；生产环境按热门顺序分页加载路线。
class RouteDiscoveryScreen extends StatefulWidget {
  final RouteDiscoveryLoader? routesLoader;
  final RouteSelectionSaver? routeSelectionSaver;

  const RouteDiscoveryScreen({
    super.key,
    this.routesLoader,
    this.routeSelectionSaver,
  });

  @override
  State<RouteDiscoveryScreen> createState() => _RouteDiscoveryScreenState();
}

class _RouteDiscoveryScreenState extends State<RouteDiscoveryScreen> {
  static const int _pageSize = 20;

  final List<RouteModel> _routes = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  Object? _initialError;
  int _page = 1;
  int _requestGeneration = 0;
  bool _isSelectingRoute = false;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<List<RouteModel>> _loadPage(int page) {
    if (widget.routesLoader case final loader?) {
      return loader(page: page, size: _pageSize);
    }
    return RouteService.getRoutes(
      sort: 'popular',
      page: page,
      size: _pageSize,
    );
  }

  Future<void> _loadInitial() async {
    final generation = ++_requestGeneration;
    setState(() {
      _isLoading = true;
      _isLoadingMore = false;
      _initialError = null;
      _page = 1;
      _hasMore = true;
    });
    try {
      final routes = await _loadPage(1);
      if (!mounted || generation != _requestGeneration) return;
      setState(() {
        _routes
          ..clear()
          ..addAll(routes);
        _page = 1;
        _hasMore = routes.length == _pageSize;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted || generation != _requestGeneration) return;
      setState(() {
        _initialError = error;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;
    setState(() {
      _isLoadingMore = true;
    });
    final generation = _requestGeneration;
    final nextPage = _page + 1;
    try {
      final routes = await _loadPage(nextPage);
      if (!mounted || generation != _requestGeneration) return;
      setState(() {
        _routes.addAll(routes);
        _page = nextPage;
        _hasMore = routes.length == _pageSize;
        _isLoadingMore = false;
      });
    } catch (error) {
      debugPrint('RouteDiscoveryScreen: 第 $nextPage 页加载失败: $error');
      if (!mounted || generation != _requestGeneration) return;
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _refreshRoutes() => _loadInitial();

  void _retry() {
    _loadInitial();
  }

  Future<void> _selectRoute(RouteModel route) async {
    if (_isSelectingRoute) return;
    _isSelectingRoute = true;
    try {
      await (widget.routeSelectionSaver ??
          CurrentRouteSelectionService.instance.setSelectedRoute)(route);
      if (!mounted) return;
      Navigator.of(context).pop(route);
    } finally {
      _isSelectingRoute = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ImmersivePageScaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _DiscoveryBackdrop(),
          _RouteDiscoveryScrollView(
            state: _state,
            routes: _routes,
            isLoadingMore: _isLoadingMore,
            onRefresh: _refreshRoutes,
            onLoadMore: _loadMore,
            onRetry: _retry,
            onRouteTap: _selectRoute,
          ),
        ],
      ),
      leadingAction: GlassIconAction(
        key: const Key('route-discovery-back'),
        semanticLabel: '返回',
        icon: CupertinoIcons.back,
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  _ListState get _state {
    if (_isLoading) return _ListState.loading;
    if (_initialError != null) return _ListState.error;
    if (_routes.isEmpty) return _ListState.empty;
    return _ListState.ready;
  }
}

enum _ListState { loading, ready, empty, error }

class _RouteDiscoveryScrollView extends StatelessWidget {
  final _ListState state;
  final List<RouteModel> routes;
  final bool isLoadingMore;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadMore;
  final VoidCallback onRetry;
  final ValueChanged<RouteModel> onRouteTap;

  const _RouteDiscoveryScrollView({
    required this.state,
    required this.routes,
    required this.isLoadingMore,
    required this.onRefresh,
    required this.onLoadMore,
    required this.onRetry,
    required this.onRouteTap,
  });

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.viewPaddingOf(context).top;
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 200) {
          onLoadMore();
        }
        return false;
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          CupertinoSliverRefreshControl(onRefresh: onRefresh),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.heroHorizontal,
                topInset + AppSpacing.hero,
                AppSpacing.heroHorizontal,
                AppSpacing.sectionGap,
              ),
              child: const _HeaderCopy(),
            ),
          ),
          switch (state) {
            _ListState.loading => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal,
                  ),
                  child: _HeroSkeleton(),
                ),
              ),
            _ListState.ready => SliverList.builder(
                itemCount: routes.length,
                itemBuilder: (context, index) {
                  final route = routes[index];
                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.pageHorizontal,
                      index == 0 ? 0 : AppSpacing.listItemGap / 2,
                      AppSpacing.pageHorizontal,
                      index == routes.length - 1
                          ? 0
                          : AppSpacing.listItemGap / 2,
                    ),
                    child: _RouteHeroItem(
                      route: route,
                      onTap: () => onRouteTap(route),
                    ),
                  );
                },
              ),
            _ListState.empty => const SliverFillRemaining(
                hasScrollBody: false,
                child: _StateMessage(text: '暂无路线，下拉刷新'),
              ),
            _ListState.error => SliverFillRemaining(
                hasScrollBody: false,
                child: _StateMessage(
                  text: '加载失败，点击重试',
                  onTap: onRetry,
                ),
              ),
          },
          if (isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: AppSpacing.verticalLg,
                child: Center(child: CupertinoActivityIndicator()),
              ),
            ),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.sectionGap),
          ),
        ],
      ),
    );
  }
}

class _HeaderCopy extends StatelessWidget {
  const _HeaderCopy();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('WALK / 发现', style: AppTypography.label),
        SizedBox(height: AppSpacing.sm),
        Text('这周，走进山里。', style: AppTypography.displayTitle),
        SizedBox(height: AppSpacing.sm),
        Text('一屏一条经典路线，上滑继续探索。', style: AppTypography.heroSubtitle),
      ],
    );
  }
}

class _RouteHeroItem extends StatefulWidget {
  final RouteModel route;
  final VoidCallback onTap;

  const _RouteHeroItem({required this.route, required this.onTap});

  @override
  State<_RouteHeroItem> createState() => _RouteHeroItemState();
}

class _RouteHeroItemState extends State<_RouteHeroItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final heroHeight = (screenHeight * 0.72).clamp(400.0, 680.0);

    return Semantics(
      button: true,
      label: '选择路线 ${widget.route.name}',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _pressed ? 0.985 : 1,
          duration: AppMotion.feedback,
          curve: AppMotion.out,
          child: SizedBox(
            key: Key('route-hero-${widget.route.id}'),
            height: heroHeight,
            child: ImmersiveHero(
              variant: ImmersiveHeroVariant.editorial,
              image: _RouteHeroImage(route: widget.route),
              overlay: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.heroHorizontal),
                  child: _RouteHeroOverlay(route: widget.route),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RouteHeroImage extends StatelessWidget {
  final RouteModel route;

  const _RouteHeroImage({required this.route});

  @override
  Widget build(BuildContext context) {
    final url = _coverUrl(route);
    if (url == null) return _RouteImageFallback(routeId: route.id);

    return NetworkImageWithFallback(
      url: url,
      fit: BoxFit.cover,
      fallbackColor: AppColors.bgRouteStart,
      fallbackIcon: CupertinoIcons.photo_fill,
      placeholderBuilder: (_) => _RouteImageFallback(routeId: route.id),
      errorBuilder: (_) => _RouteImageFallback(routeId: route.id),
    );
  }

  String? _coverUrl(RouteModel route) {
    final cover = route.coverUrl?.trim();
    if (cover != null && cover.isNotEmpty) return cover;
    for (final url in route.imageUrls ?? const <String>[]) {
      if (url.trim().isNotEmpty) return url.trim();
    }
    return null;
  }
}

class _RouteImageFallback extends StatelessWidget {
  final String routeId;

  const _RouteImageFallback({required this.routeId});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: Key('route-image-fallback-$routeId'),
      decoration: const BoxDecoration(gradient: AppColors.gradientRouteRadial),
      child: const CustomPaint(
        painter: _MountainFallbackPainter(),
        child: SizedBox.expand(),
      ),
    );
  }
}

class _RouteHeroOverlay extends StatelessWidget {
  final RouteModel route;

  const _RouteHeroOverlay({required this.route});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeroTitleOverlay(
          eyebrow: Text(
            '${route.region} · ${route.difficulty.getName()}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.label.copyWith(
              color: AppColors.interactiveAccent,
            ),
          ),
          title: route.name,
          metrics: MetricGroup(
            metrics: [
              MetricData(value: _distance(route.distanceKm), unit: '公里'),
              MetricData(value: _elevation(route.elevationGainM), unit: '爬升'),
              MetricData(
                value: route.difficulty.getName(),
                unit: '难度',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('点击选择路线', style: AppTypography.caption),
            Icon(CupertinoIcons.arrow_up_right, color: AppColors.textPrimary),
          ],
        ),
      ],
    );
  }

  String _distance(double? value) {
    if (value == null) return '—';
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }

  String _elevation(double? value) =>
      value == null ? '—' : '${value.toStringAsFixed(0)}m';
}

class _StateMessage extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const _StateMessage({required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: onTap,
      child: Text(text, style: AppTypography.body),
    );
  }
}

class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('route-hero-skeleton'),
      height: (MediaQuery.sizeOf(context).height * 0.72).clamp(400.0, 680.0),
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.borderOverlay,
      ),
    );
  }
}

class _DiscoveryBackdrop extends StatelessWidget {
  const _DiscoveryBackdrop();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(gradient: AppColors.gradientRouteRadial),
    );
  }
}

class _MountainFallbackPainter extends CustomPainter {
  const _MountainFallbackPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.contourLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var index = 0; index < 5; index++) {
      final y = size.height * (0.32 + index * 0.1);
      final path = Path()
        ..moveTo(0, y)
        ..quadraticBezierTo(size.width * 0.35, y - 70, size.width * 0.55, y)
        ..quadraticBezierTo(size.width * 0.78, y + 55, size.width, y - 10);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
