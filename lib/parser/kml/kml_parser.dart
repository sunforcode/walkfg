import 'package:flutter/services.dart';
import 'package:xml/xml.dart';
import 'package:http/http.dart' as http;
import 'kml_models.dart';

/// KML 2.2标准解析器
///
/// 专注于KML标准数据的解析，不包含任何业务逻辑
class KmlParser {
  /// 从路径解析KML文档
  ///
  /// 支持多种路径类型：
  /// - 资源文件路径：'assets/maps/route.kml'
  /// - 网络URL：'http://example.com/route.kml' 或 'https://example.com/route.kml'
  static Future<KmlDocument> parseFromPath(String path) async {
    final String kmlContent = await _loadContentFromPath(path);
    return parseFromString(kmlContent);
  }

  /// 从字符串解析KML文档
  static KmlDocument parseFromString(String kmlContent) {
    final document = XmlDocument.parse(kmlContent);
    return _parseKmlDocument(document);
  }

  /// 根据路径类型加载内容
  static Future<String> _loadContentFromPath(String path) async {
    // 判断路径类型并加载内容
    if (_isNetworkUrl(path)) {
      // 网络URL
      return await _loadFromNetwork(path);
    } else {
      // 默认作为资源文件路径处理
      return await _loadFromAssets(path);
    }
  }

  /// 判断是否为网络URL
  static bool _isNetworkUrl(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  /// 从网络加载KML内容
  static Future<String> _loadFromNetwork(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('网络请求失败: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('网络加载KML文件失败: $e');
    }
  }

  /// 从资源文件加载KML内容
  static Future<String> _loadFromAssets(String assetPath) async {
    try {
      return await rootBundle.loadString(assetPath);
    } catch (e) {
      throw Exception('资源文件加载失败: $e');
    }
  }

  /// 解析KML文档
  static KmlDocument _parseKmlDocument(XmlDocument document) {
    final kmlElement = document.findAllElements('kml').first;
    final documentElement = kmlElement.findElements('Document').firstOrNull;

    if (documentElement == null) {
      // 如果没有Document元素，直接解析kml元素下的内容
      return KmlDocument(
        placemarks: _parsePlacemarks(kmlElement),
      );
    }

    return KmlDocument(
      id: documentElement.getAttribute('id'),
      name: _getElementText(documentElement, 'name'),
      description: _getElementText(documentElement, 'description'),
      snippet: _getElementText(documentElement, 'snippet'),
      author: _getElementText(documentElement, 'author'),
      extendedData: _parseExtendedData(documentElement),
      styles: _parseStyles(documentElement),
      styleMaps: _parseStyleMaps(documentElement),
      folders: _parseFolders(documentElement),
      placemarks: _parsePlacemarks(documentElement),
      networkLinks: _parseNetworkLinks(documentElement),
      groundOverlays: _parseGroundOverlays(documentElement),
    );
  }

  /// 获取元素文本内容
  static String? _getElementText(XmlElement parent, String elementName) {
    final element = parent.findElements(elementName).firstOrNull;
    return element?.innerText.trim().isEmpty == true
        ? null
        : element?.innerText.trim();
  }

  /// 解析扩展数据
  static Map<String, String> _parseExtendedData(XmlElement parent) {
    final extendedData = <String, String>{};
    final extendedDataElement = parent.findElements('ExtendedData').firstOrNull;

    if (extendedDataElement != null) {
      for (final dataElement in extendedDataElement.findElements('Data')) {
        final name = dataElement.getAttribute('name');
        final value = _getElementText(dataElement, 'value');
        if (name != null && value != null) {
          extendedData[name] = value;
        }
      }
    }

    return extendedData;
  }

  /// 解析样式
  static List<KmlStyle> _parseStyles(XmlElement parent) {
    final styles = <KmlStyle>[];

    for (final styleElement in parent.findElements('Style')) {
      final id = styleElement.getAttribute('id');
      if (id != null) {
        styles.add(KmlStyle(
          id: id,
          lineStyle: _parseLineStyle(styleElement),
          polyStyle: _parsePolyStyle(styleElement),
          iconStyle: _parseIconStyle(styleElement),
          labelStyle: _parseLabelStyle(styleElement),
          balloonStyle: _parseBalloonStyle(styleElement),
        ));
      }
    }

    return styles;
  }

  /// 解析线条样式
  static KmlLineStyle? _parseLineStyle(XmlElement parent) {
    final lineStyleElement = parent.findElements('LineStyle').firstOrNull;
    if (lineStyleElement == null) return null;

    return KmlLineStyle(
      color: _getElementText(lineStyleElement, 'color'),
      width: double.tryParse(_getElementText(lineStyleElement, 'width') ?? ''),
      colorMode:
          int.tryParse(_getElementText(lineStyleElement, 'colorMode') ?? ''),
    );
  }

  /// 解析多边形样式
  static KmlPolyStyle? _parsePolyStyle(XmlElement parent) {
    final polyStyleElement = parent.findElements('PolyStyle').firstOrNull;
    if (polyStyleElement == null) return null;

    return KmlPolyStyle(
      color: _getElementText(polyStyleElement, 'color'),
      colorMode:
          int.tryParse(_getElementText(polyStyleElement, 'colorMode') ?? ''),
      fill: _parseBool(_getElementText(polyStyleElement, 'fill')),
      outline: _parseBool(_getElementText(polyStyleElement, 'outline')),
    );
  }

  /// 解析图标样式
  static KmlIconStyle? _parseIconStyle(XmlElement parent) {
    final iconStyleElement = parent.findElements('IconStyle').firstOrNull;
    if (iconStyleElement == null) return null;

    return KmlIconStyle(
      color: _getElementText(iconStyleElement, 'color'),
      colorMode:
          int.tryParse(_getElementText(iconStyleElement, 'colorMode') ?? ''),
      scale: double.tryParse(_getElementText(iconStyleElement, 'scale') ?? ''),
      heading:
          double.tryParse(_getElementText(iconStyleElement, 'heading') ?? ''),
      icon: _parseIcon(iconStyleElement),
      hotSpot: _parseHotSpot(iconStyleElement),
    );
  }

  /// 解析图标
  static KmlIcon? _parseIcon(XmlElement parent) {
    final iconElement = parent.findElements('Icon').firstOrNull;
    if (iconElement == null) return null;

    return KmlIcon(
      href:
          _getElementText(iconElement, 'href') ?? iconElement.innerText.trim(),
      refreshMode:
          int.tryParse(_getElementText(iconElement, 'refreshMode') ?? ''),
      refreshInterval: double.tryParse(
          _getElementText(iconElement, 'refreshInterval') ?? ''),
    );
  }

  /// 解析热点
  static KmlHotSpot? _parseHotSpot(XmlElement parent) {
    final hotSpotElement = parent.findElements('hotSpot').firstOrNull;
    if (hotSpotElement == null) return null;

    final x = double.tryParse(hotSpotElement.getAttribute('x') ?? '');
    final y = double.tryParse(hotSpotElement.getAttribute('y') ?? '');
    final xunits = hotSpotElement.getAttribute('xunits');
    final yunits = hotSpotElement.getAttribute('yunits');

    if (x != null && y != null && xunits != null && yunits != null) {
      return KmlHotSpot(x: x, y: y, xunits: xunits, yunits: yunits);
    }

    return null;
  }

  /// 解析标签样式
  static KmlLabelStyle? _parseLabelStyle(XmlElement parent) {
    final labelStyleElement = parent.findElements('LabelStyle').firstOrNull;
    if (labelStyleElement == null) return null;

    return KmlLabelStyle(
      color: _getElementText(labelStyleElement, 'color'),
      colorMode:
          int.tryParse(_getElementText(labelStyleElement, 'colorMode') ?? ''),
      scale: double.tryParse(_getElementText(labelStyleElement, 'scale') ?? ''),
    );
  }

  /// 解析气球样式
  static KmlBalloonStyle? _parseBalloonStyle(XmlElement parent) {
    final balloonStyleElement = parent.findElements('BalloonStyle').firstOrNull;
    if (balloonStyleElement == null) return null;

    return KmlBalloonStyle(
      bgColor: _getElementText(balloonStyleElement, 'bgColor'),
      textColor: _getElementText(balloonStyleElement, 'textColor'),
      text: _getElementText(balloonStyleElement, 'text'),
      displayMode: _getElementText(balloonStyleElement, 'displayMode'),
    );
  }

  /// 解析样式映射
  static List<KmlStyleMap> _parseStyleMaps(XmlElement parent) {
    final styleMaps = <KmlStyleMap>[];

    for (final styleMapElement in parent.findElements('StyleMap')) {
      final id = styleMapElement.getAttribute('id');
      if (id != null) {
        final pairs = <KmlPair>[];
        for (final pairElement in styleMapElement.findElements('Pair')) {
          final key = _getElementText(pairElement, 'key');
          final styleUrl = _getElementText(pairElement, 'styleUrl');
          if (key != null && styleUrl != null) {
            pairs.add(KmlPair(key: key, styleUrl: styleUrl));
          }
        }
        styleMaps.add(KmlStyleMap(id: id, pairs: pairs));
      }
    }

    return styleMaps;
  }

  /// 解析文件夹
  static List<KmlFolder> _parseFolders(XmlElement parent) {
    final folders = <KmlFolder>[];

    for (final folderElement in parent.findElements('Folder')) {
      folders.add(KmlFolder(
        id: folderElement.getAttribute('id'),
        name: _getElementText(folderElement, 'name'),
        description: _getElementText(folderElement, 'description'),
        snippet: _getElementText(folderElement, 'snippet'),
        visibility: _parseBool(_getElementText(folderElement, 'visibility')),
        open: _parseBool(_getElementText(folderElement, 'open')),
        styleUrl: _getElementText(folderElement, 'styleUrl'),
        extendedData: _parseExtendedData(folderElement),
        folders: _parseFolders(folderElement), // 递归解析子文件夹
        placemarks: _parsePlacemarks(folderElement),
      ));
    }

    return folders;
  }

  /// 解析地标
  static List<KmlPlacemark> _parsePlacemarks(XmlElement parent) {
    final placemarks = <KmlPlacemark>[];

    for (final placemarkElement in parent.findElements('Placemark')) {
      placemarks.add(KmlPlacemark(
        id: placemarkElement.getAttribute('id'),
        name: _getElementText(placemarkElement, 'name'),
        description: _getElementText(placemarkElement, 'description'),
        snippet: _getElementText(placemarkElement, 'snippet'),
        visibility: _parseBool(_getElementText(placemarkElement, 'visibility')),
        open: _parseBool(_getElementText(placemarkElement, 'open')),
        styleUrl: _getElementText(placemarkElement, 'styleUrl'),
        geometry: _parseGeometry(placemarkElement),
        timeStamp: _parseTimeStamp(placemarkElement),
        timeSpan: _parseTimeSpan(placemarkElement),
        extendedData: _parseExtendedData(placemarkElement),
      ));
    }

    return placemarks;
  }

  /// 解析几何体
  static KmlGeometry? _parseGeometry(XmlElement parent) {
    // 解析Point
    final pointElement = parent.findElements('Point').firstOrNull;
    if (pointElement != null) {
      return _parsePoint(pointElement);
    }

    // 解析LineString
    final lineStringElement = parent.findElements('LineString').firstOrNull;
    if (lineStringElement != null) {
      return _parseLineString(lineStringElement);
    }

    // 解析Polygon
    final polygonElement = parent.findElements('Polygon').firstOrNull;
    if (polygonElement != null) {
      return _parsePolygon(polygonElement);
    }

    // 解析MultiGeometry
    final multiGeometryElement =
        parent.findElements('MultiGeometry').firstOrNull;
    if (multiGeometryElement != null) {
      return _parseMultiGeometry(multiGeometryElement);
    }

    // 解析gx:Track (Google扩展)
    final trackElement = parent.findElements('gx:Track').firstOrNull;
    if (trackElement != null) {
      return _parseTrack(trackElement);
    }

    return null;
  }

  /// 解析点
  static KmlPoint _parsePoint(XmlElement pointElement) {
    return KmlPoint(
      extrude: _parseBool(_getElementText(pointElement, 'extrude')),
      altitudeMode: _getElementText(pointElement, 'altitudeMode'),
      coordinates:
          _parseCoordinates(_getElementText(pointElement, 'coordinates') ?? '')
              .first,
    );
  }

  /// 解析线串
  static KmlLineString _parseLineString(XmlElement lineStringElement) {
    return KmlLineString(
      extrude: _parseBool(_getElementText(lineStringElement, 'extrude')),
      tessellate: _parseBool(_getElementText(lineStringElement, 'tessellate')),
      altitudeMode: _getElementText(lineStringElement, 'altitudeMode'),
      coordinates: _parseCoordinates(
          _getElementText(lineStringElement, 'coordinates') ?? ''),
    );
  }

  /// 解析多边形
  static KmlPolygon _parsePolygon(XmlElement polygonElement) {
    final outerBoundaryElement =
        polygonElement.findElements('outerBoundaryIs').firstOrNull;
    final innerBoundaryElements =
        polygonElement.findElements('innerBoundaryIs');

    return KmlPolygon(
      extrude: _parseBool(_getElementText(polygonElement, 'extrude')),
      tessellate: _parseBool(_getElementText(polygonElement, 'tessellate')),
      altitudeMode: _getElementText(polygonElement, 'altitudeMode'),
      outerBoundaryIs: outerBoundaryElement != null
          ? _parseLinearRing(outerBoundaryElement)
          : null,
      innerBoundaryIs: innerBoundaryElements.map(_parseLinearRing).toList(),
    );
  }

  /// 解析线性环
  static KmlLinearRing _parseLinearRing(XmlElement boundaryElement) {
    final linearRingElement = boundaryElement.findElements('LinearRing').first;

    return KmlLinearRing(
      extrude: _parseBool(_getElementText(linearRingElement, 'extrude')),
      tessellate: _parseBool(_getElementText(linearRingElement, 'tessellate')),
      altitudeMode: _getElementText(linearRingElement, 'altitudeMode'),
      coordinates: _parseCoordinates(
          _getElementText(linearRingElement, 'coordinates') ?? ''),
    );
  }

  /// 解析多重几何体
  static KmlMultiGeometry _parseMultiGeometry(XmlElement multiGeometryElement) {
    final geometries = <KmlGeometry>[];

    for (final child in multiGeometryElement.children.whereType<XmlElement>()) {
      final geometry = _parseGeometry(child);
      if (geometry != null) {
        geometries.add(geometry);
      }
    }

    return KmlMultiGeometry(geometries: geometries);
  }

  /// 解析轨迹（Google扩展）
  static KmlTrack _parseTrack(XmlElement trackElement) {
    final whenElements = trackElement.findElements('when');
    final coordElements = trackElement.findElements('gx:coord');

    final when = <DateTime>[];
    final coord = <KmlCoordinates>[];

    for (final whenElement in whenElements) {
      final dateTime = DateTime.tryParse(whenElement.innerText.trim());
      if (dateTime != null) {
        when.add(dateTime);
      }
    }

    for (final coordElement in coordElements) {
      final coordText = coordElement.innerText.trim();
      final parts = coordText.split(' ');
      if (parts.length >= 2) {
        final longitude = double.tryParse(parts[0]);
        final latitude = double.tryParse(parts[1]);
        final altitude =
            parts.length > 2 ? double.tryParse(parts[2]) ?? 0.0 : 0.0;

        if (longitude != null && latitude != null) {
          coord.add(KmlCoordinates(
            longitude: longitude,
            latitude: latitude,
            altitude: altitude,
          ));
        }
      }
    }

    return KmlTrack(
      extrude: _parseBool(_getElementText(trackElement, 'extrude')),
      tessellate: _parseBool(_getElementText(trackElement, 'tessellate')),
      altitudeMode: _getElementText(trackElement, 'altitudeMode'),
      when: when,
      coord: coord,
      extendedData: _parseExtendedData(trackElement),
    );
  }

  /// 解析坐标
  static List<KmlCoordinates> _parseCoordinates(String coordinatesText) {
    print(
        'KmlParser._parseCoordinates: 开始解析坐标，原始文本长度: ${coordinatesText.length}');
    print(
        'KmlParser._parseCoordinates: 原始坐标文本前100字符: ${coordinatesText.length > 100 ? coordinatesText.substring(0, 100) + '...' : coordinatesText}');

    final coordinates = <KmlCoordinates>[];
    final lines = coordinatesText.split(RegExp(r'[\s\n\r]+'));

    print('KmlParser._parseCoordinates: 分割后行数: ${lines.length}');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      final parts = trimmed.split(',');
      if (i < 3 || i >= lines.length - 3) {
        print(
            'KmlParser._parseCoordinates: 第${i + 1}行: "$trimmed", 分割后部分数: ${parts.length}');
      } else if (i == 3) {
        print('KmlParser._parseCoordinates: ... (省略中间行) ...');
      }

      if (parts.length >= 2) {
        final longitude = double.tryParse(parts[0]);
        final latitude = double.tryParse(parts[1]);
        final altitude =
            parts.length > 2 ? double.tryParse(parts[2]) ?? 0.0 : 0.0;

        if (longitude != null && latitude != null) {
          coordinates.add(KmlCoordinates(
            longitude: longitude,
            latitude: latitude,
            altitude: altitude,
          ));
          if (i < 3 || i >= lines.length - 3) {
            print(
                'KmlParser._parseCoordinates: 成功解析坐标: ($longitude, $latitude, $altitude)');
          }
        } else {
          print(
              'KmlParser._parseCoordinates: 解析失败，经纬度为null: longitude=$longitude, latitude=$latitude');
        }
      } else {
        print('KmlParser._parseCoordinates: 跳过无效行，部分数不足: ${parts.length}');
      }
    }

    print('KmlParser._parseCoordinates: 解析完成，总坐标数: ${coordinates.length}');
    return coordinates;
  }

  /// 解析时间戳
  static KmlTimeStamp? _parseTimeStamp(XmlElement parent) {
    final timeStampElement = parent.findElements('TimeStamp').firstOrNull;
    if (timeStampElement == null) return null;

    final whenText = _getElementText(timeStampElement, 'when');
    if (whenText == null) return null;

    final when = DateTime.tryParse(whenText);
    return when != null ? KmlTimeStamp(when: when) : null;
  }

  /// 解析时间跨度
  static KmlTimeSpan? _parseTimeSpan(XmlElement parent) {
    final timeSpanElement = parent.findElements('TimeSpan').firstOrNull;
    if (timeSpanElement == null) return null;

    final beginText = _getElementText(timeSpanElement, 'begin');
    final endText = _getElementText(timeSpanElement, 'end');

    final begin = beginText != null ? DateTime.tryParse(beginText) : null;
    final end = endText != null ? DateTime.tryParse(endText) : null;

    return KmlTimeSpan(begin: begin, end: end);
  }

  /// 解析网络链接
  static List<KmlNetworkLink> _parseNetworkLinks(XmlElement parent) {
    final networkLinks = <KmlNetworkLink>[];

    for (final networkLinkElement in parent.findElements('NetworkLink')) {
      networkLinks.add(KmlNetworkLink(
        id: networkLinkElement.getAttribute('id'),
        name: _getElementText(networkLinkElement, 'name'),
        description: _getElementText(networkLinkElement, 'description'),
        visibility:
            _parseBool(_getElementText(networkLinkElement, 'visibility')),
        open: _parseBool(_getElementText(networkLinkElement, 'open')),
        refreshVisibility: _parseBool(
            _getElementText(networkLinkElement, 'refreshVisibility')),
        flyToView: _parseBool(_getElementText(networkLinkElement, 'flyToView')),
        link: _parseLink(networkLinkElement),
      ));
    }

    return networkLinks;
  }

  /// 解析链接
  static KmlLink? _parseLink(XmlElement parent) {
    final linkElement = parent.findElements('Link').firstOrNull ??
        parent.findElements('Url').firstOrNull;
    if (linkElement == null) return null;

    final href = _getElementText(linkElement, 'href');
    if (href == null) return null;

    return KmlLink(
      href: href,
      refreshMode: _getElementText(linkElement, 'refreshMode'),
      refreshInterval: double.tryParse(
          _getElementText(linkElement, 'refreshInterval') ?? ''),
      viewRefreshMode: _getElementText(linkElement, 'viewRefreshMode'),
      viewRefreshTime: double.tryParse(
          _getElementText(linkElement, 'viewRefreshTime') ?? ''),
    );
  }

  /// 解析地面覆盖
  static List<KmlGroundOverlay> _parseGroundOverlays(XmlElement parent) {
    final groundOverlays = <KmlGroundOverlay>[];

    for (final groundOverlayElement in parent.findElements('GroundOverlay')) {
      groundOverlays.add(KmlGroundOverlay(
        id: groundOverlayElement.getAttribute('id'),
        name: _getElementText(groundOverlayElement, 'name'),
        description: _getElementText(groundOverlayElement, 'description'),
        visibility:
            _parseBool(_getElementText(groundOverlayElement, 'visibility')),
        icon: _parseIcon(groundOverlayElement),
        latLonBox: _parseLatLonBox(groundOverlayElement),
        altitude: double.tryParse(
            _getElementText(groundOverlayElement, 'altitude') ?? ''),
        altitudeMode: _getElementText(groundOverlayElement, 'altitudeMode'),
      ));
    }

    return groundOverlays;
  }

  /// 解析经纬度框
  static KmlLatLonBox? _parseLatLonBox(XmlElement parent) {
    final latLonBoxElement = parent.findElements('LatLonBox').firstOrNull;
    if (latLonBoxElement == null) return null;

    final north =
        double.tryParse(_getElementText(latLonBoxElement, 'north') ?? '');
    final south =
        double.tryParse(_getElementText(latLonBoxElement, 'south') ?? '');
    final east =
        double.tryParse(_getElementText(latLonBoxElement, 'east') ?? '');
    final west =
        double.tryParse(_getElementText(latLonBoxElement, 'west') ?? '');

    if (north != null && south != null && east != null && west != null) {
      return KmlLatLonBox(
        north: north,
        south: south,
        east: east,
        west: west,
        rotation: double.tryParse(
            _getElementText(latLonBoxElement, 'rotation') ?? ''),
      );
    }

    return null;
  }

  /// 解析布尔值
  static bool? _parseBool(String? value) {
    if (value == null) return null;
    return value.toLowerCase() == 'true' || value == '1';
  }
}

/*
使用示例：

// 1. 解析不同类型的路径
// 资源文件
final kmlDoc1 = await KmlParser.parseFromPath('assets/maps/route.kml');

// 网络URL
final kmlDoc4 = await KmlParser.parseFromPath('https://example.com/route.kml');
final kmlDoc5 = await KmlParser.parseFromPath('http://example.com/route.kml');

// 2. 访问解析结果
print('文档名称: ${kmlDoc1.name}');
print('样式数量: ${kmlDoc1.styles.length}');
print('地标数量: ${kmlDoc1.placemarks.length}');
print('文件夹数量: ${kmlDoc1.folders.length}');

// 3. 访问样式信息
for (final style in kmlDoc1.styles) {
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

// 4. 访问地标信息
for (final placemark in kmlDoc1.placemarks) {
  print('地标: ${placemark.name}');
  print('样式引用: ${placemark.styleUrl}');

  // 访问几何体
  if (placemark.geometry is KmlPoint) {
    final point = placemark.geometry as KmlPoint;
    print('  点坐标: ${point.coordinates.longitude}, ${point.coordinates.latitude}');
  } else if (placemark.geometry is KmlLineString) {
    final lineString = placemark.geometry as KmlLineString;
    print('  线串点数: ${lineString.coordinates.length}');
  }

  // 访问扩展数据
  for (final entry in placemark.extendedData.entries) {
    print('  ${entry.key}: ${entry.value}');
  }
}

// 5. 访问文件夹结构
for (final folder in kmlDoc1.folders) {
  print('文件夹: ${folder.name}');
  print('  地标数量: ${folder.placemarks.length}');
  print('  子文件夹数量: ${folder.folders.length}');
}

支持的路径类型：
- 资源文件路径: 'assets/maps/route.kml'
- 网络URL: 'http://example.com/route.kml', 'https://example.com/route.kml'

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
*/
