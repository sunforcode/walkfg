、、# KML数据解析示例

## 概述

展示如何从KML格式数据解析创建 `TrackPointVO`、`MarkerPointModel` 等模型对象。

## KML数据结构示例

\`\`\`xml
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Document>
    <name>黄山徒步路线</name>
    <description>黄山东线经典徒步路线</description>
    
    <!-- 轨迹线 -->
    <Placemark>
      <name>主要轨迹</name>
      <description>从云谷寺到光明顶的主要轨迹</description>
      <LineString>
        <coordinates>
          118.1567,30.1234,630
          118.1578,30.1245,680
          118.1589,30.1256,720
          118.1600,30.1267,780
        </coordinates>
      </LineString>
    </Placemark>
    
    <!-- 标记点 -->
    <Placemark>
      <name>云谷寺</name>
      <description>黄山东部入口，海拔约630米</description>
      <Point>
        <coordinates>118.1567,30.1234,630</coordinates>
      </Point>
      <ExtendedData>
        <Data name="type">
          <value>landmark</value>
        </Data>
        <Data name="facilities">
          <value>停车场,售票处,厕所</value>
        </Data>
      </ExtendedData>
    </Placemark>
    
    <Placemark>
      <name>观景台</name>
      <description>可以俯瞰整个山谷的绝佳观景点</description>
      <Point>
        <coordinates>118.1600,30.1267,1200</coordinates>
      </Point>
      <ExtendedData>
        <Data name="type">
          <value>viewpoint</value>
        </Data>
        <Data name="best_time">
          <value>日出和日落</value>
        </Data>
      </ExtendedData>
    </Placemark>
  </Document>
</kml>
\`\`\`

## 解析代码示例

\`\`\`dart
import 'package:xml/xml.dart';
import 'package:walk/model/map/track_point_model.dart';
import 'package:walk/model/map/marker_point_model.dart';

class KmlParser {
  /// 解析KML数据
  static KmlParseResult parseKml(String kmlContent) {
    final document = XmlDocument.parse(kmlContent);
    final kmlElement = document.findElements('kml').first;
    final documentElement = kmlElement.findElements('Document').first;
    
    final trackPoints = <TrackPointVO>[];
    final markerPoints = <MarkerPointModel>[];
    
    // 解析所有Placemark元素
    for (final placemark in documentElement.findElements('Placemark')) {
      final name = placemark.findElements('name').first.text;
      final description = placemark.findElements('description').firstOrNull?.text;
      
      // 检查是否为轨迹线
      final lineString = placemark.findElements('LineString').firstOrNull;
      if (lineString != null) {
        trackPoints.addAll(_parseLineString(lineString));
        continue;
      }
      
      // 检查是否为标记点
      final point = placemark.findElements('Point').firstOrNull;
      if (point != null) {
        final markerPoint = _parseMarkerPoint(placemark, name, description);
        if (markerPoint != null) {
          markerPoints.add(markerPoint);
        }
      }
    }
    
    return KmlParseResult(
      trackPoints: trackPoints,
      markerPoints: markerPoints,
    );
  }
  
  /// 解析轨迹线
  static List<TrackPointVO> _parseLineString(XmlElement lineString) {
    final coordinates = lineString.findElements('coordinates').first.text.trim();
    final points = <TrackPointVO>[];
    
    final lines = coordinates.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      
      final parts = trimmed.split(',');
      if (parts.length >= 2) {
        final longitude = double.tryParse(parts[0]);
        final latitude = double.tryParse(parts[1]);
        final elevation = parts.length > 2 ? double.tryParse(parts[2]) ?? 0.0 : 0.0;
        
        if (longitude != null && latitude != null) {
          points.add(TrackPointVO(
            latitude: latitude,
            longitude: longitude,
            elevation: elevation,
            timestamp: DateTime.now(),
          ));
        }
      }
    }
    
    // 计算距离起点的累计距离
    double totalDistance = 0.0;
    for (int i = 0; i < points.length; i++) {
      if (i > 0) {
        totalDistance += _calculateDistance(
          points[i - 1].latitude,
          points[i - 1].longitude,
          points[i].latitude,
          points[i].longitude,
        );
      }
      
      // 更新距离信息
      points[i] = points[i].copyWith(distanceFromStart: totalDistance);
    }
    
    return points;
  }
  
  /// 解析标记点
  static MarkerPointModel? _parseMarkerPoint(
    XmlElement placemark,
    String name,
    String? description,
  ) {
    final point = placemark.findElements('Point').first;
    final coordinates = point.findElements('coordinates').first.text.trim();
    
    final parts = coordinates.split(',');
    if (parts.length < 2) return null;
    
    final longitude = double.tryParse(parts[0]);
    final latitude = double.tryParse(parts[1]);
    final elevation = parts.length > 2 ? double.tryParse(parts[2]) ?? 0.0 : 0.0;
    
    if (longitude == null || latitude == null) return null;
    
    // 解析扩展数据中的类型信息
    final extendedData = placemark.findElements('ExtendedData').firstOrNull;
    MarkerPointType markerType = MarkerPointType.poi;
    String? color;
    
    if (extendedData != null) {
      for (final data in extendedData.findElements('Data')) {
        final key = data.getAttribute('name');
        final value = data.findElements('value').firstOrNull?.text;
        
        if (key != null && value != null) {
          // 解析标记点类型
          if (key == 'type') {
            markerType = _parseMarkerType(value);
          }
          // 解析颜色
          else if (key == 'color') {
            color = value;
        }
      }
    }
    }
    
    return MarkerPointModel.fromKml(
      id: 'kml_${DateTime.now().millisecondsSinceEpoch}',
      latitude: latitude,
      longitude: longitude,
      elevation: elevation,
      name: name,
      description: description,
      markerType: markerType,
      color: color,
    );
  }
  
  /// 解析标记点类型
  static MarkerPointType _parseMarkerType(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'landmark':
        return MarkerPointType.landmark;
      case 'viewpoint':
        return MarkerPointType.viewpoint;
      case 'rest':
      case 'restpoint':
        return MarkerPointType.restPoint;
      case 'danger':
      case 'dangerpoint':
        return MarkerPointType.dangerPoint;
      case 'info':
      case 'infopoint':
        return MarkerPointType.infoPoint;
      case 'poi':
        return MarkerPointType.poi;
      default:
        return MarkerPointType.other;
    }
  }
  
  /// 计算两点间距离（简化版）
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // 地球半径（米）
    final double dLat = (lat2 - lat1) * (3.14159 / 180);
    final double dLon = (lon2 - lon1) * (3.14159 / 180);
    
    final double a = (dLat / 2).sin() * (dLat / 2).sin() +
        lat1 * (3.14159 / 180).cos() * lat2 * (3.14159 / 180).cos() *
        (dLon / 2).sin() * (dLon / 2).sin();
    final double c = 2 * a.sqrt().asin();
    
    return earthRadius * c;
  }
}

/// KML解析结果
class KmlParseResult {
  final List<TrackPointVO> trackPoints;
  final List<MarkerPointModel> markerPoints;
  
  KmlParseResult({
    required this.trackPoints,
    required this.markerPoints,
  });
}
\`\`\`

## 使用示例

\`\`\`dart
// 解析KML文件
final kmlContent = await File('route.kml').readAsString();
final result = KmlParser.parseKml(kmlContent);

print('解析到 ${result.trackPoints.length} 个轨迹点');
print('解析到 ${result.markerPoints.length} 个标记点');

// 使用解析结果
final mapWidget = EnhancedDailyMapWidget(
  trackPoints: result.trackPoints,
  markers: result.markerPoints,
  days: 3,
  height: 400.0,
);

// 查看标记点信息
for (final marker in result.markerPoints) {
  print('标记点: ${marker.displayTitle}');
  print('类型: ${marker.markerTypeText}');
  print('位置: ${marker.latitude}, ${marker.longitude}');
  print('优先级: ${marker.priority}');
  
  if (marker.color != null) {
    print('颜色: ${marker.color}');
  }
}
\`\`\`

## 扩展功能

### 1. 支持更多KML元素
- Style和StyleMap（样式定义）
- Folder（文件夹组织）
- NetworkLink（网络链接）
- GroundOverlay（地面覆盖）

### 2. 错误处理
\`\`\`dart
try {
  final result = KmlParser.parseKml(kmlContent);
  // 处理结果
} catch (e) {
  print('KML解析失败: $e');
  // 错误处理
}
\`\`\`

### 3. 异步解析
\`\`\`dart
static Future<KmlParseResult> parseKmlAsync(String kmlContent) async {
  return await compute(_parseKmlInIsolate, kmlContent);
}

static KmlParseResult _parseKmlInIsolate(String kmlContent) {
  return parseKml(kmlContent);
}
\`\`\`

这种设计使得KML数据能够完美地映射到我们的模型架构中，既保持了数据的完整性，又提供了良好的扩展性。