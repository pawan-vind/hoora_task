import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import 'package:hoora_task/screens/home/favorite_services_screen.dart';
import 'package:hoora_task/src/bloc/services/services_bloc.dart';

import '../test/helpers/fake_repository.dart';

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
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('integration: tap favorite and verify state update', (
    tester,
  ) async {
    final tmp = Directory.systemTemp.createTempSync();
    Hive.init(tmp.path);
    final box = await Hive.openBox<int>('favorites');
    addTearDown(() async {
      if (box.isOpen) await box.close();
      try {
        tmp.deleteSync(recursive: true);
      } catch (_) {}
    });

    final bloc = ServicesBloc(repository: FakeRepository(), favoritesBox: box);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: bloc..add(FetchServices(pageSize: 20)),
          child: const FavoriteServicesScreen(),
        ),
      ),
    );

    // Wait until the first page loads and the favorite button is available
    await waitForCondition(
      tester,
      () => find.byKey(const Key('fav_1')).evaluate().isNotEmpty,
      timeout: const Duration(seconds: 8),
    );

    // tap first favorite using key
    final fav = find.byKey(const Key('fav_1'));
    expect(fav, findsOneWidget);
    await tester.tap(fav);
    await tester.pump(const Duration(milliseconds: 100));

    expect(box.values.contains(1), isTrue);

    await bloc.close();
  });
}
