import 'dart:async';
import 'package:geolocator/geolocator.dart';

/// 海拔信息类
class AltitudeInfo {
  /// 海拔高度（米）
  final double altitude;

  /// 海拔精度/误差（米）
  final double accuracy;

  /// 获取时间戳
  final DateTime timestamp;

  /// 样本数量（用于计算平均值）
  final int sampleCount;

  const AltitudeInfo({
    required this.altitude,
    required this.accuracy,
    required this.timestamp,
    this.sampleCount = 1,
  });

  @override
  String toString() {
    return 'AltitudeInfo(altitude: ${altitude.toStringAsFixed(2)}m, accuracy: ±${accuracy.toStringAsFixed(2)}m, samples: $sampleCount)';
  }
}

/// 位置服务 - 负责获取和管理设备位置信息
class LocationService {
  /// 单例实例
  static LocationService? _instance;

  /// 获取单例实例
  static LocationService get instance {
    _instance ??= LocationService._internal();
    return _instance!;
  }

  /// 私有构造函数
  LocationService._internal();

  /// 位置权限状态缓存
  LocationPermission? _lastPermissionStatus;

  /// 最后获取的位置
  Position? _lastKnownPosition;

  /// 位置更新流控制器
  StreamController<Position>? _positionStreamController;

  /// 位置更新流
  Stream<Position>? _positionStream;

  /// 海拔信息缓存
  AltitudeInfo? _lastKnownAltitude;

  /// 海拔更新流控制器
  StreamController<AltitudeInfo>? _altitudeStreamController;

  /// 海拔更新流
  Stream<AltitudeInfo>? _altitudeStream;

  /// 检查位置服务是否可用
  ///
  /// 返回位置服务是否启用
  Future<bool> isLocationServiceEnabled() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print('位置服务状态: ${serviceEnabled ? "已启用" : "未启用"}');
      return serviceEnabled;
    } catch (e) {
      print('检查位置服务状态失败: $e');
      return false;
    }
  }

  /// 检查并请求位置权限
  ///
  /// 返回最终的权限状态
  Future<LocationPermission> checkAndRequestPermission() async {
    try {
      // 检查当前权限状态
      LocationPermission permission = await Geolocator.checkPermission();
      print('当前位置权限状态: $permission');

      // 如果权限被拒绝，尝试请求权限
      if (permission == LocationPermission.denied) {
        print('位置权限被拒绝，正在请求权限...');
        permission = await Geolocator.requestPermission();
        print('权限请求结果: $permission');
      }

      _lastPermissionStatus = permission;
      return permission;
    } catch (e) {
      print('检查或请求位置权限失败: $e');
      return LocationPermission.denied;
    }
  }

  /// 获取当前位置
  ///
  /// [accuracy] 定位精度，默认为高精度
  /// [timeoutSeconds] 超时时间（秒），默认15秒
  /// [forceRefresh] 是否强制刷新，不使用缓存
  /// 返回当前位置信息
  Future<Position?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int timeoutSeconds = 15,
    bool forceRefresh = false,
  }) async {
    try {
      // 如果不强制刷新且有缓存位置，检查缓存是否还新鲜（5分钟内）
      if (!forceRefresh && _lastKnownPosition != null) {
        final now = DateTime.now();
        final lastTime = DateTime.fromMillisecondsSinceEpoch(
          _lastKnownPosition!.timestamp.millisecondsSinceEpoch,
        );
        final difference = now.difference(lastTime).inMinutes;

        if (difference < 5) {
          print(
              '使用缓存位置: 纬度=${_lastKnownPosition!.latitude}, 经度=${_lastKnownPosition!.longitude}');
          return _lastKnownPosition;
        }
      }

      // 检查位置服务是否启用
      if (!await isLocationServiceEnabled()) {
        print('位置服务未启用，请在设置中开启位置服务');
        return await _tryGetLastKnownPosition();
      }

      // 检查并请求权限
      final permission = await checkAndRequestPermission();
      if (permission == LocationPermission.denied) {
        print('位置权限被用户拒绝');
        return await _tryGetLastKnownPosition();
      }

      if (permission == LocationPermission.deniedForever) {
        print('位置权限被永久拒绝，请在设置中手动开启');
        return await _tryGetLastKnownPosition();
      }

      // 获取当前位置
      print('开始获取当前位置...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
        timeLimit: Duration(seconds: timeoutSeconds),
      );

      print(
          '成功获取位置: 纬度=${position.latitude}, 经度=${position.longitude}, 精度=${position.accuracy}米');

      // 缓存位置
      _lastKnownPosition = position;

      return position;
    } catch (e) {
      print('获取当前位置失败: $e');
      return await _tryGetLastKnownPosition();
    }
  }

  /// 尝试获取最后已知位置
  Future<Position?> _tryGetLastKnownPosition() async {
    try {
      print('尝试获取最后已知位置...');
      final lastPosition = await Geolocator.getLastKnownPosition();
      if (lastPosition != null) {
        print(
            '获取到最后已知位置: 纬度=${lastPosition.latitude}, 经度=${lastPosition.longitude}');
        _lastKnownPosition = lastPosition;
        return lastPosition;
      } else {
        print('没有最后已知位置');
      }
    } catch (e) {
      print('获取最后已知位置失败: $e');
    }
    return null;
  }

  /// 获取位置更新流
  ///
  /// [accuracy] 定位精度
  /// [distanceFilter] 距离过滤器（米），只有移动超过此距离才会触发更新
  /// [intervalDuration] 更新间隔
  /// 返回位置更新流
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10,
    Duration? intervalDuration,
  }) {
    if (_positionStream != null) {
      return _positionStream!;
    }

    _positionStreamController = StreamController<Position>.broadcast();

    final locationSettings = LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
    );

    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).handleError((error) {
      print('位置流错误: $error');
      _positionStreamController?.addError(error);
    });

    return _positionStream!;
  }

  /// 获取当前海拔信息
  ///
  /// [accuracy] 定位精度，默认为最佳精度
  /// [timeoutSeconds] 超时时间（秒），默认15秒
  /// [forceRefresh] 是否强制刷新，不使用缓存
  /// 返回当前海拔信息
  Future<AltitudeInfo?> getCurrentAltitude({
    LocationAccuracy accuracy = LocationAccuracy.best,
    int timeoutSeconds = 15,
    bool forceRefresh = false,
  }) async {
    try {
      // 如果不强制刷新且有缓存海拔，检查缓存是否还新鲜（2分钟内）
      if (!forceRefresh && _lastKnownAltitude != null) {
        final now = DateTime.now();
        final difference =
            now.difference(_lastKnownAltitude!.timestamp).inMinutes;

        if (difference < 2) {
          print('使用缓存海拔: ${_lastKnownAltitude!}');
          return _lastKnownAltitude;
        }
      }

      // 检查位置服务是否启用
      if (!await isLocationServiceEnabled()) {
        print('位置服务未启用，无法获取海拔信息');
        return _lastKnownAltitude;
      }

      // 检查并请求权限
      final permission = await checkAndRequestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print('位置权限不足，无法获取海拔信息');
        return _lastKnownAltitude;
      }

      // 获取当前位置（包含海拔信息）
      print('开始获取当前海拔信息...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
        timeLimit: Duration(seconds: timeoutSeconds),
      );

      // 创建海拔信息对象
      final altitudeInfo = AltitudeInfo(
        altitude: position.altitude,
        accuracy: position.altitudeAccuracy,
        timestamp: DateTime.now(),
      );

      print('成功获取海拔信息: ${altitudeInfo}');

      // 缓存海拔信息
      _lastKnownAltitude = altitudeInfo;

      return altitudeInfo;
    } catch (e) {
      print('获取当前海拔失败: $e');
      return _lastKnownAltitude;
    }
  }

  /// 获取持续的海拔更新流（用于提高精度）
  ///
  /// [accuracy] 定位精度，默认为最佳精度
  /// [distanceFilter] 距离过滤器（米），默认5米
  /// [sampleCount] 样本数量，用于计算平均值提高精度，默认5个样本
  /// [intervalDuration] 更新间隔，默认5秒
  /// 返回海拔更新流
  Stream<AltitudeInfo> getAltitudeStream({
    LocationAccuracy accuracy = LocationAccuracy.best,
    int distanceFilter = 5,
    int sampleCount = 5,
    Duration intervalDuration = const Duration(seconds: 5),
  }) {
    if (_altitudeStream != null) {
      return _altitudeStream!;
    }

    _altitudeStreamController = StreamController<AltitudeInfo>.broadcast();

    // 用于存储海拔样本的列表
    List<double> altitudeSamples = [];
    List<double> accuracySamples = [];

    final locationSettings = LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
    );

    // 创建定时器，定期获取位置信息
    Timer.periodic(intervalDuration, (timer) async {
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: accuracy,
          timeLimit: Duration(seconds: 10),
        );

        // 添加样本到列表
        altitudeSamples.add(position.altitude);
        accuracySamples.add(position.altitudeAccuracy);

        // 保持样本数量在指定范围内
        if (altitudeSamples.length > sampleCount) {
          altitudeSamples.removeAt(0);
          accuracySamples.removeAt(0);
        }

        // 计算平均海拔和平均精度
        final avgAltitude =
            altitudeSamples.reduce((a, b) => a + b) / altitudeSamples.length;
        final avgAccuracy =
            accuracySamples.reduce((a, b) => a + b) / accuracySamples.length;

        // 创建海拔信息对象
        final altitudeInfo = AltitudeInfo(
          altitude: avgAltitude,
          accuracy: avgAccuracy,
          timestamp: DateTime.now(),
          sampleCount: altitudeSamples.length,
        );

        // 缓存最新的海拔信息
        _lastKnownAltitude = altitudeInfo;

        // 发送到流
        _altitudeStreamController?.add(altitudeInfo);

        print('海拔流更新: ${altitudeInfo}');
      } catch (e) {
        print('海拔流获取失败: $e');
        _altitudeStreamController?.addError(e);
      }
    });

    _altitudeStream = _altitudeStreamController!.stream;
    return _altitudeStream!;
  }

  /// 停止海拔更新流
  void stopAltitudeStream() {
    _altitudeStreamController?.close();
    _altitudeStreamController = null;
    _altitudeStream = null;
    print('海拔更新流已停止');
  }

  /// 计算两点之间的距离
  ///
  /// [startLatitude] 起点纬度
  /// [startLongitude] 起点经度
  /// [endLatitude] 终点纬度
  /// [endLongitude] 终点经度
  /// 返回距离（米）
  double calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// 计算两点之间的方位角
  ///
  /// [startLatitude] 起点纬度
  /// [startLongitude] 起点经度
  /// [endLatitude] 终点纬度
  /// [endLongitude] 终点经度
  /// 返回方位角（度）
  double calculateBearing({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// 获取权限状态描述
  String getPermissionStatusDescription(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.denied:
        return '位置权限被拒绝';
      case LocationPermission.deniedForever:
        return '位置权限被永久拒绝';
      case LocationPermission.whileInUse:
        return '仅在使用应用时允许位置权限';
      case LocationPermission.always:
        return '始终允许位置权限';
      default:
        return '未知权限状态';
    }
  }

  /// 打开位置设置页面
  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      print('打开位置设置失败: $e');
      return false;
    }
  }

  /// 打开应用设置页面
  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (e) {
      print('打开应用设置失败: $e');
      return false;
    }
  }

  /// 清除缓存的位置信息
  void clearCache() {
    _lastKnownPosition = null;
    _lastPermissionStatus = null;
    print('位置缓存已清除');
  }

  /// 释放资源
  void dispose() {
    _positionStreamController?.close();
    _positionStreamController = null;
    _positionStream = null;

    _altitudeStreamController?.close();
    _altitudeStreamController = null;
    _altitudeStream = null;

    clearCache();
  }
}
