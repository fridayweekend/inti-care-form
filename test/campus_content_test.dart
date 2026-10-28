import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inti_care/main.dart';
import 'package:inti_care/screens/campus_content_screens.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widget_test.dart' show FakeRequestStore;
import 'package:inti_care/data/campus_data.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  testWidgets('Request draft survives campus navigation', (tester) async {
    await tester.pumpWidget(IntiCareApp(store: FakeRequestStore()));
    final name = find.descendant(
      of: find.byKey(const ValueKey('name')),
      matching: find.byType(TextFormField),
    );
    await tester.ensureVisible(name);
    await tester.enterText(name, 'Alex Tan');
    for (final destination in [
      'nav-announcements',
      'nav-services',
      'nav-request',
    ]) {
      await tester.tap(find.byKey(ValueKey(destination)));
      await tester.pumpAndSettle();
    }
    expect(tester.widget<TextFormField>(name).controller!.text, 'Alex Tan');
    expect(tester.takeException(), isNull);
  });
  testWidgets('Bookmarks survive details and tab changes', (tester) async {
    await tester.pumpWidget(IntiCareApp(store: FakeRequestStore()));
    await tester.tap(find.byKey(const ValueKey('nav-announcements')));
    await tester.pumpAndSettle();
    final bookmark = find.byKey(const ValueKey('bookmark-wellbeing-workshop'));
    await tester.tap(bookmark);
    await tester.pump();
    expect(tester.widget<IconButton>(bookmark).isSelected, isTrue);
    await tester.tap(find.text(announcements[1].title));
    await tester.pumpAndSettle();
    expect(find.text(announcements[1].detail), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(tester.widget<IconButton>(bookmark).isSelected, isTrue);
    await tester.tap(find.byIcon(Icons.grid_view));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.campaign_outlined));
    await tester.pumpAndSettle();
    expect(tester.widget<IconButton>(bookmark).isSelected, isTrue);
    await tester.tap(bookmark);
    await tester.pump();
    expect(tester.widget<IconButton>(bookmark).isSelected, isFalse);
  });

  testWidgets('Eighth announcement opens its own detail', (tester) async {
    await tester.pumpWidget(IntiCareApp(store: FakeRequestStore()));
    await tester.tap(find.byKey(const ValueKey('nav-announcements')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text(announcements.last.title), 250);
    await tester.tap(find.text(announcements.last.title));
    await tester.pumpAndSettle();
    expect(find.text(announcements.last.detail), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text(announcements.last.title), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('All six services open matching information', (tester) async {
    await tester.pumpWidget(IntiCareApp(store: FakeRequestStore()));
    await tester.tap(find.byKey(const ValueKey('nav-announcements')));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.grid_view));
    await tester.pumpAndSettle();
    for (final service in services) {
      final tile = find.byKey(ValueKey('service-${service.id}'));
      await tester.ensureVisible(tile);
      await tester.tap(tile);
      await tester.pumpAndSettle();
      expect(find.text(service.detailDestination.description), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
  });

  for (final width in [320.0, 420.0, 700.0, 1000.0]) {
    for (final scale in [1.0, 2.0, 3.0]) {
      testWidgets('Grid fits width $width at scale $scale', (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: const Scaffold(body: ServicesScreen()),
            ),
          ),
        );
        final grid = tester.widget<GridView>(find.byType(GridView));
        final delegate =
            grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(
          delegate.crossAxisCount,
          width >= 700
              ? 4
              : width >= 420
              ? 3
              : 2,
        );
        for (final service in services) {
          await tester.ensureVisible(
            find.byKey(ValueKey('service-${service.id}')),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      });
    }
  }
}
