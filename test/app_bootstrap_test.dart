import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walk/app_bootstrap.dart';

void main() {
  testWidgets('shows Flutter loading UI before initialization completes', (
    tester,
  ) async {
    final initialization = Completer<void>();

    await tester.pumpWidget(
      AppBootstrap(
        initialize: () => initialization.future,
        app: const MaterialApp(home: Text('应用主页')),
      ),
    );

    expect(find.text('正在加载徒步应用...'), findsOneWidget);
    expect(find.text('应用主页'), findsNothing);
  });

  testWidgets('shows the app after initialization completes', (tester) async {
    final initialization = Completer<void>();

    await tester.pumpWidget(
      AppBootstrap(
        initialize: () => initialization.future,
        app: const MaterialApp(home: Text('应用主页')),
      ),
    );

    initialization.complete();
    await tester.pumpAndSettle();

    expect(find.text('正在加载徒步应用...'), findsNothing);
    expect(find.text('应用主页'), findsOneWidget);
  });

  testWidgets('shows an error and retries failed initialization', (
    tester,
  ) async {
    var attempts = 0;
    final retryInitialization = Completer<void>();

    Future<void> initialize() {
      attempts += 1;
      if (attempts == 1) {
        return Future<void>.error(StateError('初始化失败'));
      }
      return retryInitialization.future;
    }

    await tester.pumpWidget(
      AppBootstrap(
        initialize: initialize,
        app: const MaterialApp(home: Text('应用主页')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('应用初始化失败'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);

    await tester.tap(find.text('重试'));
    await tester.pump();

    expect(attempts, 2);
    expect(find.text('正在加载徒步应用...'), findsOneWidget);

    retryInitialization.complete();
    await tester.pumpAndSettle();

    expect(find.text('应用主页'), findsOneWidget);
  });

  testWidgets('shows an error when initialization throws synchronously', (
    tester,
  ) async {
    Future<void> initialize() {
      throw StateError('同步初始化失败');
    }

    await tester.pumpWidget(
      AppBootstrap(
        initialize: initialize,
        app: const MaterialApp(home: Text('应用主页')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('应用初始化失败'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);
  });
}
