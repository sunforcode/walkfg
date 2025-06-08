import 'package:flutter/cupertino.dart';
import 'package:walk/model/weather/weather_model.dart';
import 'package:walk/model/weather/weather_condition.dart';

/// 天气预报卡片组件
class WeatherForecastWidget extends StatelessWidget {
  /// 天气数据列表
  final List<WeatherModel> weatherList;

  /// 位置名称
  final String locationName;

  /// 是否显示详细信息
  final bool showDetails;

  /// 点击回调
  final VoidCallback? onTap;

  const WeatherForecastWidget({
    super.key,
    required this.weatherList,
    required this.locationName,
    this.showDetails = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (weatherList.isEmpty) {
      return _buildEmptyState();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: _getWeatherGradient(weatherList.first.weatherCondition),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(),
            if (showDetails)
              _buildDetailedForecast()
            else
              _buildSimpleForecast(),
          ],
        ),
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.cloud_bolt,
            size: 48,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(height: 12),
          Text(
            '天气数据加载中...',
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建头部
  Widget _buildHeader() {
    final currentWeather = weatherList.first;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // 天气图标和温度
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getWeatherIcon(currentWeather.weatherCondition),
                      size: 32,
                      color: CupertinoColors.white,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${currentWeather.temperature.toInt()}°',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _getWeatherDescription(currentWeather.weatherCondition),
                  style: TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.white.withOpacity(0.9),
                  ),
                ),
                Text(
                  locationName,
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          // 温度范围和其他信息
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (currentWeather.maxTemperature != null &&
                  currentWeather.minTemperature != null)
                Text(
                  '${currentWeather.maxTemperature!.toInt()}° / ${currentWeather.minTemperature!.toInt()}°',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.white.withOpacity(0.9),
                  ),
                ),
              const SizedBox(height: 8),
              _buildWeatherDetail(
                CupertinoIcons.drop,
                '${currentWeather.humidity.toInt()}%',
              ),
              const SizedBox(height: 4),
              _buildWeatherDetail(
                CupertinoIcons.wind,
                '${currentWeather.windSpeed.toInt()} km/h',
              ),
              const SizedBox(height: 4),
              if (currentWeather.visibility != null)
                _buildWeatherDetail(
                  CupertinoIcons.eye,
                  '${currentWeather.visibility!.toInt()} km',
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建简单预报
  Widget _buildSimpleForecast() {
    final forecastDays = weatherList.take(5).toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: forecastDays.map((weather) {
          final isToday = forecastDays.indexOf(weather) == 0;

          return Column(
            children: [
              Text(
                isToday ? '今天' : _formatWeekday(weather.date),
                style: TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8),
              Icon(
                _getWeatherIcon(weather.weatherCondition),
                size: 24,
                color: CupertinoColors.white,
              ),
              const SizedBox(height: 8),
              if (weather.maxTemperature != null)
                Text(
                  '${weather.maxTemperature!.toInt()}°',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.white,
                  ),
                ),
              if (weather.minTemperature != null)
                Text(
                  '${weather.minTemperature!.toInt()}°',
                  style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.white.withOpacity(0.7),
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// 构建详细预报
  Widget _buildDetailedForecast() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: weatherList.take(7).map((weather) {
          final isToday = weatherList.indexOf(weather) == 0;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CupertinoColors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // 日期
                SizedBox(
                  width: 60,
                  child: Text(
                    isToday ? '今天' : _formatDate(weather.date),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: CupertinoColors.white.withOpacity(0.9),
                    ),
                  ),
                ),

                // 天气图标
                Icon(
                  _getWeatherIcon(weather.weatherCondition),
                  size: 24,
                  color: CupertinoColors.white,
                ),

                const SizedBox(width: 12),

                // 天气描述
                Expanded(
                  child: Text(
                    _getWeatherDescription(weather.weatherCondition),
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.white.withOpacity(0.8),
                    ),
                  ),
                ),

                // 降水概率
                if (weather.precipitationProbability != null &&
                    weather.precipitationProbability! > 0)
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.drop,
                          size: 12,
                          color: CupertinoColors.white.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${weather.precipitationProbability}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),

                // 温度
                if (weather.maxTemperature != null &&
                    weather.minTemperature != null)
                  Text(
                    '${weather.maxTemperature!.toInt()}° / ${weather.minTemperature!.toInt()}°',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.white,
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 构建天气详情项
  Widget _buildWeatherDetail(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: CupertinoColors.white.withOpacity(0.7),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: CupertinoColors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  /// 获取天气渐变色
  LinearGradient _getWeatherGradient(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.sunny:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4A90E2),
            Color(0xFF7BB3F0),
          ],
        );
      case WeatherCondition.cloudy:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6C7B7F),
            Color(0xFF9B9B9B),
          ],
        );
      case WeatherCondition.rainy:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4A6FA5),
            Color(0xFF166BA0),
          ],
        );
      case WeatherCondition.snowy:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF9BB5FF),
            Color(0xFFE6F3FF),
          ],
        );
      case WeatherCondition.foggy:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8E8E93),
            Color(0xFFAEAEB2),
          ],
        );
      case WeatherCondition.stormy:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2C3E50),
            Color(0xFF4A6741),
          ],
        );
    }
  }

  /// 获取天气图标
  IconData _getWeatherIcon(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.sunny:
        return CupertinoIcons.sun_max;
      case WeatherCondition.cloudy:
        return CupertinoIcons.cloud;
      case WeatherCondition.rainy:
        return CupertinoIcons.cloud_rain;
      case WeatherCondition.snowy:
        return CupertinoIcons.snow;
      case WeatherCondition.foggy:
        return CupertinoIcons.cloud_fog;
      case WeatherCondition.stormy:
        return CupertinoIcons.cloud_bolt;
    }
  }

  /// 获取天气描述
  String _getWeatherDescription(WeatherCondition condition) {
    return condition.description;
  }

  /// 格式化星期
  String _formatWeekday(DateTime date) {
    final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return weekdays[date.weekday - 1];
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}
