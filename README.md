# Walk - 徒步旅行助手应用

Walk是一款功能强大的徒步旅行助手应用，旨在帮助户外爱好者规划、准备和享受徒步旅行。无论是短途远足还是多日徒步，Walk都能提供全方位的支持。

## 主要功能

- **路线规划与导航**：浏览、搜索和保存徒步路线，获取详细的路线信息和导航指引。
- **天气预报**：获取路线沿途的实时天气预报和预警信息，帮助您做好准备。
- **装备推荐**：根据路线、天气和个人偏好，获取智能装备推荐清单。
- **食物计划**：根据行程长度和难度，获取合理的食物计划建议。
- **行程调整**：根据实际情况灵活调整行程，获取替代路线和住宿建议。
- **离线地图**：下载地图数据，在无网络区域也能使用导航功能。
- **紧急求助**：一键发送位置信息给紧急联系人，确保安全。
- **社区分享**：分享徒步经验、照片和路线评价，与其他徒步爱好者交流。

## 技术架构

### 前端

- **框架**：Flutter
- **状态管理**：Riverpod
- **路由管理**：GoRouter
- **网络请求**：Dio
- **本地存储**：Hive
- **地图服务**：MapLibre GL
- **认证服务**：Firebase Authentication

### 后端

- **API服务**：Node.js + Express
- **数据库**：MongoDB
- **地图数据**：OpenStreetMap
- **天气数据**：OpenWeatherMap API
- **AI推荐**：OpenAI API

## 项目结构

\`\`\`
lib/
├── core/                 # 核心模块
│   ├── models/           # 基础数据模型
│   ├── services/         # 核心服务
│   └── utils/            # 工具类
├── features/             # 功能模块
│   ├── route/            # 路线功能
│   ├── weather/          # 天气功能
│   ├── equipment/        # 装备功能
│   ├── food/             # 食物功能
│   └── trip_adjustment/  # 行程调整功能
├── ui/                   # UI组件
│   ├── screens/          # 页面
│   ├── widgets/          # 组件
│   └── theme/            # 主题
└── main.dart             # 应用入口
\`\`\`

## 核心模型

### 基础模型 (BaseModel)

所有模型的基类，包含ID、创建时间和更新时间等基本属性。

### 用户模型 (UserModel)

存储用户信息，包括基本信息、偏好设置和统计数据。

### 天气模型 (WeatherModel)

存储天气预报信息，包括当前天气、每日预报和每小时预报等。

### 装备模型 (EquipmentModel)

存储装备推荐信息，包括装备清单、装备分类和装备项目等。

### 食物模型 (FoodModel)

存储食物计划信息，包括食物计划、餐食类型和食物项目等。

### 行程调整模型 (TripAdjustmentModel)

存储行程调整信息，包括行程调整、每日行程和调整建议等。

## 核心服务

### API服务 (ApiService)

处理网络请求，包括GET、POST、PUT、DELETE等HTTP请求方法。

### 存储服务 (StorageService)

处理本地数据存储，包括保存、获取、删除和清除数据等方法。

### 认证服务 (AuthService)

处理用户认证，包括登录、注册、登出和获取用户信息等方法。

### 连接服务 (ConnectivityService)

检测网络连接状态，包括检测网络连接状态和监听网络变化等方法。

### LLM服务 (LlmService)

处理与大型语言模型的交互，包括发送提示、处理响应和管理提示模板等方法。

## 安装与运行

### 前提条件

- Flutter SDK 3.0.0或更高版本
- Dart SDK 3.0.0或更高版本
- Android Studio或Visual Studio Code

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
