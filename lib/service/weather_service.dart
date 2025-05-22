import '../model/weather/weather_model.dart';

/// 天气服务接口
abstract class WeatherService {
  /// 获取指定位置的天气
  ///
  /// [latitude] 纬度
  /// [longitude] 经度
  Future<WeatherModel> getWeather(double latitude, double longitude);

  /// 获取指定城市的天气
  ///
  /// [city] 城市名称
  Future<WeatherModel> getWeatherByCity(String city);

  /// 获取海拔
  ///
  /// [latitude] 纬度
  /// [longitude] 经度
  Future<double> getAltitude(double latitude, double longitude);

  /// 获取天气预报
  ///
  /// [latitude] 纬度
  /// [longitude] 经度
  /// [days] 预报天数，默认7天
  Future<List<WeatherModel>> getForecast(double latitude, double longitude,
      {int days = 7});
}
