import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../model/user_model.dart';
import '../../../../model/weather_model.dart';
import '../../../../service/service_locator.dart';
import '../../../theme/app_color_palette.dart';
import '../../../widgets/common/async_content_builder.dart';
import '../../../widgets/common/cupertino_card.dart';

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

    return AsyncContentBuilder<Map<String, dynamic>>(
      future: _dataFuture,
      loadingBuilder: (context) => _buildLoadingCard(context),
      errorBuilder: (context, error) => _buildErrorCard(context, error),
      builder: (context, data) {
        final user = data['user'] as UserModel;
        final weather = data['weather'] as WeatherModel;
        return _buildCard(context, user, weather);
      },
      onRetry: () {
        setState(() {
          _dataFuture = _loadData();
        });
      },
    );
  }

  /// 构建加载中的卡片
  Widget _buildLoadingCard(BuildContext context) {
    return CupertinoCard(
      gradient: AppColorPalette.blueGradient,
      child: const SizedBox(
        height: 200,
        child: Center(
          child: CupertinoActivityIndicator(
            color: CupertinoColors.white,
          ),
        ),
      ),
    );
  }

  /// 构建错误卡片
  Widget _buildErrorCard(BuildContext context, String errorMessage) {
    return CupertinoCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.red,
          Color(0xFFE57373),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_circle,
            color: CupertinoColors.white,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            errorMessage,
            style: const TextStyle(color: CupertinoColors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          CupertinoButton(
            color: CupertinoColors.white,
            onPressed: () {
              setState(() {
                _dataFuture = _loadData();
              });
            },
            child: const Text(
              '重试',
              style: TextStyle(color: CupertinoColors.systemRed),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建数据卡片
  Widget _buildCard(BuildContext context, UserModel user, WeatherModel weather) {
    return CupertinoCard(
      gradient: AppColorPalette.blueGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: CupertinoColors.white, width: 2),
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: CupertinoColors.white.withOpacity(0.9),
                  child: Icon(
                    CupertinoIcons.person,
                    size: 32,
                    color: AppColorPalette.blueColors[0],
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
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user.nickname,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: CupertinoColors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.pencil, color: CupertinoColors.white),
                onPressed: () {
                  showCupertinoDialog(
                    context: context,
                    builder: (context) => CupertinoAlertDialog(
                      title: const Text('提示'),
                      content: const Text('编辑个人资料功能尚未实现'),
                      actions: [
                        CupertinoDialogAction(
                          child: const Text('确定'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
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
                      CupertinoIcons.sun_max,
                      size: 24,
                      color: CupertinoColors.systemYellow,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '今日天气',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: CupertinoColors.white,
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
                          CupertinoIcons.thermometer,
                          size: 20,
                          color: CupertinoColors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          weather.temperature,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: CupertinoColors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          weather.condition,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: CupertinoColors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: weather.isSuitableForHiking
                            ? CupertinoColors.systemGreen.withOpacity(0.3)
                            : CupertinoColors.systemRed.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            weather.isSuitableForHiking
                                ? CupertinoIcons.checkmark_circle
                                : CupertinoIcons.xmark_circle,
                            size: 16,
                            color: CupertinoColors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            weather.isSuitableForHiking
                                ? '适合徒步'
                                : '不宜徒步',
                            style: const TextStyle(
                              color: CupertinoColors.white,
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
              color: CupertinoColors.white,
            ),
          ),
        ],
      ),
    );
  }
}