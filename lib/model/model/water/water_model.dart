/// 水模块模型
///
/// 用于存储户外活动的饮水计划信息
/// 
/// 水模块是户外活动规划系统的重要组成部分，提供了饮水管理功能。
/// 该模块采用多层结构设计：
/// 
/// 1. WaterPlanModel (饮水计划模型)：顶层模型，代表整个行程的饮水规划方案
/// 2. DayWaterPlanModel (每日饮水计划模型)：中间层，代表一天内的饮水安排
/// 3. WaterSourceModel (水源模型)：记录行程中的水源信息
/// 4. WaterContainerModel (水容器模型)：记录携带和存储水的容器信息
/// 
/// 这种结构使用户能够全面管理户外活动的饮水需求，包括：
/// - 计算行程中的饮水需求
/// - 规划水源补给策略
/// - 优化水容器的选择
/// - 确保在活动中获得充足、安全的饮用水
/// 
/// 通过这个模块，户外活动参与者可以科学地规划饮水，
/// 避免脱水风险，同时优化携带水的重量。

// 导出所有水相关模型
export 'water_types.dart';
export 'water_source_model.dart';
export 'water_container_model.dart';
export 'day_water_plan_model.dart';
export 'water_plan_model.dart';
export 'water_calculator.dart';