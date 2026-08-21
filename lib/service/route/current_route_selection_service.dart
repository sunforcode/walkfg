import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/route/route_model.dart';

/// Stores the single route selected for the v1 home experience.
class CurrentRouteSelectionService {
  CurrentRouteSelectionService._();

  static final CurrentRouteSelectionService instance =
      CurrentRouteSelectionService._();

  static const String _selectedRouteIdKey = 'walk.current_route_id';

  final ValueNotifier<String?> selectedRouteId = ValueNotifier<String?>(null);

  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    final prefs = await SharedPreferences.getInstance();
    selectedRouteId.value = prefs.getString(_selectedRouteIdKey);
    _initialized = true;
  }

  Future<String?> getSelectedRouteId() async {
    await _ensureInitialized();
    return selectedRouteId.value;
  }

  Future<void> setSelectedRoute(RouteModel route) async {
    await _ensureInitialized();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedRouteIdKey, route.id);
    selectedRouteId.value = route.id;
  }

  Future<void> clearSelectedRoute() async {
    await _ensureInitialized();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_selectedRouteIdKey);
    selectedRouteId.value = null;
  }
}
