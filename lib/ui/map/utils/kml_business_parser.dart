import 'package:flutter/foundation.dart';
import 'package:walk/model/map/map_data_model.dart';
import 'package:walk/ui/map/parser/kml/kml_models.dart';
import 'package:walk/ui/map/parser/kml/kml_parser.dart';
import 'package:walk/ui/map/parser/kml/kml_to_map_converter.dart';

/// 高级KML解析器 - 业务层接口
///
/// 提供简化的API，将KML解析和业务模型转换封装在一起
class KmlBusinessParser {
  /// 从路径解析为MapDataModel
  ///
  /// 支持的路径类型：
  /// - 资源文件路径: 'assets/maps/route.kml'
  /// - 网络URL: 'http://example.com/route.kml', 'https://example.com/route.kml'
  static Future<MapDataModel> parseFromPath(String path) async {
    try {
      // 使用底层解析器解析KML文档
      final kmlDocument = await KmlParser.parseFromPath(path);

      // 转换为业务模型
      final mapData = KmlToMapConverter.convertToMapData(
        kmlDocument,
        sourceUrl: path,
      );

      return mapData;
    } catch (e, stackTrace) {
      debugPrint('KmlBusinessParser.parseFromPath: 解析失败: $e');
      debugPrint('KmlBusinessParser.parseFromPath: 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  /// 从字符串解析为MapDataModel
  static MapDataModel parseFromString(String kmlContent, {String? sourceUrl}) {
    try {
      // 使用底层解析器解析KML文档
      final kmlDocument = KmlParser.parseFromString(kmlContent);

      // 转换为业务模型
      final mapData = KmlToMapConverter.convertToMapData(
        kmlDocument,
        sourceUrl: sourceUrl,
        rawContent: kmlContent,
      );

      return mapData;
    } catch (e, stackTrace) {
      debugPrint('KmlBusinessParser.parseFromString: 解析失败: $e');
      debugPrint('KmlBusinessParser.parseFromString: 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  /// 解析KML文档结构（不转换为业务模型）
  static Future<KmlDocument> parseKmlDocumentFromPath(String path) async {
    return await KmlParser.parseFromPath(path);
  }

  /// 从资源文件解析KML文档（向后兼容）
  @Deprecated('使用 parseKmlDocumentFromPath 替代')
  static Future<KmlDocument> parseKmlDocumentFromAsset(String assetPath) async {
    return parseKmlDocumentFromPath(assetPath);
  }
}

/*
使用示例：

// 1. 解析不同类型的路径为地图数据模型
// 资源文件
final mapData1 = await KmlParser.parseFromPath('assets/maps/route.kml');

// 网络URL
final mapData4 = await KmlParser.parseFromPath('https://example.com/route.kml');
final mapData5 = await KmlParser.parseFromPath('http://example.com/route.kml');
print('轨迹点数量: ${mapData1.trackPoints.length}');
print('路标点数量: ${mapData1.waypoints.length}');

// 2. 解析完整的KML文档结构（访问所有KML标准元素）
final kmlDocument = await KmlParser.parseKmlDocumentFromPath('assets/maps/route.kml');
print('文档名称: ${kmlDocument.name}');
print('样式数量: ${kmlDocument.styles.length}');
print('文件夹数量: ${kmlDocument.folders.length}');

// 3. 从字符串解析
final mapData6 = KmlParser.parseFromString(kmlContent, sourceUrl: 'manual_input');

// 4. 访问样式信息
for (final style in kmlDocument.styles) {
  print('样式ID: ${style.id}');
  if (style.lineStyle != null) {
    print('  线条颜色: ${style.lineStyle!.color}');
    print('  线条宽度: ${style.lineStyle!.width}');
  }
  if (style.iconStyle != null) {
    print('  图标缩放: ${style.iconStyle!.scale}');
    print('  图标URL: ${style.iconStyle!.icon?.href}');
  }
}

// 5. 访问扩展数据
for (final placemark in kmlDocument.placemarks) {
  print('地标: ${placemark.name}');
  print('样式引用: ${placemark.styleUrl}');
  for (final entry in placemark.extendedData.entries) {
    print('  ${entry.key}: ${entry.value}');
  }
}

// 6. 访问文件夹结构
for (final folder in kmlDocument.folders) {
  print('文件夹: ${folder.name}');
  print('  地标数量: ${folder.placemarks.length}');
  print('  子文件夹数量: ${folder.folders.length}');
}

支持的KML 2.2标准元素：
- Document: 文档信息和元数据
- Style/StyleMap: 样式定义和映射
- Folder: 文件夹组织结构
- Placemark: 地标和几何体
- Point/LineString/Polygon: 基础几何体
- MultiGeometry: 多重几何体
- gx:Track: Google扩展轨迹
- TimeStamp/TimeSpan: 时间信息
- ExtendedData: 扩展数据
- NetworkLink: 网络链接
- GroundOverlay: 地面覆盖
- Icon/HotSpot: 图标和热点
- LineStyle/PolyStyle/IconStyle/LabelStyle/BalloonStyle: 各种样式

支持的路径类型：
- 资源文件路径: 'assets/maps/route.kml'
- 网络URL: 'http://example.com/route.kml', 'https://example.com/route.kml'
*/
