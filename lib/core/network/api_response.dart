import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

/// 统一API响应模型
///
/// 封装所有API响应的通用结构，包括：
/// - 状态码和消息
/// - 数据载荷
/// - 分页信息
/// - 错误详情
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  /// 响应状态码
  @JsonKey(name: 'code')
  final int code;

  /// 响应消息
  @JsonKey(name: 'message')
  final String message;

  /// 响应数据
  @JsonKey(name: 'data')
  final T? data;

  /// 分页信息
  @JsonKey(name: 'pagination')
  final PaginationInfo? pagination;

  /// 时间戳
  @JsonKey(name: 'timestamp')
  final int? timestamp;

  /// 请求ID（用于追踪）
  @JsonKey(name: 'request_id')
  final String? requestId;

  const ApiResponse({
    required this.code,
    required this.message,
    this.data,
    this.pagination,
    this.timestamp,
    this.requestId,
  });

  /// 是否成功
  bool get isSuccess => code >= 200 && code < 300;

  /// 是否失败
  bool get isFailure => !isSuccess;

  /// 创建成功响应
  factory ApiResponse.success({
    required T data,
    String message = 'Success',
    int code = 200,
    PaginationInfo? pagination,
    String? requestId,
  }) {
    return ApiResponse<T>(
      code: code,
      message: message,
      data: data,
      pagination: pagination,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      requestId: requestId,
    );
  }

  /// 创建错误响应
  factory ApiResponse.error({
    required String message,
    int code = 500,
    T? data,
    String? requestId,
  }) {
    return ApiResponse<T>(
      code: code,
      message: message,
      data: data,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      requestId: requestId,
    );
  }

  /// 从JSON创建
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);

  /// 转换为JSON
  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);

  @override
  String toString() {
    return 'ApiResponse{code: $code, message: $message, data: $data, pagination: $pagination}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiResponse &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          message == other.message &&
          data == other.data &&
          pagination == other.pagination;

  @override
  int get hashCode =>
      code.hashCode ^ message.hashCode ^ data.hashCode ^ pagination.hashCode;
}

/// 分页信息模型
@JsonSerializable()
class PaginationInfo {
  /// 当前页码
  @JsonKey(name: 'current_page')
  final int currentPage;

  /// 每页数量
  @JsonKey(name: 'per_page')
  final int perPage;

  /// 总数量
  @JsonKey(name: 'total')
  final int total;

  /// 总页数
  @JsonKey(name: 'total_pages')
  final int totalPages;

  /// 是否有下一页
  @JsonKey(name: 'has_next')
  final bool hasNext;

  /// 是否有上一页
  @JsonKey(name: 'has_prev')
  final bool hasPrev;

  const PaginationInfo({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  /// 从JSON创建
  factory PaginationInfo.fromJson(Map<String, dynamic> json) =>
      _$PaginationInfoFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$PaginationInfoToJson(this);

  @override
  String toString() {
    return 'PaginationInfo{currentPage: $currentPage, perPage: $perPage, total: $total, totalPages: $totalPages, hasNext: $hasNext, hasPrev: $hasPrev}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaginationInfo &&
          runtimeType == other.runtimeType &&
          currentPage == other.currentPage &&
          perPage == other.perPage &&
          total == other.total &&
          totalPages == other.totalPages &&
          hasNext == other.hasNext &&
          hasPrev == other.hasPrev;

  @override
  int get hashCode =>
      currentPage.hashCode ^
      perPage.hashCode ^
      total.hashCode ^
      totalPages.hashCode ^
      hasNext.hashCode ^
      hasPrev.hashCode;
}

/// 列表响应模型
///
/// 专门用于处理列表数据的响应
@JsonSerializable(genericArgumentFactories: true)
class ListResponse<T> {
  /// 列表数据
  @JsonKey(name: 'items')
  final List<T> items;

  /// 分页信息
  @JsonKey(name: 'pagination')
  final PaginationInfo? pagination;

  const ListResponse({
    required this.items,
    this.pagination,
  });

  /// 从JSON创建
  factory ListResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ListResponseFromJson(json, fromJsonT);

  /// 转换为JSON
  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$ListResponseToJson(this, toJsonT);

  @override
  String toString() {
    return 'ListResponse{items: ${items.length} items, pagination: $pagination}';
  }
}

/// API错误详情模型
@JsonSerializable()
class ApiErrorDetail {
  /// 错误代码
  @JsonKey(name: 'error_code')
  final String errorCode;

  /// 错误消息
  @JsonKey(name: 'error_message')
  final String errorMessage;

  /// 错误字段（用于表单验证错误）
  @JsonKey(name: 'field')
  final String? field;

  /// 错误详情
  @JsonKey(name: 'details')
  final Map<String, dynamic>? details;

  const ApiErrorDetail({
    required this.errorCode,
    required this.errorMessage,
    this.field,
    this.details,
  });

  /// 从JSON创建
  factory ApiErrorDetail.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorDetailFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$ApiErrorDetailToJson(this);

  @override
  String toString() {
    return 'ApiErrorDetail{errorCode: $errorCode, errorMessage: $errorMessage, field: $field}';
  }
}

/// 响应状态码常量
class ApiStatusCode {
  // 成功状态码
  static const int success = 200;
  static const int created = 201;
  static const int accepted = 202;
  static const int noContent = 204;

  // 客户端错误状态码
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int methodNotAllowed = 405;
  static const int conflict = 409;
  static const int unprocessableEntity = 422;
  static const int tooManyRequests = 429;

  // 服务器错误状态码
  static const int internalServerError = 500;
  static const int badGateway = 502;
  static const int serviceUnavailable = 503;
  static const int gatewayTimeout = 504;

  /// 判断是否为成功状态码
  static bool isSuccess(int code) => code >= 200 && code < 300;

  /// 判断是否为客户端错误
  static bool isClientError(int code) => code >= 400 && code < 500;

  /// 判断是否为服务器错误
  static bool isServerError(int code) => code >= 500 && code < 600;

  /// 获取状态码描述
  static String getDescription(int code) {
    switch (code) {
      case success:
        return '请求成功';
      case created:
        return '创建成功';
      case accepted:
        return '请求已接受';
      case noContent:
        return '无内容';
      case badRequest:
        return '请求参数错误';
      case unauthorized:
        return '未授权';
      case forbidden:
        return '禁止访问';
      case notFound:
        return '资源不存在';
      case methodNotAllowed:
        return '请求方法不允许';
      case conflict:
        return '资源冲突';
      case unprocessableEntity:
        return '请求参数验证失败';
      case tooManyRequests:
        return '请求过于频繁';
      case internalServerError:
        return '服务器内部错误';
      case badGateway:
        return '网关错误';
      case serviceUnavailable:
        return '服务不可用';
      case gatewayTimeout:
        return '网关超时';
      default:
        return '未知错误';
    }
  }
}
