import 'package:walk/core/network/api_exception.dart';

/// 统一响应解包工具
///
/// 后端统一返回 `{code, message, data}` 信封结构。这里提供共享的解包方法，
/// 避免各 Service 重复手写 `responseData['code'] != 200` 的样板代码。
///
/// 说明：[BusinessException] 的 `code` 字段为 `String?`，因此这里会把后端返回的
/// `code`（通常为 int）转换为字符串再传入，与既有异常体系保持一致。

/// 解包标准 `{code, message, data}` 信封，返回 `data` 字段（Map）。
///
/// 若 `code` 非 200，抛出 [BusinessException]。
/// `data` 为空时返回空 Map。
Map<String, dynamic> unwrapResponse(Map<String, dynamic> responseData) {
  final code = responseData['code'];
  final success = responseData['success'];
  if (code != 200 && code != 201 || success == false) {
    final message = responseData['message'] ?? 'Unknown error';
    throw BusinessException(message.toString(), code: code?.toString());
  }
  return responseData['data'] as Map<String, dynamic>? ?? {};
}

/// 解包并将 `data` 字段作为 List 返回。
///
/// 若 `code` 非 200，抛出 [BusinessException]。
/// `data` 不是 List 时返回空 List。
List<dynamic> unwrapResponseList(Map<String, dynamic> responseData) {
  final code = responseData['code'];
  final success = responseData['success'];
  if (code != 200 && code != 201 || success == false) {
    final message = responseData['message'] ?? 'Unknown error';
    throw BusinessException(message.toString(), code: code?.toString());
  }
  final data = responseData['data'];
  if (data is List) return data;
  return [];
}
