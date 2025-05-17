import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../model/user_model.dart';
import '../../../../model/weather_model.dart';
import '../../../../service/service_locator.dart';

/// 欢迎卡片与天气预报结合组件
class WelcomeWeatherCard extends StatefulWidget {
  /// 构造函数
  const WelcomeWeatherCard({super.key});

  @override
  State<WelcomeWeatherCard> createState() => _WelcomeWeatherCardState();
}

class _WelcomeWeatherCardState extends State<WelcomeWeatherCard> with AutomaticKeepAliveClientMixin {
  /// 数据加载Future
  late Future<Map<String, dynamic>> _dataFuture;

  /// 蓝色系渐变色
  final List<Color> _blueGradient = const [
    Color(0xFF1976D2), // 深蓝色
    Color(0xFF42A5F5), // 浅蓝色
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  /// 加载数据
  Future<Map<String, dynamic>> _loadData() async {
    final apiService = ServiceLocator.instance.getApiService();

    // 并行加载用户和天气数据
    final results = await Future.wait([
      apiService.getCurrentUser(),
      apiService.getWeather(30.2741, 120.1551), // 杭州的经纬度
    ]);

    return {
      'user': results[0] as UserModel,
      'weather': results[1] as WeatherModel,
    };
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用super.build

    return FutureBuilder<Map<String, dynamic>>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard(context);
        }

        if (snapshot.hasError) {
          return _buildErrorCard(context, snapshot.error.toString());
        }

        final data = snapshot.data!;
        final user = data['user'] as UserModel;
        final weather = data['weather'] as WeatherModel;

        return _buildCard(context, user, weather);
      },
    );
  }

  /// 构建加载中的卡片
  Widget _buildLoadingCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _blueGradient,
          ),
        ),
        height: 200,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// 构建错误卡片
  Widget _buildErrorCard(BuildContext context, String errorMessage) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.red,
              Colors.red.withOpacity(0.7),
            ],
          ),
        ),
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
              errorMessage,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _dataFuture = _loadData();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
              ),
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建数据卡片
  Widget _buildCard(BuildContext context, UserModel user, WeatherModel weather) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _blueGradient,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white.withOpacity(0.9),
                    child: Icon(
                      Icons.person,
                      size: 32,
                      color: _blueGradient[0],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '欢迎回来',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.nickname,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('编辑个人资料功能尚未实现')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 天气信息
            Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.wb_sunny,
                        size: 24,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '今日天气',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.thermostat,
                            size: 20,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            weather.temperature,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            weather.condition,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: weather.isSuitableForHiking
                              ? Colors.green.withOpacity(0.3)
                              : Colors.red.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              weather.isSuitableForHiking
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              weather.isSuitableForHiking
                                  ? '适合徒步'
                                  : '不宜徒步',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Text(
              weather.advice,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}