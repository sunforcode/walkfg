import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/utils/date_time_utils.dart';
import '../../../../model/user/user_model.dart';
import '../../../../model/weather/weather_model.dart';

/// 欢迎和天气卡片组件
class WelcomeWeatherCard extends StatelessWidget {
  /// 用户数据
  final UserModel? user;

  /// 天气数据
  final WeatherModel? weather;

  /// 问候语
  final String? greeting;

  /// 现在海拔
  /// 天气描述
  final String? weatherDescription;

  /// 天气状况文本
  final String? weatherConditionText;

  /// 背景颜色
  final Color? backgroundColor;

  /// 构造函数
  const WelcomeWeatherCard({
    super.key,
    required this.user,
    required this.weather,
    this.greeting,
    this.weatherDescription,
    this.weatherConditionText,
    this.backgroundColor,
  });

  /// 创建加载中状态的卡片
  static Widget loading() {
    return const _LoadingWelcomeWeatherCard();
  }

  /// 创建错误状态的卡片
  static Widget error({required String errorMessage}) {
    return _ErrorWelcomeWeatherCard(errorMessage: errorMessage);
  }

  /// 从Future创建卡片
  ///
  /// 处理数据加载、错误处理和状态管理
  static Widget fromFuture({
    required Future<Map<String, dynamic>> future,
  }) {
    return FutureBuilder<Map<String, dynamic>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loading();
        } else if (snapshot.hasError) {
          return error(errorMessage: snapshot.error.toString());
        } else if (snapshot.hasData) {
          final user = snapshot.data!['user'] as UserModel;
          final weather = snapshot.data!['weather'] as WeatherModel;

          // 获取问候语和天气相关文本
          final greeting = DateTimeUtils.getGreeting();
          final weatherDescription = weather.getWeatherDescription();
          final weatherConditionText = weather.getWeatherConditionText();
          final backgroundColor = weather.getWeatherColor();

          return WelcomeWeatherCard(
            user: user,
            weather: weather,
            greeting: greeting,
            weatherDescription: weatherDescription,
            weatherConditionText: weatherConditionText,
            backgroundColor: backgroundColor,
          );
        } else {
          return error(errorMessage: '数据加载失败');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 确保user和weather不为null
    if (user == null || weather == null) {
      return _ErrorWelcomeWeatherCard(errorMessage: '数据不完整');
    }

    // 使用提供的背景颜色或默认颜色
    final bgColor = backgroundColor ?? const Color(0xFF3498DB);

    // 安全获取温度字符串
    final temperatureStr = weather?.temperature.toStringAsFixed(1) ?? "";

    // 安全获取风速字符串
    final windSpeedStr = weather?.windSpeed.toStringAsFixed(1) ?? "";

    // 安全获取湿度值
    final humidityStr = '${weather?.humidityValue}';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bgColor,
            bgColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${greeting ?? '你好'}，${user?.nickname}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        weatherDescription != null
                            ? '今天是个$weatherDescription的日子'
                            : weather?.advice ?? "",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$temperatureStr°C',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      weatherConditionText ?? weather?.condition ?? "",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildWeatherDetail(
                  icon: CupertinoIcons.wind,
                  label: '风速',
                  value: '$windSpeedStr m/s',
                ),
                const SizedBox(width: 24),
                _buildWeatherDetail(
                  icon: CupertinoIcons.drop,
                  label: '湿度',
                  value: '$humidityStr%',
                ),
                const SizedBox(width: 24),
                _buildWeatherDetail(
                  icon: CupertinoIcons.location,
                  label: '城市',
                  value: weather?.city ?? "位置城市",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建天气详情项
  Widget _buildWeatherDetail({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 加载中状态的欢迎和天气卡片
class _LoadingWelcomeWeatherCard extends StatelessWidget {
  /// 构造函数
  const _LoadingWelcomeWeatherCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF3498DB).withOpacity(0.7),
            const Color(0xFF2980B9).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3498DB).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Center(
        child: CupertinoActivityIndicator(
          color: Colors.white,
          radius: 15,
        ),
      ),
    );
  }
}

/// 错误状态的欢迎和天气卡片
class _ErrorWelcomeWeatherCard extends StatelessWidget {
  /// 错误信息
  final String errorMessage;

  /// 构造函数
  const _ErrorWelcomeWeatherCard({required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF3498DB).withOpacity(0.7),
            const Color(0xFF2980B9).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3498DB).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.exclamationmark_circle,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '天气数据加载失败',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                errorMessage,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
