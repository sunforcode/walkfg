import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walk/model/equipment/equipment_enums.dart';
import 'package:walk/model/equipment/equipment_list_model.dart';
import 'package:walk/service/equipment_service.dart';
import 'package:walk/theme/app_theme.dart';
import 'package:walk/theme/tokens/colors.dart';
import 'package:walk/ui/page/common/utility_page_scaffold.dart';
import 'package:walk/ui/page/equipment/equipment_list_list_screen.dart';

void main() {
  EquipmentListModel equipmentList({
    String id = 'list-1',
    String name = '两天一夜高山徒步装备清单',
  }) {
    return EquipmentListModel(
      id: id,
      name: name,
      type: EquipmentListType.personal,
      typeName: '个人',
      totalWeight: 3260,
      personCount: 2,
      status: EquipmentListStatus.preparing,
      statusName: '准备中',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
      itemCount: 12,
    );
  }

  Widget app({
    required EquipmentListsLoader loader,
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
        home: EquipmentListListScreen(listsLoader: loader),
      ),
    );
  }

  testWidgets('uses a dark utility layout without decorative imagery',
      (tester) async {
    await tester.pumpWidget(
      app(
          loader: ({required page}) async =>
              equipmentListPage([equipmentList()])),
    );
    await tester.pumpAndSettle();

    final scaffold = tester.widget<CupertinoPageScaffold>(
      find.byType(CupertinoPageScaffold),
    );
    expect(find.byType(UtilityPageScaffold), findsOneWidget);
    expect(scaffold.backgroundColor, AppColors.bgBase);
    expect(find.text('装备清单'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.add), findsOneWidget);
    expect(find.byType(Image), findsNothing);
    expect(find.byKey(const Key('equipment-list-card-list-1')), findsOneWidget);
    expect(find.text('12 件装备'), findsOneWidget);
    expect(find.text('2 人'), findsOneWidget);
    expect(find.text('3.3kg'), findsOneWidget);
  });

  testWidgets('keeps the empty state available', (tester) async {
    await tester.pumpWidget(
      app(loader: ({required page}) async => equipmentListPage(const [])),
    );
    await tester.pumpAndSettle();

    expect(find.text('暂无装备清单'), findsOneWidget);
    expect(find.text('新建清单'), findsOneWidget);
  });

  testWidgets('retries a failed initial load', (tester) async {
    var calls = 0;
    Future<EquipmentPageResult<EquipmentListModel>> loader({
      required int page,
    }) async {
      calls += 1;
      if (calls == 1) throw StateError('network');
      return equipmentListPage([equipmentList()]);
    }

    await tester.pumpWidget(app(loader: loader));
    await tester.pumpAndSettle();
    expect(find.text('重试'), findsOneWidget);

    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();

    expect(calls, 2);
    expect(find.byKey(const Key('equipment-list-card-list-1')), findsOneWidget);
  });

  testWidgets('supports a long title and large text on a small screen',
      (tester) async {
    await tester.pumpWidget(
      app(
        loader: ({required page}) async => equipmentListPage([
          equipmentList(
            name: '这是一份非常非常长但在小屏幕和大字体下仍应保持可读的装备清单',
          ),
        ]),
        size: const Size(320, 568),
        textScale: 2,
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('equipment-list-card-list-1')), findsOneWidget);
  });

  testWidgets('discards an old pagination response after refresh',
      (tester) async {
    final stalePage = Completer<EquipmentPageResult<EquipmentListModel>>();
    final refreshPage = Completer<EquipmentPageResult<EquipmentListModel>>();
    final requestedPages = <int>[];
    var pageZeroCalls = 0;

    Future<EquipmentPageResult<EquipmentListModel>> loader({
      required int page,
    }) {
      requestedPages.add(page);
      if (page == 0) {
        pageZeroCalls += 1;
        if (pageZeroCalls == 1) {
          return Future.value(
            equipmentListPage([equipmentList(id: 'initial')], hasMore: true),
          );
        }
        return refreshPage.future;
      }
      if (page == 1 &&
          requestedPages.where((value) => value == 1).length == 1) {
        return stalePage.future;
      }
      return Future.value(equipmentListPage(const []));
    }

    await tester.pumpWidget(app(loader: loader));
    await tester.pumpAndSettle();

    final scrollContext = tester.element(find.byType(CustomScrollView));
    final onScroll = equipmentScrollListener(tester).onNotification!;
    final refreshCallback = tester
        .widget<CupertinoSliverRefreshControl>(
          find.byType(CupertinoSliverRefreshControl, skipOffstage: false),
        )
        .onRefresh!;
    onScroll(bottomNotification(scrollContext));
    await tester.pump();
    expect(requestedPages, [0, 1]);

    final refreshFuture = refreshCallback();
    await tester.pump();
    expect(requestedPages, [0, 1, 0]);

    refreshPage.complete(
      equipmentListPage([equipmentList(id: 'refreshed')], hasMore: true),
    );
    await refreshFuture;
    await tester.pump();

    stalePage.complete(
      equipmentListPage([equipmentList(id: 'stale')], hasMore: true, page: 1),
    );
    await tester.pump();

    expect(
        find.byKey(const Key('equipment-list-card-refreshed')), findsOneWidget);
    expect(find.byKey(const Key('equipment-list-card-stale')), findsNothing);

    final refreshedScrollContext =
        tester.element(find.byType(CustomScrollView));
    equipmentScrollListener(tester)
        .onNotification!(bottomNotification(refreshedScrollContext));
    await tester.pumpAndSettle();
    expect(requestedPages.last, 1);
  });

  testWidgets('does not paginate while refresh is loading', (tester) async {
    final refreshPage = Completer<EquipmentPageResult<EquipmentListModel>>();
    final requestedPages = <int>[];
    var pageZeroCalls = 0;

    Future<EquipmentPageResult<EquipmentListModel>> loader({
      required int page,
    }) {
      requestedPages.add(page);
      if (page == 0 && pageZeroCalls++ == 0) {
        return Future.value(
          equipmentListPage([equipmentList()], hasMore: true),
        );
      }
      if (page == 0) return refreshPage.future;
      return Future.value(equipmentListPage(const []));
    }

    await tester.pumpWidget(app(loader: loader));
    await tester.pumpAndSettle();

    final scrollContext = tester.element(find.byType(CustomScrollView));
    final onScroll = equipmentScrollListener(tester).onNotification!;
    final refreshCallback = tester
        .widget<CupertinoSliverRefreshControl>(
          find.byType(CupertinoSliverRefreshControl, skipOffstage: false),
        )
        .onRefresh!;
    final refreshFuture = refreshCallback();
    await tester.pump();

    onScroll(bottomNotification(scrollContext));
    await tester.pump();
    expect(requestedPages, [0, 0]);

    refreshPage.complete(equipmentListPage([equipmentList()]));
    await refreshFuture;
    await tester.pump();
  });

  testWidgets('respects non-zero view padding through SafeArea',
      (tester) async {
    const viewPadding = EdgeInsets.only(top: 44, bottom: 34);
    await tester.pumpWidget(
      app(
        loader: ({required page}) async => equipmentListPage([equipmentList()]),
        viewPadding: viewPadding,
      ),
    );
    await tester.pumpAndSettle();

    final safeAreaFinder = find.descendant(
      of: find.byType(UtilityPageScaffold),
      matching: find.byType(SafeArea),
    );
    expect(safeAreaFinder, findsWidgets);
    final safeAreas = tester.widgetList<SafeArea>(safeAreaFinder);
    expect(
      safeAreas.any((safeArea) => safeArea.top && safeArea.bottom),
      isTrue,
    );
    expect(
      tester.getBottomRight(find.byType(CustomScrollView)).dy,
      lessThanOrEqualTo(844 - viewPadding.bottom),
    );
  });
}

NotificationListener<ScrollNotification> equipmentScrollListener(
  WidgetTester tester,
) {
  return tester
      .widgetList<NotificationListener<ScrollNotification>>(
        find.byType(NotificationListener<ScrollNotification>),
      )
      .firstWhere((listener) => listener.child is CustomScrollView);
}

ScrollEndNotification bottomNotification(BuildContext context) {
  return ScrollEndNotification(
    metrics: FixedScrollMetrics(
      minScrollExtent: 0,
      maxScrollExtent: 100,
      pixels: 100,
      viewportDimension: 100,
      axisDirection: AxisDirection.down,
      devicePixelRatio: 1,
    ),
    context: context,
  );
}

EquipmentPageResult<EquipmentListModel> equipmentListPage(
  List<EquipmentListModel> content, {
  bool hasMore = false,
  int page = 0,
}) {
  return EquipmentPageResult(
    content: content,
    totalElements: hasMore ? content.length + 1 : content.length,
    totalPages: hasMore ? page + 2 : page + 1,
    page: page,
    size: 10,
  );
}
