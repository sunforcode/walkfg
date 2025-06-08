# 地图组件架构说明

## 🎯 设计原则

**单一职责 + 统一核心**：所有地图功能都基于统一的 `UnifiedMapCore`，避免重复的 FlutterMap 实例。

## 📁 目录结构

\`\`\`
lib/ui/map/
├── 📁 core/                    # 核心组件
│   ├── unified_map_core.dart   # 统一地图核心（唯一的 FlutterMap 封装）
│   └── map_enum.dart          # 地图相关枚举
├── 📁 layers/                 # 图层组件
│   ├── track_layer.dart       # 轨迹图层
│   └── marker_layer.dart      # 标记图层
├── 📁 widgets/                # 对外组件
│   ├── simple_map_widget.dart # 简单地图组件
│   └── elevation_chart_widget.dart # 海拔图表组件
├── 📁 components/             # 复合组件
│   └── enhanced_daily_map_widget.dart # 增强日程地图
├── 📁 controllers/            # 控制器
│   ├── navigation_controller.dart # 导航控制器
│   └── ...
├── 📁 utils/                  # 工具类
│   └── kml_parser.dart        # KML解析器
├── 📁 screens/                # 页面组件
│   └── ...
└── 📁 examples/               # 示例代码
    └── ...
\`\`\`

## 🏗️ 架构层次

\`\`\`
┌─────────────────────────────────────────────────────────────┐
│                    对外接口层 (Public API)                    │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │  SimpleMapWidget  │  EnhancedDailyMapWidget  │  其他...  │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                      图层层 (Layers)                        │
│  ┌─────────────────┐              ┌─────────────────────────┐ │
│  │   TrackLayer    │              │  CustomMarkerLayer      │ │
│  └─────────────────┘              └─────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                 统一地图核心 (Unified Core)                   │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              UnifiedMapCore                             │ │
│  │          (唯一的 FlutterMap 封装)                        │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
\`\`\`

## 🎨 组件使用指南

### 1. 简单场景 - SimpleMapWidget

适用于大部分基础地图显示需求：

\`\`\`dart
// 基础轨迹显示
SimpleMapWidget(
  trackPoints: trackPoints,
  config: SimpleMapPresets.basicTrack,
)

// 详细轨迹显示
SimpleMapWidget(
  trackPoints: trackPoints,
  config: SimpleMapPresets.detailedTrack,
  events: SimpleMapEvents(
    onMarkerTap: (point) => print('点击: ${point.name}'),
  ),
)

// 自定义配置
SimpleMapWidget(
  trackPoints: trackPoints,
  config: SimpleMapConfig(
    height: 400,
    trackColor: Colors.red,
    trackRenderMode: TrackRenderMode.elevation,
  ),
)
\`\`\`

### 2. 多日行程 - EnhancedDailyMapWidget

专门用于显示多日行程的地图：

\`\`\`dart
EnhancedDailyMapWidget(
  trackPoints: trackPoints,
  markers: waypoints,
  days: 3,
  height: 400,
  onDayChanged: (day) => print('切换到第${day}天'),
)
\`\`\`

### 3. 高度自定义 - UnifiedMapCore

需要完全控制地图行为时使用：

\`\`\`dart
UnifiedMapCore(
  config: UnifiedMapConfig(
    mapType: MapType.satellite,
    mapProvider: MapProviderType.amap,
  ),
  events: UnifiedMapEvents(
    onTap: (position) => print('点击: $position'),
  ),
  layers: [
    TrackLayer(trackPoints: points),
    CustomMarkerLayer(markers: markers),
    // 自定义图层...
  ],
  onControllerCreated: (controller) {
    // 获取控制器进行高级操作
    _mapController = controller;
  },
)
\`\`\`

## 🔧 核心特性

### UnifiedMapCore
- **唯一的 FlutterMap 封装**：项目中所有地图都基于此核心
- **统一的配置管理**：通过 `UnifiedMapConfig` 统一配置
- **图层系统**：支持任意图层组合
- **控制器管理**：统一的 MapController 创建和管理

### 图层系统
- **TrackLayer**：专门处理轨迹线渲染，支持多种着色模式
- **CustomMarkerLayer**：处理各种标记点，支持自定义样式
- **可扩展**：可以轻松添加新的图层类型

### 预设配置
- **SimpleMapPresets.basicTrack**：基础轨迹显示
- **SimpleMapPresets.detailedTrack**：详细轨迹显示
- **SimpleMapPresets.preview**：预览模式
- **SimpleMapPresets.navigation**：导航模式

## 📊 数据流向

\`\`\`
KML文件/API数据 → KmlParser → TrackPointVO → UI组件 → 图层 → UnifiedMapCore → FlutterMap
\`\`\`

## 🚀 性能优化

1. **单一 FlutterMap 实例**：避免多个地图实例的内存开销
2. **图层缓存**：图层组件支持缓存，减少重建
3. **按需渲染**：只渲染当前需要的图层
4. **统一控制器**：避免重复的控制器创建

## 💡 最佳实践

### 1. 组件选择
- 简单显示 → `SimpleMapWidget`
- 多日行程 → `EnhancedDailyMapWidget`
- 高度自定义 → `UnifiedMapCore`

### 2. 性能优化
\`\`\`dart
// 缓存图层避免重建
late final List<Widget> _cachedLayers = [
  TrackLayer(trackPoints: trackPoints),
  CustomMarkerLayer(markers: markers),
];

UnifiedMapCore(layers: _cachedLayers)
\`\`\`

### 3. 错误处理
\`\`\`dart
UnifiedMapCore(
  onControllerCreated: (controller) {
    try {
      controller.move(center, zoom);
    } catch (e) {
      print('地图操作失败: $e');
    }
  },
)
\`\`\`

## 🔄 与旧架构的区别

| 特性 | 旧架构 | 新架构 |
|------|--------|--------|
| FlutterMap 实例 | 多个重复实例 | 统一的单一实例 |
| 配置管理 | 分散在各组件 | 统一的配置类 |
| 控制器管理 | 各自创建管理 | 统一创建管理 |
| 代码复用 | 大量重复代码 | 高度复用 |
| 维护成本 | 高 | 低 |
| 性能 | 多实例开销大 | 单实例性能好 |

## 🎯 总结

新的地图架构通过统一的 `UnifiedMapCore` 解决了之前 FlutterMap 多处使用导致的架构混乱问题，提供了：

- **清晰的职责分离**：核心、图层、组件各司其职
- **简单的使用接口**：预设配置满足大部分需求
- **强大的扩展能力**：图层系统支持任意扩展
- **优秀的性能表现**：单一实例，按需渲染

这个架构既满足了简单使用的需求，又保留了高度自定义的能力，是一个平衡性很好的解决方案。