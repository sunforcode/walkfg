import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../../../../model/route/route_model.dart';
import '../../../../model/weather/weather_model.dart';
import '../../../../theme/tokens/colors.dart';
import '../../../../theme/tokens/radius.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../common/immersive_components.dart';
import '../../common/network_image_with_fallback.dart';
import '../home_screen.dart' show HomeData;

// ─────────────────────────────────────────────────────────────────────────────
// P2 首页-有行程 (PRD §3.2)
// ─────────────────────────────────────────────────────────────────────────────

class RouteHome extends StatelessWidget {
  final HomeData data;
  final VoidCallback onChangeRoute;

  const RouteHome({
    super.key,
    required this.data,
    required this.onChangeRoute,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final viewPadding = mediaQuery.viewPadding;
    final isCompactHeight = mediaQuery.size.height <= 600;

    return ImmersiveHero(
      image: _RouteHeroImage(route: data.route),
      overlay: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: viewPadding.top + AppSpacing.hero,
            left: AppSpacing.heroHorizontal,
            right: AppSpacing.hero,
            child: KeyedSubtree(
              key: const Key('home-info-overlay'),
              child: _InfoOverlay(data: data),
            ),
          ),
          if (isCompactHeight)
            Positioned(
              bottom: viewPadding.bottom + AppSpacing.heroHorizontal,
              left: AppSpacing.heroHorizontal,
              right: AppSpacing.heroHorizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GlassIconAction(
                    key: const Key('home-change-route'),
                    semanticLabel: '更换路线',
                    icon: CupertinoIcons.arrow_2_circlepath,
                    onPressed: onChangeRoute,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _WeatherHud(weather: data.weatherFor(data.hikingDate)),
                ],
              ),
            )
          else ...[
            Positioned(
              bottom: viewPadding.bottom + 200,
              left: AppSpacing.heroHorizontal,
              child: GlassIconAction(
                key: const Key('home-change-route'),
                semanticLabel: '更换路线',
                icon: CupertinoIcons.arrow_2_circlepath,
                onPressed: onChangeRoute,
              ),
            ),
            Positioned(
              bottom: viewPadding.bottom + 100,
              left: AppSpacing.heroHorizontal,
              right: AppSpacing.heroHorizontal,
              child: _WeatherHud(weather: data.weatherFor(data.hikingDate)),
            ),
            Positioned(
              bottom: viewPadding.bottom + AppSpacing.heroHorizontal,
              left: 0,
              right: 0,
              child: const _SwipeIndicator(),
            ),
          ],
        ],
      ),
    );
  }
}

class _RouteHeroImage extends StatelessWidget {
  final RouteModel route;

  const _RouteHeroImage({required this.route});

  @override
  Widget build(BuildContext context) {
    final imageUrl = _imageUrl;
    if (imageUrl == null) return const _TrailBackground();

    return SizedBox.expand(
      key: const Key('home-route-image'),
      child: NetworkImageWithFallback(
        url: imageUrl,
        fit: BoxFit.cover,
        fallbackColor: AppColors.bgBase,
        placeholderBuilder: (_) => const _TrailBackground(),
        errorBuilder: (_) => const _TrailBackground(),
      ),
    );
  }

  String? get _imageUrl {
    final coverUrl = route.coverUrl?.trim();
    if (coverUrl != null && coverUrl.isNotEmpty) return coverUrl;
    for (final imageUrl in route.imageUrls ?? const <String>[]) {
      final trimmedUrl = imageUrl.trim();
      if (trimmedUrl.isNotEmpty) return trimmedUrl;
    }
    return null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Trail 背景 (P2 Layer 1)
// 基底 #0a0a1a + 山峦剪影 + 轨迹线 + 起终点标记
// ─────────────────────────────────────────────────────────────────────────────

class _TrailBackground extends StatelessWidget {
  const _TrailBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      key: const Key('home-route-image-fallback'),
      painter: _TrailPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _TrailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 基底色
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = AppColors.bgBase,
    );

    // 山峦剪影 — rgba(255,255,255,.02)
    final mountainPaint = Paint()..color = const Color(0x05FFFFFF);
    final mountainPath = Path()
      ..moveTo(0, size.height * 0.739)
      ..lineTo(size.width * 0.213, size.height * 0.431)
      ..lineTo(size.width * 0.400, size.height * 0.555)
      ..lineTo(size.width * 0.667, size.height * 0.345)
      ..lineTo(size.width, size.height * 0.493)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(mountainPath, mountainPaint);

    // 轨迹线外光晕 — 12px rgba(100,200,255,.15)
    final glowPaint = Paint()
      ..color = AppColors.trailOuter
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12;
    final trailPath = Path()
      ..moveTo(size.width * 0.160, size.height * 0.677)
      ..cubicTo(
        size.width * 0.267,
        size.height * 0.591,
        size.width * 0.320,
        size.height * 0.517,
        size.width * 0.427,
        size.height * 0.468,
      )
      ..cubicTo(
        size.width * 0.533,
        size.height * 0.419,
        size.width * 0.587,
        size.height * 0.443,
        size.width * 0.667,
        size.height * 0.394,
      )
      ..cubicTo(
        size.width * 0.747,
        size.height * 0.357,
        size.width * 0.800,
        size.height * 0.382,
        size.width * 0.853,
        size.height * 0.345,
      );
    canvas.drawPath(trailPath, glowPaint);

    // 轨迹线内线 — 3px rgba(100,200,255,.6)
    final innerPaint = Paint()
      ..color = AppColors.interactiveAccentSoft
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;
    canvas.drawPath(trailPath, innerPaint);

    // 起点标记 — 圆 5px rgba(100,200,255,.8)
    final startOffset = Offset(size.width * 0.160, size.height * 0.677);
    canvas.drawCircle(startOffset, 5, Paint()..color = AppColors.trailStart);

    // 终点标记 — 圆 5px rgba(255,100,100,.8)
    final endOffset = Offset(size.width * 0.853, size.height * 0.345);
    canvas.drawCircle(endOffset, 5, Paint()..color = const Color(0xCCFF6464));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// 上方信息覆盖 (P2 Layer 3)
// 路线名 + 出发日期 + 倒计时 + 核心指标
// ─────────────────────────────────────────────────────────────────────────────

class _InfoOverlay extends StatelessWidget {
  final HomeData data;
  const _InfoOverlay({required this.data});

  @override
  Widget build(BuildContext context) {
    return HeroTitleOverlay(
      title: data.route.name,
      supportingText: _DepartureLine(hikingDate: data.hikingDate),
      metrics: MetricGroup(metrics: _metrics(data.route)),
    );
  }

  List<MetricData> _metrics(RouteModel route) {
    final distance = route.distance == route.distance.roundToDouble()
        ? route.distance.round().toString()
        : route.distance.toStringAsFixed(1);
    return [
      MetricData(value: distance, unit: '公里'),
      MetricData(
        value: route.elevationGain.toStringAsFixed(0),
        unit: '米爬升',
      ),
      MetricData(value: route.durationText, unit: '预计用时'),
    ];
  }
}

class _DepartureLine extends StatelessWidget {
  final DateTime hikingDate;
  const _DepartureLine({required this.hikingDate});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(hikingDate.year, hikingDate.month, hikingDate.day);
    final diff = target.difference(today).inDays;

    final dateStr = '${hikingDate.month}月${hikingDate.day}日';

    if (diff <= 0) {
      return Text(
        '$dateStr · 今天出发',
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      );
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        children: [
          TextSpan(text: '$dateStr · 距离出发还有 '),
          TextSpan(
            text: '$diff',
            style: const TextStyle(
              color: AppColors.interactiveAccent,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const TextSpan(text: ' 天'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Weather HUD (P2 Layer 4)
// 毛玻璃风格：rgba(255,255,255,.08) + backdrop blur 20px + 边框 .06
// ─────────────────────────────────────────────────────────────────────────────

class _WeatherHud extends StatelessWidget {
  final WeatherModel? weather;
  const _WeatherHud({this.weather});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      key: const Key('home-weather-overlay'),
      borderRadius: BorderRadius.circular(AppRadius.panel),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0x14FFFFFF), // rgba(255,255,255,.08)
            borderRadius: BorderRadius.circular(AppRadius.panel),
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Label
              const Text(
                '徒步日天气',
                style: TextStyle(
                  color: AppColors.textWeak,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
              // 三栏数据
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _HudMetric(
                    value: _rainValue,
                    label: '降雨',
                  ),
                  _HudMetric(
                    value: _windValue,
                    label: '风',
                  ),
                  _HudMetric(
                    value: _tempValue,
                    label: '温度',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _rainValue {
    final p = weather?.precipitationProbability;
    return p != null ? '$p%' : '--';
  }

  String get _windValue {
    if (weather == null) return '--';
    return '${weather!.windSpeed.toStringAsFixed(0)}km/h';
  }

  String get _tempValue {
    if (weather == null) return '--';
    final min = weather!.minTemperature;
    final max = weather!.maxTemperature;
    if (min != null && max != null) return '${min.round()}-${max.round()}°';
    return '${weather!.temperature.round()}°';
  }
}

class _HudMetric extends StatelessWidget {
  final String value;
  final String label;
  const _HudMetric({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textWeak,
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 上滑指示器 (P2 Layer 7)
// 箭头 + "推荐路线" 文字，带循环动画
// ─────────────────────────────────────────────────────────────────────────────

class _SwipeIndicator extends StatefulWidget {
  const _SwipeIndicator();

  @override
  State<_SwipeIndicator> createState() => _SwipeIndicatorState();
}

class _SwipeIndicatorState extends State<_SwipeIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _offsetAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _offsetAnim = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offsetAnim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _offsetAnim.value),
          child: child,
        );
      },
      child: Column(
        key: const Key('home-swipe-indicator'),
        mainAxisSize: MainAxisSize.min,
        children: [
          // 向上箭头
          CustomPaint(
            size: const Size(20, 20),
            painter: _UpArrowPainter(),
          ),
          const SizedBox(height: 4),
          const Text(
            '推荐路线',
            style: TextStyle(
              color: AppColors.textWeak,
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _UpArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textWeak
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(size.width * 0.25, size.height * 0.65)
      ..lineTo(size.width * 0.5, size.height * 0.25)
      ..lineTo(size.width * 0.75, size.height * 0.65);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
