import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:walk/app_initializer.dart';

void main() {
  test('starts independent foundation initialization concurrently', () async {
    final environment = Completer<void>();
    final locales = Completer<void>();
    final storage = Completer<void>();
    final calls = <String>[];

    final initializer = AppInitializer(
      loadEnvironment: () {
        calls.add('environment');
        return environment.future;
      },
      initializeLocales: () {
        calls.add('locales');
        return locales.future;
      },
      initializeStorage: () {
        calls.add('storage');
        return storage.future;
      },
      initializeConfiguration: () => calls.add('configuration'),
      initializeNetwork: () async => calls.add('network'),
      restoreAuthentication: () async => calls.add('authentication'),
      preloadMockData: () async => calls.add('mock'),
      useMockServices: () => false,
    );

    final initialization = initializer.initialize();
    await Future<void>.delayed(Duration.zero);

    expect(calls, ['environment', 'locales', 'storage']);

    environment.complete();
    locales.complete();
    storage.complete();
    await initialization;

    expect(calls, [
      'environment',
      'locales',
      'storage',
      'configuration',
      'network',
      'authentication',
    ]);
  });

  test('waits for network initialization before restoring authentication',
      () async {
    final network = Completer<void>();
    final calls = <String>[];

    final initializer = AppInitializer(
      loadEnvironment: () async {},
      initializeLocales: () async {},
      initializeStorage: () async {},
      initializeConfiguration: () => calls.add('configuration'),
      initializeNetwork: () {
        calls.add('network');
        return network.future;
      },
      restoreAuthentication: () async => calls.add('authentication'),
      preloadMockData: () async => calls.add('mock'),
      useMockServices: () => false,
    );

    final initialization = initializer.initialize();
    await Future<void>.delayed(Duration.zero);

    expect(calls, ['configuration', 'network']);

    network.complete();
    await initialization;

    expect(calls, ['configuration', 'network', 'authentication']);
  });

  test('preloads mock data only when mock services are enabled', () async {
    var preloadCount = 0;

    AppInitializer createInitializer(bool useMockServices) {
      return AppInitializer(
        loadEnvironment: () async {},
        initializeLocales: () async {},
        initializeStorage: () async {},
        initializeConfiguration: () {},
        initializeNetwork: () async {},
        restoreAuthentication: () async {},
        preloadMockData: () async => preloadCount += 1,
        useMockServices: () => useMockServices,
      );
    }

    await createInitializer(false).initialize();
    expect(preloadCount, 0);

    await createInitializer(true).initialize();
    expect(preloadCount, 1);
  });
}
