/// 水模块枚举类型
///
/// 定义水模块中使用的各种枚举类型

/// 水源类型
enum WaterSourceType {
  /// 河流
  river,
  
  /// 溪流
  stream,
  
  /// 湖泊
  lake,
  
  /// 泉水
  spring,
  
  /// 水龙头/自来水
  tap,
}

/// 水质等级
enum WaterQuality {
  /// 优质
  excellent,
  
  /// 良好
  good,
  
  /// 一般
  fair,
  
  /// 较差
  poor,
}

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
  moderate,
  
  /// 高强度(快速徒步、跑步)
  high,
  
  /// 极高强度(登山、负重徒步)
  veryHigh,
}