import 'package:json_annotation/json_annotation.dart';
import '../base/base_model.dart';

part 'search_history.g.dart';

/// 搜索历史模型
@JsonSerializable()
class SearchHistory extends BaseModel {
  /// 关键词
  final String keyword;

  /// 时间戳
  final DateTime timestamp;

  /// 类型
  final String type;

  /// 构造函数
  SearchHistory({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.keyword,
    required this.timestamp,
    required this.type,
  });

  /// 从JSON创建
  factory SearchHistory.fromJson(Map<String, dynamic> json) =>
      _$SearchHistoryFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$SearchHistoryToJson(this);
}

/// 搜索历史响应模型
@JsonSerializable()
class SearchHistoryResponse {
  /// 搜索历史列表
  final List<SearchHistory> searchHistories;

  /// 构造函数
  SearchHistoryResponse({required this.searchHistories});

  /// 从JSON创建
  factory SearchHistoryResponse.fromJson(Map<String, dynamic> json) =>
      _$SearchHistoryResponseFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$SearchHistoryResponseToJson(this);
}
