# 模拟数据文件说明

本目录包含用于应用开发和测试的模拟数据JSON文件。这些文件提供了户外活动规划系统中各个模块的示例数据，特别是水模块、食物模块和装备模块的数据。

## 文件列表

### 水模块相关文件

- **water_sources.json**: 水源数据，包含不同类型的水源信息
- **water_containers.json**: 水容器数据，包含不同类型的水容器信息
- **day_water_plans.json**: 每日饮水计划数据，包含不同天数的饮水安排
- **water_plans.json**: 饮水计划数据，包含完整的饮水规划方案

### 食物模块相关文件

- **food_items.json**: 食物项目数据，包含不同类型的食物信息
- **day_meal_plans.json**: 每日膳食计划数据，包含不同天数的膳食安排
- **meal_plans.json**: 膳食计划数据，包含完整的膳食规划方案

### 装备模块相关文件

- **equipment_items.json**: 装备项目数据，包含不同类型的装备信息
- **equipment_lists.json**: 装备清单数据，包含完整的装备规划方案
- **equipment_templates.json**: 装备模板数据，包含预设的装备模板
- **user_equipment_inventory.json**: 用户装备库数据，包含用户拥有的装备信息

### 行程模块相关文件

- **trips.json**: 行程数据，包含多个行程的基本信息和关联ID
- **trip_with_water_plan.json**: 包含完整水模块关联的行程示例
- **trip_with_meal_plan.json**: 包含完整食物模块关联的行程示例
- **trip_with_equipment_list.json**: 包含完整装备模块关联的行程示例

## 数据结构说明

### 水源 (WaterSourceModel)

水源模型表示户外活动中的水源点，包含以下主要字段：

- `id`: 唯一标识符
- `name`: 水源名称
- `description`: 水源描述
- `type`: 水源类型 (1=溪流, 2=湖泊, 3=泉水, 4=水龙头)
- `location`: 位置描述
- `distanceFromTrail`: 距离路线的偏移距离(米)
- `quality`: 水质等级 (0=优质, 1=良好, 2=一般, 3=较差)
- `reliability`: 可靠性评级(1-5)
- `estimatedVolume`: 预计可用水量(ml)
- `needsTreatment`: 是否需要处理

### 水容器 (WaterContainerModel)

水容器模型表示携带和存储水的容器，包含以下主要字段：

- `id`: 唯一标识符
- `name`: 容器名称
- `description`: 容器描述
- `type`: 容器类型 (0=水壶, 1=水袋, 2=软水瓶, 3=保温杯)
- `capacity`: 容量(ml)
- `emptyWeight`: 空重(g)
- `material`: 材质
- `collapsible`: 是否可折叠

### 每日饮水计划 (DayWaterPlanModel)

每日饮水计划模型表示一天的饮水安排，包含以下主要字段：

- `dayNumber`: 天数序号(从1开始)
- `baseWaterIntake`: 基础饮水量(ml)
- `activityWaterIntake`: 活动饮水量(ml)
- `temperature`: 环境温度(°C)
- `activityIntensity`: 活动强度 (0=低, 1=中, 2=高, 3=极高)
- `availableSources`: 当天可用水源列表

### 饮水计划 (WaterPlanModel)

饮水计划模型表示整个行程的饮水计划，包含以下主要字段：

- `id`: 唯一标识符
- `name`: 计划名称
- `description`: 计划描述
- `tripDays`: 行程天数
- `personCount`: 人数
- `dayWaterPlans`: 每日饮水计划列表
- `waterSources`: 水源补给点列表
- `tags`: 标签列表
- `creatorId`: 创建者ID
- `creatorName`: 创建者名称

### 食物项目 (FoodItemModel)

食物项目模型表示单个食物项目，包含以下主要字段：

- `id`: 唯一标识符
- `name`: 食物名称
- `description`: 食物描述
- `weight`: 重量(g)
- `quantity`: 数量
- `calories`: 卡路里(kcal/100g)
- `protein`: 蛋白质(g/100g)
- `fat`: 脂肪(g/100g)
- `carbs`: 碳水化合物(g/100g)
- `price`: 单价(元)
- `prepared`: 是否已准备
- `notes`: 备注

### 每日膳食计划 (DayMealPlanModel)

每日膳食计划模型表示一天的膳食安排，包含以下主要字段：

- `dayNumber`: 天数序号(从1开始)
- `breakfast`: 早餐食物列表
- `lunch`: 午餐食物列表
- `dinner`: 晚餐食物列表
- `snacks`: 零食列表
- `drinks`: 饮料列表

### 膳食计划 (MealPlanModel)

膳食计划模型表示整个行程的膳食计划，包含以下主要字段：

- `id`: 唯一标识符
- `name`: 计划名称
- `description`: 计划描述
- `tripDays`: 行程天数
- `personCount`: 人数
- `dayMealPlans`: 每日膳食计划列表
- `tags`: 标签列表
- `creatorId`: 创建者ID
- `creatorName`: 创建者名称

### 装备项目 (EquipmentItemModel)

装备项目模型表示单个装备项目，包含以下主要字段：

- `id`: 唯一标识符
- `name`: 装备名称
- `category`: 类别
- `description`: 装备描述
- `weight`: 重量(g)
- `weight_unit`: 重量单位 (gram=克, kilogram=千克, pound=磅, ounce=盎司)
- `quantity`: 数量
- `necessity`: 必要性 (0=必需, 1=推荐, 2=可选)
- `prepared`: 是否已准备
- `brand`: 品牌
- `model`: 型号
- `price`: 价格(元)
- `notes`: 备注
- `is_owned`: 是否拥有
- `is_shared`: 是否共享装备
- `shared_person_count`: 共享人数
- `usage_count`: 使用次数
- `condition`: 使用状态 (new=全新, good=良好, fair=一般, poor=较差, damaged=损坏)
- `image_url`: 装备图片URL

### 装备清单 (EquipmentListModel)

装备清单模型表示整个行程的装备清单，包含以下主要字段：

- `id`: 唯一标识符
- `name`: 清单名称
- `description`: 清单描述
- `type`: 清单类型 (shortHike=短途徒步, longHike=长途徒步, camping=露营, mountaineering=登山, trekking=穿越, custom=自定义)
- `route_id`: 路线ID
- `route_name`: 路线名称
- `trip_id`: 行程ID
- `trip_days`: 行程天数
- `person_count`: 适用人数
- `seasons`: 季节适用性
- `equipments`: 装备项目列表
- `total_weight`: 总重量(g)
- `base_weight`: 基础重量(g)
- `consumable_weight`: 消耗品重量(g)
- `worn_weight`: 穿着重量(g)
- `tags`: 标签列表
- `creator_id`: 创建者ID
- `creator_name`: 创建者名称
- `is_official`: 是否官方推荐
- `is_template`: 是否为模板
- `template_id`: 模板ID (如果是从模板创建)
- `status`: 状态 (planning=规划中, preparing=准备中, ready=已准备, inUse=使用中, completed=已完成, archived=已归档)

### 装备模板 (EquipmentTemplateModel)

装备模板模型表示预设的装备清单模板，包含以下主要字段：

- `id`: 唯一标识符
- `name`: 模板名称
- `description`: 模板描述
- `type`: 模板类型 (同装备清单类型)
- `seasons`: 季节适用性
- `equipments`: 装备项目列表
- `tags`: 标签列表
- `is_official`: 是否官方模板
- `creator_id`: 创建者ID
- `creator_name`: 创建者名称
- `usage_count`: 使用次数
- `rating`: 评分 (1-5)

### 用户装备库 (UserEquipmentInventoryModel)

用户装备库模型表示用户拥有的装备集合，包含以下主要字段：

- `id`: 唯一标识符
- `user_id`: 用户ID
- `equipments`: 装备项目列表
- `last_updated_at`: 最后更新时间

### 行程 (TripModel)

行程模型表示具体行程的规划和执行实体，包含以下主要字段：

- `id`: 唯一标识符
- `name`: 行程名称
- `description`: 行程描述
- `start_date`: 开始日期
- `end_date`: 结束日期
- `status`: 状态 (0=计划中, 1=进行中, 2=已完成, 3=已取消)
- `participants`: 参与者列表
- `participant_count`: 参与者数量
- `organizer_id`: 组织者ID
- `equipment_list_id`: 装备清单ID
- `equipment_list`: 装备清单对象 (组合关系)
- `meal_plan_id`: 膳食计划ID
- `meal_plan`: 膳食计划对象 (组合关系)
- `water_plan_id`: 饮水计划ID
- `water_plan`: 饮水计划对象 (组合关系)
- `itinerary`: 行程安排列表
- `log_entries`: 行程日志列表

## 使用方法

这些JSON文件可以通过以下方式使用：

1. **开发测试**: 在开发过程中作为模拟数据使用
2. **UI设计**: 为UI组件提供真实的数据结构和内容
3. **API模拟**: 作为API响应的模拟数据
4. **演示**: 用于产品演示和展示

可以通过以下代码加载这些JSON文件：

\`\`\`dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:walk/model/water/water_model.dart';
import 'package:walk/model/food/meal_plan_model.dart';
import 'package:walk/model/equipment/equipment_model.dart';
import 'package:walk/model/trip/trip_model.dart';

// 加载水源数据
Future<List<WaterSourceModel>> loadWaterSources() async {
  final jsonString = await rootBundle.loadString('assets/mock_data_new/water_sources.json');
  final jsonList = jsonDecode(jsonString) as List;
  return jsonList.map((json) => WaterSourceModel.fromJson(json)).toList();
}

// 加载饮水计划数据
Future<List<WaterPlanModel>> loadWaterPlans() async {
  final jsonString = await rootBundle.loadString('assets/mock_data_new/water_plans.json');
  final jsonList = jsonDecode(jsonString) as List;
  return jsonList.map((json) => WaterPlanModel.fromJson(json)).toList();
}

// 加载食物项目数据
Future<List<FoodItemModel>> loadFoodItems() async {
  final jsonString = await rootBundle.loadString('assets/mock_data_new/food_items.json');
  final jsonList = jsonDecode(jsonString) as List;
  return jsonList.map((json) => FoodItemModel.fromJson(json)).toList();
}

// 加载膳食计划数据
Future<List<MealPlanModel>> loadMealPlans() async {
  final jsonString = await rootBundle.loadString('assets/mock_data_new/meal_plans.json');
  final jsonList = jsonDecode(jsonString) as List;
  return jsonList.map((json) => MealPlanModel.fromJson(json)).toList();
}

// 加载装备项目数据
Future<List<EquipmentItemModel>> loadEquipmentItems() async {
  final jsonString = await rootBundle.loadString('assets/mock_data_new/equipment_items.json');
  final jsonList = jsonDecode(jsonString) as List;
  return jsonList.map((json) => EquipmentItemModel.fromJson(json)).toList();
}

// 加载装备清单数据
Future<List<EquipmentListModel>> loadEquipmentLists() async {
  final jsonString = await rootBundle.loadString('assets/mock_data_new/equipment_lists.json');
  final jsonList = jsonDecode(jsonString) as List;
  return jsonList.map((json) => EquipmentListModel.fromJson(json)).toList();
}

// 加载装备模板数据
Future<List<EquipmentTemplateModel>> loadEquipmentTemplates() async {
  final jsonString = await rootBundle.loadString('assets/mock_data_new/equipment_templates.json');
  final jsonList = jsonDecode(jsonString) as List;
  return jsonList.map((json) => EquipmentTemplateModel.fromJson(json)).toList();
}

// 加载用户装备库数据
Future<List<UserEquipmentInventoryModel>> loadUserEquipmentInventories() async {
  final jsonString = await rootBundle.loadString('assets/mock_data_new/user_equipment_inventory.json');
  final jsonList = jsonDecode(jsonString) as List;
  return jsonList.map((json) => UserEquipmentInventoryModel.fromJson(json)).toList();
}

// 加载行程数据
Future<List<TripModel>> loadTrips() async {
  final jsonString = await rootBundle.loadString('assets/mock_data_new/trips.json');
  final jsonList = jsonDecode(jsonString) as List;
  return jsonList.map((json) => TripModel.fromJson(json)).toList();
}

// 加载包含水模块的完整行程示例
Future<TripModel> loadTripWithWaterPlan() async {
  final jsonString = await rootBundle.loadString('assets/mock_data_new/trip_with_water_plan.json');
  final json = jsonDecode(jsonString);
  return TripModel.fromJson(json);
}

// 加载包含食物模块的完整行程示例
Future<TripModel> loadTripWithMealPlan() async {
  final jsonString = await rootBundle.loadString('assets/mock_data_new/trip_with_meal_plan.json');
  final json = jsonDecode(jsonString);
  return TripModel.fromJson(json);
}

// 加载包含装备模块的完整行程示例
Future<TripModel> loadTripWithEquipmentList() async {
  final jsonString = await rootBundle.loadString('assets/mock_data_new/trip_with_equipment_list.json');
  final json = jsonDecode(jsonString);
  return TripModel.fromJson(json);
}
\`\`\`

## 注意事项

1. 这些数据仅用于开发和测试，不应在生产环境中使用
2. 数据中的ID、时间戳等信息是模拟的，不代表实际数据
3. 图片URL是示例链接，不指向实际图片资源