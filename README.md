# Walk - 徒步应用

一个专为徒步爱好者设计的移动应用，提供路线规划、装备管理、行程记录等功能。

## 📱 功能模块

### 核心模块
- **Route（路线）** - 主要模块，包含徒步路线的详细信息、分段数据、海拔变化等
- **Trip（行程）** - 主要模块，记录实际的徒步行程、时间轨迹、照片等
- **Equipment（装备）** - 装备管理，包含装备清单、重量计算、打包建议等
- **Weather（天气）** - 天气信息查询和预报
- **Map（地图）** - 地图显示、轨迹点管理、导航功能

### 页面结构
\`\`\`
├── 首页 - 路线推荐和快速入口
├── 路线模块
│   ├── 路线列表
│   ├── 路线详情
│   └── 路线分段信息
├── 行程模块
│   ├── 行程计划
│   ├── 行程记录
│   └── 行程回顾
├── 装备模块
│   ├── 装备库
│   ├── 打包清单
│   └── 装备推荐
└── 个人中心
    ├── 用户信息
    ├── 历史记录
    └── 设置
\`\`\`

## 🛠 技术架构

### 数据模型
- **JSON序列化**: 使用 `json_annotation` 进行数据模型与JSON的自动转换
- **命名规范**:
  - Dart模型使用驼峰命名法 (camelCase)
  - JSON字段使用下划线命名法 (snake_case)
  - 通过 `@JsonKey(name: 'field_name')` 进行映射

\`\`\`dart
@JsonSerializable()
class RouteModel {
  final String routeName;           // Dart中使用驼峰

  @JsonKey(name: 'created_time')    // JSON中使用下划线
  final DateTime createdTime;
}
\`\`\`

### 枚举处理
- 枚举值使用整数类型，便于数据库存储和网络传输
- 使用 `@JsonValue()` 注解指定序列化值
- 通过扩展方法提供多种转换方式
- 支持自定义JSON转换器处理复杂场景

\`\`\`dart
/// 道路类型枚举定义
enum RouteType {
  @JsonValue(0)
  mudRoad,      // 泥路

  @JsonValue(1)
  farmRoad,     // 机耕路

  @JsonValue(2)
  stoneRoad,    // 石路

  @JsonValue(3)
  concreteRoad, // 水泥路

  @JsonValue(4)
  asphaltRoad,  // 柏油路

  @JsonValue(5)
  trail,        // 小径

  @JsonValue(6)
  boardwalk,    // 栈道
}

/// 枚举扩展方法
extension RouteTypeExtension on RouteType {
  /// 转换为整数值（用于JSON序列化）
  int get intValue {
    switch (this) {
      case RouteType.mudRoad:
        return 0;
      case RouteType.farmRoad:
        return 1;
      case RouteType.stoneRoad:
        return 2;
      case RouteType.concreteRoad:
        return 3;
      case RouteType.asphaltRoad:
        return 4;
      case RouteType.trail:
        return 5;
      case RouteType.boardwalk:
        return 6;
    }
  }

  /// 转换为字符串标识符（用于内部处理）
  String get value {
    switch (this) {
      case RouteType.mudRoad:
        return 'mud_road';
      case RouteType.farmRoad:
        return 'farm_road';
      case RouteType.stoneRoad:
        return 'stone_road';
      case RouteType.concreteRoad:
        return 'concrete_road';
      case RouteType.asphaltRoad:
        return 'asphalt_road';
      case RouteType.trail:
        return 'trail';
      case RouteType.boardwalk:
        return 'boardwalk';
    }
  }

  /// 获取中文显示名称（用于UI显示）
  String get displayName {
    switch (this) {
      case RouteType.mudRoad:
        return '泥路';
      case RouteType.farmRoad:
        return '机耕路';
      case RouteType.stoneRoad:
        return '石路';
      case RouteType.concreteRoad:
        return '水泥路';
      case RouteType.asphaltRoad:
        return '柏油路';
      case RouteType.trail:
        return '小径';
      case RouteType.boardwalk:
        return '栈道';
    }
  }

  /// 从整数创建枚举（用于JSON反序列化）
  static RouteType fromInt(int value) {
    switch (value) {
      case 0:
        return RouteType.mudRoad;
      case 1:
        return RouteType.farmRoad;
      case 2:
        return RouteType.stoneRoad;
      case 3:
        return RouteType.concreteRoad;
      case 4:
        return RouteType.asphaltRoad;
      case 5:
        return RouteType.trail;
      case 6:
        return RouteType.boardwalk;
      default:
        return RouteType.trail; // 默认值
    }
  }

  /// 从字符串创建枚举（用于兼容处理）
  static RouteType fromString(String value) {
    switch (value) {
      case 'mud_road':
        return RouteType.mudRoad;
      case 'farm_road':
        return RouteType.farmRoad;
      case 'stone_road':
        return RouteType.stoneRoad;
      case 'concrete_road':
        return RouteType.concreteRoad;
      case 'asphalt_road':
        return RouteType.asphaltRoad;
      case 'trail':
        return RouteType.trail;
      case 'boardwalk':
        return RouteType.boardwalk;
      default:
        return RouteType.trail; // 默认值
    }
  }
}

/// 在模型中使用自定义JSON转换器
@JsonSerializable()
class SegmentModel {
  @JsonKey(
    name: 'route_type',
    defaultValue: RouteType.trail,
    fromJson: _routeTypeFromJson,
    toJson: _routeTypeToJson,
  )
  final RouteType type;

  /// 自定义RouteType从JSON转换
  static RouteType _routeTypeFromJson(int? value) {
    if (value == null) return RouteType.trail;
    return RouteTypeExtension.fromInt(value);
  }

  /// 自定义RouteType转JSON
  static int _routeTypeToJson(RouteType type) {
    return type.intValue;
  }
}
\`\`\`

### 状态管理
- 使用 Provider/Riverpod 进行状态管理
- 数据持久化使用 Hive/SharedPreferences

### 网络请求
- 使用 Dio 进行HTTP请求
- 统一的API响应处理和错误处理机制

## 🎨 UI设计规范

### 设计系统
- **设计语言**: Material Design 3.0 + 自定义徒步主题
- **色彩方案**:
  - 主色调: 自然绿色系 (#2E7D32, #4CAF50)
  - 辅助色: 橙色警示 (#FF9800), 蓝色信息 (#2196F3)
  - 中性色: 灰色系 (#757575, #BDBDBD, #F5F5F5)
- **字体**:
  - 中文: PingFang SC / Noto Sans CJK
  - 英文/数字: Roboto
  - 等宽字体: Roboto Mono (用于数据展示)

### 组件规范
\`\`\`dart
// 主题配置示例
class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    primarySwatch: Colors.green,
    primaryColor: const Color(0xFF2E7D32),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4CAF50),
      brightness: Brightness.light,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(fontSize: 16, height: 1.5),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    ),
  );
}
\`\`\`

### 间距规范
\`\`\`dart
class AppSpacing {
  static const double xs = 4.0;    // 极小间距
  static const double sm = 8.0;    // 小间距
  static const double md = 16.0;   // 中等间距
  static const double lg = 24.0;   // 大间距
  static const double xl = 32.0;   // 超大间距
}
\`\`\`

### 图标规范
- **系统图标**: 优先使用 Material Icons
- **自定义图标**: SVG格式，24x24dp基准尺寸
- **徒步专用图标**: 登山包、指南针、海拔等专业图标

## 🏗️ 架构设计

### 项目架构
\`\`\`
lib/
├── app/                    # 应用入口和配置
│   ├── app.dart           # 应用主类
│   ├── routes.dart        # 路由配置
│   └── theme.dart         # 主题配置
├── core/                  # 核心功能
│   ├── constants/         # 常量定义
│   ├── extensions/        # 扩展方法
│   ├── utils/            # 工具类
│   └── exceptions/       # 异常定义
├── data/                  # 数据层
│   ├── models/           # 数据模型
│   ├── repositories/     # 数据仓库
│   ├── datasources/      # 数据源
│   └── services/         # 网络服务
├── domain/               # 业务逻辑层
│   ├── entities/         # 业务实体
│   ├── usecases/         # 用例
│   └── repositories/     # 仓库接口
├── presentation/         # 表现层
│   ├── pages/           # 页面
│   ├── widgets/         # 通用组件
│   ├── providers/       # 状态管理
│   └── utils/           # UI工具
└── shared/              # 共享资源
    ├── assets/          # 静态资源
    ├── l10n/           # 国际化
    └── config/         # 配置文件
\`\`\`

### 状态管理模式
\`\`\`dart
// 使用Provider进行状态管理
class RouteProvider extends ChangeNotifier {
  List<RouteModel> _routes = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<RouteModel> get routes => _routes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 业务方法
  Future<void> loadRoutes() async {
    _setLoading(true);
    try {
      _routes = await _routeRepository.getRoutes();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
\`\`\`

## 📝 代码规范

### Widget设计原则
1. **单一职责**: 每个Widget只负责一个明确的功能
2. **合理大小**: 单个Widget代码行数控制在150行以内
3. **组件化**: 复杂UI拆分为多个小Widget组合
4. **可复用**: 通用组件抽取为独立Widget

\`\`\`dart
// ❌ 不推荐 - Widget过大
class LargeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 200+ 行代码...
    );
  }
}

// ✅ 推荐 - 拆分为小组件
class RouteDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          RouteInfoCard(),
          RouteSegmentsList(),
          RouteElevationChart(),
        ],
      ),
    );
  }
}
\`\`\`

### 页面结构模板
\`\`\`dart
class RoutePage extends StatefulWidget {
  const RoutePage({Key? key}) : super(key: key);

  @override
  State<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  @override
  void initState() {
    super.initState();
    // 初始化逻辑
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('路线'),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: _onSearchPressed,
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Consumer<RouteProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return ErrorWidget(provider.error!);
        }

        return ListView.builder(
          itemCount: provider.routes.length,
          itemBuilder: (context, index) {
            return RouteCard(route: provider.routes[index]);
          },
        );
      },
    );
  }

  Widget? _buildFAB() {
    return FloatingActionButton(
      onPressed: _onAddRoute,
      child: const Icon(Icons.add),
    );
  }

  void _onSearchPressed() {
    // 搜索逻辑
  }

  void _onAddRoute() {
    // 添加路线逻辑
  }
}
\`\`\`

### 命名规范
- **文件命名**: 使用下划线分隔 (`route_model.dart`)
- **类命名**: 使用大驼峰 (`RouteModel`)
- **变量/方法**: 使用小驼峰 (`routeName`)
- **常量**: 使用大写下划线 (`MAX_ROUTE_COUNT`)
- **私有成员**: 以下划线开头 (`_privateMethod`)

### 目录结构
\`\`\`
lib/
├── model/              # 数据模型
│   ├── route/         # 路线相关模型
│   ├── trip/          # 行程相关模型
│   └── equipment/     # 装备相关模型
├── pages/             # 页面
├── widgets/           # 通用组件
├── services/          # 业务服务
├── utils/             # 工具类
└── constants/         # 常量定义
\`\`\`

### 注释规范
- 类和重要方法必须添加文档注释
- 使用 `///` 进行文档注释
- 复杂逻辑添加行内注释说明

\`\`\`dart
/// 路线分段模型
///
/// 用于表示徒步路线中的一个分段，包含距离、海拔、道路类型等信息
@JsonSerializable()
class SegmentModel {
  /// 分段ID，全局唯一标识符
  final String id;

  /// 道路类型，影响徒步难度和装备选择
  final RouteType type;
}
\`\`\`

### 错误处理
- 统一的异常处理机制
- 用户友好的错误提示
- 关键操作添加try-catch

\`\`\`dart
try {
  final route = await routeService.getRoute(id);
  return route;
} on NetworkException catch (e) {
  showErrorSnackBar('网络连接失败，请检查网络设置');
} catch (e) {
  showErrorSnackBar('获取路线信息失败');
}
\`\`\`

## 🚀 开发指南

### 环境要求
- Flutter SDK >= 3.0.0
- Dart SDK >= 2.17.0

### 依赖管理
\`\`\`yaml
# pubspec.yaml 主要依赖
dependencies:
  flutter:
    sdk: flutter
  json_annotation: ^4.8.1      # JSON序列化注解
  dio: ^5.3.2                  # 网络请求
  provider: ^6.0.5             # 状态管理
  hive: ^2.2.3                 # 本地数据库
  geolocator: ^9.0.2           # 地理位置
  flutter_map: ^6.0.1          # 地图组件

dev_dependencies:
  flutter_test:
    sdk: flutter
  json_serializable: ^6.7.1    # JSON序列化代码生成
  build_runner: ^2.4.7         # 代码生成工具
  flutter_lints: ^2.0.0        # 代码规范检查
\`\`\`

### 安装依赖
\`\`\`bash
flutter pub get
\`\`\`

### 代码生成
\`\`\`bash
# 生成JSON序列化代码
flutter packages pub run build_runner build

# 监听文件变化自动生成
flutter packages pub run build_runner watch
\`\`\`

### 运行项目
\`\`\`bash
# 调试模式
flutter run

# 发布模式
flutter run --release
\`\`\`

## 🔧 工具和插件

### 推荐VS Code插件
- Flutter
- Dart
- Flutter Widget Snippets
- Awesome Flutter Snippets
- Flutter Tree
- Error Lens

### 代码片段示例
\`\`\`json
// .vscode/snippets.json
{
  "Stateful Widget": {
    "prefix": "stf",
    "body": [
      "class ${1:WidgetName} extends StatefulWidget {",
      "  const ${1:WidgetName}({Key? key}) : super(key: key);",
      "",
      "  @override",
      "  State<${1:WidgetName}> createState() => _${1:WidgetName}State();",
      "}",
      "",
      "class _${1:WidgetName}State extends State<${1:WidgetName}> {",
      "  @override",
      "  Widget build(BuildContext context) {",
      "    return ${2:Container()};",
      "  }",
      "}"
    ]
  }
}
\`\`\`

## 🧪 测试规范

### 测试结构
\`\`\`
test/
├── unit/              # 单元测试
│   ├── models/       # 模型测试
│   ├── services/     # 服务测试
│   └── utils/        # 工具测试
├── widget/           # Widget测试
└── integration/      # 集成测试
\`\`\`

### 测试示例
\`\`\`dart
// 单元测试示例
void main() {
  group('RouteModel', () {
    test('should create RouteModel from JSON', () {
      // Arrange
      final json = {
        'id': '1',
        'name': 'Test Route',
        'distance': 10.5,
      };

      // Act
      final route = RouteModel.fromJson(json);

      // Assert
      expect(route.id, '1');
      expect(route.name, 'Test Route');
      expect(route.distance, 10.5);
    });
  });
}

// Widget测试示例
void main() {
  testWidgets('RouteCard should display route information', (tester) async {
    // Arrange
    final route = RouteModel(id: '1', name: 'Test Route');

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: RouteCard(route: route),
      ),
    );

    // Assert
    expect(find.text('Test Route'), findsOneWidget);
  });
}
\`\`\`

## 📋 开发规范检查清单

### 提交代码前检查
- [ ] 代码格式化 (`flutter format .`)
- [ ] 静态分析通过 (`flutter analyze`)
- [ ] 单元测试通过 (`flutter test`)
- [ ] Widget大小合理（<150行）
- [ ] 添加必要注释
- [ ] 遵循命名规范

### Code Review要点
- [ ] 业务逻辑正确性
- [ ] 性能优化考虑
- [ ] 错误处理完整性
- [ ] UI/UX体验
- [ ] 代码可维护性

### 枚举使用示例
\`\`\`dart
// 创建枚举
RouteType type = RouteType.mudRoad;

// 获取不同格式的值
int jsonValue = type.intValue;        // 0 (用于JSON)
String identifier = type.value;       // 'mud_road' (用于内部)
String displayText = type.displayName; // '泥路' (用于UI)

// 从不同格式创建枚举
RouteType fromJson = RouteTypeExtension.fromInt(0);
RouteType fromString = RouteTypeExtension.fromString('mud_road');

// JSON序列化示例
Map<String, dynamic> json = {
  'route_type': 0,  // JSON中使用整数
};
SegmentModel segment = SegmentModel.fromJson(json);
print(segment.type.displayName); // 输出: 泥路
\`\`\`

