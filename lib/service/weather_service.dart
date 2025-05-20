import '../model/weather/weather_model.dart';

/// 天气服务接口
abstract class WeatherService {
  /// 获取指定位置的天气信息
  Future<WeatherModel> getWeather(double latitude, double longitude);

  /// 获取指定城市的天气信息
  Future<WeatherModel> getWeatherByCity(String city);

  /// 获取海拔信息
  Future<double> getAltitude(double latitude, double longitude);

  /// 获取未来天气预报
  Future<List<WeatherModel>> getForecast(double latitude, double longitude,
      {int days = 7});
}