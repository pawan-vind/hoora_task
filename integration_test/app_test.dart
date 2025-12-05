import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import 'package:hoora_task/screens/home/favorite_services_screen.dart';
import 'package:hoora_task/src/bloc/services/services_bloc.dart';

import '../test/helpers/fake_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('integration: tap favorite and verify state update', (
    tester,
  ) async {
    final tmp = Directory.systemTemp.createTempSync();
    Hive.init(tmp.path);
    final box = await Hive.openBox<int>('favorites');
    final bloc = ServicesBloc(repository: FakeRepository(), favoritesBox: box);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: bloc..add(FetchServices(pageSize: 20)),
          child: const FavoriteServicesScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 2));

    // tap first favorite
    final fav = find.byIcon(Icons.favorite_border).first;
    expect(fav, findsOneWidget);
    await tester.tap(fav);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(box.values.contains(1), isTrue);

    await bloc.close();
    await box.close();
    try {
      tmp.deleteSync(recursive: true);
    } catch (_) {}
  });
}
