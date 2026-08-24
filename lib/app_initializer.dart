class AppInitializer {
  AppInitializer({
    required this.loadEnvironment,
    required this.initializeLocales,
    required this.initializeStorage,
    required this.initializeConfiguration,
    required this.initializeNetwork,
    required this.restoreAuthentication,
    required this.preloadMockData,
    required this.useMockServices,
  });

  final Future<void> Function() loadEnvironment;
  final Future<void> Function() initializeLocales;
  final Future<void> Function() initializeStorage;
  final void Function() initializeConfiguration;
  final Future<void> Function() initializeNetwork;
  final Future<void> Function() restoreAuthentication;
  final Future<void> Function() preloadMockData;
  final bool Function() useMockServices;

  bool _configurationInitialized = false;

  Future<void> initialize() async {
    await Future.wait([
      loadEnvironment(),
      initializeLocales(),
      initializeStorage(),
    ]);

    if (!_configurationInitialized) {
      initializeConfiguration();
      _configurationInitialized = true;
    }

    await initializeNetwork();
    await restoreAuthentication();

    if (useMockServices()) {
      await preloadMockData();
    }
  }
}
