import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../model/weather/weather_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Weather card
// ─────────────────────────────────────────────────────────────────────────────

class WeatherCard extends StatelessWidget {
  final WeatherModel? weather;
  const WeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1A13).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '徒步日天气',
            style: TextStyle(
              color: const Color(0xFFB6FF5C).withValues(alpha: 0.9),
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _WeatherCol(
                    icon: CupertinoIcons.cloud_rain,
                    value: _rain(weather),
                    label: '降雨',
                  ),
                ),
                Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                Expanded(
                  child: _WeatherCol(
                    icon: CupertinoIcons.wind,
                    value: _wind(weather),
                    label: '风',
                  ),
                ),
                Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                Expanded(
                  child: _WeatherCol(
                    icon: CupertinoIcons.thermometer,
                    value: _temp(weather),
                    label: '温度',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _rain(WeatherModel? w) {
    final p = w?.precipitationProbability;
    return p != null ? '$p%' : '--';
  }

  static String _wind(WeatherModel? w) =>
      w != null ? '${w.windSpeed.toStringAsFixed(0)}km/h' : '--';

  static String _temp(WeatherModel? w) {
    if (w == null) return '--';
    final min = w.minTemperature;
    final max = w.maxTemperature;
    if (min != null && max != null) return '${min.round()}-${max.round()}°';
    return '${w.temperature.round()}°';
  }
}

class _WeatherCol extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _WeatherCol({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.5), size: 19),
        const SizedBox(height: 7),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.45),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
