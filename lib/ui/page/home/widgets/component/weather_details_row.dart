import 'package:flutter/material.dart';
import 'package:walk/model/weather/weather_model.dart';
import 'package:walk/services/location/location_service.dart';
import 'weather_detail_item.dart';
import 'altitude_button.dart';

/// 天气详情行组件
class WeatherDetailsRow extends StatelessWidget {
  /// 天气模型
  final WeatherModel weather;

  /// 海拔信息
  final AltitudeInfo? altitudeInfo;

  /// 是否正在获取海拔
  final bool isLoadingAltitude;

  /// 获取海拔回调
  final Future<void> Function()? onGetAltitude;

  const WeatherDetailsRow({
    Key? key,
    required this.weather,
    this.altitudeInfo,
    this.isLoadingAltitude = false,
    this.onGetAltitude,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        WeatherDetailItem(
          icon: Icons.air,
          label: '风级',
          value: '${weather.windLevel}',
        ),
        WeatherDetailItem(
          icon: Icons.water_drop,
          label: '湿度',
          value: "${weather.humidity}",
        ),
        if (weather.precipitationProbability != null)
          WeatherDetailItem(
            icon: Icons.umbrella,
            label: '降水概率',
            value: '${weather.precipitationProbability}%',
          ),
        // 海拔按钮
        AltitudeButton(
          altitudeInfo: altitudeInfo,
          isLoadingAltitude: isLoadingAltitude,
          onGetAltitude: onGetAltitude,
        ),
      ],
    );
  }
}
