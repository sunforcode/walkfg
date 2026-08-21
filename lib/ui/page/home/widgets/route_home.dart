import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../model/route/route_model.dart';
import '../../../../model/weather/weather_model.dart';
import '../../../../theme/tokens/colors.dart';
import '../../../../theme/tokens/radius.dart';
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
    return Stack(
      fit: StackFit.expand,
      children: [
        // Layer 1 — Trail 背景（山峦 + 轨迹线）
        const _TrailBackground(),

        // Layer 2 — 全屏点击层（→ P6）
        // 交互由 HomeScreen 管理，此处仅占位保证视觉层级

        // Layer 3 — 上方信息覆盖
        Positioned(
          top: 80,
          left: 24,
          right: 80,
          child: _InfoOverlay(data: data),
        ),

        // Layer 4 — Weather HUD
        Positioned(
          bottom: 100,
          left: 20,
          right: 20,
          child: _WeatherHud(weather: data.weatherFor(data.hikingDate)),
        ),

        // Layer 7 — 上滑指示器
        const Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: _SwipeIndicator(),
        ),
      ],
    );
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
    canvas.drawCircle(
        endOffset, 5, Paint()..color = const Color(0xCCFF6464));
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 路线名
        Text(
          data.route.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 28,
            fontWeight: FontWeight.w700,
            height: 1.1,
            shadows: [
              Shadow(
                color: Color(0x80000000),
                blurRadius: 12,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        // 出发日期 + 倒计时
        _DepartureLine(hikingDate: data.hikingDate),
        const SizedBox(height: 4),
        // 核心指标
        _MetricLine(route: data.route),
      ],
    );
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
              color: AppColors.accentBlue,
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

class _MetricLine extends StatelessWidget {
  final RouteModel route;
  const _MetricLine({required this.route});

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    final dist = route.distance;
    if (dist == dist.roundToDouble()) {
      parts.add('${dist.round()} km');
    } else {
      parts.add('${dist.toStringAsFixed(1)} km');
    }
    parts.add('爬升 ${route.elevationGain.toStringAsFixed(0)} m');
    parts.add(route.durationText);
    return Text(
      parts.join('  ·  '),
      style: const TextStyle(
        color: AppColors.textBody,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.0,
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
      borderRadius: BorderRadius.circular(AppRadius.xxl),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0x14FFFFFF), // rgba(255,255,255,.08)
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            border: Border.all(
              color: AppColors.surfaceCardBorder,
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
                  color: AppColors.textSubtitle,
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
            color: AppColors.textSubtitle,
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
              color: AppColors.textDim,
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
      ..color = AppColors.textDim
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
