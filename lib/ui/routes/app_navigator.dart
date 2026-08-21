import 'package:flutter/cupertino.dart';

import '../page/calendar/calendar_screen.dart';
import '../page/equipment/equipment_list_create_screen.dart';
import '../page/equipment/equipment_list_detail_screen.dart';
import '../page/equipment/equipment_list_list_screen.dart';
import '../page/profile/profile_screen.dart';
import '../page/route/detail/route_detail_screen.dart';
import '../page/route/route_discovery_screen.dart';
import '../page/trip/create/trip_create_screen.dart';
import '../page/trip/trip_detail_screen.dart';
import '../page/trip/trip_edit_screen.dart';
import '../page/weather/weather_screen.dart';
import 'app_routes.dart';

/// Walk v1 导航工具
///
/// 封装各页面的 push 逻辑，统一参数传递方式。
/// 全部使用 CupertinoPageRoute + Navigator.push。
class AppNavigator {
  AppNavigator._();

  // ─── 路线 ───

  /// P3 路线发现
  static Future<T?> pushRouteDiscovery<T>(BuildContext context) {
    return Navigator.of(context).push<T>(
      CupertinoPageRoute(
        builder: (_) => const RouteDiscoveryScreen(),
        settings: const RouteSettings(name: AppRoutes.routeDiscovery),
      ),
    );
  }

  /// P4 路线详情
  static Future<T?> pushRouteDetail<T>(BuildContext context, {
    required String routeId,
  }) {
    return Navigator.of(context).push<T>(
      CupertinoPageRoute(
        builder: (_) => RouteDetailScreen(routeId: routeId),
        settings: RouteSettings(
          name: AppRoutes.routeDetail,
          arguments: {'routeId': routeId},
        ),
      ),
    );
  }

  // ─── 行程 ───

  /// P5 创建行程
  static Future<T?> pushTripCreate<T>(BuildContext context, {
    required String routeId,
  }) {
    return Navigator.of(context).push<T>(
      CupertinoPageRoute(
        builder: (_) => TripCreateScreen(routeId: routeId),
        settings: RouteSettings(
          name: AppRoutes.tripCreate,
          arguments: {'routeId': routeId},
        ),
      ),
    );
  }

  /// P6 行程详情
  /// [tripId] 行程 ID（可选，v1 优先用 routeId）
  /// [routeId] 路线 ID（TripDetailScreen 当前接受此参数）
  static Future<T?> pushTripDetail<T>(BuildContext context, {
    String? tripId,
    String? routeId,
  }) {
    return Navigator.of(context).push<T>(
      CupertinoPageRoute(
        builder: (_) => TripDetailScreen(tripId: tripId, routeId: routeId),
        settings: RouteSettings(
          name: AppRoutes.tripDetail,
          arguments: {'tripId': tripId, 'routeId': routeId},
        ),
      ),
    );
  }

  /// P7 行程编辑
  static Future<T?> pushTripEdit<T>(BuildContext context, {
    required String tripId,
  }) {
    return Navigator.of(context).push<T>(
      CupertinoPageRoute(
        builder: (_) => TripEditScreen(tripId: tripId),
        settings: RouteSettings(
          name: AppRoutes.tripEdit,
          arguments: {'tripId': tripId},
        ),
      ),
    );
  }

  // ─── 装备 ───

  /// P8 装备清单列表
  static Future<T?> pushGearList<T>(BuildContext context) {
    return Navigator.of(context).push<T>(
      CupertinoPageRoute(
        builder: (_) => const EquipmentListListScreen(),
        settings: const RouteSettings(name: AppRoutes.gearList),
      ),
    );
  }

  /// P9 装备清单详情
  static Future<T?> pushGearDetail<T>(BuildContext context, {
    required String listId,
  }) {
    return Navigator.of(context).push<T>(
      CupertinoPageRoute(
        builder: (_) => EquipmentListDetailScreen(listId: listId),
        settings: RouteSettings(
          name: AppRoutes.gearDetail,
          arguments: {'listId': listId},
        ),
      ),
    );
  }

  /// P10 新建装备清单
  static Future<T?> pushGearCreate<T>(BuildContext context) {
    return Navigator.of(context).push<T>(
      CupertinoPageRoute(
        builder: (_) => const EquipmentListCreateScreen(),
        settings: const RouteSettings(name: AppRoutes.gearCreate),
      ),
    );
  }

  // ─── 天气 ───

  /// P11 天气
  static Future<T?> pushWeather<T>(BuildContext context) {
    return Navigator.of(context).push<T>(
      CupertinoPageRoute(
        builder: (_) => const WeatherScreen(),
        settings: const RouteSettings(name: AppRoutes.weather),
      ),
    );
  }

  // ─── 日历 ───

  /// P12 日历面板
  static Future<T?> pushCalendar<T>(BuildContext context) {
    return Navigator.of(context).push<T>(
      CupertinoPageRoute(
        builder: (_) => const CalendarScreen(),
        settings: const RouteSettings(name: AppRoutes.calendar),
      ),
    );
  }

  // ─── 个人中心 ───

  /// P13 个人中心
  static Future<T?> pushProfile<T>(BuildContext context) {
    return Navigator.of(context).push<T>(
      CupertinoPageRoute(
        builder: (_) => const ProfileScreen(),
        settings: const RouteSettings(name: AppRoutes.profile),
      ),
    );
  }
}
