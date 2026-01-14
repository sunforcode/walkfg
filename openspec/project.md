# Project Context

## Purpose
Walk 是一款专为徒步爱好者设计的移动应用，提供完整的户外徒步体验支持。

**核心目标**：
- 提供路线规划和发现功能，帮助用户找到合适的徒步路线
- 行程管理和记录，支持行程计划、实时追踪和回顾
- 装备管理系统，包含打包清单、重量计算和装备推荐
- 天气信息集成，为徒步活动提供天气预报支持
- 地图和轨迹功能，支持 GPX 导入/导出、离线地图

## Tech Stack
- **框架**: Flutter 3.x / Dart SDK >= 3.2.3
- **UI 风格**: Cupertino (iOS风格) 为主，自定义徒步主题
- **状态管理**: flutter_riverpod + riverpod_annotation (代码生成)
- **路由管理**: go_router
- **网络请求**: Dio (带拦截器链：认证、重试、日志、错误处理)
- **本地存储**: 
  - shared_preferences (简单键值存储)
  - sqflite (SQLite数据库)
  - hive + hive_flutter (NoSQL存储)
- **地图组件**: 
  - flutter_map (2D地图)
  - maplibre_gl (3D地图支持)
  - flutter_map_location_marker (位置标记)
- **轨迹处理**: gpx, polyline_codec, latlong2
- **JSON序列化**: json_annotation + json_serializable (代码生成)
- **依赖注入**: 自定义 ServiceLocator 单例模式

## Project Conventions

### Code Style
**命名规范**：
- 文件命名：下划线分隔 (`route_model.dart`)
- 类命名：大驼峰 (`RouteModel`)
- 变量/方法：小驼峰 (`routeName`)
- 常量：大写下划线 (`MAX_ROUTE_COUNT`)
- 私有成员：以下划线开头 (`_privateMethod`)

**JSON字段映射**：
- Dart 模型使用驼峰命名法 (camelCase)
- JSON 字段使用下划线命名法 (snake_case)
- 通过 `@JsonKey(name: 'field_name')` 进行映射

**枚举处理**：
- 枚举值使用整数类型，便于数据库存储和网络传输
- 使用 `@JsonValue()` 注解指定序列化值
- 提供扩展方法：`intValue`, `value`, `displayName`
- 支持 `fromInt()` 和 `fromString()` 工厂方法

**注释规范**：
- 类和重要方法必须添加文档注释
- 使用 `///` 进行文档注释（三斜杠）
- 复杂逻辑添加行内注释说明

### Architecture Patterns
**目录结构**：
```
lib/
├── app.dart               # 应用入口组件
├── main.dart              # 应用主入口
├── core/                  # 核心功能
│   ├── config/           # 应用配置
│   ├── constants/        # 常量定义
│   └── network/          # 网络层（ApiClient, 拦截器）
├── model/                 # 数据模型（按领域划分）
│   ├── base/             # 基础模型
│   ├── route/            # 路线模型
│   ├── trip/             # 行程模型
│   ├── equipment/        # 装备模型
│   ├── map/              # 地图模型
│   ├── weather/          # 天气模型
│   └── ...
├── service/              # 业务服务层
│   ├── impl/             # 真实服务实现
│   └── mock/             # Mock服务实现
├── services/             # 特定领域服务
│   ├── location/         # 位置服务
│   └── weather/          # 天气服务
├── theme/                # 主题和布局
│   └── theme/            # 颜色、样式定义
├── ui/                   # 表现层
│   ├── map/              # 地图相关组件
│   ├── page/             # 页面（按功能模块划分）
│   └── widget/           # 通用组件
└── utils/                # 工具类
```

**服务层模式**：
- 使用 ServiceLocator 单例进行服务注册和获取
- 支持 Mock/Real 服务切换（通过 `useMock` 配置）
- 服务接口与实现分离

**Widget 设计原则**：
- 单一职责：每个 Widget 只负责一个明确的功能
- 合理大小：单个 Widget 代码行数控制在 150 行以内
- 组件化：复杂 UI 拆分为多个小 Widget 组合
- 可复用：通用组件抽取为独立 Widget

### Testing Strategy
**测试结构**：
```
test/
├── unit/              # 单元测试
│   ├── models/       # 模型测试
│   ├── services/     # 服务测试
│   └── utils/        # 工具测试
├── widget/           # Widget测试
└── integration/      # 集成测试
```

**代码生成**：
```bash
# 生成 JSON 序列化代码
flutter packages pub run build_runner build

# 监听文件变化自动生成
flutter packages pub run build_runner watch
```

### Git Workflow
**提交前检查清单**：
- 代码格式化 (`flutter format .`)
- 静态分析通过 (`flutter analyze`)
- 单元测试通过 (`flutter test`)
- Widget 大小合理（<150行）
- 添加必要注释
- 遵循命名规范

## Domain Context
**核心领域模型**：
- **Route（路线）**: 户外徒步路线，包含分段、海拔、难度、水源点、营地等
- **Trip（行程）**: 实际的徒步行程记录
- **Equipment（装备）**: 徒步装备管理，支持清单、模板
- **Weather（天气）**: 天气预报和警报
- **Map（地图）**: 地图数据、轨迹点、标记点

**业务特点**：
- 支持多日行程规划
- 路线难度分级系统
- 水源点、补给点、营地等户外资源管理
- GPX/KML 轨迹文件处理
- 离线地图支持

## Important Constraints
- **Flutter SDK 版本**: >= 3.2.3 < 4.0.0
- **平台支持**: iOS、Android、Web
- **UI 风格**: Cupertino (iOS 风格) + 专业运动风格
- **设计系统**: 详见 `specs/design-system/spec.md`
- **字体**: SF Pro Text (系统字体)

## External Dependencies
**地图服务**：
- flutter_map (OpenStreetMap 等开源地图)
- maplibre_gl (3D 矢量地图)
- 地图瓦片缓存 (flutter_cache_manager)

**位置服务**：
- geolocator (地理位置获取)
- permission_handler (权限管理)

**天气服务**：
- 通过网络 API 获取天气数据（具体 API 通过配置）

**数据存储**：
- 本地 JSON Mock 数据（assets/mock_data/）
- 后端 API 服务（通过 ApiClient 调用）
