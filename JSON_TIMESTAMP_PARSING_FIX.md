# JSON 时间戳解析修复总结

## 问题描述

在使用 `json_annotation` 进行 JSON 序列化时，以下几个模型的 `created_at` 和 `updated_at` 字段解析方法不正确：

- `WaterSourceModel`
- `SupplyPointModel`
- `CampsiteModel`
- `HitchhikeContactModel`

这些模型没有使用统一的时间戳解析方法，导致在处理不同格式的时间戳时可能出现解析错误。

## 解决方案

### 1. 创建统一的工具类

创建了 `lib/utils/json_utils.dart` 工具类，提供统一的时间戳解析和转换方法：

```dart
class JsonUtils {
  /// 解析时间戳（支持秒和毫秒）
  static DateTime? parseTimestamp(dynamic timestamp) {
    // 支持 int、String、null 等多种格式
    // 自动判断秒/毫秒时间戳
    // 支持 ISO 8601 格式字符串
  }

  /// 时间戳转JSON（输出毫秒时间戳）
  static int? timestampToJson(DateTime? dateTime) {
    return dateTime?.millisecondsSinceEpoch;
  }
}
```

### 2. 修复模型定义

为每个模型添加正确的 `@JsonKey` 注解：

#### WaterSourceModel
```dart
@JsonKey(name: 'created_at', fromJson: JsonUtils.parseTimestamp, toJson: JsonUtils.timestampToJson)
final DateTime? createdAt;

@JsonKey(name: 'updated_at', fromJson: JsonUtils.parseTimestamp, toJson: JsonUtils.timestampToJson)
final DateTime? updatedAt;

@JsonKey(name: 'last_verified', fromJson: JsonUtils.parseTimestamp, toJson: JsonUtils.timestampToJson)
final DateTime? lastVerified;
```

#### SupplyPointModel
```dart
@JsonKey(name: 'created_at', fromJson: JsonUtils.parseTimestamp, toJson: JsonUtils.timestampToJson)
final DateTime? createdAt;

@JsonKey(name: 'updated_at', fromJson: JsonUtils.parseTimestamp, toJson: JsonUtils.timestampToJson)
final DateTime? updatedAt;
```

#### CampsiteModel
```dart
@JsonKey(name: 'created_at', fromJson: JsonUtils.parseTimestamp, toJson: JsonUtils.timestampToJson)
final DateTime? createdAt;

@JsonKey(name: 'updated_at', fromJson: JsonUtils.parseTimestamp, toJson: JsonUtils.timestampToJson)
final DateTime? updatedAt;
```

#### HitchhikeContactModel
```dart
// 新增时间字段
@JsonKey(name: 'created_at', fromJson: JsonUtils.parseTimestamp, toJson: JsonUtils.timestampToJson)
final DateTime? createdAt;

@JsonKey(name: 'updated_at', fromJson: JsonUtils.parseTimestamp, toJson: JsonUtils.timestampToJson)
final DateTime? updatedAt;
```

### 3. 重新生成代码

运行代码生成命令：
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## 修复结果

### 生成的代码验证

修复后，生成的 JSON 序列化代码正确使用了 `JsonUtils` 方法：

```dart
// fromJson 方法
createdAt: JsonUtils.parseTimestamp(json['created_at']),
updatedAt: JsonUtils.parseTimestamp(json['updated_at']),

// toJson 方法
'created_at': JsonUtils.timestampToJson(instance.createdAt),
'updated_at': JsonUtils.timestampToJson(instance.updatedAt),
```

### 支持的时间戳格式

现在这些模型可以正确处理以下格式的时间戳：

1. **整数时间戳**：
   - 秒级时间戳：`1640995200`
   - 毫秒级时间戳：`1640995200000`

2. **字符串时间戳**：
   - 数字字符串：`"1640995200"`
   - ISO 8601 格式：`"2024-01-15T08:45:00.000Z"`

3. **null 值**：返回 `null`

## 优势

1. **统一性**：所有模型使用相同的时间戳解析逻辑
2. **灵活性**：支持多种时间戳格式
3. **可维护性**：集中管理时间戳解析逻辑，便于后续修改
4. **扩展性**：`JsonUtils` 类还提供了其他常用的解析方法
5. **向后兼容**：不影响现有的 JSON 数据格式

## 注意事项

1. 所有使用这些模型的地方无需修改代码
2. JSON 输出格式保持一致（毫秒时间戳）
3. 如果需要添加新的时间字段，请使用相同的注解格式
4. 工具类位于 `lib/utils/json_utils.dart`，可以在其他模型中复用
