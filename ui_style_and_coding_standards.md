# Walk 徒步旅行助手 - UI风格与代码编写规范

## 🎨 UI设计风格

### 1. 设计系统 - Cupertino Design System

#### 1.1 核心设计理念
- **原生iOS体验**: 采用Cupertino设计语言，提供原生iOS应用体验
- **简洁优雅**: 界面简洁，信息层次清晰，避免视觉噪音
- **功能导向**: 以用户任务为中心，突出核心功能
- **一致性**: 统一的视觉语言和交互模式

#### 1.2 色彩规范
\`\`\`dart
// 主题色彩定义
class AppColors {
  // 主色调 - 蓝色系
  static const Color primary = Color(0xFF2196F3);      // 主要操作按钮
  static const Color primaryLight = Color(0xFF64B5F6);  // 次要元素
  static const Color primaryDark = Color(0xFF1976D2);   // 强调状态
  
  // 辅助色 - 绿色系（户外主题）
  static const Color secondary = Color(0xFF4CAF50);     // 成功状态
  static const Color accent = Color(0xFF66BB6A);        // 装饰元素
  
  // 背景色系
  static const Color background = Color(0xFFF5F5F5);    // 页面背景
  static const Color surface = Color(0xFFFFFFFF);       // 卡片背景
  static const Color cardBackground = Color(0xFFFAFAFA); // 次级卡片
  
  // 状态色系
  static const Color success = Color(0xFF4CAF50);       // 成功
  static const Color warning = Color(0xFFFF9800);       // 警告
  static const Color error = Color(0xFFF44336);         // 错误
  static const Color info = Color(0xFF2196F3);          // 信息
}
\`\`\`

#### 1.3 字体规范
\`\`\`dart
// 字体大小层级
class AppTextStyles {
  // 标题层级
  static const TextStyle h1 = TextStyle(fontSize: 28, fontWeight: FontWeight.bold);
  static const TextStyle h2 = TextStyle(fontSize: 24, fontWeight: FontWeight.w600);
  static const TextStyle h3 = TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
  static const TextStyle h4 = TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
  
  // 正文层级
  static const TextStyle bodyLarge = TextStyle(fontSize: 16, fontWeight: FontWeight.normal);
  static const TextStyle bodyMedium = TextStyle(fontSize: 14, fontWeight: FontWeight.normal);
  static const TextStyle bodySmall = TextStyle(fontSize: 12, fontWeight: FontWeight.normal);
  
  // 特殊用途
  static const TextStyle caption = TextStyle(fontSize: 12, color: CupertinoColors.secondaryLabel);
  static const TextStyle button = TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
}
\`\`\`

#### 1.4 间距规范
\`\`\`dart
// 间距系统 - 8px基准
class AppSpacing {
  static const double xs = 4.0;    // 极小间距
  static const double sm = 8.0;    // 小间距
  static const double md = 16.0;   // 中等间距（标准）
  static const double lg = 24.0;   // 大间距
  static const double xl = 32.0;   // 超大间距
  static const double xxl = 48.0;  // 特大间距
}
\`\`\`

---

## 📱 页面UI拆分规范

### 1. 页面拆分原则

#### 1.1 单一职责原则
每个Widget只负责一个明确的功能或展示一块特定的内容区域。

\`\`\`dart
// ❌ 错误示例 - 一个Widget承担过多职责
class TripDetailWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 地图区域
        Container(/* 地图相关代码 */),
        // 行程概览
        Container(/* 概览相关代码 */),
        // 装备清单
        Container(/* 装备相关代码 */),
        // 预算信息
        Container(/* 预算相关代码 */),
        // ... 更多内容
      ],
    );
  }
}

// ✅ 正确示例 - 按功能拆分Widget
class TripDetailScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // 地图头部
        SliverToBoxAdapter(
          child: TripMapHeaderWidget(trip: trip),
        ),
        
        // 行程概览
        SliverToBoxAdapter(
          child: TripOverviewDisplayWidget(trip: trip),
        ),
        
        // 装备清单
        SliverToBoxAdapter(
          child: TripEquipmentDisplayWidget(trip: trip),
        ),
        
        // 预算信息
        SliverToBoxAdapter(
          child: TripBudgetDisplayWidget(trip: trip),
        ),
      ],
    );
  }
}
\`\`\`

#### 1.2 组件层次结构
\`\`\`
页面级组件 (Screen)
├── 区域级组件 (Section/Display Widget)
│   ├── 功能级组件 (Feature Widget)
│   │   ├── 基础组件 (Basic Widget)
│   │   └── 通用组件 (Common Widget)
│   └── 卡片级组件 (Card Widget)
└── 操作级组件 (Action Widget)
\`\`\`

### 2. 组件命名规范

#### 2.1 页面级组件
\`\`\`dart
// 页面 - Screen后缀
class TripDetailScreen extends StatefulWidget {}
class RouteListScreen extends StatelessWidget {}
class EquipmentManagementScreen extends StatefulWidget {}
\`\`\`

#### 2.2 区域级组件
\`\`\`dart
// 展示组件 - DisplayWidget后缀
class TripOverviewDisplayWidget extends StatelessWidget {}
class RouteInfoDisplayWidget extends StatelessWidget {}

// 区域组件 - SectionWidget后缀  
class TripEquipmentSectionWidget extends StatelessWidget {}
class WeatherInfoSectionWidget extends StatelessWidget {}
\`\`\`

#### 2.3 功能级组件
\`\`\`dart
// 功能组件 - Widget后缀
class ElevationProfileWidget extends StatelessWidget {}
class TrackSelectorWidget extends StatefulWidget {}
class DailyPlanTimelineWidget extends StatelessWidget {}
\`\`\`

#### 2.4 卡片级组件
\`\`\`dart
// 卡片组件 - CardWidget后缀
class TripBasicInfoCardWidget extends StatelessWidget {}
class EquipmentItemCardWidget extends StatelessWidget {}
\`\`\`

### 3. 实际拆分案例分析

#### 3.1 行程详情页面拆分
\`\`\`dart
/// 行程详情页面 - 主页面
class TripDetailScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: _buildNavigationBar(),
      child: CustomScrollView(
        slivers: [
          // 1. 地图头部区域 (300px)
          SliverToBoxAdapter(
            child: TripMapHeaderWidget(
              route: _relatedRoutes.isNotEmpty ? _relatedRoutes.first : null,
              height: 220,
            ),
          ),

          // 2. 行程概览区域
          SliverToBoxAdapter(
            child: TripOverviewDisplayWidget(
              trip: trip,
              relatedRoutes: _relatedRoutes,
              isReadOnly: widget.isReadOnly || !_isOwnTrip(trip),
            ),
          ),

          // 3. 每日行程区域
          SliverToBoxAdapter(
            child: TripItineraryDisplayWidget(trip: trip),
          ),

          // 4. 参与者信息区域
          SliverToBoxAdapter(
            child: TripParticipantsDisplayWidget(trip: trip),
          ),

          // 5. 装备清单区域
          SliverToBoxAdapter(
            child: TripEquipmentDisplayWidget(trip: trip),
          ),

          // 6. 预算信息区域
          SliverToBoxAdapter(
            child: TripBudgetDisplayWidget(trip: trip),
          ),

          // 7. 食物饮水区域
          SliverToBoxAdapter(
            child: TripFoodWaterDisplayWidget(trip: trip),
          ),

          // 8. 交通住宿区域
          SliverToBoxAdapter(
            child: TripTransportationDisplayWidget(trip: trip),
          ),

          // 9. 天气安全区域
          SliverToBoxAdapter(
            child: TripWeatherSafetyDisplayWidget(trip: trip),
          ),

          // 10. 操作按钮区域
          SliverToBoxAdapter(
            child: _buildActionButtons(trip),
          ),
        ],
      ),
    );
  }
}
\`\`\`

#### 3.2 行程概览组件内部拆分
\`\`\`dart
/// 行程概览展示组件 - 区域级组件
class TripOverviewDisplayWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: _buildCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题区域
          _buildTitleSection(),
          
          // 重要提醒区域（条件显示）
          ..._buildImportantAlerts(),
          
          // 计划现状概览
          _buildStatusSection(),
        ],
      ),
    );
  }

  /// 构建标题区域
  Widget _buildTitleSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _buildSectionBorder(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              Text(_getOverviewTitle(), style: AppTextStyles.h4),
              const Spacer(),
              _buildStatusBadge(),
            ],
          ),
          const SizedBox(height: 12),
          
          // 基础信息
          ..._buildBasicInfo(),
        ],
      ),
    );
  }

  /// 构建基础信息列表
  List<Widget> _buildBasicInfo() {
    return [
      _buildInfoRow(
        icon: CupertinoIcons.calendar,
        label: '出行时间',
        value: _formatDateRange(),
      ),
      _buildInfoRow(
        icon: CupertinoIcons.person_2,
        label: '参与人数',
        value: '${trip.participantCount}人',
      ),
      if (relatedRoutes.isNotEmpty)
        _buildInfoRow(
          icon: CupertinoIcons.map,
          label: '主要路线',
          value: relatedRoutes.first.name,
        ),
    ];
  }

  /// 构建信息行组件 - 基础组件
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: CupertinoColors.secondaryLabel),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.bodyMedium),
          const Spacer(),
          Text(value, style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          )),
        ],
      ),
    );
  }
}
\`\`\`

### 4. 组件设计模式

#### 4.1 展示型组件 (Display Widget)
\`\`\`dart
/// 展示型组件特点：
/// 1. 只接收数据，不处理业务逻辑
/// 2. 通过回调函数与父组件通信
/// 3. 可复用性强
class TripEquipmentDisplayWidget extends StatelessWidget {
  final TripModel trip;
  final VoidCallback? onManageEquipment;
  final bool isReadOnly;

  const TripEquipmentDisplayWidget({
    super.key,
    required this.trip,
    this.onManageEquipment,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    if (trip.equipmentList == null) {
      return _buildEmptyState();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: _buildCardDecoration(),
      child: Column(
        children: [
          _buildHeader(),
          _buildEquipmentSummary(),
          if (!isReadOnly) _buildActionButton(),
        ],
      ),
    );
  }
}
\`\`\`

#### 4.2 交互型组件 (Interactive Widget)
\`\`\`dart
/// 交互型组件特点：
/// 1. 包含内部状态管理
/// 2. 处理用户交互
/// 3. 通过回调通知父组件状态变化
class TrackSelectorWidget extends StatefulWidget {
  final List<TrackModel> tracks;
  final int selectedIndex;
  final Function(int) onTrackSelected;

  const TrackSelectorWidget({
    super.key,
    required this.tracks,
    required this.selectedIndex,
    required this.onTrackSelected,
  });

  @override
  State<TrackSelectorWidget> createState() => _TrackSelectorWidgetState();
}

class _TrackSelectorWidgetState extends State<TrackSelectorWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.tracks.length,
        itemBuilder: (context, index) {
          return _buildTrackItem(index);
        },
      ),
    );
  }

  Widget _buildTrackItem(int index) {
    final track = widget.tracks[index];
    final isSelected = index == widget.selectedIndex;

    return GestureDetector(
      onTap: () => widget.onTrackSelected(index),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        decoration: _buildTrackItemDecoration(isSelected),
        child: _buildTrackContent(track, isSelected),
      ),
    );
  }
}
\`\`\`

#### 4.3 容器型组件 (Container Widget)
\`\`\`dart
/// 容器型组件特点：
/// 1. 负责布局和样式
/// 2. 组合多个子组件
/// 3. 提供统一的视觉风格
class TripSectionContainer extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? action;
  final bool showBorder;

  const TripSectionContainer({
    super.key,
    required this.title,
    required this.child,
    this.action,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(16),
        border: showBorder ? Border.all(
          color: CupertinoColors.separator,
          width: 0.5,
        ) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          if (action != null) ...[
            const Spacer(),
            action!,
          ],
        ],
      ),
    );
  }
}
\`\`\`

---

## 🔧 代码编写规范

### 1. Widget拆分最佳实践

#### 1.1 拆分时机判断
\`\`\`dart
// 当一个build方法超过50行时，考虑拆分
// 当一个功能区域可以独立复用时，必须拆分
// 当一个区域有独立的状态管理时，应该拆分

// ❌ 过长的build方法
@override
Widget build(BuildContext context) {
  return Column(
    children: [
      // 100+ 行代码
    ],
  );
}

// ✅ 拆分后的build方法
@override
Widget build(BuildContext context) {
  return Column(
    children: [
      _buildHeader(),
      _buildContent(),
      _buildFooter(),
    ],
  );
}
\`\`\`

#### 1.2 私有方法拆分
\`\`\`dart
class TripDetailScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildMapHeader(),
        _buildOverviewSection(),
        _buildItinerarySection(),
        _buildEquipmentSection(),
      ],
    );
  }

  /// 构建地图头部
  Widget _buildMapHeader() {
    return SliverToBoxAdapter(
      child: TripMapHeaderWidget(
        route: _relatedRoutes.isNotEmpty ? _relatedRoutes.first : null,
        height: 220,
      ),
    );
  }

  /// 构建概览区域
  Widget _buildOverviewSection() {
    return SliverToBoxAdapter(
      child: TripOverviewDisplayWidget(
        trip: _currentTrip,
        relatedRoutes: _relatedRoutes,
        isReadOnly: widget.isReadOnly,
      ),
    );
  }
}
\`\`\`

#### 1.3 独立Widget拆分
\`\`\`dart
// 当私有方法变得复杂时，拆分为独立Widget
// 文件结构：
// lib/ui/page/trip/
// ├── trip_detail_screen.dart          # 主页面
// └── widget/
//     ├── display/                     # 展示组件
//     │   ├── trip_overview_display_widget.dart
//     │   ├── trip_equipment_display_widget.dart
//     │   └── trip_budget_display_widget.dart
//     ├── trip_map_header_widget.dart  # 功能组件
//     └── trip_action_buttons_widget.dart
\`\`\`

### 2. 组件通信规范

#### 2.1 父子组件通信
\`\`\`dart
// 父组件向子组件传递数据
class ParentWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChildWidget(
      data: someData,
      onAction: _handleChildAction,
    );
  }

  void _handleChildAction(String result) {
    // 处理子组件的回调
  }
}

// 子组件通过回调与父组件通信
class ChildWidget extends StatelessWidget {
  final SomeData data;
  final Function(String) onAction;

  const ChildWidget({
    super.key,
    required this.data,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: () => onAction('result'),
      child: Text('Action'),
    );
  }
}
\`\`\`

#### 2.2 状态提升
\`\`\`dart
// 当多个子组件需要共享状态时，将状态提升到共同的父组件
class TripPlanningScreen extends StatefulWidget {
  @override
  State<TripPlanningScreen> createState() => _TripPlanningScreenState();
}

class _TripPlanningScreenState extends State<TripPlanningScreen> {
  TripModel _currentTrip = TripModel.empty();
  List<RouteModel> _selectedRoutes = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 两个子组件都需要访问和修改相同的状态
        TripBasicInfoWidget(
          trip: _currentTrip,
          onTripUpdated: _updateTrip,
        ),
        RouteSelectionWidget(
          selectedRoutes: _selectedRoutes,
          onRoutesChanged: _updateRoutes,
        ),
      ],
    );
  }

  void _updateTrip(TripModel newTrip) {
    setState(() {
      _currentTrip = newTrip;
    });
  }

  void _updateRoutes(List<RouteModel> routes) {
    setState(() {
      _selectedRoutes = routes;
    });
  }
}
\`\`\`

### 3. 性能优化规范

#### 3.1 条件渲染
\`\`\`dart
// 使用条件渲染避免不必要的Widget创建
@override
Widget build(BuildContext context) {
  return Column(
    children: [
      // ✅ 条件渲染
      if (trip.hasEquipmentList)
        TripEquipmentDisplayWidget(trip: trip),
      
      // ❌ 避免这样写
      // trip.hasEquipmentList 
      //   ? TripEquipmentDisplayWidget(trip: trip)
      //   : const SizedBox.shrink(),
      
      // ✅ 列表条件渲染
      ...trip.importantAlerts.map((alert) => 
        ImportantAlertWidget(alert: alert)
      ),
    ],
  );
}
\`\`\`

#### 3.2 懒加载和缓存
\`\`\`dart
class ExpensiveWidget extends StatefulWidget {
  @override
  State<ExpensiveWidget> createState() => _ExpensiveWidgetState();
}

class _ExpensiveWidgetState extends State<ExpensiveWidget> {
  Widget? _cachedContent;

  @override
  Widget build(BuildContext context) {
    // 缓存复杂的Widget构建结果
    _cachedContent ??= _buildExpensiveContent();
    
    return Container(
      child: _cachedContent,
    );
  }

  Widget _buildExpensiveContent() {
    // 复杂的Widget构建逻辑
    return Column(
      children: [
        // 大量复杂的子Widget
      ],
    );
  }
}
\`\`\`

#### 3.3 列表优化
\`\`\`dart
// 使用ListView.builder进行懒加载
class TripListWidget extends StatelessWidget {
  final List<TripModel> trips;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: trips.length,
      itemBuilder: (context, index) {
        return TripListItemWidget(
          trip: trips[index],
          key: ValueKey(trips[index].id), // 提供稳定的key
        );
      },
    );
  }
}
\`\`\`

### 4. 错误处理规范

#### 4.1 空状态处理
\`\`\`dart
class TripEquipmentDisplayWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 处理空状态
    if (trip.equipmentList == null || trip.equipmentList!.equipments.isEmpty) {
      return _buildEmptyState();
    }

    return _buildContent();
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.bag,
            size: 48,
            color: CupertinoColors.secondaryLabel,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无装备清单',
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击下方按钮开始规划装备',
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.tertiaryLabel,
            ),
          ),
        ],
      ),
    );
  }
}
\`\`\`

#### 4.2 异步数据处理
\`\`\`dart
class AsyncDataWidget extends StatelessWidget {
  final Future<DataModel> dataFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DataModel>(
      future: dataFuture,
      builder: (context, snapshot) {
        // 加载状态
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        }

        // 错误状态
        if (snapshot.hasError) {
          return ErrorWidget(
            error: snapshot.error.toString(),
            onRetry: () {
              // 重试逻辑
            },
          );
        }

        // 空数据状态
        if (!snapshot.hasData) {
          return _buildEmptyState();
        }

        // 正常数据状态
        return _buildContent(snapshot.data!);
      },
    );
  }
}
\`\`\`

---

## 📋 组件设计检查清单

### 1. 设计阶段检查
- [ ] 组件职责是否单一明确？
- [ ] 组件是否可以独立复用？
- [ ] 组件接口是否简洁清晰？
- [ ] 组件是否遵循命名规范？

### 2. 实现阶段检查
- [ ] build方法是否过长（>50行）？
- [ ] 是否正确处理了空状态？
- [ ] 是否正确处理了错误状态？
- [ ] 是否使用了合适的Key？

### 3. 性能阶段检查
- [ ] 是否避免了不必要的重建？
- [ ] 是否使用了条件渲染？
- [ ] 列表是否使用了懒加载？
- [ ] 复杂Widget是否考虑了缓存？

### 4. 维护阶段检查
- [ ] 组件是否有清晰的文档注释？
- [ ] 组件是否易于测试？
- [ ] 组件是否易于修改和扩展？
- [ ] 组件是否符合团队代码风格？

---

## 🎯 总结

Walk项目的UI风格和代码编写规范体现了以下核心理念：

### 🎨 UI风格特点
1. **原生iOS体验** - Cupertino设计系统
2. **简洁优雅** - 清晰的信息层次和视觉语言
3. **功能导向** - 以用户任务为中心的设计
4. **一致性** - 统一的组件和交互模式

### 📱 组件拆分原则
1. **单一职责** - 每个组件只负责一个明确功能
2. **合理层次** - 页面→区域→功能→基础的清晰层级
3. **高内聚低耦合** - 组件内部紧密相关，组件间松散耦合
4. **可复用性** - 通过合理的接口设计提高复用性

### 🔧 编码最佳实践
1. **及时拆分** - build方法超过50行时考虑拆分
2. **状态管理** - 合理的状态提升和组件通信
3. **性能优化** - 条件渲染、懒加载、缓存策略
4. **错误处理** - 完善的空状态和异常处理

这套规范确保了代码的可维护性、可扩展性和团队协作效率，为项目的长期发展奠定了坚实基础。