import 'package:walk/model/map/map_data_model.dart';
import 'package:walk/model/map/marker_point_model.dart';
import 'package:walk/model/route/poi_point_model.dart';
import 'package:walk/model/route/route_model.dart';
import 'package:walk/model/route/segment_model.dart';

/// 地图数据处理工具类
///
/// 封装从 RouteModel 解析分段和标记点的统一优先级逻辑，
/// 供各业务页面调用，避免重复代码。
class MapDataHelper {
  MapDataHelper._();

  /// 解析路线分段数据（统一优先级）
  ///
  /// 优先级（仅使用远端数据，无硬编码 fallback）：
  /// 1. `route.segmentSchemes` 中 `isDefault: true` 的默认方案
  /// 2. `route.segments`
  /// 3. `mapData.segments`（KML 解析结果）
  /// 4. 空列表
  ///
  /// 返回按 [SegmentModel.sequenceNumber] 升序排序的分段列表。
  static List<SegmentModel> resolveSegments(
    RouteModel route,
    MapDataModel? mapData,
  ) {
    List<SegmentModel> raw;

    // 1. 优先从 segmentSchemes 取默认方案的分段
    final defaultScheme = route.defaultSegmentScheme;
    if (defaultScheme != null && defaultScheme.segments.isNotEmpty) {
      raw = defaultScheme.segments;
    } else if (route.segments?.isNotEmpty ?? false) {
      // 2. 尝试 route.segments
      raw = route.segments!;
    } else if (mapData?.segments.isNotEmpty ?? false) {
      // 3. 尝试 mapData.segments（KML 解析结果）
      raw = mapData!.segments;
    } else {
      // 4. 无可用数据，返回空列表
      return [];
    }

    // 按 sequenceNumber 升序排序
    return List<SegmentModel>.from(raw)
      ..sort((a, b) => a.sequenceNumber.compareTo(b.sequenceNumber));
  }

  /// 解析路线标记点数据（统一优先级）
  ///
  /// 优先级：
  /// 1. `route.poiPoints`（转换为 [MarkerPointModel]，过滤 start/end 类型）
  /// 2. `route.markerPoints`
  /// 3. 空列表
  static List<MarkerPointModel> resolveMarkers(RouteModel route) {
    // 1. 优先从 poiPoints 转换（过滤 start/end，这两类由 startEndMarkers 特性单独处理）
    if (route.poiPoints.isNotEmpty) {
      return route.poiPoints
          .where((p) => p.category != 'start' && p.category != 'end')
          .map((p) => _poiToMarker(p))
          .toList();
    }

    // 2. fallback 到 markerPoints
    if (route.markerPoints != null && route.markerPoints!.isNotEmpty) {
      return route.markerPoints!;
    }

    return [];
  }

  /// 将 [PoiPointModel] 转换为 [MarkerPointModel]
  static MarkerPointModel _poiToMarker(PoiPointModel poi) {
    final MarkerPointType markerType;
    switch (poi.category) {
      case 'water':
      case 'supply':
        markerType = MarkerPointType.poi;
        break;
      case 'camp':
        markerType = MarkerPointType.restPoint;
        break;
      case 'photo':
        markerType = MarkerPointType.viewpoint;
        break;
      case 'pass':
      case 'valley':
        markerType = MarkerPointType.landmark;
        break;
      case 'danger':
        markerType = MarkerPointType.dangerPoint;
        break;
      case 'start':
      case 'end':
        markerType = MarkerPointType.infoPoint;
        break;
      default:
        markerType = MarkerPointType.other;
    }

    return MarkerPointModel(
      id: poi.id,
      latitude: poi.latitude,
      longitude: poi.longitude,
      elevation: poi.elevation ?? 0.0,
      name: poi.name,
      description: poi.description,
      markerType: markerType,
    );
  }
}
