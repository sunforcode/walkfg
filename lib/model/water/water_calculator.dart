/// 饮水计算工具类
///
/// 提供饮水需求计算的静态方法
///
/// WaterCalculator包含了计算户外活动饮水需求的各种方法，
/// 帮助用户科学地规划饮水量。

import 'water_types.dart';

/// 饮水计算工具类
class WaterCalculator {
  /// 计算每日基础饮水需求(ml)
  static int calculateBaseWaterIntake({
    required int personWeight, // 体重(kg)
    required bool isAdult, // 是否成人
  }) {
    // 简化计算：成人每公斤体重30-35ml，儿童每公斤40-45ml
    return isAdult ? personWeight * 35 : personWeight * 45;
  }

  /// 计算活动饮水需求(ml)
  static int calculateActivityWaterIntake({
    required ActivityIntensity intensity, // 活动强度
    required int durationHours, // 活动时长(小时)
    required double temperature, // 环境温度(°C)
  }) {
    // 基础每小时需求
    int baseHourlyNeed;
    switch (intensity) {
      case ActivityIntensity.low:
        baseHourlyNeed = 300;
        break;
      case ActivityIntensity.medium:
        baseHourlyNeed = 500;
        break;
      case ActivityIntensity.high:
        baseHourlyNeed = 700;
        break;
      case ActivityIntensity.extreme:
        baseHourlyNeed = 1000;
        break;
    }

    // 温度调整系数
    double tempFactor = 1.0;
    if (temperature > 30)
      tempFactor = 1.5;
    else if (temperature > 25)
      tempFactor = 1.3;
    else if (temperature > 15)
      tempFactor = 1.0;
    else if (temperature > 5)
      tempFactor = 0.8;
    else
      tempFactor = 0.7;

    return (baseHourlyNeed * durationHours * tempFactor).toInt();
  }

  /// 计算携带水量(ml)
  static int calculateWaterToCarry({
    required int totalWaterNeed, // 总饮水需求(ml)
    required int reliableSourceWater, // 可靠水源提供量(ml)
    double safetyMargin = 1.2, // 安全余量系数
  }) {
    return ((totalWaterNeed * safetyMargin) - reliableSourceWater).toInt();
  }

  /// 计算水的重量(g)
  static int calculateWaterWeight(int volumeInMl) {
    // 水的密度约为1g/ml
    return volumeInMl;
  }

  /// 获取饮水建议
  static String getWaterIntakeAdvice({
    required ActivityIntensity intensity,
    required double temperature,
  }) {
    if (temperature > 30) {
      switch (intensity) {
        case ActivityIntensity.low:
          return '高温环境下即使是低强度活动也需要大量饮水，建议每小时至少饮用500ml水。';
        case ActivityIntensity.medium:
          return '高温环境下中等强度活动会导致大量出汗，建议每小时饮用700-800ml水，并补充电解质。';
        case ActivityIntensity.high:
        case ActivityIntensity.extreme:
          return '高温环境下高强度活动极易导致脱水，建议每小时饮用1000ml以上的水，必须补充电解质，并考虑调整活动计划。';
      }
    } else if (temperature > 20) {
      switch (intensity) {
        case ActivityIntensity.low:
          return '温暖环境下低强度活动建议每小时饮用300-400ml水。';
        case ActivityIntensity.medium:
          return '温暖环境下中等强度活动建议每小时饮用500-600ml水。';
        case ActivityIntensity.high:
        case ActivityIntensity.extreme:
          return '温暖环境下高强度活动建议每小时饮用700-900ml水，并考虑补充电解质。';
      }
    } else {
      switch (intensity) {
        case ActivityIntensity.low:
          return '凉爽环境下低强度活动建议每小时饮用200-300ml水。';
        case ActivityIntensity.medium:
          return '凉爽环境下中等强度活动建议每小时饮用300-500ml水。';
        case ActivityIntensity.high:
        case ActivityIntensity.extreme:
          return '凉爽环境下高强度活动建议每小时饮用500-700ml水。';
      }
    }
  }
}
