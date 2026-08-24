import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walk/model/route/route_enums.dart';
import 'package:walk/model/route/route_model.dart';
import 'package:walk/theme/app_theme.dart';
import 'package:walk/theme/tokens/colors.dart';
import 'package:walk/ui/page/common/immersive_components.dart';
import 'package:walk/ui/page/common/immersive_page_scaffold.dart';
import 'package:walk/ui/page/home/home_screen.dart';
import 'package:walk/ui/page/home/widgets/empty_home.dart';
import 'package:walk/ui/page/home/widgets/route_home.dart';

void main() {
  RouteModel route({
    String name = '鳌太穿越',
    String? coverUrl,
    List<String>? imageUrls,
  }) {
    return RouteModel(
      id: 'route-1',
      name: name,
      regionId: 'region-1',
      region: '秦岭',
      difficulty: RouteDifficulty.hard,
      popularity: 10,
      distanceKm: 42.6,
      elevationGainM: 1860,
      durationMinutes: 600,
      coverUrl: coverUrl,
      imageUrls: imageUrls,
    );
  }

  HomeData data(RouteModel route) => HomeData(
        route: route,
        forecasts: const [],
        hikingDate: DateTime(2030, 5, 18),
      );

  Widget app(
    Widget child, {
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
        home: child,
      ),
    );
  }

  testWidgets('uses coverUrl as the full-screen image and applies hero scrim',
      (tester) async {
    await tester.pumpWidget(
      app(RouteHome(
        data: data(route(
          coverUrl: 'https://example.com/cover.jpg',
          imageUrls: const ['https://example.com/gallery.jpg'],
        )),
        onChangeRoute: () {},
      )),
    );
    await tester.pump();

    final image = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    expect(image.imageUrl, 'https://example.com/cover.jpg');
    expect(image.fit, BoxFit.cover);
    expect(
      tester.getSize(find.byKey(const Key('home-route-image'))),
      tester.getSize(find.byType(RouteHome)),
    );
    final hero = find.byType(ImmersiveHero);
    final scrim = find.byWidgetPredicate(
      (widget) =>
          widget is DecoratedBox &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).gradient == AppColors.heroScrim,
    );
    expect(scrim, findsOneWidget);
    expect(hero, findsOneWidget);
    expect(find.byType(HeroTitleOverlay), findsOneWidget);
    expect(find.byType(MetricGroup), findsOneWidget);
  });

  testWidgets('Home uses the immersive scaffold with its trailing menu',
      (tester) async {
    const topPadding = 47.0;

    await tester.pumpWidget(
      app(
        HomeScreen(
          dataLoader: ({RouteModel? routeHint}) async => data(route()),
          onOpenDrawer: () {},
        ),
        viewPadding: const EdgeInsets.only(top: topPadding),
      ),
    );
    await tester.pump();
    await tester.pump();

    final scaffold = tester.widget<ImmersivePageScaffold>(
      find.byType(ImmersivePageScaffold),
    );
    expect(scaffold.leadingAction, isNull);
    expect(scaffold.trailingAction, isA<GlassIconAction>());
    expect(find.byType(RouteHome), findsOneWidget);
    expect(find.byType(GlassIconAction), findsNWidgets(2));
    expect(find.bySemanticsLabel('打开菜单'), findsOneWidget);
    expect(find.bySemanticsLabel('更换路线'), findsOneWidget);
    expect(
      tester.getTopLeft(find.bySemanticsLabel('打开菜单')).dy,
      greaterThanOrEqualTo(topPadding),
    );
  });

  testWidgets('RouteHome exposes change route and invokes it once',
      (tester) async {
    var changeCalls = 0;

    await tester.pumpWidget(
      app(
        RouteHome(
          data: data(route()),
          onChangeRoute: () => changeCalls += 1,
        ),
      ),
    );
    await tester.pump();

    final action = find.bySemanticsLabel('更换路线');
    expect(action, findsOneWidget);
    await tester.tap(action);

    expect(changeCalls, 1);
  });

  testWidgets('uses the first non-empty imageUrl when coverUrl is blank',
      (tester) async {
    await tester.pumpWidget(
      app(RouteHome(
        data: data(route(
          coverUrl: '  ',
          imageUrls: const [
            '',
            '   ',
            'https://example.com/gallery-first.jpg',
            'https://example.com/gallery-second.jpg',
          ],
        )),
        onChangeRoute: () {},
      )),
    );
    await tester.pump();

    expect(
      tester
          .widget<CachedNetworkImage>(find.byType(CachedNetworkImage))
          .imageUrl,
      'https://example.com/gallery-first.jpg',
    );
  });

  testWidgets('keeps title and metrics over the trail fallback without images',
      (tester) async {
    await tester.pumpWidget(
      app(RouteHome(
        data: data(route(imageUrls: const ['', '  '])),
        onChangeRoute: () {},
      )),
    );
    await tester.pump();

    expect(find.byKey(const Key('home-route-image-fallback')), findsOneWidget);
    expect(find.text('鳌太穿越'), findsOneWidget);
    expect(find.text('42.6'), findsOneWidget);
    expect(find.text('公里'), findsOneWidget);
    expect(find.text('徒步日天气'), findsOneWidget);
    expect(find.text('推荐路线'), findsOneWidget);
  });

  testWidgets('keeps the existing empty home while home data is pending',
      (tester) async {
    final pending = Completer<HomeData?>();

    await tester.pumpWidget(
      app(HomeScreen(dataLoader: ({RouteModel? routeHint}) => pending.future)),
    );
    await tester.pump();

    expect(find.byType(EmptyHome), findsOneWidget);
    pending.complete(null);
    await tester.pumpAndSettle();
  });

  testWidgets('compact large-text overlays do not overlap', (tester) async {
    await tester.pumpWidget(
      app(
        RouteHome(
          data: data(route(
            name: '一条很长很长仍然需要保持两行可读的经典高山穿越路线',
          )),
          onChangeRoute: () {},
        ),
        size: const Size(320, 568),
        textScale: 2,
      ),
    );
    await tester.pump();

    final title = tester.widget<Text>(find.textContaining('一条很长很长'));
    expect(title.maxLines, 2);
    expect(title.style?.fontSize, 40);

    final overlays = <String, Rect>{
      'info': tester.getRect(find.byKey(const Key('home-info-overlay'))),
      'change-route':
          tester.getRect(find.byKey(const Key('home-change-route'))),
      'weather': tester.getRect(find.byKey(const Key('home-weather-overlay'))),
      if (find.byKey(const Key('home-swipe-indicator')).evaluate().isNotEmpty)
        'swipe': tester.getRect(find.byKey(const Key('home-swipe-indicator'))),
    };
    expect(find.text('推荐路线'), findsNothing);
    for (final first in overlays.entries) {
      for (final second in overlays.entries) {
        if (first.key.compareTo(second.key) >= 0) continue;
        expect(
          first.value.overlaps(second.value),
          isFalse,
          reason: '${first.key} overlaps ${second.key}: '
              '${first.value} vs ${second.value}',
        );
      }
    }
  });

  testWidgets('positions top information below non-zero view padding',
      (tester) async {
    const topPadding = 47.0;

    await tester.pumpWidget(
      app(
        RouteHome(data: data(route()), onChangeRoute: () {}),
        viewPadding: const EdgeInsets.only(top: topPadding),
      ),
    );
    await tester.pump();

    expect(
      tester.getTopLeft(find.byKey(const Key('home-info-overlay'))).dy,
      greaterThanOrEqualTo(topPadding),
    );
  });
}
