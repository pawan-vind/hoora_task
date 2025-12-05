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

  testWidgets('integration: favorites persist across bloc restarts', (
    tester,
  ) async {
    final tmp = Directory.systemTemp.createTempSync();
    Hive.init(tmp.path);
    final box = await Hive.openBox<int>('favorites');
    final repo = FakeRepository();

    // Start first instance and toggle favorite
    var bloc = ServicesBloc(repository: repo, favoritesBox: box);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: bloc..add(FetchServices(pageSize: 20)),
          child: const FavoriteServicesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(find.byIcon(Icons.favorite_border).first);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(box.values.isNotEmpty, isTrue);

    await bloc.close();

    // Create a new bloc instance (simulating app restart) and ensure favorites load
    bloc = ServicesBloc(repository: repo, favoritesBox: box);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: bloc..add(FetchServices(pageSize: 20)),
          child: const FavoriteServicesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(bloc.state.favorites.isNotEmpty, isTrue);

    await bloc.close();
    await box.close();
    try {
      tmp.deleteSync(recursive: true);
    } catch (_) {}
  });
}
