import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pomocnik_wokalisty/helpers/full_screen_helper.dart';
import 'package:pomocnik_wokalisty/helpers/local_storage.dart';
import 'package:pomocnik_wokalisty/injection_container.dart' as di;
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';
import 'package:pomocnik_wokalisty/modules/client_screen_mode/cubit/client_screen_mode_cubit.dart';
import 'package:pomocnik_wokalisty/modules/client_screen_mode/views/client_screen_mode.dart';
import 'package:pomocnik_wokalisty/socket_connection/cubit/client_cubit/client_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockClientCubit extends MockCubit<ClientState> implements ClientCubit {}

class MockClientScreenModeCubit extends MockCubit<ClientScreenModeState>
    implements ClientScreenModeCubit {}

void main() {
  group('ClientScreenMode', () {
    late MockClientCubit mockClientCubit;
    late MockClientScreenModeCubit mockClientScreenModeCubit;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();

      SharedPreferences.setMockInitialValues({'fontSize': 20});
      await LocalStorage.init();

      const windowManagerChannel = MethodChannel('window_manager');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(windowManagerChannel,
              (MethodCall methodCall) async {
        if (methodCall.method == 'isFullScreen') {
          return false;
        }
        return null;
      });

      await di.init();

      await FullScreenHelper.init();
    });

    setUp(() {
      mockClientCubit = MockClientCubit();
      mockClientScreenModeCubit = MockClientScreenModeCubit();

      when(() => mockClientCubit.state).thenReturn(const ClientState(
          isConnected: true,
          ip: '127.0.0.1',
          connectionStarted: false,
          connectionError: false));
      when(() => mockClientCubit.dataStream)
          .thenAnswer((_) => const Stream.empty());
      when(() => mockClientCubit.stop()).thenAnswer((_) async {});
      when(() => mockClientScreenModeCubit.state)
          .thenReturn(ClientScreenModeState(text: 'Test Song Text'));
    });

    testWidgets('shows song text when connected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MultiBlocProvider(
            providers: [
              BlocProvider<ClientCubit>.value(value: mockClientCubit),
              BlocProvider<ClientScreenModeCubit>.value(
                  value: mockClientScreenModeCubit),
            ],
            child: const ClientScreenMode(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test Song Text'), findsOneWidget);
    });

    testWidgets('shows connection dialog when disconnected', (tester) async {
      when(() => mockClientCubit.state).thenReturn(const ClientState(
          isConnected: false,
          ip: '',
          connectionStarted: false,
          connectionError: false));

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MultiBlocProvider(
            providers: [
              BlocProvider<ClientCubit>.value(value: mockClientCubit),
              BlocProvider<ClientScreenModeCubit>.value(
                  value: mockClientScreenModeCubit),
            ],
            child: const ClientScreenMode(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Connection to the server'), findsOneWidget);
    });
  });
}
