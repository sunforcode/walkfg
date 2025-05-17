# Walk - 徒步旅行助手应用

Walk是一款功能强大的徒步旅行助手应用，旨在帮助户外爱好者规划、准备和享受徒步旅行。无论是短途远足还是多日徒步，Walk都能提供全方位的支持。本应用采用iOS风格设计，提供流畅、直观的用户体验。

## 主要功能

- **路线规划与导航**：浏览、搜索和保存徒步路线，获取详细的路线信息和导航指引。
- **天气预报**：获取路线沿途的实时天气预报和预警信息，帮助您做好准备。
- **装备推荐**：根据路线、天气和个人偏好，获取智能装备推荐清单。
- **徒步攻略**：查看专业徒步攻略，学习徒步技巧和安全知识。
- **行程管理**：规划和管理您的徒步行程，记录徒步里程和成就。
- **离线地图**：下载地图数据，在无网络区域也能使用导航功能。
- **社区分享**：分享徒步经验、照片和路线评价，与其他徒步爱好者交流。

## 技术架构

### 前端

- **框架**：Flutter
- **UI风格**：iOS风格 (Cupertino)
- **状态管理**：Riverpod
- **导航**：CupertinoTabScaffold + CupertinoTabBar
- **网络请求**：Dio
- **本地存储**：Hive, SharedPreferences
- **地图服务**：Flutter Map

## 项目结构

\`\`\`
lib/
├── common/              # 通用组件和工具
├── helper/              # 辅助类和函数
├── model/               # 数据模型
│   ├── guide_model.dart # 攻略模型
│   ├── route_model.dart # 路线模型
│   └── user_model.dart  # 用户模型
├── service/             # 服务层
│   ├── api_service.dart       # API服务接口
│   ├── mock_api_service.dart  # 模拟API服务
│   └── service_locator.dart   # 服务定位器
├── ui/                  # UI层
│   ├── page/            # 页面
│   │   ├── equipment/   # 装备页面
│   │   ├── home/        # 首页
│   │   ├── profile/     # 个人页面
│   │   ├── route/       # 路线页面
│   │   └── main_layout.dart  # 主布局
│   ├── theme/           # 主题
│   └── widgets/         # 组件
└── main.dart            # 应用入口
\`\`\`

## iOS风格实现特点

### 1. Cupertino组件

应用全面采用Flutter的Cupertino组件库，实现了iOS原生的视觉效果和交互体验：

- **CupertinoApp**：应用根组件，提供iOS风格的主题和导航
- **CupertinoTabScaffold**：实现底部标签栏导航
- **CupertinoNavigationBar**：iOS风格的导航栏
- **CupertinoPageScaffold**：页面基础结构
- **CupertinoButton**：iOS风格按钮
- **CupertinoActivityIndicator**：iOS风格加载指示器
- **CupertinoAlertDialog**：iOS风格对话框

### 2. 导航系统

采用iOS原生的导航方式，确保用户体验的一致性：

- **底部标签栏**：使用CupertinoTabBar实现常驻底部的标签导航
- **页面导航**：使用CupertinoPageRoute进行页面切换，保持iOS原生的页面过渡动画
- **导航堆栈**：每个标签页拥有独立的导航堆栈，通过CupertinoTabView实现

### 3. 视觉设计

遵循iOS设计规范，确保应用在iOS设备上的原生体验：

- **颜色系统**：使用iOS标准颜色，如systemBlue、systemGrey等
- **字体**：采用iOS默认字体和文本样式
- **圆角和阴影**：遵循iOS的视觉风格，使用适当的圆角和阴影效果
- **间距和布局**：符合iOS人机界面指南的间距和布局规范

### 4. 交互模式

实现iOS特有的交互模式，提供熟悉的用户体验：

- **下拉刷新**：iOS风格的下拉刷新控件
- **滑动手势**：支持iOS标准的滑动手势操作
- **长按菜单**：iOS风格的长按上下文菜单
- **反馈动画**：符合iOS风格的交互反馈动画

## 核心页面

### 主布局 (MainLayout)

使用CupertinoTabScaffold实现的主布局，包含四个主要标签页：首页、路线、装备和个人中心。

### 首页 (HomeScreen)

展示用户个性化内容，包括：
- 欢迎卡片与天气预报
- 用户统计信息
- 规划路线列表
- 当季推荐路线
- 徒步攻略

### 路线页面 (RouteListScreen)

展示徒步路线列表，支持筛选和搜索功能。

### 装备页面 (EquipmentListScreen)

展示装备清单列表，支持筛选和搜索功能。

### 个人中心 (ProfileScreen)

展示用户信息和个人设置，包括：
- 用户基本信息
- 徒步统计数据
- 功能入口
- 设置选项

## 安装与运行

### 前提条件

- Flutter SDK 3.0.0或更高版本
- Dart SDK 3.0.0或更高版本
- iOS 13.0或更高版本（最佳体验）
- Android 5.0或更高版本

### 安装步骤

1. 克隆仓库：
   \`\`\`bash
   git clone https://github.com/yourusername/walk.git
   cd walk
   \`\`\`

2. 安装依赖：
   \`\`\`bash
   flutter pub get
   \`\`\`

3. 运行应用：
   \`\`\`bash
   flutter run
   \`\`\`

## 贡献指南

1. Fork仓库
2. 创建特性分支：`git checkout -b feature/amazing-feature`
3. 提交更改：`git commit -m 'Add some amazing feature'`
4. 推送到分支：`git push origin feature/amazing-feature`
5. 提交Pull Request

## 许可证

本项目采用MIT许可证 - 详情请参阅[LICENSE](LICENSE)文件。

## 联系方式

如有任何问题或建议，请通过以下方式联系我们：

- 电子邮件：contact@walkapp.com
- 网站：https://walkapp.com
- GitHub：https://github.com/yourusername/walk
