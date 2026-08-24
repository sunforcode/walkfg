import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walk/core/config/app_config.dart';
import 'package:walk/core/network/api_client.dart';
import 'package:walk/core/network/interceptors/mock_interceptor.dart';
import 'package:walk/model/route/route_model.dart';
import 'package:walk/service/route/current_route_selection_service.dart';
import 'package:walk/ui/page/route/route_discovery_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
    AppConfig.instance.initialize(useMockServices: true);
    ApiClient.instance.dio.interceptors.add(MockInterceptor());
  });

  testWidgets('selecting a route saves it and returns it to the previous page',
      (tester) async {
    RouteModel? selectedRoute;

    await tester.pumpWidget(
      CupertinoApp(
        home: Builder(
          builder: (context) => CupertinoPageScaffold(
            child: CupertinoButton(
              onPressed: () async {
                selectedRoute = await Navigator.of(context).push<RouteModel>(
                  CupertinoPageRoute(
                    builder: (_) => const RouteDiscoveryScreen(),
                  ),
                );
              },
              child: const Text('选择路线'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('选择路线'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('鳌太穿越'), findsOneWidget);
    await tester.tap(find.text('鳌太穿越'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(selectedRoute?.id, 'route_001');
    expect(
      await CurrentRouteSelectionService.instance.getSelectedRouteId(),
      'route_001',
    );
    expect(find.byType(RouteDiscoveryScreen), findsNothing);
  });
}
