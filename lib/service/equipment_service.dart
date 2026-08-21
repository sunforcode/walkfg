import 'package:flutter/foundation.dart';
import 'package:walk/core/network/api_client.dart';
import 'package:walk/core/network/api_endpoints.dart';
import 'package:walk/core/network/api_exception.dart';
import 'package:walk/core/network/response_unwrap.dart';
import 'package:walk/model/equipment/equipment_enums.dart';
import 'package:walk/model/equipment/equipment_item_model.dart';
import 'package:walk/model/equipment/equipment_list_item_model.dart';
import 'package:walk/model/equipment/equipment_list_model.dart';

/// 分页结果包装
///
/// 对应后端 Spring `Page<T>` 的 JSON 结构（`content`/`totalElements`/
/// `totalPages`/`number`/`size`）。
class EquipmentPageResult<T> {
  /// 当前页数据
  final List<T> content;

  /// 总条数
  final int totalElements;

  /// 总页数
  final int totalPages;

  /// 当前页码（从0开始）
  final int page;

  /// 每页大小
  final int size;

  const EquipmentPageResult({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.page,
    required this.size,
  });

  /// 是否还有下一页
  bool get hasMore => page + 1 < totalPages;

  factory EquipmentPageResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final contentJson = json['content'] as List<dynamic>? ?? [];
    return EquipmentPageResult<T>(
      content: contentJson
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList(),
      totalElements: (json['totalElements'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      page: (json['number'] as num?)?.toInt() ?? 0,
      size: (json['size'] as num?)?.toInt() ?? contentJson.length,
    );
  }

  static EquipmentPageResult<T> empty<T>() => EquipmentPageResult<T>(
        content: const [],
        totalElements: 0,
        totalPages: 0,
        page: 0,
        size: 0,
      );
}

/// 装备模块服务
///
/// 严格对齐后端 `walkbg` 的 `EquipmentController` / `EquipmentListController`
/// 真实接口，不使用任何 mock 数据降级。
///
/// 关键约束（务必遵守，详见各 model 文件顶部注释）：
/// - 创建装备清单通过 [EquipmentListCreateRequestModel]（支持 name/type/
///   personCount；不暴露 tripId/description，因为后端对这两个字段的处理
///   仍存在已知限制：tripId 不会被 controller 透传，description 无对应列）。
/// - 修改清单状态推荐调用 [updateEquipmentListStatus]（对应专用端点
///   `PATCH /equipment-lists/{id}/status`，语义更清晰）；后端 Int/String
///   类型解析 bug 已修复后，[updateEquipmentList] 通用接口传 status 字段
///   同样能生效，但目前客户端统一走专用端点以保持调用方式单一。
/// - 清单类型（type）创建后不支持修改，后端 `updateEquipmentList` 未处理
///   该字段，因此 [updateEquipmentList] 不暴露 type 参数。
/// - 清单本身不内嵌装备详情，需要通过 [getEquipmentListItems] 获取关联关系，
///   再按需通过 [getEquipmentItemById] 查询每个装备的详情。
class EquipmentService {
  // 禁止实例化
  EquipmentService._();

  // ==================== 装备单品 ====================

  /// 分页获取装备单品列表
  static Future<EquipmentPageResult<EquipmentItemModel>> getEquipmentItems({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.equipmentItems,
        queryParameters: {
          'page': page,
          'size': size,
        },
      );
      return _parsePagedResponse(response.data, EquipmentItemModel.fromJson);
    } catch (e) {
      debugPrint('EquipmentService: 获取装备单品列表失败: $e');
      if (e is ApiException) rethrow;
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 多条件搜索装备单品
  static Future<EquipmentPageResult<EquipmentItemModel>> searchEquipmentItems({
    String? keyword,
    EquipmentCategory? category,
    double? minWeight,
    double? maxWeight,
    EquipmentWeightUnit? weightUnit,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.equipmentItemSearch,
        queryParameters: {
          if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
          if (category != null) 'category': category.toCode(),
          if (minWeight != null) 'minWeight': minWeight,
          if (maxWeight != null) 'maxWeight': maxWeight,
          if (weightUnit != null) 'weightUnit': weightUnit.toCode(),
          'page': page,
          'size': size,
        },
      );
      return _parsePagedResponse(response.data, EquipmentItemModel.fromJson);
    } catch (e) {
      debugPrint('EquipmentService: 搜索装备单品失败: $e');
      if (e is ApiException) rethrow;
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 获取装备单品详情
  static Future<EquipmentItemModel> getEquipmentItemById(String itemId) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.equipmentItemDetail(itemId),
      );
      final data = unwrapResponse(response.data as Map<String, dynamic>);
      return EquipmentItemModel.fromJson(data);
    } catch (e) {
      debugPrint('EquipmentService: 获取装备详情失败: $e');
      if (e is ApiException) rethrow;
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 创建装备单品
  static Future<EquipmentItemModel> createEquipmentItem(
    EquipmentItemUpsertRequest request,
  ) async {
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.equipmentItems,
        data: request.toJson(),
      );
      final data = unwrapResponse(response.data as Map<String, dynamic>);
      return EquipmentItemModel.fromJson(data);
    } catch (e) {
      debugPrint('EquipmentService: 创建装备失败: $e');
      if (e is ApiException) rethrow;
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 更新装备单品
  static Future<EquipmentItemModel> updateEquipmentItem(
    String itemId,
    EquipmentItemUpsertRequest request,
  ) async {
    try {
      final response = await ApiClient.instance.put(
        ApiEndpoints.equipmentItemDetail(itemId),
        data: request.toJson(),
      );
      final data = unwrapResponse(response.data as Map<String, dynamic>);
      return EquipmentItemModel.fromJson(data);
    } catch (e) {
      debugPrint('EquipmentService: 更新装备失败: $e');
      if (e is ApiException) rethrow;
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 删除装备单品
  static Future<void> deleteEquipmentItem(String itemId) async {
    try {
      await ApiClient.instance.delete(
        ApiEndpoints.equipmentItemDetail(itemId),
      );
    } catch (e) {
      debugPrint('EquipmentService: 删除装备失败: $e');
      if (e is ApiException) rethrow;
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 获取装备分类统计
  ///
  /// 后端返回 `List<Array<Any>>`（每项形如 `[category, count]`），
  /// 这里转换为 `{分类: 数量}` 的 Map，key 为 [EquipmentCategory]。
  static Future<Map<EquipmentCategory, int>> getCategoryStats() async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.equipmentCategoryStats,
      );
      final list = unwrapResponseList(response.data as Map<String, dynamic>);
      final result = <EquipmentCategory, int>{};
      for (final row in list) {
        if (row is List && row.length >= 2) {
          final category = equipmentCategoryFromCode(
            row[0] is int ? row[0] : int.tryParse(row[0].toString()),
          );
          final count = (row[1] as num?)?.toInt() ?? 0;
          result[category] = count;
        }
      }
      return result;
    } catch (e) {
      debugPrint('EquipmentService: 获取分类统计失败: $e');
      if (e is ApiException) rethrow;
      throw ApiExceptionFactory.fromException(e);
    }
  }

  // ==================== 装备清单 ====================

  /// 分页获取装备清单列表
  ///
  /// [status] 不传时后端默认取当前登录用户创建的清单。
  static Future<EquipmentPageResult<EquipmentListModel>> getEquipmentLists({
    EquipmentListType? type,
    EquipmentListStatus? status,
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.equipmentLists,
        queryParameters: {
          if (type != null) 'type': type.toCode(),
          if (status != null) 'status': status.toCode(),
          'page': page,
          'size': size,
        },
      );
      return _parsePagedResponse(response.data, EquipmentListModel.fromJson);
    } catch (e) {
      debugPrint('EquipmentService: 获取装备清单列表失败: $e');
      if (e is ApiException) rethrow;
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 获取指定行程关联的所有装备清单（分页）
  ///
  /// 对应后端新增接口 `GET /trips/{id}/equipment-lists`（trip-equipment-link）。
  static Future<EquipmentPageResult<EquipmentListModel>> getEquipmentListsByTrip(
    String tripId, {
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.tripEquipmentLists(tripId),
        queryParameters: {
          'page': page,
          'size': size,
        },
      );
      return _parsePagedResponse(response.data, EquipmentListModel.fromJson);
    } catch (e) {
      debugPrint('EquipmentService: 获取行程关联装备清单失败: $e');
      if (e is ApiException) rethrow;
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 获取装备清单详情
  static Future<EquipmentListModel> getEquipmentListById(String listId) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.equipmentListDetail(listId),
      );
      final data = unwrapResponse(response.data as Map<String, dynamic>);
      return EquipmentListModel.fromJson(data);
    } catch (e) {
      debugPrint('EquipmentService: 获取装备清单详情失败: $e');
      if (e is ApiException) rethrow;
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 创建装备清单
  ///
  /// 只支持 [EquipmentListCreateRequestModel] 暴露的 name/personCount，
  /// 见该类注释中记录的后端已知限制。
  static Future<EquipmentListModel> createEquipmentList(
    EquipmentListCreateRequestModel request,
  ) async {
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.equipmentLists,
        data: request.toJson(),
      );
      final data = unwrapResponse(response.data as Map<String, dynamic>);
      return EquipmentListModel.fromJson(data);
    } catch (e) {
      debugPrint('EquipmentService: 创建装备清单失败: $e');
      if (e is ApiException) rethrow;
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 更新装备清单（支持 name/personCount/tripId；状态修改请调用
  /// [updateEquipmentListStatus]，类型（type）创建后不支持修改）
  ///
  /// [tripId] 用于将一个已存在的清单关联到某个行程（或更换关联的行程）。
  /// 注意：暂不支持传 `null` 来解除关联，省略该参数则保持原有关联不变。
  static Future<EquipmentListModel> updateEquipmentList(
    String listId, {
    String? name,
    int? personCount,
    String? tripId,
  }) async {
    try {
      final response = await ApiClient.instance.put(
        ApiEndpoints.equipmentListDetail(listId),
        data: {
          if (name != null) 'name': name,
          if (personCount != null) 'personCount': personCount,
          if (tripId != null) 'tripId': tripId,
        },
      );
      final data = unwrapResponse(response.data as Map<String, dynamic>);
      return EquipmentListModel.fromJson(data);
    } catch (e) {
      debugPrint('EquipmentService: 更新装备清单失败: $e');
      if (e is ApiException) rethrow;
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 更新装备清单状态（唯一能生效的状态修改方式，对应专用端点 PATCH .../status）
  static Future<EquipmentListModel> updateEquipmentListStatus(
    String listId,
    EquipmentListStatus status,
  ) async {
    try {
      final response = await ApiClient.instance.patch(
        ApiEndpoints.equipmentListStatus(listId),
        data: {'status': status.toCode()},
      );
      final data = unwrapResponse(response.data as Map<String, dynamic>);
      return EquipmentListModel.fromJson(data);
    } catch (e) {
      debugPrint('EquipmentService: 更新装备清单状态失败: $e');
      if (e is ApiException) rethrow;
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 删除装备清单
  static Future<void> deleteEquipmentList(String listId) async {
    try {
      await ApiClient.instance.delete(
        ApiEndpoints.equipmentListDetail(listId),
      );
    } catch (e) {
      debugPrint('EquipmentService: 删除装备清单失败: $e');
      if (e is ApiException) rethrow;
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 获取装备清单的统计信息（后端返回结构较自由的 Map，原样透传）
  static Future<Map<String, dynamic>> getEquipmentListStatistics(
    String listId,
  ) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.equipmentListStatistics(listId),
      );
      return unwrapResponse(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('EquipmentService: 获取装备清单统计失败: $e');
      if (e is ApiException) rethrow;
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 获取装备清单的重量统计
  ///
  /// 后端返回 `{listId, totalWeight, totalQuantity, categoryStats,
  /// categoryWeightDistribution}`，原样透传为 Map，由调用方按需取值。
  static Future<Map<String, dynamic>> getEquipmentListWeightStats(
    String listId,
  ) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.equipmentListWeightStats(listId),
      );
      return unwrapResponse(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('EquipmentService: 获取装备清单重量统计失败: $e');
      if (e is ApiException) rethrow;
      throw ApiExceptionFactory.fromException(e);
    }
  }

  // ==================== 装备清单内的装备条目 ====================

  /// 获取装备清单内的装备条目关联列表（不含装备详情，只有 ID/数量/备注）
  static Future<List<EquipmentListItemModel>> getEquipmentListItems(
    String listId, {
    int page = 0,
    int size = 50,
  }) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.equipmentListItems(listId),
        queryParameters: {
          'page': page,
          'size': size,
        },
      );
      final list = unwrapResponseList(response.data as Map<String, dynamic>);
      return list
          .map((e) =>
              EquipmentListItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('EquipmentService: 获取清单装备条目失败: $e');
      if (e is ApiException) rethrow;
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 向清单中添加装备
  static Future<EquipmentListItemModel> addEquipmentToList(
    String listId, {
    required String equipmentItemId,
    int quantity = 1,
    String? notes,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.equipmentListItems(listId),
        data: {
          'equipmentItemId': equipmentItemId,
          'quantity': quantity,
          if (notes != null) 'notes': notes,
        },
      );
      final data = unwrapResponse(response.data as Map<String, dynamic>);
      return EquipmentListItemModel.fromJson(data);
    } catch (e) {
      debugPrint('EquipmentService: 添加装备到清单失败: $e');
      if (e is ApiException) rethrow;
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 更新清单内某个装备条目的数量/备注
  static Future<EquipmentListItemModel> updateEquipmentInList(
    String listId,
    String equipmentItemId, {
    int? quantity,
    String? notes,
  }) async {
    try {
      final response = await ApiClient.instance.put(
        ApiEndpoints.equipmentListItemDetail(listId, equipmentItemId),
        data: {
          if (quantity != null) 'quantity': quantity,
          if (notes != null) 'notes': notes,
        },
      );
      final data = unwrapResponse(response.data as Map<String, dynamic>);
      return EquipmentListItemModel.fromJson(data);
    } catch (e) {
      debugPrint('EquipmentService: 更新清单装备条目失败: $e');
      if (e is ApiException) rethrow;
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 从清单中移除装备
  static Future<void> removeEquipmentFromList(
    String listId,
    String equipmentItemId,
  ) async {
    try {
      await ApiClient.instance.delete(
        ApiEndpoints.equipmentListItemDetail(listId, equipmentItemId),
      );
    } catch (e) {
      debugPrint('EquipmentService: 从清单移除装备失败: $e');
      if (e is ApiException) rethrow;
      throw ApiExceptionFactory.fromException(e);
    }
  }

  // ==================== 内部工具方法 ====================

  /// 解析分页响应，`data` 字段本身即为 Spring `Page` 结构
  static EquipmentPageResult<T> _parsePagedResponse<T>(
    dynamic responseData,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final data = unwrapResponse(responseData as Map<String, dynamic>);
    if (data.isEmpty) return EquipmentPageResult.empty<T>();
    return EquipmentPageResult.fromJson(
      data,
      fromJson,
    );
  }
}
