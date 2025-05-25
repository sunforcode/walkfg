/// 地图类型
enum MapType {
  /// 标准地图
  standard,

  /// 卫星地图
  satellite,

  /// 混合地图
  hybrid,

  /// 地形图
  terrain,

  /// 高德标准地图
  amapStandard,

  /// 高德卫星地图
  amapSatellite,

  /// 高德夜间地图
  amapNight,

  /// 天地图矢量
  tiandituVector,

  /// 天地图卫星
  tiandituSatellite,

  /// 天地图地形
  tiandituTerrain,

  /// OpenStreetMap标准
  osmStandard,

  /// OpenStreetMap人道主义
  osmHumanitarian,

  /// 谷歌标准地图
  googleStandard,

  /// 谷歌卫星地图
  googleSatellite,

  /// 谷歌地形图
  googleTerrain,

  /// 3D地图
  threeD,
}

/// 地图提供商
enum MapProviderType {
  /// 苹果地图
  apple,

  /// 高德地图
  amap,

  /// 天地图
  tianditu,

  /// OpenStreetMap
  osm,

  /// 谷歌地图
  google,
}

/// 轨迹渲染模式
enum TrackRenderMode {
  /// 普通模式（单色）
  normal,

  /// 速度模式（根据速度渲染颜色）
  speed,

  /// 海拔模式（根据海拔渲染颜色）
  elevation,

  /// 坡度模式（根据坡度渲染颜色）
  gradient,
}
