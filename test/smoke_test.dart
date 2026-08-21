import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

/// 冒烟测试：保证 flutter test 有可执行用例，验证基础框架可加载。
/// 后续补齐真实单元测试后，此文件可保留或删除。
void main() {
  testWidgets('framework loads and builds a widget', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Text('smoke'))));
    expect(find.text('smoke'), findsOneWidget);
  });
}
