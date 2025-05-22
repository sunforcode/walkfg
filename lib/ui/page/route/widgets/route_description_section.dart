import 'package:flutter/cupertino.dart';
import '../../../../model/model/route/route_model.dart';

/// 描述信息组件
class RouteDescriptionSection extends StatelessWidget {
  final RouteModel route;

  const RouteDescriptionSection({
    super.key,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '路线描述',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            route.description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}