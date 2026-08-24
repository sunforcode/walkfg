import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walk/ui/page/home/home_screen.dart';

void main() {
  test('web startup shell is mobile-sized and business-neutral', () {
    final index = File('web/index.html').readAsStringSync();

    expect(index, contains('name="viewport"'));
    expect(index, contains('width=device-width'));
    expect(index, contains('aria-label="Walk 正在启动"'));
    expect(index, isNot(contains('class="home-shell__button"')));
    expect(index, isNot(contains('class="home-shell__menu"')));
    expect(index, isNot(contains('还没有行程')));
  });

  testWidgets(
      'does not expose an empty business state while startup is pending', (
    tester,
  ) async {
    final startup = Completer<void>();

    await tester.pumpWidget(
      CupertinoApp(
        home: HomeScreen(
          startup: ValueNotifier<Future<void>>(startup.future),
        ),
      ),
    );

    expect(find.text('WALK'), findsNothing);
    expect(find.text('找路线'), findsNothing);
    expect(find.text('还没有行程'), findsNothing);
    expect(find.byType(CupertinoActivityIndicator), findsNothing);
  });

  testWidgets('reveals Flutter only after the home state is resolved', (
    tester,
  ) async {
    final startup = Completer<void>();
    final homeData = Completer<HomeData?>();
    var reveals = 0;

    await tester.pumpWidget(
      CupertinoApp(
        home: HomeScreen(
          startup: ValueNotifier<Future<void>>(startup.future),
          dataLoader: ({routeHint}) => homeData.future,
          onHomeReady: () => reveals += 1,
        ),
      ),
    );

    expect(reveals, 0);

    startup.complete();
    await tester.pump();
    await tester.pump();
    expect(reveals, 0);

    homeData.complete(null);
    await tester.pump();
    await tester.pump();
    expect(reveals, 1);
  });

  testWidgets('reveals Flutter when startup fails', (tester) async {
    final startup = Completer<void>();
    var reveals = 0;

    await tester.pumpWidget(
      CupertinoApp(
        home: HomeScreen(
          startup: ValueNotifier<Future<void>>(startup.future),
          onHomeReady: () => reveals += 1,
        ),
      ),
    );

    startup.completeError(StateError('startup failed'));
    await tester.pump();
    await tester.pump();

    expect(reveals, 1);
    expect(find.text('当前路线加载失败'), findsOneWidget);
  });

  testWidgets('does not expose the empty home while selected route data loads',
      (
    tester,
  ) async {
    final startup = Completer<void>();
    final homeData = Completer<HomeData?>();

    await tester.pumpWidget(
      CupertinoApp(
        home: HomeScreen(
          startup: ValueNotifier<Future<void>>(startup.future),
          dataLoader: ({routeHint}) => homeData.future,
        ),
      ),
    );

    startup.complete();
    await tester.pump();
    await tester.pump();

    expect(find.text('WALK'), findsNothing);
    expect(find.text('找路线'), findsNothing);
    expect(find.text('还没有行程'), findsNothing);
    expect(find.byType(CupertinoActivityIndicator), findsNothing);
  });

  testWidgets('retries startup after initialization failure', (tester) async {
    final firstStartup = Completer<void>();
    final secondStartup = Completer<void>();
    final startup = ValueNotifier<Future<void>>(firstStartup.future);
    var retries = 0;

    await tester.pumpWidget(
      CupertinoApp(
        home: HomeScreen(
          startup: startup,
          dataLoader: ({routeHint}) async => null,
          retryStartup: () {
            retries += 1;
            startup.value = secondStartup.future;
            return secondStartup.future;
          },
        ),
      ),
    );

    firstStartup.completeError(StateError('startup failed'));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('重试'));
    await tester.pump();

    expect(retries, 1);
    expect(find.text('WALK'), findsNothing);

    secondStartup.complete();
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.text('WALK'), findsOneWidget);
  });

  testWidgets('ignores repeated startup retry taps', (tester) async {
    final firstStartup = Completer<void>();
    final secondStartup = Completer<void>();
    final startup = ValueNotifier<Future<void>>(firstStartup.future);
    var retries = 0;

    await tester.pumpWidget(
      CupertinoApp(
        home: HomeScreen(
          startup: startup,
          retryStartup: () {
            retries += 1;
            return secondStartup.future;
          },
        ),
      ),
    );

    firstStartup.completeError(StateError('startup failed'));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('重试'));
    await tester.pump();
    await tester.tap(find.text('重试'));
    await tester.pump();

    expect(retries, 1);
  });

  testWidgets('retries only home data after home data failure', (tester) async {
    var dataLoads = 0;
    var startupRetries = 0;

    await tester.pumpWidget(
      CupertinoApp(
        home: HomeScreen(
          dataLoader: ({routeHint}) async {
            dataLoads += 1;
            if (dataLoads == 1) throw StateError('home data failed');
            return null;
          },
          retryStartup: () async {
            startupRetries += 1;
          },
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('重试'));
    await tester.pump();
    await tester.pump();

    expect(dataLoads, 2);
    expect(startupRetries, 0);
    expect(find.text('WALK'), findsOneWidget);
  });
}
