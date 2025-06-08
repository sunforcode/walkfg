## 5. MarkerPointModel - 标记点模型（KML标记点专用）

**继承**: `extends TrackPointVO`

**字段**:
\`\`\`dart
class MarkerPointModel extends TrackPointVO {
  // 基础元数据
  final String id;                     // 唯一标识
  final String? name;                  // 标记点名称
  final String? description;           // 标记点描述
  final DateTime? createdAt;           // 创建时间
  final DateTime? updatedAt;           // 更新时间
  
  // 标记点特有属性
  final MarkerPointType markerType;    // 标记点类型
  final String? iconUrl;               // 图标URL或图标名称
  final String? color;                 // 颜色（十六进制字符串）
  final bool isVisible;                // 是否可见
  final int priority;                  // 优先级（显示层级）
  final Map<String, dynamic>? extraProperties; // 额外属性（KML扩展数据）
}
\`\`\`

**枚举**:
- `MarkerPointType`: poi, landmark, viewpoint, restPoint, dangerPoint, infoPoint, other

**便捷方法**:
- `markerTypeText` / `markerTypeIcon`: 类型显示
- `defaultColor`: 获取默认颜色
- `isImportant`: 是否为重要标记点
- `displayTitle` / `displayDescription`: 显示标题和描述
- `getExtraProperty<T>()`: 从扩展属性获取值

**工厂方法**:
- `MarkerPointModel.fromKml()`: 专门用于从KML数据创建标记点
