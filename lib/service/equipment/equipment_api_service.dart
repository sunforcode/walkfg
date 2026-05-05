import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../../core/network/api_endpoints.dart';
import '../../model/equipment/equipment_item_model.dart';
import '../../model/equipment/equipment_list_model.dart';
import '../../model/equipment/equipment_list_type.dart';
import '../../model/equipment/equipment_list_status.dart';
import '../../model/equipment/equipment_template_model.dart';
import '../../model/equipment/user_equipment_inventory_model.dart';

class EquipmentApiService {
  static final EquipmentApiService _instance = EquipmentApiService._internal();
  factory EquipmentApiService() => _instance;
  EquipmentApiService._internal();

  ApiClient get _apiClient => ApiClient.instance;

  Map<String, dynamic> _extractResponseData(Map<String, dynamic> json) {
    final code = json['code'] as int?;
    final message = json['message'] as String?;
    final data = json['data'];

    if (code != null && code >= 200 && code < 300) {
      if (data is Map<String, dynamic>) {
        return data;
      } else if (data is List) {
        return {'content': data};
      }
      return {};
    }

    throw ApiException(
      code: code ?? 500,
      message: message ?? '未知错误',
    );
  }

  List<T> _extractList<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final data = _extractResponseData(json);
    
    List<dynamic>? items;
    if (data.containsKey('content')) {
      items = data['content'] as List<dynamic>?;
    } else if (data.containsKey('items')) {
      items = data['items'] as List<dynamic>?;
    } else {
      items = data.values.whereType<List<dynamic>>().firstOrNull;
    }
    
    if (items == null) {
      debugPrint('EquipmentApiService: 未找到列表数据，尝试直接解析');
      items = [data];
    }

    return items.map((item) => fromJson(item as Map<String, dynamic>)).toList();
  }

  int _extractTotal(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      return (data['totalElements'] as int?) ??
          (data['total'] as int?) ??
          (data['totalElements'] as int?) ??
          0;
    }
    return 0;
  }

  Future<List<EquipmentListModel>> getEquipmentLists({
    int page = 0,
    int size = 20,
    int? type,
    int? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };
      if (type != null) queryParams['type'] = type;
      if (status != null) queryParams['status'] = status;

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.equipmentLists,
        queryParameters: queryParams,
      );

      if (response.data == null) {
        throw const ApiException(code: 500, message: '响应数据为空');
      }

      return _extractList(response.data!, (json) {
        return _parseEquipmentListFromApiResponse(json);
      });
    } catch (e) {
      debugPrint('EquipmentApiService - 获取装备清单列表失败: $e');
      rethrow;
    }
  }

  Future<EquipmentListModel> getEquipmentListById(String id) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.equipmentListDetail(id),
      );

      if (response.data == null) {
        throw const ApiException(code: 500, message: '响应数据为空');
      }

      final data = _extractResponseData(response.data!);
      return _parseEquipmentListFromApiResponse(data);
    } catch (e) {
      debugPrint('EquipmentApiService - 获取装备清单详情失败: $e');
      rethrow;
    }
  }

  Future<EquipmentListModel> createEquipmentList({
    required String name,
    required int type,
    int personCount = 1,
    String? description,
    String? templateId,
  }) async {
    try {
      final requestData = <String, dynamic>{
        'name': name,
        'type': type,
        'personCount': personCount,
      };
      if (description != null) requestData['description'] = description;
      if (templateId != null) requestData['templateId'] = templateId;

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.equipmentLists,
        data: requestData,
      );

      if (response.data == null) {
        throw const ApiException(code: 500, message: '响应数据为空');
      }

      final data = _extractResponseData(response.data!);
      return _parseEquipmentListFromApiResponse(data);
    } catch (e) {
      debugPrint('EquipmentApiService - 创建装备清单失败: $e');
      rethrow;
    }
  }

  Future<EquipmentListModel> updateEquipmentList(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        ApiEndpoints.equipmentListDetail(id),
        data: updates,
      );

      if (response.data == null) {
        throw const ApiException(code: 500, message: '响应数据为空');
      }

      final data = _extractResponseData(response.data!);
      return _parseEquipmentListFromApiResponse(data);
    } catch (e) {
      debugPrint('EquipmentApiService - 更新装备清单失败: $e');
      rethrow;
    }
  }

  Future<void> deleteEquipmentList(String id) async {
    try {
      await _apiClient.delete(
        ApiEndpoints.equipmentListDetail(id),
      );
    } catch (e) {
      debugPrint('EquipmentApiService - 删除装备清单失败: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getListWeightStats(String listId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.equipmentListWeightStats(listId),
      );

      if (response.data == null) {
        throw const ApiException(code: 500, message: '响应数据为空');
      }

      return _extractResponseData(response.data!);
    } catch (e) {
      debugPrint('EquipmentApiService - 获取清单重量统计失败: $e');
      rethrow;
    }
  }

  Future<List<EquipmentItemModel>> getListItems(
    String listId, {
    int page = 0,
    int size = 50,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.equipmentListItems(listId),
        queryParameters: queryParams,
      );

      if (response.data == null) {
        throw const ApiException(code: 500, message: '响应数据为空');
      }

      return _extractList(response.data!, (json) {
        return EquipmentItemModel.fromJson(json);
      });
    } catch (e) {
      debugPrint('EquipmentApiService - 获取清单装备列表失败: $e');
      rethrow;
    }
  }

  Future<void> addItemToList({
    required String listId,
    required String equipmentItemId,
    int quantity = 1,
    String? notes,
  }) async {
    try {
      final requestData = <String, dynamic>{
        'equipmentItemId': equipmentItemId,
        'quantity': quantity,
      };
      if (notes != null) requestData['notes'] = notes;

      await _apiClient.post(
        ApiEndpoints.equipmentListItems(listId),
        data: requestData,
      );
    } catch (e) {
      debugPrint('EquipmentApiService - 添加装备到清单失败: $e');
      rethrow;
    }
  }

  Future<void> removeItemFromList(String listId, String itemId) async {
    try {
      await _apiClient.delete(
        ApiEndpoints.equipmentListItems(listId).replaceAll('/items', '/items/$itemId'),
      );
    } catch (e) {
      debugPrint('EquipmentApiService - 从清单移除装备失败: $e');
      rethrow;
    }
  }

  Future<List<EquipmentItemModel>> getEquipmentItems({
    int page = 0,
    int size = 20,
    String? keyword,
    int? category,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };
      if (keyword != null && keyword.isNotEmpty) {
        queryParams['keyword'] = keyword;
      }
      if (category != null) queryParams['category'] = category;

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.equipmentItems,
        queryParameters: queryParams,
      );

      if (response.data == null) {
        throw const ApiException(code: 500, message: '响应数据为空');
      }

      return _extractList(response.data!, (json) {
        return EquipmentItemModel.fromJson(json);
      });
    } catch (e) {
      debugPrint('EquipmentApiService - 获取装备物品列表失败: $e');
      rethrow;
    }
  }

  Future<EquipmentItemModel> getEquipmentItemById(String id) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.equipmentItemDetail(id),
      );

      if (response.data == null) {
        throw const ApiException(code: 500, message: '响应数据为空');
      }

      final data = _extractResponseData(response.data!);
      return EquipmentItemModel.fromJson(data);
    } catch (e) {
      debugPrint('EquipmentApiService - 获取装备物品详情失败: $e');
      rethrow;
    }
  }

  Future<EquipmentItemModel> createEquipmentItem({
    required String name,
    required int category,
    required double weight,
    int weightUnit = 0,
    int quantity = 1,
    String? description,
    String? brand,
    String? model,
    double? price,
  }) async {
    try {
      final requestData = <String, dynamic>{
        'name': name,
        'category': category,
        'weight': weight,
        'weightUnit': weightUnit,
        'quantity': quantity,
      };
      if (description != null) requestData['description'] = description;
      if (brand != null) requestData['brand'] = brand;
      if (model != null) requestData['model'] = model;
      if (price != null) requestData['price'] = price;

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.equipmentItems,
        data: requestData,
      );

      if (response.data == null) {
        throw const ApiException(code: 500, message: '响应数据为空');
      }

      final data = _extractResponseData(response.data!);
      return EquipmentItemModel.fromJson(data);
    } catch (e) {
      debugPrint('EquipmentApiService - 创建装备物品失败: $e');
      rethrow;
    }
  }

  Future<EquipmentItemModel> updateEquipmentItem(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        ApiEndpoints.equipmentItemDetail(id),
        data: updates,
      );

      if (response.data == null) {
        throw const ApiException(code: 500, message: '响应数据为空');
      }

      final data = _extractResponseData(response.data!);
      return EquipmentItemModel.fromJson(data);
    } catch (e) {
      debugPrint('EquipmentApiService - 更新装备物品失败: $e');
      rethrow;
    }
  }

  Future<void> deleteEquipmentItem(String id) async {
    try {
      await _apiClient.delete(
        ApiEndpoints.equipmentItemDetail(id),
      );
    } catch (e) {
      debugPrint('EquipmentApiService - 删除装备物品失败: $e');
      rethrow;
    }
  }

  Future<List<EquipmentTemplateModel>> getEquipmentTemplates({
    int page = 0,
    int size = 20,
    String? keyword,
    bool? isOfficial,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };
      if (keyword != null && keyword.isNotEmpty) {
        queryParams['keyword'] = keyword;
      }
      if (isOfficial != null) queryParams['isOfficial'] = isOfficial;

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.equipmentTemplates,
        queryParameters: queryParams,
      );

      if (response.data == null) {
        throw const ApiException(code: 500, message: '响应数据为空');
      }

      return _extractList(response.data!, (json) {
        return EquipmentTemplateModel.fromJson(json);
      });
    } catch (e) {
      debugPrint('EquipmentApiService - 获取装备模板列表失败: $e');
      rethrow;
    }
  }

  Future<EquipmentTemplateModel> getEquipmentTemplateById(String id) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.equipmentTemplateDetail(id),
      );

      if (response.data == null) {
        throw const ApiException(code: 500, message: '响应数据为空');
      }

      final data = _extractResponseData(response.data!);
      return EquipmentTemplateModel.fromJson(data);
    } catch (e) {
      debugPrint('EquipmentApiService - 获取装备模板详情失败: $e');
      rethrow;
    }
  }

  Future<List<EquipmentTemplateModel>> getOfficialTemplates({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.officialEquipmentTemplates,
        queryParameters: queryParams,
      );

      if (response.data == null) {
        throw const ApiException(code: 500, message: '响应数据为空');
      }

      return _extractList(response.data!, (json) {
        return EquipmentTemplateModel.fromJson(json);
      });
    } catch (e) {
      debugPrint('EquipmentApiService - 获取官方模板失败: $e');
      rethrow;
    }
  }

  EquipmentListModel _parseEquipmentListFromApiResponse(Map<String, dynamic> json) {
    final now = DateTime.now();
    
    return EquipmentListModel(
      id: json['id'] as String? ?? 'list_${now.millisecondsSinceEpoch}',
      name: json['name'] as String? ?? '未命名清单',
      description: json['description'] as String? ?? '',
      type: _parseListType(json['type']),
      routeId: json['routeId'] as String?,
      routeName: json['routeName'] as String?,
      tripId: json['tripId'] as String?,
      tripDays: json['tripDays'] as int? ?? 1,
      personCount: json['personCount'] as int? ?? 1,
      seasons: _parseSeasons(json['seasons']),
      equipments: _parseEquipmentItems(json['equipments']),
      totalWeight: _parseDouble(json['totalWeight']),
      baseWeight: _parseDouble(json['baseWeight']),
      consumableWeight: _parseDouble(json['consumableWeight']),
      wornWeight: _parseDouble(json['wornWeight']),
      creatorId: json['creatorId'] as String? ?? 'api_user',
      creatorName: json['creatorName'] as String? ?? 'API用户',
      tags: _parseStringList(json['tags']),
      isOfficial: json['isOfficial'] as bool? ?? false,
      isTemplate: json['isTemplate'] as bool? ?? false,
      templateId: json['templateId'] as String?,
      status: _parseListStatus(json['status']),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  EquipmentListType _parseListType(dynamic type) {
    if (type is int && type >= 0 && type < EquipmentListType.values.length) {
      return EquipmentListType.values[type];
    } else if (type is String) {
      return parseListTypeFromString(type);
    }
    return EquipmentListType.custom;
  }

  EquipmentListStatus _parseListStatus(dynamic status) {
    if (status is int && status >= 0 && status < EquipmentListStatus.values.length) {
      return EquipmentListStatus.values[status];
    } else if (status is String) {
      return parseListStatusFromString(status);
    }
    return EquipmentListStatus.planning;
  }

  List<SeasonSuitability> _parseSeasons(dynamic seasons) {
    if (seasons == null) return [SeasonSuitability.allSeasons];
    if (seasons is List) {
      return seasons.map((s) {
        if (s is int && s >= 0 && s < SeasonSuitability.values.length) {
          return SeasonSuitability.values[s];
        }
        return SeasonSuitability.allSeasons;
      }).toList();
    }
    return [SeasonSuitability.allSeasons];
  }

  List<EquipmentItemModel> _parseEquipmentItems(dynamic items) {
    if (items == null || items is! List) return [];
    return items.map((item) {
      if (item is Map<String, dynamic>) {
        return EquipmentItemModel.fromJson(item);
      }
      return null;
    }).whereType<EquipmentItemModel>().toList();
  }

  List<String> _parseStringList(dynamic list) {
    if (list == null || list is! List) return [];
    return list.map((s) => s.toString()).toList();
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  DateTime? _parseDateTime(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is int) {
      if (timestamp > 1000000000000) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
      return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    }
    if (timestamp is String) {
      return DateTime.tryParse(timestamp);
    }
    return null;
  }
}

class ApiException implements Exception {
  final int code;
  final String message;

  const ApiException({
    required this.code,
    required this.message,
  });

  @override
  String toString() => 'ApiException(code: $code, message: $message)';
}
