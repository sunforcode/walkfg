/// 水模块枚举类型
///
/// 定义水模块中使用的各种枚举类型

/// 水源类型枚举
enum WaterSourceType { stream, lake, spring, well, tap, snow, rain }

/// 水质枚举
enum WaterQuality { excellent, good, fair, poor, unknown }

/// 水容器类型
enum WaterContainerType {
  /// 水壶
  bottle,

  /// 水袋
  bladder,

  /// 软水瓶
  softBottle,

  /// 保温杯
  thermos,
}

/// 活动强度
enum ActivityIntensity {
  /// 低强度(散步、轻松徒步)
  low,

  /// 中等强度(常规徒步、骑行)
  medium,

  /// 高强度(快速徒步、跑步)
  high,

  /// 极高强度(登山、负重徒步)
  extreme,
}
