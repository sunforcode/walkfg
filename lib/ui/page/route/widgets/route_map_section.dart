import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../model/model/route/route_model.dart';
import '../../map/route_map_widget.dart';

/// 地图部分组件
class RouteMapSection extends StatelessWidget {
  final RouteModel route;
  final MapType currentMapType;
  final ValueChanged<MapType> onMapTypeChanged;

  const RouteMapSection({
    super.key,
    required this.route,
    required this.currentMapType,
    required this.onMapTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    // print('构建地图部分 - 轨迹点数量: ${route.trackPoints!.length}');
    return Text("data");
    // 如果没有轨迹点，显示提示
    //   if (route.trackPoints!.isEmpty) {
    //     print('路线没有轨迹点数据，显示提示信息');
    //     return Container(
    //       height: MediaQuery.of(context).size.height * 0.3,
    //       color: CupertinoColors.systemGrey6,
    //       child: Center(
    //         child: Column(
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             Icon(
    //               CupertinoIcons.map,
    //               size: 48,
    //               color: CupertinoColors.systemGrey,
    //             ),
    //             const SizedBox(height: 16),
    //             Text(
    //               '该路线暂无轨迹数据',
    //               style: TextStyle(
    //                 color: CupertinoColors.systemGrey,
    //                 fontSize: 16,
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     );
    //   }

    //   // 显示地图
    //   print('显示地图，轨迹点数量: ${route.trackPoints!.length}');
    //   return RouteMapWidget(
    //     route: route,
    //     height: MediaQuery.of(context).size.height * 0.3,
    //     showCurrentLocation: false,
    //     showMapTypeToolbar: true,
    //     mapType: currentMapType,
    //     onMapTypeChanged: onMapTypeChanged,
    //   );
  }
}
