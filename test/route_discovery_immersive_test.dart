import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walk/model/route/route_enums.dart';
import 'package:walk/model/route/route_model.dart';
import 'package:walk/theme/app_theme.dart';
import 'package:walk/ui/page/common/immersive_components.dart';
import 'package:walk/ui/page/common/immersive_page_scaffold.dart';
import 'package:walk/ui/page/route/route_discovery_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  RouteModel route({
    String id = 'route-1',
    String name = '一条很长很长仍然需要保持两行可读的经典高山穿越路线',
    String? coverUrl,
  }) {
    return RouteModel(
      id: id,
      name: name,
      regionId: 'region-1',
      region: '秦岭 · 太白山',
      difficulty: RouteDifficulty.hard,
      popularity: 10,
      distanceKm: 42.6,
      elevationGainM: 1860,
      coverUrl: coverUrl,
    );
  }

  Widget app({
    required RouteDiscoveryLoader loader,
    Size size = const Size(390, 844),
    double textScale = 1,
    EdgeInsets viewPadding = EdgeInsets.zero,
  }) {
    return MediaQuery(
      data: MediaQueryData(
        size: size,
        textScaler: TextScaler.linear(textScale),
        viewPadding: viewPadding,
      ),
      child: CupertinoApp(
        theme: AppTheme.cupertino,
        builder: AppTheme.buildMaterialTheme,
        home: RouteDiscoveryScreen(routesLoader: loader),
      ),
    );
  }

  testWidgets('ignores a second route tap while selection is being saved',
      (tester) async {
    final observer = _PopCountingObserver();
    final selectionStarted = Completer<void>();
    final allowSelectionToFinish = Completer<void>();
    var selectionCalls = 0;

    await tester.pumpWidget(
      CupertinoApp(
        navigatorObservers: [observer],
        home: Builder(
          builder: (context) => CupertinoButton(
            onPressed: () => Navigator.of(context).push<void>(
              CupertinoPageRoute(
                builder: (_) => RouteDiscoveryScreen(
                  routesLoader: ({required page, required size}) async =>
                      [route()],
                  routeSelectionSaver: (_) async {
                    selectionCalls += 1;
                    if (!selectionStarted.isCompleted) {
                      selectionStarted.complete();
                    }
                    await allowSelectionToFinish.future;
                  },
                ),
              ),
            ),
            child: const Text('打开路线发现'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('打开路线发现'));
    await tester.pumpAndSettle();

    final hero = find.byKey(const Key('route-hero-route-1'));
    await tester.tap(hero);
    await selectionStarted.future;
    await tester.tap(hero);

    expect(selectionCalls, 1);

    allowSelectionToFinish.complete();
    await tester.pumpAndSettle();

    expect(observer.popCount, 1);
  });

  testWidgets('shows a route hero skeleton during the initial load',
      (tester) async {
    final pendingRoutes = Completer<List<RouteModel>>();

    await tester.pumpWidget(
      app(
        loader: ({required page, required size}) => pendingRoutes.future,
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('route-hero-skeleton')), findsOneWidget);
    expect(find.byType(CupertinoActivityIndicator), findsNothing);

    pendingRoutes.complete([route()]);
    await tester.pumpAndSettle();
  });

  testWidgets('positions top content below non-zero view padding',
      (tester) async {
    const topPadding = 47.0;

    await tester.pumpWidget(
      app(
        loader: ({required page, required size}) async => [route()],
        viewPadding: const EdgeInsets.only(top: topPadding),
      ),
    );
    await tester.pumpAndSettle();

    final scaffold = tester.widget<ImmersivePageScaffold>(
      find.byType(ImmersivePageScaffold),
    );
    expect(scaffold.leadingAction, isA<GlassIconAction>());
    expect(scaffold.trailingAction, isNull);
    expect(find.byType(CustomScrollView), findsOneWidget);
    expect(
      tester.getTopLeft(find.byKey(const Key('route-discovery-back'))).dy,
      greaterThanOrEqualTo(topPadding),
    );
    expect(
      tester.getTopLeft(find.text('WALK / 发现')).dy,
      greaterThanOrEqualTo(topPadding),
    );
  });

  testWidgets('renders one full-bleed route hero per route', (tester) async {
    final routes = [route(), route(id: 'route-2', name: '鳌太穿越')];

    await tester.pumpWidget(
      app(loader: ({required page, required size}) async => routes),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('route-hero-route-1')), findsOneWidget);
    expect(
        find.byKey(const Key('route-image-fallback-route-1')), findsOneWidget);
    expect(find.text('42.6'), findsOneWidget);
    expect(find.text('公里'), findsOneWidget);
    expect(find.byType(ImmersiveHero), findsWidgets);
    expect(find.byType(HeroTitleOverlay), findsWidgets);
    expect(find.byType(MetricGroup), findsWidgets);
    expect(find.byType(GlassIconAction), findsOneWidget);
    expect(find.bySemanticsLabel('返回'), findsOneWidget);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -620));
    await tester.pump();
    expect(find.byKey(const Key('route-hero-route-2')), findsOneWidget);
  });

  testWidgets('supports long titles and large text on a small screen',
      (tester) async {
    await tester.pumpWidget(
      app(
        loader: ({required page, required size}) async => [route()],
        size: const Size(320, 568),
        textScale: 2,
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('route-hero-route-1')), findsOneWidget);
    expect(find.byKey(const Key('route-discovery-back')), findsOneWidget);
  });

  testWidgets(
      'retries the error state without returning a Future from setState',
      (tester) async {
    var calls = 0;
    Future<List<RouteModel>> loader({
      required int page,
      required int size,
    }) async {
      calls += 1;
      if (calls == 1) throw StateError('network');
      return [route()];
    }

    await tester.pumpWidget(app(loader: loader));
    await tester.pumpAndSettle();
    expect(find.text('加载失败，点击重试'), findsOneWidget);

    await tester.tap(find.text('加载失败，点击重试'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(calls, 2);
    expect(find.byKey(const Key('route-hero-route-1')), findsOneWidget);
  });

  testWidgets('refreshes an empty state with a pull gesture', (tester) async {
    var calls = 0;
    Future<List<RouteModel>> loader({
      required int page,
      required int size,
    }) async {
      calls += 1;
      return calls == 1 ? const [] : [route()];
    }

    await tester.pumpWidget(app(loader: loader));
    await tester.pumpAndSettle();
    expect(find.text('暂无路线，下拉刷新'), findsOneWidget);

    await tester.fling(
      find.byType(CustomScrollView),
      const Offset(0, 400),
      1000,
    );
    await tester.pumpAndSettle();

    expect(calls, 2);
    expect(find.byKey(const Key('route-hero-route-1')), findsOneWidget);
  });

  testWidgets('loads 1-based pages and appends until the last page',
      (tester) async {
    final requestedPages = <int>[];
    final requestedSizes = <int>[];
    final firstPage = List.generate(
      20,
      (index) => route(id: 'page-1-$index', name: '首屏路线 $index'),
    );
    final secondPage = [route(id: 'page-2-0', name: '追加路线')];

    Future<List<RouteModel>> loader({
      required int page,
      required int size,
    }) async {
      requestedPages.add(page);
      requestedSizes.add(size);
      return switch (page) {
        1 => firstPage,
        2 => secondPage,
        _ => throw StateError('last page must stop pagination'),
      };
    }

    await tester.pumpWidget(app(loader: loader));
    await tester.pumpAndSettle();

    expect(requestedPages, [1]);
    expect(requestedSizes, [20]);

    await tester.scrollUntilVisible(
      find.byKey(const Key('route-hero-page-1-19')),
      600,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(requestedPages, [1, 2]);
    expect(find.byKey(const Key('route-hero-page-1-19')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('route-hero-page-2-0')),
      600,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('route-hero-page-2-0')), findsOneWidget);
    expect(requestedPages, [1, 2]);
  });

  testWidgets('discards an old load-more response after refresh starts',
      (tester) async {
    final stalePage = Completer<List<RouteModel>>();
    final stalePageStarted = Completer<void>();
    var firstPageCalls = 0;
    final initialRoutes = List.generate(
      20,
      (index) => route(id: 'initial-$index', name: '初始路线 $index'),
    );

    Future<List<RouteModel>> loader({
      required int page,
      required int size,
    }) async {
      if (page == 2) {
        if (!stalePageStarted.isCompleted) stalePageStarted.complete();
        return stalePage.future;
      }
      expect(page, 1);
      firstPageCalls += 1;
      return firstPageCalls == 1
          ? initialRoutes
          : [route(id: 'refreshed', name: '刷新路线')];
    }

    await tester.pumpWidget(app(loader: loader));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('route-hero-initial-19')),
      600,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    await stalePageStarted.future;

    final scrollable = tester.state<ScrollableState>(
      find.byType(Scrollable).first,
    );
    scrollable.position.jumpTo(0);
    await tester.pump();
    await tester.drag(
      find.byType(CustomScrollView),
      const Offset(0, 400),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(firstPageCalls, 2);
    expect(find.byKey(const Key('route-hero-refreshed')), findsOneWidget);

    stalePage.complete([route(id: 'stale', name: '过期分页路线')]);
    await tester.pumpAndSettle();
    scrollable.position.jumpTo(scrollable.position.maxScrollExtent);
    await tester.pump();

    expect(find.byKey(const Key('route-hero-stale')), findsNothing);
    expect(find.byKey(const Key('route-hero-refreshed')), findsOneWidget);
  });

  testWidgets('keeps existing routes when loading the next page fails',
      (tester) async {
    final requestedPages = <int>[];

    Future<List<RouteModel>> loader({
      required int page,
      required int size,
    }) async {
      requestedPages.add(page);
      if (page == 2) throw StateError('next page failed');
      return List.generate(
        size,
        (index) => route(id: 'stable-$index', name: '保留路线 $index'),
      );
    }

    await tester.pumpWidget(app(loader: loader));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('route-hero-stable-19')),
      600,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(requestedPages, [1, 2]);
    expect(find.text('加载失败，点击重试'), findsNothing);
    expect(find.byKey(const Key('route-hero-stable-19')), findsOneWidget);
  });
}

class _PopCountingObserver extends NavigatorObserver {
  int popCount = 0;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    popCount += 1;
    super.didPop(route, previousRoute);
  }
}
