import 'package:flutter/material.dart';
import 'package:walk/model/user/user_model.dart';
import 'package:walk/model/weather/weather_model.dart';
import 'package:walk/service/location/location_service.dart';
import 'package:walk/theme/tokens/tokens.dart';
import 'package:walk/ui/page/home/widgets/component/error_card.dart';
import 'package:walk/ui/page/home/widgets/component/loading_card.dart';
import 'package:walk/ui/page/home/widgets/component/weather_header.dart';
import 'package:walk/ui/page/home/widgets/component/weather_main_info.dart';
import 'package:walk/ui/page/home/widgets/component/weather_details_row.dart';

/// 欢迎和天气卡片组件
class WelcomeWeatherCard extends StatelessWidget {
  /// 用户模型
  final UserModel user;

  /// 天气模型
  final WeatherModel? weather;

  /// 刷新回调
  final Future<void> Function()? onRefresh;

  /// 海拔信息
  final AltitudeInfo? altitudeInfo;

  /// 是否正在获取海拔
  final bool isLoadingAltitude;

  /// 获取海拔回调
  final Future<void> Function()? onGetAltitude;

  /// 构造函数
  const WelcomeWeatherCard({
    Key? key,
    required this.user,
    this.weather,
    this.onRefresh,
    this.altitudeInfo,
    this.isLoadingAltitude = false,
    this.onGetAltitude,
  }) : super(key: key);

  /// 从Future创建
  static Widget fromFuture({
    required Future<Map<String, dynamic>> future,
    Future<void> Function()? onRefresh,
    AltitudeInfo? altitudeInfo,
    bool isLoadingAltitude = false,
    Future<void> Function()? onGetAltitude,
  }) {
    return FutureBuilder<Map<String, dynamic>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingCard();
        } else if (snapshot.hasData) {
          final user = snapshot.data!['user'] as UserModel;
          final weather = snapshot.data!['weather'] as WeatherModel?;
          return WelcomeWeatherCard(
            user: user,
            weather: weather,
            onRefresh: onRefresh,
            altitudeInfo: altitudeInfo,
            isLoadingAltitude: isLoadingAltitude,
            onGetAltitude: onGetAltitude,
          );
        } else {
          return const ErrorCard(
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
        gradient:
            weather != null ? AppColors.getWeatherGradient(weather!.condition.name) : AppColors.weatherDefaultGradient,
        borderRadius: AppRadius.borderXl,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.borderXl,
        child: Stack(
          children: [
            // 背景图案
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                weather != null ? weather!.weatherIcon : Icons.cloud,
                size: 120,
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),

            // 内容
            Padding(
              padding: AppSpacing.allMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 欢迎信息
                  WeatherHeader(
                    user: user,
                    onRefresh: onRefresh,
                  ),

                  const SizedBox(height: 20),

                  // 天气信息
                  if (weather != null) ...[
                    WeatherMainInfo(weather: weather!),
                    const SizedBox(height: 16),
                    WeatherDetailsRow(
                      weather: weather!,
                      altitudeInfo: altitudeInfo,
                      isLoadingAltitude: isLoadingAltitude,
                      onGetAltitude: onGetAltitude,
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
}
