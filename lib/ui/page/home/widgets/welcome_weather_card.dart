import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../model/user/user_model.dart';
import '../../../../model/weather/weather_model.dart';

/// 欢迎和天气卡片组件
class WelcomeWeatherCard extends StatelessWidget {
  /// 用户模型
  final UserModel user;

  /// 天气模型
  final WeatherModel? weather;

  /// 刷新回调
  final Future<void> Function()? onRefresh;

  /// 构造函数
  const WelcomeWeatherCard({
    Key? key,
    required this.user,
    this.weather,
    this.onRefresh,
  }) : super(key: key);

  /// 从Future创建
  static Widget fromFuture({
    required Future<Map<String, dynamic>> future,
    Future<void> Function()? onRefresh,
  }) {
    return FutureBuilder<Map<String, dynamic>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingCard();
        } else if (snapshot.hasError) {
          return _ErrorCard(
            error: snapshot.error.toString(),
            onRetry: onRefresh,
          );
        } else if (snapshot.hasData) {
          final user = snapshot.data!['user'] as UserModel;
          final weather = snapshot.data!['weather'] as WeatherModel?;
          return WelcomeWeatherCard(
            user: user,
            weather: weather,
            onRefresh: onRefresh,
          );
        } else {
          return const _ErrorCard(
            error: '无法加载数据',
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: weather != null
              ? _getWeatherGradient(weather!)
              : [Colors.blue.shade300, Colors.blue.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // 背景图案
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                weather != null ? weather!.weatherIcon : Icons.cloud,
                size: 120,
                color: Colors.white.withOpacity(0.2),
              ),
            ),

            // 内容
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 欢迎信息
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: user.avatarUrl != null
                            ? NetworkImage(user.avatarUrl!)
                            : null,
                        child: user.avatarUrl == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '欢迎，${user.nickname ?? '徒步者'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _getGreetingByTime(),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (onRefresh != null)
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          onPressed: onRefresh,
                          tooltip: '刷新天气',
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 天气信息
                  if (weather != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.white.withOpacity(0.9),
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  weather!.city,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${weather!.temperature.toInt()}°C',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              weather!.getWeatherConditionText(),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Icon(
                              weather!.weatherIcon,
                              color: Colors.white,
                              size: 48,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: weather!.suitability
                                    ? Colors.green.withOpacity(0.8)
                                    : Colors.red.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                weather!.suitability ? '适宜徒步' : '不宜徒步',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 天气详情
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildWeatherDetail(
                          Icons.air,
                          '风级',
                          '${weather!.windLevel}',
                        ),
                        _buildWeatherDetail(
                          Icons.water_drop,
                          '湿度',
                          "${weather!.humidity}",
                        ),
                        if (weather!.precipitationProbability != null)
                          _buildWeatherDetail(
                            Icons.umbrella,
                            '降水概率',
                            '${weather!.precipitationProbability}%',
                          ),
                      ],
                    ),
                  ] else ...[
                    const Center(
                      child: Text(
                        '无法获取天气信息',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建天气详情项
  Widget _buildWeatherDetail(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.9),
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 根据时间获取问候语
  String _getGreetingByTime() {
    final hour = DateTime.now().hour;
    if (hour < 6) {
      return '夜深了，注意休息';
    } else if (hour < 9) {
      return '早上好，新的一天';
    } else if (hour < 12) {
      return '上午好，今天天气不错';
    } else if (hour < 14) {
      return '中午好，享用午餐吧';
    } else if (hour < 18) {
      return '下午好，来杯咖啡？';
    } else if (hour < 22) {
      return '晚上好，度过愉快的夜晚';
    } else {
      return '夜深了，注意休息';
    }
  }

  /// 根据天气获取渐变色
  List<Color> _getWeatherGradient(WeatherModel weather) {
    final condition = weather.condition.toLowerCase();

    if (condition.contains('晴') || condition.contains('sunny')) {
      return [Colors.orange.shade300, Colors.orange.shade700];
    } else if (condition.contains('多云') || condition.contains('cloudy')) {
      return [Colors.blueGrey.shade300, Colors.blueGrey.shade700];
    } else if (condition.contains('雨') || condition.contains('rain')) {
      return [Colors.blue.shade300, Colors.blue.shade700];
    } else if (condition.contains('雪') || condition.contains('snow')) {
      return [Colors.lightBlue.shade100, Colors.lightBlue.shade400];
    } else if (condition.contains('雾') || condition.contains('fog')) {
      return [Colors.grey.shade300, Colors.grey.shade600];
    } else if (condition.contains('风') || condition.contains('wind')) {
      return [Colors.teal.shade300, Colors.teal.shade700];
    } else {
      return [Colors.blue.shade300, Colors.blue.shade600];
    }
  }
}

/// 加载中的卡片
class _LoadingCard extends StatelessWidget {
  const _LoadingCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade300, Colors.blue.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: CupertinoActivityIndicator(
          color: Colors.white,
          radius: 16,
        ),
      ),
    );
  }
}

/// 错误卡片
class _ErrorCard extends StatelessWidget {
  final String error;
  final Future<void> Function()? onRetry;

  const _ErrorCard({
    Key? key,
    required this.error,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.red.shade300, Colors.red.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              '加载失败: $error',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                color: Colors.white.withOpacity(0.3),
                child: const Text(
                  '重试',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
