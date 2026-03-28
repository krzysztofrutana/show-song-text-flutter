import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pomocnik_wokalisty/injection_container.dart';
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';
import 'package:pomocnik_wokalisty/modules/playlists/add/bloc/add_playlist_bloc.dart';
import 'package:pomocnik_wokalisty/modules/playlists/add/views/add_playlist_dialog.dart';
import 'package:pomocnik_wokalisty/modules/playlists/list/partials/list/bloc/playlists_list_component_bloc.dart'
    as playlists_bloc;
import 'package:pomocnik_wokalisty/modules/playlists/models/playlist_model.dart';
import 'package:pomocnik_wokalisty/modules/playlists/repositories/playlists_repository.dart';
import 'package:pomocnik_wokalisty/modules/songs/models/song_model.dart';
import 'package:pomocnik_wokalisty/modules/songs/repositories/songs_repository.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/add/cubit/songs_add_cubit.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/add/songs_add.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/edit/cubit/songs_edit_cubit.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/edit/songs_edit.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/list/partials/list/bloc/songs_list_component_bloc.dart'
    as songs_bloc;

class MockAddPlaylistBloc extends MockBloc<AddPlaylistEvent, AddPlaylistState>
    implements AddPlaylistBloc {}

class MockPlaylistsListComponentBloc extends MockBloc<
        playlists_bloc.PlaylistsListComponentEvent,
        playlists_bloc.PlaylistsListComponentState>
    implements playlists_bloc.PlaylistsListComponentBloc {}

class MockSongsAddCubit extends MockCubit<SongsAddState>
    implements SongsAddCubit {}

class MockSongsEditCubit extends MockCubit<SongsEditState>
    implements SongsEditCubit {}

class MockSongsListComponentBloc extends MockBloc<
        songs_bloc.SongsListComponentEvent, songs_bloc.SongsListComponentState>
    implements songs_bloc.SongsListComponentBloc {}

class MockSongsRepository extends Mock implements SongsRepository {}

class MockPlaylistsRepository extends Mock implements PlaylistsRepository {}

class SongFake extends Fake implements Song {}

class PlaylistFake extends Fake implements Playlist {}

void main() {
  setUpAll(() {
    registerFallbackValue(SongFake());
    registerFallbackValue(PlaylistFake());
    sl.registerLazySingleton<SongsRepository>(() => MockSongsRepository());
    sl.registerLazySingleton<PlaylistsRepository>(
        () => MockPlaylistsRepository());
  });

  group('AddPlaylistDialog Validation', () {
    late MockAddPlaylistBloc mockAddPlaylistBloc;
    late MockPlaylistsListComponentBloc mockPlaylistsListComponentBloc;

    setUp(() {
      mockAddPlaylistBloc = MockAddPlaylistBloc();
      mockPlaylistsListComponentBloc = MockPlaylistsListComponentBloc();

      when(() => mockAddPlaylistBloc.state).thenReturn(
        const AddPlaylistState(
          playlist: Playlist(uuid: '', name: '', songsIds: []),
        ),
      );
    });

    testWidgets('shows validation error when name is empty and save is pressed',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: MultiBlocProvider(
            providers: [
              BlocProvider<AddPlaylistBloc>.value(value: mockAddPlaylistBloc),
              BlocProvider<playlists_bloc.PlaylistsListComponentBloc>.value(
                  value: mockPlaylistsListComponentBloc),
            ],
            child: Scaffold(body: AddPlaylistDialog()),
          ),
        ),
      );

      // Verify initial state
      expect(
          find.text('Add Playlist'), findsNothing); // It's in the dialog title
      // Wait, the title in English is 'Adding playlist'? Let's check AppLocalizations
      // line 101: pl: 'Dodawanie playlisty', so en is likely 'Adding playlist'

      // Since it's an AlertDialog, it might not be visible immediately if not shown correctly
      // But here it's the home widget, so it should be visible.

      await tester
          .tap(find.text('Yes')); // The save button text is 'Yes' (Tak in PL)
      await tester.pumpAndSettle();

      // Should find 'Name is required' (localizations.nameIsRequired)
      // pl: 'Nazwa jest wymagana', en: likely 'Name is required'
      expect(find.text('Name is required'), findsOneWidget);

      // Verify that AddPlaylistUpdateAutovalidateMode was added
      verify(() => mockAddPlaylistBloc.add(
              const AddPlaylistUpdateAutovalidateMode(AutovalidateMode.always)))
          .called(1);
    });

    testWidgets('calls save when name is provided', (tester) async {
      when(() => mockAddPlaylistBloc.state).thenReturn(
        const AddPlaylistState(
          playlist: Playlist(uuid: '', name: 'My Playlist', songsIds: []),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: MultiBlocProvider(
            providers: [
              BlocProvider<AddPlaylistBloc>.value(value: mockAddPlaylistBloc),
              BlocProvider<playlists_bloc.PlaylistsListComponentBloc>.value(
                  value: mockPlaylistsListComponentBloc),
            ],
            child: Scaffold(body: AddPlaylistDialog()),
          ),
        ),
      );

      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();

      verify(() => mockAddPlaylistBloc.add(AddPlaylistSave())).called(1);
    });
  });

  group('SongsAdd Validation', () {
    late MockSongsAddCubit mockSongsAddCubit;
    late MockSongsListComponentBloc mockSongsListComponentBloc;

    setUp(() {
      mockSongsAddCubit = MockSongsAddCubit();
      mockSongsListComponentBloc = MockSongsListComponentBloc();

      when(() => mockSongsAddCubit.state).thenReturn(
        const SongsAddState(
          autovalidateMode: AutovalidateMode.disabled,
          uuid: '1',
          author: '',
          title: '',
          text: '',
          key: '',
        ),
      );
    });

    testWidgets(
        'shows validation error when fields are empty and save is pressed',
        (tester) async {
      when(() => sl<SongsRepository>().getAllSongs()).thenReturn([]);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: MultiBlocProvider(
            providers: [
              BlocProvider<songs_bloc.SongsListComponentBloc>.value(
                  value: mockSongsListComponentBloc),
            ],
            child: SongsAdd(cubit: mockSongsAddCubit),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      expect(find.text('Author is required'), findsOneWidget);
      expect(find.text('Title is required'), findsOneWidget);
      expect(find.text('Text is required'), findsOneWidget);

      verify(() =>
              mockSongsAddCubit.updateAutovalidateMode(AutovalidateMode.always))
          .called(1);
    });

    testWidgets('calls save when all fields are provided', (tester) async {
      when(() => mockSongsAddCubit.state).thenReturn(
        const SongsAddState(
          autovalidateMode: AutovalidateMode.disabled,
          uuid: '1',
          author: 'Test Author',
          title: 'Test Title',
          text: 'Test Text',
          key: 'C',
        ),
      );
      when(() => mockSongsAddCubit.save()).thenAnswer((_) async {});
      when(() => sl<SongsRepository>().getAllSongs()).thenReturn([]);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: MultiBlocProvider(
            providers: [
              BlocProvider<songs_bloc.SongsListComponentBloc>.value(
                  value: mockSongsListComponentBloc),
            ],
            child: SongsAdd(cubit: mockSongsAddCubit),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      verify(() => mockSongsAddCubit.save()).called(1);
      verify(() => mockSongsListComponentBloc.add(songs_bloc.ReloadListEvent()))
          .called(1);
    });
  });

  group('SongsEdit Validation', () {
    late MockSongsEditCubit mockSongsEditCubit;
    late MockSongsListComponentBloc mockSongsListComponentBloc;

    setUp(() {
      mockSongsEditCubit = MockSongsEditCubit();
      mockSongsListComponentBloc = MockSongsListComponentBloc();

      when(() => sl<PlaylistsRepository>().getAllPlaylists()).thenReturn([]);

      when(() => mockSongsEditCubit.state).thenReturn(
        const SongsEditState(
          autovalidateMode: AutovalidateMode.disabled,
          uuid: '1',
          author: '',
          title: '',
          text: '',
          key: '',
        ),
      );
      when(() => mockSongsEditCubit.initForm(any())).thenReturn(null);
    });

    testWidgets(
        'shows validation error when fields are empty and save is pressed',
        (tester) async {
      when(() => sl<SongsRepository>().getAllSongs()).thenReturn([]);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: MultiBlocProvider(
            providers: [
              BlocProvider<songs_bloc.SongsListComponentBloc>.value(
                  value: mockSongsListComponentBloc),
            ],
            child: SongsEdit(songId: '1', cubit: mockSongsEditCubit),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      expect(find.text('Author is required'), findsOneWidget);
      expect(find.text('Title is required'), findsOneWidget);
      expect(find.text('Text is required'), findsOneWidget);

      verify(() => mockSongsEditCubit
          .updateAutovalidateMode(AutovalidateMode.always)).called(1);
    });

    testWidgets('calls save when all fields are provided', (tester) async {
      when(() => mockSongsEditCubit.state).thenReturn(
        const SongsEditState(
          autovalidateMode: AutovalidateMode.disabled,
          uuid: '1',
          author: 'Test Author',
          title: 'Test Title',
          text: 'Test Text',
          key: 'C',
        ),
      );
      when(() => mockSongsEditCubit.save()).thenAnswer((_) async {});
      when(() => sl<SongsRepository>().getAllSongs()).thenReturn([]);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: MultiBlocProvider(
            providers: [
              BlocProvider<songs_bloc.SongsListComponentBloc>.value(
                  value: mockSongsListComponentBloc),
            ],
            child: SongsEdit(songId: '1', cubit: mockSongsEditCubit),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      verify(() => mockSongsEditCubit.save()).called(1);
      verify(() => mockSongsListComponentBloc.add(songs_bloc.ReloadListEvent()))
          .called(1);
    });
  });
}
