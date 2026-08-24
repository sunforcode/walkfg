import 'dart:async';

import 'package:flutter/material.dart';

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({
    required this.initialize,
    required this.app,
    super.key,
  });

  final Future<void> Function() initialize;
  final Widget app;

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = _startInitialization();
  }

  Future<void> _startInitialization() {
    return Future<void>.sync(widget.initialize);
  }

  void _retry() {
    setState(() {
      _initialization = _startInitialization();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _InitializationLoadingApp();
        }
        if (snapshot.hasError) {
          return _InitializationErrorApp(onRetry: _retry);
        }
        return widget.app;
      },
    );
  }
}

class _InitializationLoadingApp extends StatelessWidget {
  const _InitializationLoadingApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('正在加载徒步应用...'),
            ],
          ),
        ),
      ),
    );
  }
}

class _InitializationErrorApp extends StatelessWidget {
  const _InitializationErrorApp({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('应用初始化失败'),
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('重试')),
            ],
          ),
        ),
      ),
    );
  }
}
