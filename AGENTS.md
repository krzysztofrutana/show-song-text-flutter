# AGENTS.md

## Project Overview
Flutter mobile app "Pomocnik Wokalisty" (Singer Assistant). Source code lives in `src/`.
- **Version:** 0.9.3+6
- **SDK:** `dart: ^3.7.2` per `src/pubspec.yaml`

## Commands (all from src/ directory)
```bash
cd src
flutter pub get          # Install dependencies
flutter analyze          # Lint & static analysis
flutter test             # Run all tests
flutter test <file>      # Run single test file
flutter run              # Run on device/emulator
flutter build apk        # Build Android APK
```

## CI/CD (GitHub Actions)
- Triggers: push/PR to `master` or `develop`
- Pipeline: `pub get` → `analyze` → `test`
- Working directory: `src/`

## Architecture
- **Entry point:** `src/lib/main.dart`
- **Init order:** `DataCollections.initCollections()` (Hive) → `LocalStorage.init()` (SharedPrefs) → `EventsHub.init()` → `di.init()` (GetIt) → `FullScreenHelper.init()` → `MobileAds.initialize()` (Android only)
- **DI:** GetIt (`src/lib/injection_container.dart`)
- **State:** flutter_bloc (Cubits/Blocs)
- **Storage:** Hive (local DB), SharedPreferences
- **Modules:** `src/lib/modules/` (songs, playlists, presentation, etc.)
- **Tests:** `src/test/` (unit & widget tests)

## Key Dependencies
- `flutter_bloc` - state management
- `get_it` - dependency injection
- `hive_ce_flutter` - local database
- `google_mobile_ads` - ads (Android only)
- `mocktail` / `bloc_test` - testing

## Generated Code
Run after modifying `.dart` files with annotations:
```bash
cd src && flutter pub run build_runner build --delete-conflicting-outputs
```
Generates: Hive adapters (`src/lib/hive_registrar.g.dart`), l10n files (`src/lib/l10n/generated/`)
- `hive_registrar.g.dart` is generated but **checked in** (see its "Check in to version control" comment)

## Localization
- ARB files: `src/lib/l10n/`
- Template: `app_pl.arb` (Polish)
- Generated: `src/lib/l10n/generated/`
- App name localized via `flutter_app_name_localization`: "Singer assistant" (en) / "Pomocnik wokalisty" (pl)

## Testing Notes
- Tests use `mocktail` for mocking; `bloc_test` for bloc/cubit tests
- Repository tests mock Hive `Box<Song>` / `Box<Playlist>` directly (box passed as constructor param)
- Widget/bloc tests register mocks in GetIt (`sl.registerLazySingleton` / `sl.registerFactory`)
- See `test/helpers/songs_helper.dart` for reusable `Song` test fixtures

## Platform Notes
- Android: Mobile Ads initialized in `main.dart`
- VS Code debug configs in `.vscode/launch.json`

## Web Scraping
- `TekstowoService` (`src/lib/webscraping/sources/`) scrapes Polish lyrics from tekstowo.pl
- Requires network connectivity; errors surface to user via UI

## LAN Networking
- `src/lib/socket_connection/` has socket server (`Server`) & client (`Client`) services for presentation mode
- Uses `lan_scanner`, `network_info_plus`, `connectivity_plus` for device discovery
