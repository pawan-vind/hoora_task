# hoora_task

This repository contains the Hoora demo Flutter app with a "Favorite Services" screen, Hive persistence for favorites, pagination, and tests.

## Prerequisites
- Flutter SDK (>= stable). Install from https://flutter.dev
- A connected device or emulator/simulator for `flutter run`.

## Install dependencies
Run the following in the project root:

```bash
flutter pub get
```

## Run the app
- To run on the default connected device or emulator:

```bash
flutter run
```

- To run on a specific device (list devices first):

```bash
flutter devices
flutter run -d <device-id>
```

Notes:
- The app uses Hive for local persistence (favorites). The app initializes Hive automatically in `main.dart`.

## Run tests

- Run unit & widget tests:

```bash
flutter test
```

- Run integration tests (integration tests are located in `integration_test/`):

```bash
flutter test integration_test
```

- Run a single test file:

```bash
flutter test test/favorite_services_widget_test.dart
```

If your integration tests require a device you can target an emulator or physical device before running them.

## Demo video
- A demo video is included at `assets/demo_video.mov` in the repository. You can open it with QuickTime (macOS) or any compatible media player.

## Troubleshooting
- If tests reference missing Hive boxes during CI or test runs, ensure tests initialize Hive with a temporary directory (tests in this repo create a temp Hive directory).
- If you see failures related to missing assets, run `flutter pub get` and ensure `assets/` entries are declared in `pubspec.yaml`.

## Contact / Notes
- This README is minimal — if you want, I can add CI steps, a demo GIF in the README, or a quick script to run the integration tests on a device.

