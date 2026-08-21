import 'package:flutter/material.dart';

import '../../../../model/route/route_model.dart';
import '../home_screen.dart' show HomeData;
import 'topo_background.dart';
import 'weather_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Main: route home
// ─────────────────────────────────────────────────────────────────────────────

class RouteHome extends StatelessWidget {
  final HomeData data;
  final VoidCallback onChangeRoute;

  const RouteHome({super.key, required this.data, required this.onChangeRoute}); // onChangeRoute kept for future use

  @override
  Widget build(BuildContext context) {
    final weather = data.weatherFor(data.hikingDate);
    final coverUrl = data.route.coverUrl;

    return Stack(
      fit: StackFit.expand,
      children: [
        // ── background: cover image or topo fallback ──────────────────────
        if (coverUrl != null && coverUrl.isNotEmpty)
          _CoverBackground(url: coverUrl)
        else
          const TopoBackground(),

        // ── dark gradient overlay for legibility ──────────────────────────
        const _OverlayGradient(),

        // ── content ───────────────────────────────────────────────────────
        SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── top-left info ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // route name
                    Text(
                      data.route.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // hiking date  (6月6日)
                    Text(
                      '${data.hikingDate.month}月${data.hikingDate.day}日',
                      style: const TextStyle(
                        color: Color(0xFFB6FF5C),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // countdown  (距离出发还有 N 天)
                    _Countdown(hikingDate: data.hikingDate),
                    const SizedBox(height: 14),

                    // metric strip  (32.4 km · 爬升 1800 m · 9:30)
                    _MetricLine(route: data.route),
                  ],
                ),
              ),

              const Spacer(),

              // weather card (bottom)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: WeatherCard(weather: weather),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cover image background
// ─────────────────────────────────────────────────────────────────────────────

class _CoverBackground extends StatelessWidget {
  final String url;
  const _CoverBackground({required this.url});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const TopoBackground(),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const TopoBackground();
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gradient overlay (top transparent → bottom dark)
// ─────────────────────────────────────────────────────────────────────────────

class _OverlayGradient extends StatelessWidget {
  const _OverlayGradient();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.28, 0.60, 1.0],
          colors: [
            Colors.black.withValues(alpha: 0.52),
            Colors.black.withValues(alpha: 0.18),
            Colors.black.withValues(alpha: 0.55),
            Colors.black.withValues(alpha: 0.88),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small widgets
// ─────────────────────────────────────────────────────────────────────────────

class _Countdown extends StatelessWidget {
  final DateTime hikingDate;
  const _Countdown({required this.hikingDate});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff =
        DateTime(hikingDate.year, hikingDate.month, hikingDate.day)
            .difference(today)
            .inDays;

    if (diff <= 0) {
      return Text(
        '今天就出发！',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.85),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.85),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        children: [
          const TextSpan(text: '距离出发还有 '),
          TextSpan(
            text: '$diff',
            style: const TextStyle(
              color: Color(0xFFB6FF5C),
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
    final parts = [
      '${route.distance.toStringAsFixed(1)} km',
      '爬升 ${route.elevationGain.toStringAsFixed(0)} m',
      route.durationText,
    ];
    return Text(
      parts.join('  ·  '),
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.7),
        fontSize: 15,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
    );
  }
}
