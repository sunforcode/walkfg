import 'package:walk/model/weather/weather_condition.dart';
import 'package:walk/model/weather/weather_model.dart';

/// 天气数据解析服务 - 负责解析和风天气API返回的数据
class WeatherParserService {
  /// 解析和风天气API响应（合并地点信息）
  ///
  /// [weatherData] 天气数据
  /// [locationData] 地点数据
  /// [latitude] 纬度
  /// [longitude] 经度
  /// 返回天气模型
  WeatherModel? parseHeWeatherResponseWithLocation(
    Map<String, dynamic> weatherData,
    Map<String, dynamic>? locationData,
    double latitude,
    double longitude,
  ) {
    try {
      // 检查API响应状态码
      final code = weatherData['code'];
      if (code != '200') {
        print('和风天气API错误: ${weatherData['code']} - ${weatherData['fxLink']}');
        return null;
      }

      // 获取实时天气数据
      final now = weatherData['now'];
      if (now == null) {
        print('和风天气API返回数据格式错误: 缺少now字段');
        return null;
      }

      // 获取位置信息 - 优先使用地点查询API的结果
      String cityName = '未知位置';
      if (locationData != null) {
        final name = locationData['name'] ?? '';
        final adm2 = locationData['adm2'] ?? '';
        final adm1 = locationData['adm1'] ?? '';

        // 构造更完整的地点名称
        if (name.isNotEmpty) {
          if (adm2.isNotEmpty && adm2 != name) {
            cityName = '$adm2$name';
          } else if (adm1.isNotEmpty && adm1 != name) {
            cityName = '$adm1$name';
          } else {
            cityName = name;
          }
        } else {
          cityName = adm2.isNotEmpty ? adm2 : (adm1.isNotEmpty ? adm1 : '未知位置');
        }

        print(
            '使用地点查询API获取的城市名称: $cityName (原始: name=$name, adm2=$adm2, adm1=$adm1)');
      } else {
        print('地点查询API未返回数据，使用默认城市名称');
      }

      // 解析天气状况
      String weatherText = now['text'] ?? '';
      String temp = now['temp'] ?? '0';
      String windSpeed = now['windSpeed'] ?? '0';
      String humidity = now['humidity'] ?? '0';
      String feelsLike = now['feelsLike'] ?? temp;
      String pressure = now['pressure'] ?? '0';
      String visibility = now['vis'] ?? '0';
      String windDir = now['windDir'] ?? '';
      String windScale = now['windScale'] ?? '0';

      print(
          '天气解析结果: 城市=$cityName, 天气=$weatherText, 温度=${temp}°C, 体感温度=${feelsLike}°C');

      // 判断是否适合徒步
      final isSuitable = isWeatherSuitableForHiking(weatherText, windSpeed);

      // 根据天气文本判断天气状况
      final condition = getWeatherConditionFromText(weatherText);

      return WeatherModel(
        city: cityName,
        condition: condition,
        suitability: isSuitable,
        temperature: double.tryParse(temp) ?? 0.0,
        windLevel: double.tryParse(windSpeed) ?? 0.0,
        humidity: double.tryParse(humidity) ?? 0.0,
        // 可以添加更多字段
        // feelsLikeTemperature: double.tryParse(feelsLike) ?? 0.0,
        // pressure: double.tryParse(pressure) ?? 0.0,
        // visibility: double.tryParse(visibility) ?? 0.0,
        // windDirection: windDir,
        // windScale: windScale,
      );
    } catch (e) {
      print('解析和风天气API响应失败: $e');
      return null;
    }
  }

  /// 解析和风天气API响应
  ///
  /// [data] API响应数据
  /// [latitude] 纬度
  /// [longitude] 经度
  /// 返回天气模型
  WeatherModel? parseHeWeatherResponse(
      Map<String, dynamic> data, double latitude, double longitude) {
    try {
      // 检查API响应状态码
      final code = data['code'];
      if (code != '200') {
        print('和风天气API错误: ${data['code']} - ${data['fxLink']}');
        return null;
      }

      // 获取实时天气数据
      final now = data['now'];
      if (now == null) {
        print('和风天气API返回数据格式错误: 缺少now字段${data}');
        return null;
      }

      // 获取位置信息
      final location = data['location']?[0] ?? {'name': '未知位置'};
      final cityName = location['name'] ?? '未知位置';

      // 解析天气状况
      String weatherText = now['text'] ?? '';
      String temp = now['temp'] ?? '0';
      String windSpeed = now['windSpeed'] ?? '0';
      String humidity = now['humidity'] ?? '0';

      // 判断是否适合徒步
      final isSuitable = isWeatherSuitableForHiking(weatherText, windSpeed);

      return WeatherModel(
        city: cityName,
        condition: getWeatherConditionFromText(weatherText),
        suitability: isSuitable,
        temperature: double.tryParse(temp) ?? 0.0,
        windLevel: double.tryParse(windSpeed) ?? 0.0,
        humidity: double.tryParse(humidity) ?? 0.0,
      );
    } catch (e) {
      print('解析和风天气API响应失败: $e');
      return null;
    }
  }

  /// 解析和风天气API预报响应
  ///
  /// [data] API响应数据
  /// [latitude] 纬度
  /// [longitude] 经度
  /// [locationName] 地点名称
  /// 返回天气预报列表
  List<WeatherModel> parseHeWeatherForecastResponse(
    Map<String, dynamic> data,
    double latitude,
    double longitude,
    String locationName,
  ) {
    final List<WeatherModel> forecasts = [];

    try {
      // 检查API响应状态码
      final code = data['code'];
      if (code != '200') {
        print('和风天气API错误: ${data['code']} - ${data['fxLink']}');
        return [];
      }

      // 获取天气预报数据
      final daily = data['daily'];
      if (daily == null || daily is! List) {
        print('和风天气API返回数据格式错误: 缺少daily字段或格式不正确');
        return [];
      }

      // 使用传入的位置名称，因为预报API也不包含location信息
      final cityName = locationName;

      // 解析每日预报
      for (final day in daily) {
        try {
          final date =
              DateTime.parse(day['fxDate'] ?? DateTime.now().toString());
          final weatherText = day['textDay'] ?? '';
          final tempMax = double.tryParse(day['tempMax'] ?? '0') ?? 0.0;
          final tempMin = double.tryParse(day['tempMin'] ?? '0') ?? 0.0;
          final avgTemp = (tempMax + tempMin) / 2;
          final windSpeed = day['windSpeedDay'] ?? '0';
          final humidity = day['humidity'] ?? '0';
          final precip = double.tryParse(day['precip'] ?? '0') ?? 0.0;

          // 计算降水概率（简单转换：降水量 > 0 时，按比例计算概率）
          final precipProb =
              precip > 0 ? (precip * 10).clamp(0, 100).toInt() : 0;

          // 判断是否适合徒步
          final isSuitable = isWeatherSuitableForHiking(weatherText, windSpeed);

          forecasts.add(WeatherModel(
            city: cityName,
            condition: getWeatherConditionFromText(weatherText),
            suitability: isSuitable,
            temperature: avgTemp,
            windLevel: double.tryParse(windSpeed) ?? 0.0,
            humidity: double.tryParse(humidity) ?? 0.0,
            forecastDate: date,
            maxTemperature: tempMax,
            minTemperature: tempMin,
            precipitationProbability: precipProb,
          ));
        } catch (e) {
          print('解析单日预报数据失败: $e');
        }
      }
    } catch (e) {
      print('解析和风天气API预报响应失败: $e');
    }

    return forecasts;
  }

  /// 根据天气文本获取天气状况枚举
  ///
  /// [weatherText] 天气文本描述
  /// 返回天气状况枚举
  WeatherCondition getWeatherConditionFromText(String weatherText) {
    if (weatherText.contains('晴')) {
      return WeatherCondition.sunny;
    } else if (weatherText.contains('云') || weatherText.contains('阴')) {
      return WeatherCondition.cloudy;
    } else if (weatherText.contains('雨')) {
      return WeatherCondition.rainy;
    } else if (weatherText.contains('雪')) {
      return WeatherCondition.snowy;
    } else if (weatherText.contains('雾') || weatherText.contains('霾')) {
      return WeatherCondition.foggy;
    } else if (weatherText.contains('雷')) {
      return WeatherCondition.stormy;
    } else {
      return WeatherCondition.cloudy; // 默认值
    }
  }

  /// 判断天气是否适合徒步
  ///
  /// [weatherText] 天气文本描述
  /// [windSpeed] 风速
  /// 返回是否适合徒步
  bool isWeatherSuitableForHiking(String weatherText, String windSpeed) {
    // 不适合徒步的天气状况关键词
    final badWeatherKeywords = [
      '雷',
      '暴',
      '大雨',
      '中雨',
      '冰雹',
      '雪',
      '霾',
      '沙尘',
      '雾',
      '台风',
      '飓风'
    ];

    // 检查天气状况是否包含不适合徒步的关键词
    final containsBadWeather =
        badWeatherKeywords.any((keyword) => weatherText.contains(keyword));

    // 检查风速是否过大（大于5级风不适合徒步）
    final windSpeedValue = int.tryParse(windSpeed) ?? 0;
    final windTooStrong = windSpeedValue > 5;

    // 如果不包含不良天气关键词且风速适中，则适合徒步
    return !containsBadWeather && !windTooStrong;
  }
}
