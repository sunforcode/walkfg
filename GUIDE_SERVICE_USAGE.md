# GuideService.getGuideWithDetails 使用指南

## 概述

`getGuideWithDetails` 方法是 GuideService 的增强版本，它不仅加载攻略的基础信息，还会并行加载所有关联的数据，包括路线、行程、装备清单、作者信息和相关攻略。

## 方法签名

\`\`\`dart
Future<GuideModel> getGuideWithDetails(String guideId);
\`\`\`

## 加载的关联数据

### 1. 基础路线数据 (RouteModel)
- 通过 `guide.baseRouteId` 加载
- 提供路线的客观信息：距离、难度、每日计划等
- 用于页面显示具体的行程数据

### 2. 基础行程数据 (TripModel)
- 通过 `guide.baseTripId` 加载
- 提供具体的行程实例信息
- 包含参与者、装备、预算等信息

### 3. 装备清单 (EquipmentListModel)
- 通过 `guide.equipmentListId` 加载
- 提供推荐的装备列表
- 用于"作者推荐"部分的装备展示

### 4. 作者详细信息 (UserModel)
- 通过 `guide.authorId` 加载
- 提供作者的完整资料
- 用于显示作者经验、发布攻略数量等

### 5. 相关攻略列表 (List<GuideModel>)
- 通过 `guide.relatedGuideIds` 加载
- 提供相关的攻略推荐
- 用于"相关攻略"部分的展示

## 使用示例

### 在页面中使用

\`\`\`dart
class GuideDetailScreen extends StatefulWidget {
  final String guideId;
  
  @override
  State<GuideDetailScreen> createState() => _GuideDetailScreenState();
}

class _GuideDetailScreenState extends State<GuideDetailScreen> {
  late Future<GuideModel> _guideFuture;

  @override
  void initState() {
    super.initState();
    _loadGuideDetail();
  }

  void _loadGuideDetail() {
    final apiService = ServiceLocator.instance.getGuideService();
    // 使用增强版方法加载完整数据
    _guideFuture = apiService.getGuideWithDetails(widget.guideId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GuideModel>(
      future: _guideFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final guide = snapshot.data!;
          return _buildGuideDetail(guide);
        }
        return _buildLoadingState();
      },
    );
  }

  Widget _buildGuideDetail(GuideModel guide) {
    return Column(
      children: [
        // 使用关联的路线数据
        Text(guide.getDistanceText()), // 来自 baseRoute
        Text(guide.getDaysText()),     // 来自 baseRoute/baseTrip
        
        // 使用作者详细信息
        Text(guide.getAuthorExperienceText()), // 来自 authorProfile
        
        // 使用装备清单
        if (guide.equipmentList != null)
          _buildEquipmentSection(guide.equipmentList!),
        
        // 使用相关攻略
        if (guide.relatedGuides != null)
          _buildRelatedGuidesSection(guide.relatedGuides!),
      ],
    );
  }
}
\`\`\`

### 数据访问示例

\`\`\`dart
void handleGuideData(GuideModel guide) {
  // 访问基础攻略信息
  print('攻略标题: ${guide.title}');
  print('作者: ${guide.author}');
  
  // 访问关联的路线信息
  if (guide.baseRoute != null) {
    print('路线距离: ${guide.baseRoute!.distance}km');
    print('路线难度: ${guide.baseRoute!.difficulty.getName()}');
    print('计划天数: ${guide.baseRoute!.dailyPlans.length}天');
  }
  
  // 访问关联的行程信息
  if (guide.baseTrip != null) {
    print('行程预算: ${guide.baseTrip!.budget}');
    print('参与人数: ${guide.baseTrip!.participantCount}');
  }
  
  // 访问作者详细信息
  if (guide.authorProfile != null) {
    print('作者完成路线数: ${guide.authorProfile!.completedRoutes}');
    print('作者装备清单数: ${guide.authorProfile!.equipmentLists}');
  }
  
  // 访问装备清单
  if (guide.equipmentList != null) {
    print('推荐装备数量: ${guide.equipmentList!.equipments.length}');
  }
  
  // 访问相关攻略
  if (guide.relatedGuides != null) {
    print('相关攻略数量: ${guide.relatedGuides!.length}');
  }
}
\`\`\`

## 性能优化

### 1. 并行加载
\`\`\`dart
// 所有关联数据并行加载，减少总等待时间
final futures = await Future.wait([
  _loadBaseRoute(guide.baseRouteId),
  _loadBaseTrip(guide.baseTripId),
  _loadEquipmentList(guide.equipmentListId),
  _loadAuthorProfile(guide.authorId),
  _loadRelatedGuides(guide.relatedGuideIds),
]);
\`\`\`

### 2. 错误处理
\`\`\`dart
// 单个关联数据加载失败不影响其他数据
Future<RouteModel?> _loadBaseRoute(String? routeId) async {
  if (routeId == null || routeId.isEmpty) return null;
  
  try {
    final routeService = ServiceLocator.instance.getRouteService();
    return await routeService.getRouteById(routeId);
  } catch (e) {
    print('加载路线数据失败: $e');
    return null; // 返回 null 而不是抛出异常
  }
}
\`\`\`

### 3. 缓存策略
- 基础攻略数据可以缓存较长时间
- 关联数据根据更新频率设置不同的缓存时间
- 用户相关数据（如点赞状态）使用较短的缓存时间

## 与 getGuideById 的区别

| 方法 | 加载内容 | 网络请求数 | 适用场景 |
|------|----------|------------|----------|
| `getGuideById` | 仅基础攻略数据 | 1个 | 列表页、简单预览 |
| `getGuideWithDetails` | 完整关联数据 | 1-6个 | 详情页、完整展示 |

## 最佳实践

### 1. 在详情页使用
\`\`\`dart
// ✅ 推荐：详情页使用完整数据
_guideFuture = apiService.getGuideWithDetails(widget.guideId);
\`\`\`

### 2. 在列表页使用基础方法
\`\`\`dart
// ✅ 推荐：列表页使用基础数据
final guides = await apiService.getGuides();
\`\`\`

### 3. 条件加载
\`\`\`dart
// ✅ 推荐：根据需要选择方法
final guide = needFullData 
  ? await apiService.getGuideWithDetails(guideId)
  : await apiService.getGuideById(guideId);
\`\`\`

### 4. 错误处理
\`\`\`dart
try {
  final guide = await apiService.getGuideWithDetails(guideId);
  // 处理成功情况
} catch (e) {
  // 处理错误情况
  print('加载攻略详情失败: $e');
}
\`\`\`

## 注意事项

1. **网络延迟**：该方法需要加载多个关联数据，总耗时可能较长
2. **数据一致性**：关联数据可能存在不一致的情况，需要做好容错处理
3. **内存使用**：完整的关联数据会占用更多内存，注意及时释放
4. **缓存策略**：建议对关联数据进行适当的缓存以提高性能