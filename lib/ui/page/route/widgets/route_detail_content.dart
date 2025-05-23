import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/ui/page/map/route_map_widget.dart';
import '../../../../model/model/route/route_model.dart';
import 'route_action_buttons_section.dart';
import 'route_basic_info_section.dart';
import 'route_description_section.dart';
import 'route_detailed_info_section.dart';
import 'route_map_section.dart';

/// 路线详情内容组件
class RouteDetailContent extends StatelessWidget {
  final RouteModel route;
  final MapType currentMapType;
  final ValueChanged<MapType> onMapTypeChanged;
  final VoidCallback onViewMap;
  final VoidCallback onPlanTrip;
  final VoidCallback onFavorite;
  final bool isFavorite;

  const RouteDetailContent({
    super.key,
    required this.route,
    required this.currentMapType,
    required this.onMapTypeChanged,
    required this.onViewMap,
    required this.onPlanTrip,
    required this.onFavorite,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // 地图组件 - 放在页面顶部
        SliverToBoxAdapter(
          child: RouteMapSection(
            route: route,
            currentMapType: currentMapType,
            onMapTypeChanged: onMapTypeChanged,
          ),
        ),

        // 路线基本信息
        SliverToBoxAdapter(
          child: RouteBasicInfoSection(route: route),
        ),

        // 路线描述
        SliverToBoxAdapter(
          child: RouteDescriptionSection(route: route),
        ),

        // 路线详细信息
        SliverToBoxAdapter(
          child: RouteDetailedInfoSection(route: route),
        ),

        // 操作按钮
        SliverToBoxAdapter(
          child: RouteActionButtonsSection(
            onViewMap: onViewMap,
            onPlanTrip: onPlanTrip,
            onFavorite: onFavorite,
            isFavorite: isFavorite,
          ),
        ),

        // 底部间距
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
      ],
    );
  }
}
