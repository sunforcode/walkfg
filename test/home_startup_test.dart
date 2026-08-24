import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walk/ui/page/home/home_screen.dart';

void main() {
  testWidgets('shows the simple home shell while startup is pending', (
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

    expect(find.text('WALK'), findsOneWidget);
    expect(find.text('徒步旅行助手'), findsOneWidget);
    expect(find.text('找路线'), findsOneWidget);
    expect(find.byType(CupertinoActivityIndicator), findsNothing);
  });

  testWidgets('shows preparation feedback and ignores repeated route taps', (
    tester,
  ) async {
    final startupCompleter = Completer<void>();
    final startup = ValueNotifier<Future<void>>(startupCompleter.future);

    await tester.pumpWidget(
      CupertinoApp(
        home: HomeScreen(startup: startup),
      ),
    );

    await tester.tap(find.text('找路线'));
    await tester.pump();
    await tester.tap(find.text('准备中…'));
    await tester.pump();

    expect(find.text('准备中…'), findsOneWidget);
    expect(find.text('找路线'), findsNothing);
  });

  testWidgets('keeps the simple home shell while home data loads', (
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

    expect(find.text('WALK'), findsOneWidget);
    expect(find.text('找路线'), findsOneWidget);
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
