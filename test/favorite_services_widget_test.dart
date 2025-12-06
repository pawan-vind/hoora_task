import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import 'package:hoora_task/screens/home/favorite_services_screen.dart';
import 'package:hoora_task/src/bloc/services/services_bloc.dart';

import 'helpers/fake_repository.dart';

Future<void> waitForCondition(
  WidgetTester tester,
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final end = DateTime.now().add(timeout);
  while (!condition()) {
    if (DateTime.now().isAfter(end)) {
      throw Exception('Timeout waiting for condition');
    }
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  group('FavoriteServicesScreen widget tests', () {
    late Directory tmpDir;
    late Box<int> box;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync();
      Hive.init(tmpDir.path);
      box = await Hive.openBox<int>('favorites');
    });

    tearDown(() async {
      if (box.isOpen) await box.close();
      await Hive.deleteBoxFromDisk('favorites');
      try {
        tmpDir.deleteSync(recursive: true);
      } catch (_) {}
    });

    testWidgets('initial load shows list of 20 services', (tester) async {
      final repo = FakeRepository();
      final bloc = ServicesBloc(repository: repo, favoritesBox: box);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc..add(FetchServices(pageSize: 20)),
            child: const FavoriteServicesScreen(),
          ),
        ),
      );

      expect(find.byType(RefreshIndicator), findsNothing);

      await waitForCondition(tester, () => bloc.state.services.length == 20);

      expect(find.text('Service 1'), findsOneWidget);

      expect(bloc.state.services.length, equals(20));

      await bloc.close();
      await box.close();
    });

    testWidgets('tapping favorite toggles and persists', (tester) async {
      final repo = FakeRepository();
      final bloc = ServicesBloc(repository: repo, favoritesBox: box);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc..add(FetchServices(pageSize: 20)),
            child: const FavoriteServicesScreen(),
          ),
        ),
      );

      await waitForCondition(
        tester,
        () => find.byKey(const Key('fav_1')).evaluate().isNotEmpty,
      );

      final favButton = find.byKey(const Key('fav_1'));
      expect(favButton, findsOneWidget);

      await tester.tap(favButton);
      await tester.pump(const Duration(milliseconds: 100));

      expect(box.values.contains(1), isTrue);

      await bloc.close();
      await box.close();
    });

    testWidgets('pagination appends more items when scrolled', (tester) async {
      final repo = FakeRepository();
      final bloc = ServicesBloc(repository: repo, favoritesBox: box);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc..add(FetchServices(pageSize: 20)),
            child: const FavoriteServicesScreen(),
          ),
        ),
      );

      await waitForCondition(tester, () => bloc.state.services.length == 20);
      expect(find.text('Service 20'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Service 40'),
        400.0,
        scrollable: find.byType(Scrollable).first,
      );
      await waitForCondition(
        tester,
        () => find.text('Service 40').evaluate().isNotEmpty,
        timeout: const Duration(seconds: 8),
      );

      expect(find.text('Service 40'), findsOneWidget);

      await bloc.close();
      await box.close();
    });
  });
}
