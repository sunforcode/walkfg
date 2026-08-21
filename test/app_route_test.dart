import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walk/app.dart';
import 'package:walk/theme/main_layout.dart';
import 'package:walk/ui/page/route/route_discovery_screen.dart';
import 'package:walk/ui/routes/app_routes.dart';

void main() {
  testWidgets('route discovery deep link resolves on app root navigator',
      (tester) async {
    await tester.pumpWidget(const App());

    final context = tester.element(find.byType(MainLayout));
    Navigator.of(context, rootNavigator: true)
        .pushNamed(AppRoutes.routeDiscovery);
    await tester.pumpAndSettle();

    expect(find.byType(RouteDiscoveryScreen), findsOneWidget);
  });
}
