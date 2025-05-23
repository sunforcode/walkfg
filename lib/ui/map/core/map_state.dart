import 'package:flutter/foundation.dart';
import 'map_controller.dart';
import 'map_provider.dart';

/// 地图状态管理类
class MapState extends ChangeNotifier {
  /// 地图控制器
  final MapController _mapController;

  /// 当前地图类型
  MapType _currentMapType;

  /// 是否跟随用户位置
  bool _followUserLocation = false;

  /// 是否显示轨迹
  bool _showTrack = true;

  /// 是否使用高程渐变色
  bool _useElevationGradient = true;

  /// 构造函数
  MapState({
    required MapController mapController,
    MapType initialMapType = MapType.standard,
  })  : _mapController = mapController,
        _currentMapType = initialMapType;

  /// 获取当前地图类型
  MapType get currentMapType => _currentMapType;

  /// 是否跟随用户位置
  bool get followUserLocation => _followUserLocation;

  /// 是否显示轨迹
  bool get showTrack => _showTrack;

  /// 是否使用高程渐变色
  bool get useElevationGradient => _useElevationGradient;

  /// 设置地图类型
  Future<void> setMapType(MapType mapType) async {
    if (_currentMapType != mapType) {
      _currentMapType = mapType;
      await _mapController.setMapType(mapType);
      notifyListeners();
    }
  }

  /// 设置是否跟随用户位置
  Future<void> setFollowUserLocation(bool follow) async {
    if (_followUserLocation != follow) {
      _followUserLocation = follow;
      await _mapController.followUserLocation(follow);
      notifyListeners();
    }
  }

  /// 设置是否显示轨迹
  Future<void> setShowTrack(bool show) async {
    if (_showTrack != show) {
      _showTrack = show;

      if (show) {
        await _mapController.showTrack(
          useElevationGradient: _useElevationGradient,
        );
      } else {
        await _mapController.hideTrack();
      }

      notifyListeners();
    }
  }

  /// 设置是否使用高程渐变色
  Future<void> setUseElevationGradient(bool use) async {
    if (_useElevationGradient != use) {
      _useElevationGradient = use;

      if (_showTrack) {
        await _mapController.showTrack(
          useElevationGradient: use,
        );
      }

      notifyListeners();
    }
  }

  /// 放大
  Future<void> zoomIn() async {
    await _mapController.zoomIn();
  }

  /// 缩小
  Future<void> zoomOut() async {
    await _mapController.zoomOut();
  }

  /// 显示用户位置
  Future<void> showUserLocation() async {
    await _mapController.showMyLocation();
  }

  /// 显示整个轨迹
  Future<void> showEntireTrack() async {
    await _mapController.showEntireTrack();
  }
}
