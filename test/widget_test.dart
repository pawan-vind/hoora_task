import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import 'package:hoora_task/main.dart';
import 'package:hoora_task/src/bloc/services/services_bloc.dart';
import 'helpers/fake_repository.dart';

void main() {
  testWidgets('App shows All Services after splash', (
    WidgetTester tester,
  ) async {
    final tmp = Directory.systemTemp.createTempSync();
    Hive.init(tmp.path);
    final box = await Hive.openBox<int>('favorites');
    final repo = FakeRepository();
    final bloc = ServicesBloc(repository: repo, favoritesBox: box)
      ..add(FetchServices(pageSize: 20));

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [BlocProvider<ServicesBloc>.value(value: bloc)],
        child: const MyApp(),
      ),
    );

    // Advance time for the bloc's artificial delay and allow a frame to render.
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(find.text('All Services'), findsOneWidget);

    await bloc.close();
    if (box.isOpen) await box.close();
    try {
      tmp.deleteSync(recursive: true);
    } catch (_) {}
  });
}
