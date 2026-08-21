/// API端点配置
///
/// 统一管理所有API路径，便于维护和修改
class ApiEndpoints {
  // 基础配置
  static const String apiVersion = 'v1';
  static const String apiPrefix = '/walkbg/api/$apiVersion';

  // ==================== 路线相关 ====================
  /// 路线列表
  static const String routes = '$apiPrefix/routes';

  /// 路线详情
  static String routeDetail(String routeId) =>
      '$apiPrefix/routes/$routeId';

  /// 搜索路线
  static const String searchRoutes = '$apiPrefix/routes/search';

  /// 热门路线
  static const String popularRoutes = '$apiPrefix/routes/popular';

  /// 季节性路线
  static const String seasonalRoutes = '$apiPrefix/routes/seasonal';

  /// 新晋路线
  static const String newRoutes = '$apiPrefix/routes/new';

  /// 周末路线
  static const String weekendRoutes = '$apiPrefix/routes/weekend';

  /// 推荐路线
  static const String recommendedRoutes = '$apiPrefix/routes/recommended';

  /// 按地区获取路线
  static String routesByRegion(String region) =>
      '$apiPrefix/routes/region/$region';

  /// 按难度获取路线
  static String routesByDifficulty(String difficulty) =>
      '$apiPrefix/routes/difficulty/$difficulty';

  /// 按持续时间获取路线
  static const String routesByDuration = '$apiPrefix/routes/duration';

  /// 路线评分
  static String routeRatings(String routeId) =>
      '$apiPrefix/routes/$routeId/ratings';

  /// 路线标签
  static String routeTags(String routeId) => '$apiPrefix/routes/$routeId/tags';

  /// 路线关键点
  static String routeWaypoints(String routeId) =>
      '$apiPrefix/routes/$routeId/waypoints';

  /// 相关路线
  static String relatedRoutes(String routeId) =>
      '$apiPrefix/routes/$routeId/related';

  /// 路线评论
  static String routeComments(String routeId) =>
      '$apiPrefix/routes/$routeId/comments';

  /// 添加路线评论
  static String addRouteComment(String routeId) =>
      '$apiPrefix/routes/$routeId/comments';

  // ==================== 收藏相关 ====================
  /// 收藏路线列表
  static const String favoriteRoutes = '$apiPrefix/routes/favorites';

  /// 收藏/取消收藏路线
  static String favoriteRoute(String routeId) =>
      '$apiPrefix/routes/$routeId/favorite';

  // ==================== 行程相关 ====================
  /// 行程列表
  static const String trips = '$apiPrefix/trips';

  /// 行程详情
  static String tripDetail(String tripId) => '$apiPrefix/trips/$tripId';

  /// 创建行程
  static const String createTrip = '$apiPrefix/trips';

  /// 更新行程
  static String updateTrip(String tripId) => '$apiPrefix/trips/$tripId';

  /// 删除行程
  static String deleteTrip(String tripId) => '$apiPrefix/trips/$tripId';

  /// 更新行程状态
  static String tripStatus(String tripId) => '$apiPrefix/trips/$tripId/status';

  /// 计划行程
  static const String plannedTrips = '$apiPrefix/trips/planned';

  /// 已完成行程
  static const String completedTrips = '$apiPrefix/trips/completed';

  /// 正在进行的行程
  static const String ongoingTrips = '$apiPrefix/trips/ongoing';

  /// 行程关联的装备清单列表（分页）
  static String tripEquipmentLists(String tripId) =>
      '$apiPrefix/trips/$tripId/equipment-lists';

  // ==================== 行程计划相关 ====================
  /// 行程计划列表
  static const String tripPlans = '$apiPrefix/trip-plans';

  /// 行程计划详情
  static String tripPlanDetail(String planId) =>
      '$apiPrefix/trip-plans/$planId';

  /// 创建行程计划
  static const String createTripPlan = '$apiPrefix/trip-plans';

  /// 更新行程计划
  static String updateTripPlan(String planId) =>
      '$apiPrefix/trip-plans/$planId';

  /// 删除行程计划
  static String deleteTripPlan(String planId) =>
      '$apiPrefix/trip-plans/$planId';

  // ==================== 用户相关 ====================
  /// 当前用户信息（通过Token识别用户）
  static const String userProfile = '$apiPrefix/user/profile';

  /// 获取指定用户信息
  static String userDetail(String userId) => '$apiPrefix/users/$userId';

  /// 更新用户信息
  static const String updateUserProfile = '$apiPrefix/user/profile';

  /// 用户统计
  static const String userStats = '$apiPrefix/user/stats';

  // ==================== 认证相关 ====================
  /// 登录
  static const String login = '$apiPrefix/auth/login';

  /// 注册
  static const String register = '$apiPrefix/auth/register';

  /// 登出
  static const String logout = '$apiPrefix/auth/logout';

  /// 刷新token
  static const String refreshToken = '$apiPrefix/auth/refresh';

  // ==================== 装备相关 ====================
  // 装备单品：对应后端 EquipmentController（/api/v1/equipment）
  // 装备清单：对应后端 EquipmentListController（/api/v1/equipment-lists）
  // 注意：装备模板、用户装备库暂未接入客户端（core_only 范围）

  /// 装备单品分页列表
  static const String equipmentItems = '$apiPrefix/equipment/items';

  /// 装备单品详情 / 更新 / 删除
  static String equipmentItemDetail(String itemId) =>
      '$apiPrefix/equipment/items/$itemId';

  /// 装备单品多条件搜索
  static const String equipmentItemSearch = '$apiPrefix/equipment/items/search';

  /// 装备单品分类统计
  static const String equipmentCategoryStats =
      '$apiPrefix/equipment/category-stats';

  /// 装备清单分页列表 / 创建
  static const String equipmentLists = '$apiPrefix/equipment-lists';

  /// 装备清单详情 / 更新 / 删除
  static String equipmentListDetail(String listId) =>
      '$apiPrefix/equipment-lists/$listId';

  /// 装备清单统计信息
  static String equipmentListStatistics(String listId) =>
      '$apiPrefix/equipment-lists/$listId/statistics';

  /// 装备清单内的装备条目列表 / 添加装备
  static String equipmentListItems(String listId) =>
      '$apiPrefix/equipment-lists/$listId/items';

  /// 装备清单内单个装备条目更新 / 移除
  static String equipmentListItemDetail(String listId, String itemId) =>
      '$apiPrefix/equipment-lists/$listId/items/$itemId';

  /// 装备清单重量统计
  static String equipmentListWeightStats(String listId) =>
      '$apiPrefix/equipment-lists/$listId/weight-stats';

  /// 装备清单状态更新（专用端点，唯一能生效的状态修改方式）
  static String equipmentListStatus(String listId) =>
      '$apiPrefix/equipment-lists/$listId/status';

  // ==================== 攻略相关 ====================
  /// 攻略列表
  static const String guides = '$apiPrefix/guides';

  /// 攻略详情
  static String guideDetail(String guideId) => '$apiPrefix/guides/$guideId';

  /// 攻略点赞
  static String guideLike(String guideId) => '$apiPrefix/guides/$guideId/like';

  /// 攻略取消点赞
  static String guideUnlike(String guideId) =>
      '$apiPrefix/guides/$guideId/unlike';

  // ==================== 文件上传相关 ====================
  /// 上传头像
  static const String uploadAvatar = '$apiPrefix/upload/avatar';

  // ==================== 工具方法 ====================

  /// 构建带查询参数的URL
  static String buildUrl(String endpoint, Map<String, dynamic>? queryParams) {
    if (queryParams == null || queryParams.isEmpty) {
      return endpoint;
    }

    final uri = Uri.parse(endpoint);
    final newUri = uri.replace(queryParameters: {
      ...uri.queryParameters,
      ...queryParams.map((key, value) => MapEntry(key, value.toString())),
    });

    return newUri.toString();
  }

  /// 构建分页URL
  static String buildPaginatedUrl(
    String endpoint, {
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? additionalParams,
  }) {
    final params = {
      'page': page,
      'limit': limit,
      ...?additionalParams,
    };

    return buildUrl(endpoint, params);
  }
}
