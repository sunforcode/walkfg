import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:walk/model/equipment/equipment_category.dart';
import 'package:walk/model/equipment/equipment_list_type.dart';
import 'package:walk/model/equipment/equipment_list_status.dart';
import 'package:walk/model/equipment/equipment_template_model.dart';
import 'package:walk/model/equipment/user_equipment_inventory_model.dart';
import '../model/equipment/equipment_list_model.dart';
import '../model/equipment/equipment_item_model.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import './equipment/equipment_api_service.dart';

enum DataSourceMode {
  auto,
  mock,
  api,
}

class EquipmentServiceConfig {
  static DataSourceMode _mode = DataSourceMode.auto;
  static bool _apiAvailable = true;
  
  static DataSourceMode get mode => _mode;
  static bool get isAutoMode => _mode == DataSourceMode.auto;
  static bool get apiAvailable => _apiAvailable;
  
  static void setMode(DataSourceMode mode) {
    _mode = mode;
  }
  
  static void setApiAvailable(bool available) {
    _apiAvailable = available;
  }
  
  static bool shouldUseApi() {
    switch (_mode) {
      case DataSourceMode.api:
        return true;
      case DataSourceMode.mock:
        return false;
      case DataSourceMode.auto:
      default:
        return _apiAvailable;
    }
  }
}

class EquipmentService {
  EquipmentService._();

  static final EquipmentApiService _apiService = EquipmentApiService();

  static List<EquipmentListModel>? _equipmentListsCache;
  static List<EquipmentTemplateModel>? _equipmentTemplatesCache;
  static final Map<String, UserEquipmentInventoryModel> _userEquipmentInventoryCache = {};

  static Future<dynamic> _loadJsonData(String path) async {
    try {
      final String jsonString = await rootBundle.loadString(path);
      return json.decode(jsonString);
    } catch (e) {
      print('加载JSON文件失败: $e');
      return null;
    }
  }

  static Future<T> _tryApiOrFallback<T>(
    Future<T> Function() apiCall,
    Future<T> Function() fallbackCall, {
    String? operationName,
  }) async {
    if (!EquipmentServiceConfig.shouldUseApi()) {
      return fallbackCall();
    }

    try {
      return await apiCall();
    } catch (e) {
      print('API调用失败 [$operationName]: $e，回退到模拟数据');
      
      if (EquipmentServiceConfig.isAutoMode) {
        EquipmentServiceConfig.setApiAvailable(false);
      }
      
      return fallbackCall();
    }
  }

  static Future<List<EquipmentListModel>> _getEquipmentListsFromMock() async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (_equipmentListsCache != null) {
      return _equipmentListsCache!;
    }
    final equipmentListsJson =
        await _loadJsonData('assets/mock_data/equipment_lists.json');
    _equipmentListsCache = equipmentListsJson
        .map<EquipmentListModel>((json) => EquipmentListModel.fromJson(json))
        .toList();
    return _equipmentListsCache!;
  }

  static Future<List<EquipmentListModel>> getEquipmentLists() async {
    return _tryApiOrFallback(
      () async {
        final lists = await _apiService.getEquipmentLists(page: 0, size: 100);
        _equipmentListsCache = lists;
        return lists;
      },
      _getEquipmentListsFromMock,
      operationName: 'getEquipmentLists',
    );
  }

  static Future<EquipmentListModel> _getEquipmentListByIdFromMock(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final lists = await _getEquipmentListsFromMock();
    final equipmentList = lists.firstWhere(
      (list) => list.id == id,
      orElse: () => throw Exception('装备清单不存在: $id'),
    );
    return equipmentList;
  }

  static Future<EquipmentListModel> getEquipmentListById(String id) async {
    return _tryApiOrFallback(
      () => _apiService.getEquipmentListById(id),
      () => _getEquipmentListByIdFromMock(id),
      operationName: 'getEquipmentListById',
    );
  }

  static Future<List<EquipmentListModel>> getRecommendedEquipmentLists(
      {int limit = 10}) async {
    return _tryApiOrFallback(
      () async {
        final lists = await _apiService.getEquipmentLists(page: 0, size: limit);
        final recommendedLists = List<EquipmentListModel>.from(lists)..shuffle();
        return recommendedLists.length > limit
            ? recommendedLists.sublist(0, limit)
            : recommendedLists;
      },
      () => _getRecommendedEquipmentListsFromMock(limit: limit),
      operationName: 'getRecommendedEquipmentLists',
    );
  }

  static Future<List<EquipmentListModel>> _getRecommendedEquipmentListsFromMock(
      {int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final lists = await _getEquipmentListsFromMock();
    final recommendedLists = List<EquipmentListModel>.from(lists)..shuffle();
    if (recommendedLists.length > limit) {
      return recommendedLists.sublist(0, limit);
    }
    return recommendedLists;
  }

  static Future<List<EquipmentListModel>> getOfficialEquipmentLists(
      {int limit = 10}) async {
    return _tryApiOrFallback(
      () async {
        final templates = await _apiService.getOfficialTemplates(page: 0, size: limit);
        final now = DateTime.now();
        return templates.map((t) => t.createEquipmentList(
          id: 'official_${t.id}_${now.millisecondsSinceEpoch}',
          creatorId: 'official',
          creatorName: '官方',
          tripDays: 1,
        )).toList();
      },
      () => _getOfficialEquipmentListsFromMock(limit: limit),
      operationName: 'getOfficialEquipmentLists',
    );
  }

  static Future<List<EquipmentListModel>> _getOfficialEquipmentListsFromMock(
      {int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final lists = await _getEquipmentListsFromMock();
    final officialLists = lists.where((list) => list.isOfficial).toList();
    if (officialLists.length > limit) {
      return officialLists.sublist(0, limit);
    }
    return officialLists;
  }

  static Future<List<EquipmentListModel>> getUserEquipmentLists(
      {int limit = 10}) async {
    return _tryApiOrFallback(
      () async {
        final lists = await _apiService.getEquipmentLists(
          page: 0, 
          size: limit,
          type: 0,
        );
        return lists;
      },
      () => _getUserEquipmentListsFromMock(limit: limit),
      operationName: 'getUserEquipmentLists',
    );
  }

  static Future<List<EquipmentListModel>> _getUserEquipmentListsFromMock(
      {int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final lists = await _getEquipmentListsFromMock();
    final userLists = lists.where((list) => !list.isOfficial).toList();
    if (userLists.length > limit) {
      return userLists.sublist(0, limit);
    }
    return userLists;
  }

  static Future<List<EquipmentListModel>> searchEquipmentLists(String keyword,
      {int limit = 10}) async {
    return _tryApiOrFallback(
      () async {
        final lists = await _apiService.getEquipmentLists(
          page: 0, 
          size: limit,
        );
        
        if (keyword.isEmpty) {
          return lists.length > limit ? lists.sublist(0, limit) : lists;
        }

        final searchResults = lists.where((list) {
          return list.name.toLowerCase().contains(keyword.toLowerCase()) ||
              list.description.toLowerCase().contains(keyword.toLowerCase()) ||
              list.tags
                  .any((tag) => tag.toLowerCase().contains(keyword.toLowerCase()));
        }).toList();

        return searchResults.length > limit
            ? searchResults.sublist(0, limit)
            : searchResults;
      },
      () => _searchEquipmentListsFromMock(keyword, limit: limit),
      operationName: 'searchEquipmentLists',
    );
  }

  static Future<List<EquipmentListModel>> _searchEquipmentListsFromMock(String keyword,
      {int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final lists = await _getEquipmentListsFromMock();

    if (keyword.isEmpty) {
      return lists.length > limit ? lists.sublist(0, limit) : lists;
    }

    final searchResults = lists.where((list) {
      return list.name.toLowerCase().contains(keyword.toLowerCase()) ||
          list.description.toLowerCase().contains(keyword.toLowerCase()) ||
          list.tags
              .any((tag) => tag.toLowerCase().contains(keyword.toLowerCase()));
    }).toList();

    if (searchResults.length > limit) {
      return searchResults.sublist(0, limit);
    }
    return searchResults;
  }

  static Future<EquipmentListModel> _createEquipmentListFromMock(
      EquipmentListModel equipmentList) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final now = DateTime.now();
    final newId = 'equipment_${now.millisecondsSinceEpoch}';

    final newEquipmentList = equipmentList.copyWith(
      id: newId,
      createdAt: now,
      updatedAt: now,
    );

    if (_equipmentListsCache != null) {
      _equipmentListsCache = [..._equipmentListsCache!, newEquipmentList];
    }

    return newEquipmentList;
  }

  static Future<EquipmentListModel> createEquipmentList(
      EquipmentListModel equipmentList) async {
    return _tryApiOrFallback(
      () async {
        final created = await _apiService.createEquipmentList(
          name: equipmentList.name,
          type: equipmentList.type.index,
          personCount: equipmentList.personCount,
          description: equipmentList.description,
        );
        
        if (_equipmentListsCache != null) {
          _equipmentListsCache = [..._equipmentListsCache!, created];
        }
        return created;
      },
      () => _createEquipmentListFromMock(equipmentList),
      operationName: 'createEquipmentList',
    );
  }

  static Future<EquipmentListModel> _updateEquipmentListFromMock(
      EquipmentListModel equipmentList) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final updatedEquipmentList = equipmentList.copyWith(
      updatedAt: DateTime.now(),
    );

    if (_equipmentListsCache != null) {
      _equipmentListsCache = _equipmentListsCache!
          .map((list) =>
              list.id == updatedEquipmentList.id ? updatedEquipmentList : list)
          .toList();
    }

    return updatedEquipmentList;
  }

  static Future<EquipmentListModel> updateEquipmentList(
      EquipmentListModel equipmentList) async {
    return _tryApiOrFallback(
      () async {
        final updates = <String, dynamic>{
          'name': equipmentList.name,
          'description': equipmentList.description,
          'personCount': equipmentList.personCount,
          'status': equipmentList.status.index,
        };
        
        final updated = await _apiService.updateEquipmentList(equipmentList.id, updates);
        return updated;
      },
      () => _updateEquipmentListFromMock(equipmentList),
      operationName: 'updateEquipmentList',
    );
  }

  static Future<bool> _deleteEquipmentListFromMock(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (_equipmentListsCache != null) {
      _equipmentListsCache =
          _equipmentListsCache!.where((list) => list.id != id).toList();
    }
    return true;
  }

  static Future<bool> deleteEquipmentList(String id) async {
    return _tryApiOrFallback(
      () async {
        await _apiService.deleteEquipmentList(id);
        if (_equipmentListsCache != null) {
          _equipmentListsCache =
              _equipmentListsCache!.where((list) => list.id != id).toList();
        }
        return true;
      },
      () => _deleteEquipmentListFromMock(id),
      operationName: 'deleteEquipmentList',
    );
  }

  static Future<EquipmentListModel> addEquipmentItem(
      String equipmentListId, EquipmentItemModel item) async {
    return _tryApiOrFallback(
      () async {
        await _apiService.addItemToList(
          listId: equipmentListId,
          equipmentItemId: item.id,
          quantity: item.quantity,
        );
        return getEquipmentListById(equipmentListId);
      },
      () => _addEquipmentItemFromMock(equipmentListId, item),
      operationName: 'addEquipmentItem',
    );
  }

  static Future<EquipmentListModel> _addEquipmentItemFromMock(
      String equipmentListId, EquipmentItemModel item) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final equipmentList = await _getEquipmentListByIdFromMock(equipmentListId);
    final updatedEquipments = [...equipmentList.equipments, item];
    final updatedEquipmentList = equipmentList.copyWith(
      equipments: updatedEquipments,
      updatedAt: DateTime.now(),
    );

    if (_equipmentListsCache != null) {
      _equipmentListsCache = _equipmentListsCache!
          .map((list) =>
              list.id == equipmentListId ? updatedEquipmentList : list)
          .toList();
    }

    return updatedEquipmentList;
  }

  static Future<EquipmentListModel> updateEquipmentItem(
      String equipmentListId, EquipmentItemModel item) async {
    return _tryApiOrFallback(
      () async {
        final updates = <String, dynamic>{
          'name': item.name,
          'quantity': item.quantity,
          'weight': item.weight,
          'prepared': item.prepared,
        };
        
        return getEquipmentListById(equipmentListId);
      },
      () => _updateEquipmentItemFromMock(equipmentListId, item),
      operationName: 'updateEquipmentItem',
    );
  }

  static Future<EquipmentListModel> _updateEquipmentItemFromMock(
      String equipmentListId, EquipmentItemModel item) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final equipmentList = await _getEquipmentListByIdFromMock(equipmentListId);
    final updatedEquipments = equipmentList.equipments
        .map((existingItem) => existingItem.id == item.id ? item : existingItem)
        .toList();
    final updatedEquipmentList = equipmentList.copyWith(
      equipments: updatedEquipments,
      updatedAt: DateTime.now(),
    );

    if (_equipmentListsCache != null) {
      _equipmentListsCache = _equipmentListsCache!
          .map((list) =>
              list.id == equipmentListId ? updatedEquipmentList : list)
          .toList();
    }

    return updatedEquipmentList;
  }

  static Future<EquipmentListModel> removeEquipmentItem(
      String equipmentListId, String itemId) async {
    return _tryApiOrFallback(
      () async {
        await _apiService.removeItemFromList(equipmentListId, itemId);
        return getEquipmentListById(equipmentListId);
      },
      () => _removeEquipmentItemFromMock(equipmentListId, itemId),
      operationName: 'removeEquipmentItem',
    );
  }

  static Future<EquipmentListModel> _removeEquipmentItemFromMock(
      String equipmentListId, String itemId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final equipmentList = await _getEquipmentListByIdFromMock(equipmentListId);
    final updatedEquipments =
        equipmentList.equipments.where((item) => item.id != itemId).toList();
    final updatedEquipmentList = equipmentList.copyWith(
      equipments: updatedEquipments,
      updatedAt: DateTime.now(),
    );

    if (_equipmentListsCache != null) {
      _equipmentListsCache = _equipmentListsCache!
          .map((list) =>
              list.id == equipmentListId ? updatedEquipmentList : list)
          .toList();
    }

    return updatedEquipmentList;
  }

  static Future<List<EquipmentItemModel>> getEquipmentItems(
      String equipmentListId) async {
    return _tryApiOrFallback(
      () => _apiService.getListItems(equipmentListId, page: 0, size: 100),
      () => _getEquipmentItemsFromMock(equipmentListId),
      operationName: 'getEquipmentItems',
    );
  }

  static Future<List<EquipmentItemModel>> _getEquipmentItemsFromMock(
      String equipmentListId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final equipmentList = await _getEquipmentListByIdFromMock(equipmentListId);
    return equipmentList.equipments;
  }

  static Future<List<EquipmentTemplateModel>> _getEquipmentTemplatesFromMock(
      {int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (_equipmentTemplatesCache != null) {
      final templates = _equipmentTemplatesCache!;
      return templates.length > limit ? templates.sublist(0, limit) : templates;
    }

    try {
      final templatesJson =
          await _loadJsonData('assets/mock_data/equipment_templates.json');
      _equipmentTemplatesCache = templatesJson
          .map<EquipmentTemplateModel>(
              (json) => EquipmentTemplateModel.fromJson(json))
          .toList();

      final templates = _equipmentTemplatesCache!;
      return templates.length > limit ? templates.sublist(0, limit) : templates;
    } catch (e) {
      print('加载装备模板失败: $e');
      return [];
    }
  }

  static Future<List<EquipmentTemplateModel>> getEquipmentTemplates(
      {int limit = 10}) async {
    return _tryApiOrFallback(
      () async {
        final templates = await _apiService.getEquipmentTemplates(
          page: 0, 
          size: limit,
        );
        _equipmentTemplatesCache = templates;
        return templates;
      },
      () => _getEquipmentTemplatesFromMock(limit: limit),
      operationName: 'getEquipmentTemplates',
    );
  }

  static Future<EquipmentTemplateModel> _getEquipmentTemplateByIdFromMock(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final templates = await _getEquipmentTemplatesFromMock(limit: 1000);
    final template = templates.firstWhere(
      (template) => template.id == id,
      orElse: () => throw Exception('装备模板不存在: $id'),
    );
    return template;
  }

  static Future<EquipmentTemplateModel> getEquipmentTemplateById(String id) async {
    return _tryApiOrFallback(
      () => _apiService.getEquipmentTemplateById(id),
      () => _getEquipmentTemplateByIdFromMock(id),
      operationName: 'getEquipmentTemplateById',
    );
  }

  static Future<EquipmentListModel> updateEquipmentListStatus(
      String equipmentListId, EquipmentListStatus status) async {
    return _tryApiOrFallback(
      () async {
        final response = await _apiClient.dio.patch(
          ApiEndpoints.equipmentListStatus(equipmentListId),
          data: {'status': status.index},
        );
        
        if (response.statusCode == 200) {
          return getEquipmentListById(equipmentListId);
        }
        throw Exception('更新状态失败');
      },
      () => _updateEquipmentListStatusFromMock(equipmentListId, status),
      operationName: 'updateEquipmentListStatus',
    );
  }

  static Future<EquipmentListModel> _updateEquipmentListStatusFromMock(
      String equipmentListId, EquipmentListStatus status) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final equipmentList = await _getEquipmentListByIdFromMock(equipmentListId);
    final updatedEquipmentList = equipmentList.copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );

    if (_equipmentListsCache != null) {
      _equipmentListsCache = _equipmentListsCache!
          .map((list) =>
              list.id == equipmentListId ? updatedEquipmentList : list)
          .toList();
    }

    return updatedEquipmentList;
  }

  static Future<EquipmentListModel> updateEquipmentPreparedStatus(
      String equipmentListId, String itemId, bool prepared) async {
    return _tryApiOrFallback(
      () async {
        final equipmentList = await getEquipmentListById(equipmentListId);
        final updatedEquipments = equipmentList.equipments.map((item) {
          if (item.id == itemId) {
            return item.copyWith(prepared: prepared);
          }
          return item;
        }).toList();

        final updatedEquipmentList = equipmentList.copyWith(
          equipments: updatedEquipments,
          updatedAt: DateTime.now(),
        );

        if (_equipmentListsCache != null) {
          _equipmentListsCache = _equipmentListsCache!
              .map((list) =>
                  list.id == equipmentListId ? updatedEquipmentList : list)
              .toList();
        }

        return updatedEquipmentList;
      },
      () => _updateEquipmentPreparedStatusFromMock(equipmentListId, itemId, prepared),
      operationName: 'updateEquipmentPreparedStatus',
    );
  }

  static Future<EquipmentListModel> _updateEquipmentPreparedStatusFromMock(
      String equipmentListId, String itemId, bool prepared) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final equipmentList = await _getEquipmentListByIdFromMock(equipmentListId);
    final updatedEquipments = equipmentList.equipments.map((item) {
      if (item.id == itemId) {
        return item.copyWith(prepared: prepared);
      }
      return item;
    }).toList();

    final updatedEquipmentList = equipmentList.copyWith(
      equipments: updatedEquipments,
      updatedAt: DateTime.now(),
    );

    if (_equipmentListsCache != null) {
      _equipmentListsCache = _equipmentListsCache!
          .map((list) =>
              list.id == equipmentListId ? updatedEquipmentList : list)
          .toList();
    }

    return updatedEquipmentList;
  }

  static Future<EquipmentListStats> getEquipmentListStats(
      String equipmentListId) async {
    return _tryApiOrFallback(
      () async {
        final stats = await _apiService.getListWeightStats(equipmentListId);
        final equipmentList = await getEquipmentListById(equipmentListId);
        
        return EquipmentListStats(
          totalItems: equipmentList.totalItems,
          essentialItems: equipmentList.essentialItems,
          recommendedItems: equipmentList.recommendedItems,
          optionalItems: equipmentList.optionalItems,
          preparedItems: equipmentList.preparedItems,
          totalWeight: (stats['total_weight'] as num?)?.toDouble() ?? equipmentList.totalWeight,
          baseWeight: (stats['base_weight'] as num?)?.toDouble() ?? equipmentList.baseWeight,
          consumableWeight: (stats['consumable_weight'] as num?)?.toDouble() ?? equipmentList.consumableWeight,
          wornWeight: (stats['worn_weight'] as num?)?.toDouble() ?? equipmentList.wornWeight,
          weightPerPersonPerDay: (stats['weight_per_person_per_day'] as num?)?.toDouble() ?? equipmentList.weightPerPersonPerDay,
          totalValue: equipmentList.totalValue,
          ownedItems: equipmentList.ownedItems,
          itemsToBuy: equipmentList.itemsToBuy,
          valueToBuy: equipmentList.valueToBuy,
        );
      },
      () => _getEquipmentListStatsFromMock(equipmentListId),
      operationName: 'getEquipmentListStats',
    );
  }

  static Future<EquipmentListStats> _getEquipmentListStatsFromMock(
      String equipmentListId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final equipmentList = await _getEquipmentListByIdFromMock(equipmentListId);
    return EquipmentListStats(
      totalItems: equipmentList.totalItems,
      essentialItems: equipmentList.essentialItems,
      recommendedItems: equipmentList.recommendedItems,
      optionalItems: equipmentList.optionalItems,
      preparedItems: equipmentList.preparedItems,
      totalWeight: equipmentList.totalWeight,
      baseWeight: equipmentList.baseWeight,
      consumableWeight: equipmentList.consumableWeight,
      wornWeight: equipmentList.wornWeight,
      weightPerPersonPerDay: equipmentList.weightPerPersonPerDay,
      totalValue: equipmentList.totalValue,
      ownedItems: equipmentList.ownedItems,
      itemsToBuy: equipmentList.itemsToBuy,
      valueToBuy: equipmentList.valueToBuy,
    );
  }

  static Future<double> getEquipmentListPreparationProgress(
      String equipmentListId) async {
    return _tryApiOrFallback(
      () async {
        final equipmentList = await getEquipmentListById(equipmentListId);
        return equipmentList.preparationPercentage;
      },
      () => _getEquipmentListPreparationProgressFromMock(equipmentListId),
      operationName: 'getEquipmentListPreparationProgress',
    );
  }

  static Future<double> _getEquipmentListPreparationProgressFromMock(
      String equipmentListId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final equipmentList = await _getEquipmentListByIdFromMock(equipmentListId);
    return equipmentList.preparationPercentage;
  }

  static Future<List<EquipmentListModel>> getEquipmentListsByType(
      EquipmentListType type, {int limit = 10}) async {
    return _tryApiOrFallback(
      () async {
        final lists = await getEquipmentLists();
        final filteredLists = lists.where((list) => list.type == type).toList();
        return filteredLists.length > limit ? filteredLists.sublist(0, limit) : filteredLists;
      },
      () => _getEquipmentListsByTypeFromMock(type, limit: limit),
      operationName: 'getEquipmentListsByType',
    );
  }

  static Future<List<EquipmentListModel>> _getEquipmentListsByTypeFromMock(
      EquipmentListType type, {int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final lists = await _getEquipmentListsFromMock();
    final filteredLists = lists.where((list) => list.type == type).toList();
    return filteredLists.length > limit ? filteredLists.sublist(0, limit) : filteredLists;
  }

  static Future<List<EquipmentListModel>> getEquipmentListsByStatus(
      EquipmentListStatus status, {int limit = 10}) async {
    return _tryApiOrFallback(
      () async {
        final lists = await getEquipmentLists();
        final filteredLists = lists.where((list) => list.status == status).toList();
        return filteredLists.length > limit ? filteredLists.sublist(0, limit) : filteredLists;
      },
      () => _getEquipmentListsByStatusFromMock(status, limit: limit),
      operationName: 'getEquipmentListsByStatus',
    );
  }

  static Future<List<EquipmentListModel>> _getEquipmentListsByStatusFromMock(
      EquipmentListStatus status, {int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final lists = await _getEquipmentListsFromMock();
    final filteredLists = lists.where((list) => list.status == status).toList();
    return filteredLists.length > limit ? filteredLists.sublist(0, limit) : filteredLists;
  }

  static Future<EquipmentListModel> cloneEquipmentList(
      String equipmentListId, {String? newName}) async {
    return _tryApiOrFallback(
      () async {
        final equipmentList = await getEquipmentListById(equipmentListId);
        final now = DateTime.now();
        final newId = 'equipment_${now.millisecondsSinceEpoch}';
        final clonedEquipmentList = equipmentList.copyWith(
          id: newId,
          name: newName ?? '${equipmentList.name} (副本)',
          createdAt: now,
          updatedAt: now,
          isOfficial: false,
        );
        if (_equipmentListsCache != null) {
          _equipmentListsCache = [..._equipmentListsCache!, clonedEquipmentList];
        }
        return clonedEquipmentList;
      },
      () => _cloneEquipmentListFromMock(equipmentListId, newName: newName),
      operationName: 'cloneEquipmentList',
    );
  }

  static Future<EquipmentListModel> _cloneEquipmentListFromMock(
      String equipmentListId, {String? newName}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final equipmentList = await _getEquipmentListByIdFromMock(equipmentListId);
    final now = DateTime.now();
    final newId = 'equipment_${now.millisecondsSinceEpoch}';
    final clonedEquipmentList = equipmentList.copyWith(
      id: newId,
      name: newName ?? '${equipmentList.name} (副本)',
      createdAt: now,
      updatedAt: now,
      isOfficial: false,
    );
    if (_equipmentListsCache != null) {
      _equipmentListsCache = [..._equipmentListsCache!, clonedEquipmentList];
    }
    return clonedEquipmentList;
  }

  static Future<List<EquipmentTemplateModel>> getEquipmentTemplatesByType(
      EquipmentListType type, {int limit = 10}) async {
    return _tryApiOrFallback(
      () async {
        final templates = await getEquipmentTemplates(limit: 1000);
        final filteredTemplates = templates.where((template) => template.type == type).toList();
        return filteredTemplates.length > limit ? filteredTemplates.sublist(0, limit) : filteredTemplates;
      },
      () => _getEquipmentTemplatesByTypeFromMock(type, limit: limit),
      operationName: 'getEquipmentTemplatesByType',
    );
  }

  static Future<List<EquipmentTemplateModel>> _getEquipmentTemplatesByTypeFromMock(
      EquipmentListType type, {int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final templates = await _getEquipmentTemplatesFromMock(limit: 1000);
    final filteredTemplates = templates.where((template) => template.type == type).toList();
    return filteredTemplates.length > limit ? filteredTemplates.sublist(0, limit) : filteredTemplates;
  }

  static Future<EquipmentListModel> createEquipmentListFromTemplate(
    String templateId, {
    required String name,
    String? description,
    String? routeId,
    String? routeName,
    String? tripId,
    required int tripDays,
    int personCount = 1,
  }) async {
    return _tryApiOrFallback(
      () async {
        final template = await getEquipmentTemplateById(templateId);
        final now = DateTime.now();
        final newId = 'equipment_${now.millisecondsSinceEpoch}';
        final equipmentList = template.createEquipmentList(
          id: newId,
          creatorId: 'current_user',
          creatorName: '当前用户',
          routeId: routeId,
          routeName: routeName,
          tripId: tripId,
          tripDays: tripDays,
          personCount: personCount,
        );
        if (_equipmentListsCache != null) {
          _equipmentListsCache = [..._equipmentListsCache!, equipmentList];
        }
        return equipmentList;
      },
      () => _createEquipmentListFromTemplateFromMock(
        templateId,
        name: name,
        description: description,
        routeId: routeId,
        routeName: routeName,
        tripId: tripId,
        tripDays: tripDays,
        personCount: personCount,
      ),
      operationName: 'createEquipmentListFromTemplate',
    );
  }

  static Future<EquipmentListModel> _createEquipmentListFromTemplateFromMock(
    String templateId, {
    required String name,
    String? description,
    String? routeId,
    String? routeName,
    String? tripId,
    required int tripDays,
    int personCount = 1,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final template = await _getEquipmentTemplateByIdFromMock(templateId);
    final now = DateTime.now();
    final newId = 'equipment_${now.millisecondsSinceEpoch}';
    final equipmentList = template.createEquipmentList(
      id: newId,
      creatorId: 'current_user',
      creatorName: '当前用户',
      routeId: routeId,
      routeName: routeName,
      tripId: tripId,
      tripDays: tripDays,
      personCount: personCount,
    );
    if (_equipmentListsCache != null) {
      _equipmentListsCache = [..._equipmentListsCache!, equipmentList];
    }
    return equipmentList;
  }

  static Future<UserEquipmentInventoryModel> getUserEquipmentInventory(
      String userId) async {
    return _tryApiOrFallback(
      () async {
        if (_userEquipmentInventoryCache.containsKey(userId)) {
          return _userEquipmentInventoryCache[userId]!;
        }
        try {
          final inventoriesJson = await _loadJsonData('assets/mock_data/user_equipment_inventory.json');
          final inventories = inventoriesJson
              .map<UserEquipmentInventoryModel>(
                  (json) => UserEquipmentInventoryModel.fromJson(json))
              .toList();
          final inventory = inventories.firstWhere(
            (inventory) => inventory.userId == userId,
            orElse: () {
              final now = DateTime.now();
              return UserEquipmentInventoryModel(
                id: 'inventory_${now.millisecondsSinceEpoch}',
                userId: userId,
                equipments: [],
                lastUpdatedAt: now,
                createdAt: now,
                updatedAt: now,
              );
            },
          );
          _userEquipmentInventoryCache[userId] = inventory;
          return inventory;
        } catch (e) {
          final now = DateTime.now();
          return UserEquipmentInventoryModel(
            id: 'inventory_${now.millisecondsSinceEpoch}',
            userId: userId,
            equipments: [],
            lastUpdatedAt: now,
            createdAt: now,
            updatedAt: now,
          );
        }
      },
      () => _getUserEquipmentInventoryFromMock(userId),
      operationName: 'getUserEquipmentInventory',
    );
  }

  static Future<UserEquipmentInventoryModel> _getUserEquipmentInventoryFromMock(
      String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (_userEquipmentInventoryCache.containsKey(userId)) {
      return _userEquipmentInventoryCache[userId]!;
    }
    try {
      final inventoriesJson = await _loadJsonData('assets/mock_data/user_equipment_inventory.json');
      final inventories = inventoriesJson
          .map<UserEquipmentInventoryModel>(
              (json) => UserEquipmentInventoryModel.fromJson(json))
          .toList();
      final inventory = inventories.firstWhere(
        (inventory) => inventory.userId == userId,
        orElse: () {
          final now = DateTime.now();
          return UserEquipmentInventoryModel(
            id: 'inventory_${now.millisecondsSinceEpoch}',
            userId: userId,
            equipments: [],
            lastUpdatedAt: now,
            createdAt: now,
            updatedAt: now,
          );
        },
      );
      _userEquipmentInventoryCache[userId] = inventory;
      return inventory;
    } catch (e) {
      final now = DateTime.now();
      return UserEquipmentInventoryModel(
        id: 'inventory_${now.millisecondsSinceEpoch}',
        userId: userId,
        equipments: [],
        lastUpdatedAt: now,
        createdAt: now,
        updatedAt: now,
      );
    }
  }

  static Future<UserEquipmentInventoryModel> removeEquipmentFromInventory(
      String userId, String itemId) async {
    return _tryApiOrFallback(
      () async {
        final inventory = await getUserEquipmentInventory(userId);
        final now = DateTime.now();
        final updatedEquipments = inventory.equipments.where((item) => item.id != itemId).toList();
        final updatedInventory = inventory.copyWith(
          equipments: updatedEquipments,
          lastUpdatedAt: now,
          updatedAt: now,
        );
        _userEquipmentInventoryCache[userId] = updatedInventory;
        return updatedInventory;
      },
      () => _removeEquipmentFromInventoryFromMock(userId, itemId),
      operationName: 'removeEquipmentFromInventory',
    );
  }

  static Future<UserEquipmentInventoryModel> _removeEquipmentFromInventoryFromMock(
      String userId, String itemId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final inventory = await _getUserEquipmentInventoryFromMock(userId);
    final now = DateTime.now();
    final updatedEquipments = inventory.equipments.where((item) => item.id != itemId).toList();
    final updatedInventory = inventory.copyWith(
      equipments: updatedEquipments,
      lastUpdatedAt: now,
      updatedAt: now,
    );
    _userEquipmentInventoryCache[userId] = updatedInventory;
    return updatedInventory;
  }

  static ApiClient get _apiClient => ApiClient.instance;
}

class EquipmentListStats {
  final int totalItems;
  final int essentialItems;
  final int recommendedItems;
  final int optionalItems;
  final int preparedItems;
  final double totalWeight;
  final double baseWeight;
  final double consumableWeight;
  final double wornWeight;
  final double weightPerPersonPerDay;
  final double totalValue;
  final int ownedItems;
  final int itemsToBuy;
  final double valueToBuy;

  EquipmentListStats({
    required this.totalItems,
    required this.essentialItems,
    required this.recommendedItems,
    required this.optionalItems,
    required this.preparedItems,
    required this.totalWeight,
    required this.baseWeight,
    required this.consumableWeight,
    required this.wornWeight,
    required this.weightPerPersonPerDay,
    required this.totalValue,
    required this.ownedItems,
    required this.itemsToBuy,
    required this.valueToBuy,
  });
}
