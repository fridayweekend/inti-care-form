import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inti_care/main.dart';
import 'package:inti_care/request_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class PendingRequestStore extends FakeRequestStore {
  final completion = Completer<String>();
  int writes = 0;
  bool readFails = false;
  @override
  Future<String> create(Map<String, dynamic> fields) {
    writes++;
    data = {...fields, 'status': 'submitted'};
    reference = 'pending-id';
    return completion.future;
  }

  @override
  Future<Map<String, dynamic>?> load(String id) async {
    if (readFails) throw StateError('Offline');
    return data;
  }
}

class FakeRequestStore implements RequestStore {
  Map<String, dynamic>? data;
  @override
  String? reference;
  @override
  Future<String?> restoreReference() async => reference;
  @override
  Future<String> create(Map<String, dynamic> fields) async {
    data = {...fields, 'status': 'submitted'};
    reference = 'test-server-id';
    return reference!;
  }

  @override
  Future<Map<String, dynamic>?> load(String id) async => data;
  @override
  Future<void> clearPending() async {
    reference = null;
  }

  @override
  Future<void> startNewRequest() => clearPending();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('Validation boundaries reject malformed values and past dates', () {
    expect(CampusValidators.name('Alex'), isNotNull);
    expect(CampusValidators.name('Alex Tan'), isNull);
    expect(CampusValidators.studentId('12345'), isNotNull);
    expect(CampusValidators.studentId('INTI-2026001'), isNull);
    expect(CampusValidators.email('alex@'), isNotNull);
    expect(CampusValidators.email('alex@student.example.edu'), isNull);
    expect(CampusValidators.phone(''), isNull);
    expect(CampusValidators.phone('', required: true), isNotNull);
    expect(CampusValidators.phone('+60123456789'), isNull);
    expect(CampusValidators.phone('012 345 abc'), isNotNull);
    expect(CampusValidators.details('a' * 19), isNotNull);
    expect(CampusValidators.details('a' * 20), isNull);
    expect(CampusValidators.details('a' * 500), isNull);
    expect(CampusValidators.details('a' * 501), isNotNull);
    expect(
      CampusValidators.date(DateTime(2026, 10, 5), now: DateTime(2026, 10, 6)),
      isNotNull,
    );
    expect(
      CampusValidators.date(
        DateTime(2026, 10, 6),
        now: DateTime(2026, 10, 6, 12),
      ),
      isNull,
    );
  });

  Future<void> click(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Finder field(String id) => find.descendant(
    of: find.byKey(ValueKey(id)),
    matching: find.byType(TextFormField),
  );
  Future<void> enter(WidgetTester tester, String id, String value) async {
    await tester.ensureVisible(field(id));
    await tester.enterText(field(id), value);
    await tester.pumpAndSettle();
  }

  Future<void> category(WidgetTester tester, String value) async {
    await click(tester, find.byKey(const ValueKey('category')));
    await tester.tap(find.text(value).last);
    await tester.pumpAndSettle();
  }

  Future<void> completeForm(WidgetTester tester) async {
    await enter(tester, 'name', 'Alex Tan');
    await enter(tester, 'id', 'INTI-2026001');
    await enter(tester, 'email', 'alex@student.example.edu');
    await category(tester, 'IT & Wi-Fi');
    await enter(tester, 'subject', 'Wi-Fi connection problem');
    await enter(
      tester,
      'details',
      'The library wireless network disconnects every few minutes.',
    );
    await click(tester, find.text('Normal'));
    await click(tester, find.text('Email'));
    await click(tester, find.text('Choose a date'));
    await click(tester, find.text('OK'));
    await click(tester, find.byType(Checkbox));
  }

  testWidgets(
    'Pending sync blocks duplicate taps and Reset; confirmation waits for server',
    (tester) async {
      final store = PendingRequestStore();
      await tester.pumpWidget(IntiCareApp(store: store));
      await completeForm(tester);
      await click(tester, find.text('Send request'));
      expect(find.text('Your request is saved'), findsNothing);
      expect(find.text('Pending sync…'), findsOneWidget);
      expect(
        tester
            .widget<OutlinedButton>(
              find.widgetWithText(OutlinedButton, 'Reset form'),
            )
            .onPressed,
        isNull,
      );
      expect(store.writes, 1);
      store.completion.complete('pending-id');
      await tester.pumpAndSettle();
      expect(find.text('Your request is saved'), findsOneWidget);
      expect(store.writes, 1);
    },
  );

  testWidgets('Read failure after acknowledged write does not submit again', (
    tester,
  ) async {
    final store = PendingRequestStore()..readFails = true;
    await tester.pumpWidget(IntiCareApp(store: store));
    await completeForm(tester);
    await click(tester, find.text('Send request'));
    store.completion.complete('pending-id');
    await tester.pumpAndSettle();
    await click(tester, find.text('Back to form'));
    expect(find.textContaining('Retrieval failed.'), findsOneWidget);
    expect(store.writes, 1);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Send request'),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets(
    'Restored reference can be retrieved without creating another document',
    (tester) async {
      final store = PendingRequestStore()
        ..reference = 'retained-id'
        ..data = {
          'subject': 'Previous request',
          'serviceCategory': 'Library services',
          'status': 'submitted',
          'preferredDate': Timestamp.now(),
        };
      await tester.pumpWidget(IntiCareApp(store: store));
      await tester.pumpAndSettle();
      await click(tester, find.text('Retrieve saved request'));
      expect(find.text('Request retrieved from server'), findsOneWidget);
      expect(find.textContaining('Previous request'), findsOneWidget);
      expect(store.writes, 0);
    },
  );

  testWidgets('Empty submission stays on form and preserves entered values', (
    tester,
  ) async {
    await tester.pumpWidget(IntiCareApp(store: FakeRequestStore()));
    await enter(tester, 'name', 'Alex Tan');
    await click(tester, find.text('Send request'));
    expect(find.text('Your request is saved'), findsNothing);
    expect(
      find.text('Use INTI- followed by 7 digits, e.g. INTI-2026001.'),
      findsOneWidget,
    );
    expect(find.text('Alex Tan'), findsOneWidget);
    expect(
      find.text('Please confirm the declaration before sending.'),
      findsOneWidget,
    );
  });

  testWidgets('Valid form saves summary and new request clears all controls', (
    tester,
  ) async {
    await tester.pumpWidget(IntiCareApp(store: FakeRequestStore()));
    await enter(tester, 'name', 'Alex Tan');
    await enter(tester, 'id', 'INTI-2026001');
    await enter(tester, 'email', 'alex@student.example.edu');
    await category(tester, 'Facilities & maintenance');
    await enter(tester, 'location', 'Block B, room 2-14');
    await enter(tester, 'subject', 'Study room lighting');
    await enter(
      tester,
      'details',
      'The main light in the study room is flickering during evening sessions.',
    );
    await click(tester, find.text('Normal'));
    await click(tester, find.text('Email'));
    await click(tester, find.text('Choose a date'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await click(tester, find.byType(Checkbox));
    await click(tester, find.text('Send request'));
    expect(find.text('Your request is saved'), findsOneWidget);
    expect(find.text('test-server-id'), findsOneWidget);
    expect(find.textContaining('Block B, room 2-14'), findsWidgets);
    await click(
      tester,
      find.byKey(const ValueKey('dialog-new-request-button')),
    );
    expect(find.text('Request retrieved from server'), findsOneWidget);
    await click(tester, find.text('Close'));
    expect(find.text('Choose a date'), findsOneWidget);
    expect(find.byKey(const ValueKey('location')), findsNothing);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
    for (final id in ['name', 'id', 'email', 'phone', 'subject', 'details']) {
      expect(tester.widget<TextFormField>(field(id)).controller!.text, isEmpty);
    }
    expect(
      tester
          .widgetList<ChoiceChip>(find.byType(ChoiceChip))
          .every((chip) => !chip.selected),
      isTrue,
    );
    expect(find.text('0/500'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Phone preference and conditional location validate then reset', (
    tester,
  ) async {
    await tester.pumpWidget(IntiCareApp(store: FakeRequestStore()));
    await category(tester, 'Accommodation');
    expect(find.byKey(const ValueKey('location')), findsOneWidget);
    await click(tester, find.text('Phone call'));
    await click(tester, find.text('Send request'));
    expect(
      find.text('Add a phone number when choosing a phone call.'),
      findsOneWidget,
    );
    expect(
      find.text('Tell us which building or room needs attention.'),
      findsOneWidget,
    );
    await category(tester, 'IT & Wi-Fi');
    expect(find.byKey(const ValueKey('location')), findsNothing);
    await click(tester, find.text('Reset form'));
    expect(
      find.text('Add a phone number when choosing a phone call.'),
      findsNothing,
    );
    expect(
      tester
          .widgetList<ChoiceChip>(find.byType(ChoiceChip))
          .every((chip) => !chip.selected),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  for (final width in [320.0, 390.0, 1440.0]) {
    testWidgets('Form fits $width pixels with keyboard and large text', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(IntiCareApp(store: FakeRequestStore()));
      await category(tester, 'Facilities & maintenance');
      await enter(
        tester,
        'details',
        'A useful campus service request description.',
      );
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpAndSettle();
      await click(tester, find.text('Send request'));
      expect(tester.takeException(), isNull);
      tester.view.resetViewInsets();
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(width, 900),
              textScaler: const TextScaler.linear(1.6),
            ),
            child: const CampusRequestPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
