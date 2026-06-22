import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pomocnik_wokalisty/helpers/full_screen_helper.dart';
import 'package:pomocnik_wokalisty/helpers/local_storage.dart';
import 'package:pomocnik_wokalisty/helpers/wakelock_helper.dart';
import 'package:pomocnik_wokalisty/injection_container.dart' as di;
import 'package:pomocnik_wokalisty/injection_container.dart';
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';
import 'package:pomocnik_wokalisty/modules/presentation/bloc/presentation_bloc.dart';
import 'package:pomocnik_wokalisty/modules/presentation/views/presentation_view.dart';
import 'package:pomocnik_wokalisty/socket_connection/cubit/server_cubit/server_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/songs_helper.dart';

class MockPresentationBloc
    extends MockBloc<PresentationEvent, PresentationState>
    implements PresentationBloc {}

class MockServerCubit extends MockCubit<ServerState> implements ServerCubit {}

class SharedPreferencesMock extends Mock implements SharedPreferences {}

class FullScreenHelperMock extends Mock implements FullScreenHelper {}

class WakelockHelperMock extends Mock implements WakelockHelper {}

class FullScreenListenerFake extends Fake implements FullScreenListener {}

void main() {
  setUpAll(() {
    registerFallbackValue(FullScreenListenerFake());
  });

  group("PresentationScreen", () {
    late PresentationBloc presentationBlock;
    late ServerCubit serverCubit;

    setUp(() async {
      LocalStorage.instance = SharedPreferencesMock();
      await di.init();
      when(() => sl<SharedPreferences>().getInt(any())).thenReturn(15);
      when(
        () => sl<SharedPreferences>().getString(any()),
      ).thenReturn('horizontal');
      FullScreenHelper.instance = FullScreenHelperMock();
      WakelockHelper.instance = WakelockHelperMock();
      presentationBlock = MockPresentationBloc();
      serverCubit = MockServerCubit();

      when(() => FullScreenHelper.instance.addListener(any())).thenAnswer((
        invocation,
      ) {
        final listener =
            invocation.positionalArguments[0] as FullScreenListener;
        // Trigger fullscreen change after a small delay
        Future.delayed(
          Duration.zero,
          () =>
              listener.onFullScreenChanged(true, SystemUiMode.immersiveSticky),
        );
      });
      when(
        () => FullScreenHelper.instance.setFullScreen(any()),
      ).thenAnswer((_) async {});
      when(
        () => FullScreenHelper.instance.removeListener(any()),
      ).thenReturn(null);
    });

    testWidgets('BasePresentationView shows PageView and content', (
      tester,
    ) async {
      final song = SongsHelper.songHappysad30Raz;
      when(
        () => presentationBlock.state,
      ).thenReturn(PresentationActive(songs: [song]));
      when(() => serverCubit.state).thenReturn(const ServerState());

      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      tester.view.physicalSize = const Size(1080, 1920);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider.value(value: presentationBlock),
            BlocProvider.value(value: serverCubit),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: PresentationView(),
          ),
        ),
      );

      // Need multiple pumps to handle LayoutBuilder and delayed initialization
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.byType(PageView), findsOneWidget);
      expect(find.textContaining('30 raz'), findsWidgets); // Title or text

      tester.view.resetPhysicalSize();
      debugDefaultTargetPlatformOverride = null;
    });
  });
}
