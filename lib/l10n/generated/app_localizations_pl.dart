// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get addingPlaylist => 'Dodawanie playlisty';

  @override
  String get anErrorOccurredWhileRetrievingListInformation => 'Wystąpił błąd przy pobieraniu informacji o liście';

  @override
  String get areYouSureYouWantDeletSelectedLists => 'Czy na pewno chcesz usunąć zaznaczone listy?';

  @override
  String areYouSureYouWantRemoveSongFromPlaylistAtPosition(Object author, Object index, Object title) {
    return 'Czy na pewno chcesz usunąć utwór $author - $title z listy odtwarzania z pozycji $index?';
  }

  @override
  String get cancel => 'Anuluj';

  @override
  String get changesWillBeImplementedAfterSavingTheForm => 'Zmiany zostaną wprowadzone po zapisaniu formularza';

  @override
  String get clientMode => 'Tryb klienta';

  @override
  String get connecting => 'Trwa łączenie';

  @override
  String connectionError(Object error) {
    return 'Błąd połączenia: $error';
  }

  @override
  String get connectionFailed => 'Połączenie nieudane';

  @override
  String get connectionFailedCheckIp => 'Połączenie nieudane, sprawdź IP';

  @override
  String get connectionFailedPleaseReenterIp => 'Połączenie nieudane, wprowadź ponownie IP';

  @override
  String get connectionToTheServer => 'Podłączenie do serwera';

  @override
  String get deletingPlaylists => 'Usuwanie list odtwarzania';

  @override
  String get editPlaylist => 'Edytuj listę odtwarzania';

  @override
  String get enterName => 'Wprowadź nazwę';

  @override
  String get enterTheIpFromTheServerSettings => 'Wprowadź IP z ustawień serwera';

  @override
  String get error => 'Błąd';

  @override
  String get fontSize => 'Wielkość czcionki';

  @override
  String get fontSizeMustBeGreaterThan5 => 'Wielkość czcionki musi być większa od 5';

  @override
  String get ipIsRequired => 'IP jest wymagane';

  @override
  String get name => 'Nazwa';

  @override
  String get nameIsRequired => 'Nazwa jest wymagana';

  @override
  String get noConnection => 'Brak połączenia';

  @override
  String get noPlaylists => 'Brak list odtwarzania';

  @override
  String get noPlaylistsSelected => 'Brak zaznaczonych list odtwarzania';

  @override
  String get noSongsAssigned => 'Brak przypisanych utworów';

  @override
  String get noTextToDisplay => 'Brak tekstu do wyświetlenia';

  @override
  String numberOfPlaylists(Object number) {
    return 'Liczba list: $number';
  }

  @override
  String get ok => 'Ok';

  @override
  String get playlists => 'Listy odtwarzania';

  @override
  String get pleaseSelectOnlyOneListForPresentation => 'Należy zaznaczyć tylko jedną listę do prezentacji';

  @override
  String get pleaseSelectPlaylistForPresentation => 'Należy zaznaczyć listę do prezentacji';

  @override
  String get presentiaton => 'Prezentacja';

  @override
  String get presentationIsOnlyPossibleForOneList => 'Prezentacja możliwa tylko dla jednej listy';

  @override
  String get presentationScreen => 'Ekran prezentacji';

  @override
  String get presentationSettings => 'Ustawienia prezentacji';

  @override
  String get removingSongFromPlaylist => 'Usuwanie utworu z listy odtwarzania';

  @override
  String get reuseThisAddress => 'Czy ponownie użyć tego adresu?';

  @override
  String get search => 'Wyszukaj';

  @override
  String get serverSettings => 'Ustawienia serwera';

  @override
  String get singersAssistant => 'Pomocnik wokalisty';

  @override
  String get songsAddedToPlaylist => 'Utwory dodane do listy odtwarzania';

  @override
  String get songsList => 'Lista utworów';

  @override
  String get thisWillBeTheFontSize => 'Taka będzie wielkość czcionki';

  @override
  String get theAddressOfTheLastServerUsedIs => 'Adres ostatnio użytego serwera to:';

  @override
  String get thereIsAlreadyPlaylistWithThisName => 'Istnieje już lista odtwarzania z tą nazwą';

  @override
  String get theValueEnteredIsNotNumber => 'Wprowadzona wartość nie jest liczbą';

  @override
  String get yes => 'Tak';

  @override
  String get youShouldMarkThePlaylistsToBeDeleted => 'Należy zaznaczyć listy do usunięcia';
}
