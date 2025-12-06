import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import 'package:hoora_task/screens/home/favorite_services_screen.dart';
import 'package:hoora_task/src/bloc/services/services_bloc.dart';

import 'helpers/fake_repository.dart';

void main() {
  group('FavoriteServicesScreen widget tests', () {
    late Directory tmpDir;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync();
      Hive.init(tmpDir.path);
    });

    tearDown(() async {
      await Hive.deleteBoxFromDisk('favorites');
      try {
        tmpDir.deleteSync(recursive: true);
      } catch (_) {}
    });

    testWidgets('initial load shows list of 20 services', (tester) async {
      final box = await Hive.openBox<int>('favorites');
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

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Service 1'), findsOneWidget);

      expect(find.text('Service 20'), findsOneWidget);

      await bloc.close();
      await box.close();
    });

    testWidgets('tapping favorite toggles and persists', (tester) async {
      final box = await Hive.openBox<int>('favorites');
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

      await tester.pumpAndSettle(const Duration(seconds: 2));

      final favButton = find.byIcon(Icons.favorite_border).first;
      expect(favButton, findsOneWidget);

      await tester.tap(favButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(box.values.contains(1), isTrue);

      await bloc.close();
      await box.close();
    });

    testWidgets('pagination appends more items when scrolled', (tester) async {
      final box = await Hive.openBox<int>('favorites');
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

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Service 20'), findsOneWidget);

      await tester.drag(find.byType(ListView).first, const Offset(0, -2000));
      await tester.pumpAndSettle(const Duration(seconds: 2));
 
      expect(find.text('Service 40'), findsOneWidget);

      await bloc.close();
      await box.close();
    });
  });
}
