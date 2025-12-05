import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hoora_task/screens/splash/splash_screen.dart';

import 'core/color/appcolors.dart';
import 'src/bloc/services/services_bloc.dart';
import 'src/repositories/service_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final box = await Hive.openBox<int>('favorites');

  final repository = ServiceRepository();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ServicesBloc>(
          create: (_) =>
              ServicesBloc(repository: repository, favoritesBox: box)
                ..add(FetchServices(pageSize: 20)),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HOORA Demo',
      theme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.hooraBlack,
          onPrimary: AppColors.onPrimary,
          secondary: AppColors.hooraYellow,
          onSecondary: AppColors.onSecondary,
          surface: AppColors.surface,
          onSurface: AppColors.onSurface,
          error: AppColors.error,
          onError: AppColors.onError,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.hooraBlack,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.hooraYellow,
          foregroundColor: AppColors.onSecondary,
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.onBackground,
          ),
          bodyMedium: TextStyle(fontSize: 14, color: AppColors.onBackground),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
