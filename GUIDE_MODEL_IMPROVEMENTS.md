# GuideModel 改进方案

## 概述

本次改进采用**主观经验 + 客观数据关联**的混合模式，既满足了攻略详情页的所有功能需求，又充分利用了现有的模型生态系统。

## 主要改进内容

### 1. 新增基础字段

\`\`\`dart
// 页面功能相关
final RouteDifficulty difficulty;      // 难度等级（主观感受）
final int readingTime;                 // 阅读时长（分钟）
final bool isBookmarked;               // 收藏状态
final int commentCount;                // 评论数量
final String location;                 // 地理位置

// 经验数据
final String? bestTime;               // 最佳时间建议
final double? actualCost;             // 实际花费（元）
final int? actualDays;                // 实际用时（天数）
\`\`\`

### 2. 攻略特有内容字段

\`\`\`dart
final List<String> highlights;           // 行程亮点
final List<String> personalTips;        // 作者个人建议
final List<String> seasonalAdvice;      // 季节建议
final List<String> safetyWarnings;      // 安全警告
final List<String> equipmentAdjustments; // 装备调整建议
final List<String> routeModifications;   // 路线调整说明
\`\`\`

### 3. 关联模型ID字段

\`\`\`dart
final String? baseRouteId;              // 基础路线ID
final String? baseTripId;               // 基础行程ID
final String? equipmentListId;          // 推荐装备清单ID
final List<String> relatedGuideIds;     // 相关攻略ID列表
\`\`\`

### 4. 运行时关联数据

\`\`\`dart
@JsonKey(ignore: true)
final RouteModel? baseRoute;            // 基础路线数据
@JsonKey(ignore: true)
final TripModel? baseTrip;              // 基础行程数据
@JsonKey(ignore: true)
final EquipmentListModel? equipmentList; // 推荐装备清单
@JsonKey(ignore: true)
final UserModel? authorProfile;         // 作者详细信息
@JsonKey(ignore: true)
final List<GuideModel>? relatedGuides;  // 相关攻略列表
\`\`\`

## 新增便捷方法

### 页面显示方法
- `getDifficultyName()` - 获取难度名称
- `getReadingTimeText()` - 获取阅读时长文本
- `getTripDescription()` - 获取完整的行程描述
- `getAuthorExperienceText()` - 获取作者经验文本

### 数据获取方法
- `getDistanceText()` - 获取距离信息（优先使用客观数据）
- `getDaysText()` - 获取天数信息（实际vs计划）
- `getDifficultyComparisonText()` - 获取难度对比信息
- `getCostText()` - 获取预估费用文本

### 状态判断方法
- `hasObjectiveData` - 是否有关联的客观数据
- `primaryRoute` - 获取主要路线信息
- `primaryTrip` - 获取主要行程信息

## 页面适配示例

### 原来的硬编码
\`\`\`dart
Text('中等难度')
Text('阅读时间 5分钟')
Text('总长约5公里，建议1-2天完成')
Text('资深徒步爱好者 · 已发布32篇攻略')
\`\`\`

### 改为动态数据
\`\`\`dart
Text(guide.getDifficultyName())
Text(guide.getReadingTimeText())
Text(guide.getTripDescription())
Text(guide.getAuthorExperienceText())
\`\`\`

## 数据加载策略

### 服务层支持
\`\`\`dart
/// 获取包含完整关联数据的攻略详情
Future<GuideModel> getGuideWithDetails(String id) async {
  // 1. 获取基础攻略数据
  final guide = await getGuideById(id);
  
  // 2. 并行加载关联数据
  final futures = await Future.wait([
    _loadBaseRoute(guide.baseRouteId),
    _loadBaseTrip(guide.baseTripId),
    _loadEquipmentList(guide.equipmentListId),
    _loadAuthorProfile(guide.authorId),
    _loadRelatedGuides(guide.relatedGuideIds),
  ]);
  
  // 3. 组装完整数据
  return guide.copyWith(
    baseRoute: futures[0] as RouteModel?,
    baseTrip: futures[1] as TripModel?,
    equipmentList: futures[2] as EquipmentListModel?,
    authorProfile: futures[3] as UserModel?,
    relatedGuides: futures[4] as List<GuideModel>?,
  );
}
\`\`\`

## 设计优势

### 1. 内容丰富度
- 有具体的行程数据作为基础
- 有个人经验作为补充和修正
- 用户既能获得可操作的信息，又能了解实际体验

### 2. 数据复用
- 充分利用现有的Trip/Route数据
- 避免重复定义相同的信息
- 保持数据的一致性

### 3. 灵活性
- 可以基于已有行程创建攻略
- 也可以创建纯经验分享的攻略（不关联具体行程）
- 支持对官方数据的个人化修正

### 4. 用户价值
- **新手**：可以直接使用基础行程数据
- **有经验者**：可以参考作者的个人建议和调整
- **规划者**：可以对比官方数据和实际体验

## 实现注意事项

1. **JSON序列化**：需要重新生成 `guide_model.g.dart` 文件
2. **数据库迁移**：需要添加新字段的数据库迁移脚本
3. **API适配**：后端API需要支持新的字段和关联数据加载
4. **缓存策略**：考虑对关联数据进行适当的缓存
5. **向后兼容**：确保新字段都有合理的默认值

## 总结

这种混合模式的设计既解决了纯经验分享内容空白的问题，又保持了攻略的个人化特色，同时充分利用了现有的数据模型生态。通过关联而非重复的方式，避免了数据冗余，提高了系统的可维护性。