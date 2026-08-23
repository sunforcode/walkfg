import 'package:flutter/cupertino.dart';

import '../../../model/route/route_enums.dart';
import '../../../model/route/route_model.dart';
import '../../../service/route/current_route_selection_service.dart';
import '../../../service/route_service.dart';
import '../../../theme/tokens/colors.dart';
import '../../../theme/tokens/motion.dart';

// ─────────────────────────────────────────────────────────────────────────────
// P3 路线发现 (PRD §3)
// 暗色地形氛围下的经典路线卡片列表，一划一选，回到首页看轨迹和天气。
// ─────────────────────────────────────────────────────────────────────────────

class RouteDiscoveryScreen extends StatefulWidget {
  const RouteDiscoveryScreen({super.key});

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
      final routes = await RouteService.getPopularRoutes(limit: 50);
      if (routes.isNotEmpty) return routes;
    } catch (e) {
      debugPrint('RouteDiscoveryScreen: 热门路线加载失败，尝试全部路线: $e');
    }
    return RouteService.getRoutes(limit: 50);
  }

  void _reload() {
    setState(() {
      _routesFuture = _loadRoutes();
    });
  }

  Future<void> _onCardTap(RouteModel route) async {
    await CurrentRouteSelectionService.instance.setSelectedRoute(route);
    if (!mounted) return;
    Navigator.of(context).pop(route);
  }

  void _goHome() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.bgRouteMid,
      child: Stack(
        children: [
          // Layer 1 — 暗绿径向渐变背景
          const Positioned.fill(child: _RouteGradientBackground()),
          // Layer 2 — 地形等高线装饰
          const Positioned.fill(child: _ContourLines()),
          // Layer 3 — 内容
          SafeArea(
            child: FutureBuilder<List<RouteModel>>(
              future: _routesFuture,
              builder: (context, snapshot) {
                return _RouteListContent(
                  state: _listState(snapshot),
                  routes: snapshot.data ?? const [],
                  onCardTap: _onCardTap,
                  onRetry: _reload,
                  onGoHome: _goHome,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  _ListState _listState(AsyncSnapshot<List<RouteModel>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return _ListState.loading;
    }
    if (snapshot.hasError) return _ListState.error;
    if ((snapshot.data ?? const []).isEmpty) return _ListState.empty;
    return _ListState.ready;
  }
}

enum _ListState { loading, ready, empty, error }

// ─────────────────────────────────────────────────────────────────────────────
// 内容区 — 导航 + 头部文案 + 卡片列表（骨架屏/正常/空态/错误态）
// ─────────────────────────────────────────────────────────────────────────────

class _RouteListContent extends StatelessWidget {
  final _ListState state;
  final List<RouteModel> routes;
  final ValueChanged<RouteModel> onCardTap;
  final VoidCallback onRetry;
  final VoidCallback onGoHome;

  const _RouteListContent({
    required this.state,
    required this.routes,
    required this.onCardTap,
    required this.onRetry,
    required this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // 导航区 — "← 首页"
        SliverToBoxAdapter(child: _NavBack(onTap: onGoHome)),
        // 头部文案区
        const SliverToBoxAdapter(child: _HeaderCopy()),
        // 卡片列表区（根据状态切换）
        switch (state) {
          _ListState.loading => _skeletonSliver(),
          _ListState.ready => _routeSliver(routes, onCardTap),
          _ListState.empty => _messageSliver('暂无路线', null),
          _ListState.error => _messageSliver('加载失败，点击重试', onRetry),
        },
        // 底部留白
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  Widget _skeletonSliver() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: const _SkeletonCard(),
        ),
        childCount: 3,
      ),
    );
  }

  Widget _routeSliver(List<RouteModel> routes, ValueChanged<RouteModel> onTap) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, index) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: index == 0 ? 0 : 6,
            bottom: index == routes.length - 1 ? 0 : 6,
          ),
          child: _RouteChoiceCard(
            route: routes[index],
            onTap: () => onTap(routes[index]),
          ),
        ),
        childCount: routes.length,
      ),
    );
  }

  Widget _messageSliver(String text, VoidCallback? onTap) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textWeak,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 导航区 — "← 首页" (PRD §3.3)
// ─────────────────────────────────────────────────────────────────────────────

class _NavBack extends StatelessWidget {
  final VoidCallback onTap;
  const _NavBack({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Text(
          '← 首页',
          style: TextStyle(
            color: AppColors.textWeak,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 头部文案区 (PRD §3.4)
// ─────────────────────────────────────────────────────────────────────────────

class _HeaderCopy extends StatelessWidget {
  const _HeaderCopy();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '这周去哪走？',
            style: TextStyle(
              color: AppColors.accentGreenSoft,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '选一条经典路线',
            style: TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点选后直接回到首页，看轨迹和这周/下周天气。',
            style: TextStyle(
              color: AppColors.textWeak,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 路线卡片 (PRD §3.5.1)
// 拆分：_RouteChoiceCard → _PressableCard → _CardInner → (_Thumb / _RouteInfo / _GoButton)
// ─────────────────────────────────────────────────────────────────────────────

class _RouteChoiceCard extends StatefulWidget {
  final RouteModel route;
  final VoidCallback onTap;

  const _RouteChoiceCard({required this.route, required this.onTap});

  @override
  State<_RouteChoiceCard> createState() => _RouteChoiceCardState();
}

class _RouteChoiceCardState extends State<_RouteChoiceCard> {
  bool _pressed = false;
  DateTime? _lastTap;

  void _handleTap() {
    final now = DateTime.now();
    if (_lastTap != null && now.difference(_lastTap!).inMilliseconds < 300) {
      return;
    }
    _lastTap = now;
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return _PressableCard(
      pressed: _pressed,
      onPressChange: (v) => setState(() => _pressed = v),
      onTap: _handleTap,
      child: _CardInner(route: widget.route),
    );
  }
}

/// 交互壳：MouseRegion + GestureDetector + AnimatedScale
class _PressableCard extends StatelessWidget {
  final bool pressed;
  final ValueChanged<bool> onPressChange;
  final VoidCallback onTap;
  final Widget child;

  const _PressableCard({
    required this.pressed,
    required this.onPressChange,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {},
      onExit: (_) {},
      child: GestureDetector(
        onTapDown: (_) => onPressChange(true),
        onTapUp: (_) {
          onPressChange(false);
          onTap();
        },
        onTapCancel: () => onPressChange(false),
        child: AnimatedScale(
          scale: pressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.ease,
          child: AnimatedContainer(
            duration: AppMotion.feedback,
            curve: Curves.ease,
            decoration: BoxDecoration(
              color:
                  pressed ? AppColors.surfaceCardHover : AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.surfaceDivider, width: 1),
            ),
            padding: const EdgeInsets.all(14),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 卡片内容：缩略图 + 路线信息 + 出发按钮
class _CardInner extends StatelessWidget {
  final RouteModel route;
  const _CardInner({required this.route});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Thumb(route: route),
        const SizedBox(width: 14),
        Expanded(child: _RouteInfo(route: route)),
        const SizedBox(width: 14),
        const _GoButton(),
      ],
    );
  }
}

// ─── 缩略图 (PRD §3.5.1 .thumb) ───

class _Thumb extends StatelessWidget {
  final RouteModel route;
  const _Thumb({required this.route});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 86,
        height: 108,
        child: route.coverUrl != null && route.coverUrl!.isNotEmpty
            ? Image.network(
                route.coverUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _ThumbFallback(),
              )
            : const _ThumbFallback(),
      ),
    );
  }
}

class _ThumbFallback extends StatelessWidget {
  const _ThumbFallback();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.thumbStart, AppColors.thumbEnd],
        ),
      ),
      child: Center(
        child: Text(
          _emojiForDifficulty(null),
          style: const TextStyle(fontSize: 36),
        ),
      ),
    );
  }
}

String _emojiForDifficulty(RouteDifficulty? d) {
  switch (d) {
    case RouteDifficulty.easy:
      return '🌿';
    case RouteDifficulty.medium:
      return '⛰';
    case RouteDifficulty.hard:
      return '🏔';
    case RouteDifficulty.extreme:
      return '❄️';
    default:
      return '🌲';
  }
}

// ─── 路线信息 (PRD §3.5.1 .route-info) ───

class _RouteInfo extends StatelessWidget {
  final RouteModel route;
  const _RouteInfo({required this.route});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 区域标签
        Text(
          route.region,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.accentGreenBright,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        // 路线名
        Text(
          route.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        // 指标药丸组
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            _MetricPill(_formatDistance(route.distanceKm)),
            _MetricPill(
                '爬升 ${route.elevationGainM?.toStringAsFixed(0) ?? "—"}m'),
            _MetricPill(route.difficulty.getName()),
          ],
        ),
      ],
    );
  }

  String _formatDistance(double? km) {
    if (km == null) return '— km';
    if (km == km.roundToDouble()) return '${km.toInt()} km';
    return '${km.toStringAsFixed(1)} km';
  }
}

/// 指标药丸 (PRD §3.5.1 单个指标药丸)
class _MetricPill extends StatelessWidget {
  final String text;
  const _MetricPill(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.pillBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textWeak,
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

// ─── 出发按钮 (PRD §3.5.1 .go-btn) ───

class _GoButton extends StatelessWidget {
  const _GoButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.accentGreenFaint,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '›',
        style: TextStyle(
          color: AppColors.accentGreenArrow,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 骨架屏卡片 (PRD §4 加载态)
// ─────────────────────────────────────────────────────────────────────────────

class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard();

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value;
        // shimmer 亮度：0.03 → 0.08 → 0.03
        final alpha = (0.03 + 0.05 * (0.5 - (t - 0.5).abs())).clamp(0.03, 0.08);
        return Container(
          height: 136,
          decoration: BoxDecoration(
            color: Color.fromRGBO(255, 255, 255, alpha),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.surfaceDivider, width: 1),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // 缩略图占位
              Container(
                width: 86,
                height: 108,
                decoration: BoxDecoration(
                  color: const Color(0x0DFFFFFF),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 14),
              // 文字占位
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBar(60, 12),
                    const SizedBox(height: 8),
                    _shimmerBar(100, 17),
                    const SizedBox(height: 12),
                    _shimmerBar(48, 11),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _shimmerBar(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 暗绿径向渐变背景 (PRD §3.1)
// ─────────────────────────────────────────────────────────────────────────────

class _RouteGradientBackground extends StatelessWidget {
  const _RouteGradientBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(gradient: AppColors.gradientRouteRadial),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 地形等高线装饰 (PRD §3.2)
// 4 条贝塞尔曲线，opacity .06，stroke rgba(180,255,180,.4)
// ─────────────────────────────────────────────────────────────────────────────

class _ContourLines extends StatelessWidget {
  const _ContourLines();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ContourPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _ContourPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.contourLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // 4 条等高线，y 从 300 至 450，间隔约 50px
    for (var i = 0; i < 4; i++) {
      final y = 300.0 + i * 50.0;
      final path = Path()
        ..moveTo(-10, y)
        ..cubicTo(
          size.width * 0.3,
          y - 20 + i * 5,
          size.width * 0.6,
          y + 25 - i * 3,
          size.width + 10,
          y - 10,
        );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
