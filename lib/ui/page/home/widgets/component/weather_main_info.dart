import 'package:flutter/material.dart';
import 'package:walk/model/weather/weather_model.dart';
import 'package:walk/theme/tokens/tokens.dart';

/// 天气主要信息组件
class WeatherMainInfo extends StatelessWidget {
  /// 天气模型
  final WeatherModel weather;

  const WeatherMainInfo({
    Key? key,
    required this.weather,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: AppColors.textOnDark.withValues(alpha: 0.9),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  weather.city,
                  style: TextStyle(
                    color: AppColors.textOnDark.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${weather.temperature.toInt()}°C',
              style: TextStyle(
                color: AppColors.textOnDark,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              weather.getWeatherConditionText(),
              style: TextStyle(
                color: AppColors.textOnDark.withValues(alpha: 0.9),
                fontSize: 16,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Icon(
              weather.weatherIcon,
              color: AppColors.textOnDark,
              size: 48,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: weather.suitability ? AppColors.success.withValues(alpha: 0.8) : AppColors.error.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                weather.suitability ? '适宜徒步' : '不宜徒步',
                style: TextStyle(
                  color: AppColors.textOnDark,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
