import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walk/model/equipment/equipment_enums.dart';
import 'package:walk/model/equipment/equipment_item_model.dart';
import 'package:walk/model/equipment/equipment_list_item_model.dart';
import 'package:walk/model/equipment/equipment_list_model.dart';
import 'package:walk/theme/app_theme.dart';
import 'package:walk/theme/tokens/colors.dart';
import 'package:walk/ui/page/common/utility_page_scaffold.dart';
import 'package:walk/ui/page/equipment/equipment_list_detail_screen.dart';

void main() {
  final list = EquipmentListModel(
    id: 'list-1',
    name: '高山徒步装备清单',
    type: EquipmentListType.personal,
    typeName: '个人',
    totalWeight: 3260,
    personCount: 2,
    status: EquipmentListStatus.preparing,
    statusName: '准备中',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
    itemCount: 1,
  );
  const relation = EquipmentListItemModel(
    equipmentListId: 'list-1',
    equipmentItemId: 'item-1',
    quantity: 2,
    notes: '放在顶袋',
  );
  final item = EquipmentItemModel(
    id: 'item-1',
    name: '轻量冲锋衣',
    category: EquipmentCategory.clothing,
    categoryName: '服装',
    weight: 320,
    weightUnit: EquipmentWeightUnit.gram,
    weightUnitName: '克',
    quantity: 1,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  EquipmentListDetailDependencies dependencies({
    Future<EquipmentListModel> Function(String)? loadList,
    Future<EquipmentItemModel> Function(String)? loadItem,
    Future<Map<String, dynamic>> Function(String)? loadWeightStats,
  }) {
    return EquipmentListDetailDependencies(
      loadList: loadList ?? (_) async => list,
      loadRelations: (_) async => [relation],
      loadItem: loadItem ?? (_) async => item,
      loadWeightStats: loadWeightStats ??
          (_) async => {'totalWeight': 3260, 'totalQuantity': 2},
    );
  }

  Widget app({
    required EquipmentListDetailDependencies dependencies,
    Size size = const Size(390, 844),
    double textScale = 1,
  }) {
    return MediaQuery(
      data: MediaQueryData(
        size: size,
        textScaler: TextScaler.linear(textScale),
      ),
      child: CupertinoApp(
        theme: AppTheme.cupertino,
        builder: AppTheme.buildMaterialTheme,
        home: EquipmentListDetailScreen(
          listId: 'list-1',
          dependencies: dependencies,
        ),
      ),
    );
  }

  testWidgets('uses the dark utility layout and renders equipment details',
      (tester) async {
    await tester.pumpWidget(app(dependencies: dependencies()));
    await tester.pumpAndSettle();

    final scaffold = tester.widget<CupertinoPageScaffold>(
      find.byType(CupertinoPageScaffold),
    );
    expect(find.byType(UtilityPageScaffold), findsOneWidget);
    expect(scaffold.backgroundColor, AppColors.bgBase);
    expect(find.byType(Image), findsNothing);
    expect(find.text('高山徒步装备清单'), findsWidgets);
    expect(find.text('轻量冲锋衣'), findsOneWidget);
    expect(find.text('服装 · 320g · 数量2'), findsOneWidget);
    expect(find.text('放在顶袋'), findsOneWidget);
    expect(find.text('重量统计'), findsOneWidget);
    expect(find.text('3.3kg'), findsNWidgets(2));
  });

  testWidgets('retries when the primary detail request fails', (tester) async {
    var calls = 0;
    Future<EquipmentListModel> loadList(String _) async {
      calls += 1;
      if (calls == 1) throw StateError('network');
      return list;
    }

    await tester.pumpWidget(
      app(dependencies: dependencies(loadList: loadList)),
    );
    await tester.pumpAndSettle();
    expect(find.text('重试'), findsOneWidget);

    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();

    expect(calls, 2);
    expect(find.text('高山徒步装备清单'), findsWidgets);
  });

  testWidgets('keeps main content when optional detail requests fail',
      (tester) async {
    await tester.pumpWidget(
      app(
        dependencies: dependencies(
          loadItem: (_) async => throw StateError('item'),
          loadWeightStats: (_) async => throw StateError('stats'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('高山徒步装备清单'), findsWidgets);
    expect(find.text('未知装备'), findsOneWidget);
    expect(find.text('重量统计'), findsNothing);
  });

  testWidgets('supports long content and large text on a small screen',
      (tester) async {
    await tester.pumpWidget(
      app(
        dependencies: dependencies(),
        size: const Size(320, 568),
        textScale: 2,
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('高山徒步装备清单'), findsWidgets);
  });
}
