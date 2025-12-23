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
  String get addSong => 'Dodaj utwór';

  @override
  String get addTo => 'Dodaj do';

  @override
  String get addToPlaylistSentence => 'Dodaj do playlisty';

  @override
  String get addingToPlaylist => 'Dodawanie do playlisty';

  @override
  String get and => 'i';

  @override
  String get anErrorOccurredWhileTryingToChangeYourPrivacyPreferences => 'Wystąpił błąd podczas próby zmiany preferencji prywatności';

  @override
  String get anErrorOccurredWhileRetrievingListInformation => 'Wystąpił błąd przy pobieraniu informacji o liście';

  @override
  String get areYouSureYouWantDeletSelectedLists => 'Czy na pewno chcesz usunąć zaznaczone listy?';

  @override
  String get areYouSureYouWantDeleteSelectedSongs => 'Czy na pewno chcesz usunąć zaznaczone utwory?';

  @override
  String areYouSureYouWantRemoveCurrentSongFromPlaylistAtPosition(Object name, Object position) {
    return 'Czy na pewno chcesz usunąć utwór z listy odtwarzania $name z pozycji $position?';
  }

  @override
  String areYouSureYouWantRemoveSongFromPlaylistAtPosition(Object author, Object index, Object title) {
    return 'Czy na pewno chcesz usunąć utwór $author - $title z listy odtwarzania z pozycji $index?';
  }

  @override
  String get areYouSureYouWantToLeaveTheApplication => 'Czy na pewno chcesz opuścić aplikację?';

  @override
  String get author => 'Autor';

  @override
  String get authorIsRequired => 'Autor jest wymagany';

  @override
  String get cancel => 'Anuluj';

  @override
  String get changePrivacyPolicy => 'Zmień preferencje prywatności';

  @override
  String get changesWillBeImplementedAfterSavingTheForm => 'Zmiany zostaną wprowadzone po zapisaniu formularza';

  @override
  String get clientMode => 'Tryb klienta';

  @override
  String get confirm => 'Zatwierdź';

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
  String get couldntFindMatchingArtist => 'Nie udało się znaleźć pasującego artysty';

  @override
  String get couldntFindMatchingSong => 'Nie udało się znaleźć pasującego utworu';

  @override
  String get couldNotFindTextForGivenParameters => 'Nie udało się znaleźć tekstu do podanych parametrów';

  @override
  String get create => 'Utwórz';

  @override
  String get createPlaylist => 'Utwórz playlistę';

  @override
  String get createPresentationError => 'Błąd uruchamiania prezentacji';

  @override
  String get currentIP => 'Aktualne IP:';

  @override
  String get delete => 'Usuń';

  @override
  String get deletingPlaylists => 'Usuwanie list odtwarzania';

  @override
  String get deletingSongs => 'Usuwanie utworów';

  @override
  String get editPlaylist => 'Edytuj listę odtwarzania';

  @override
  String get editSong => 'Edytuj utwór';

  @override
  String get enterName => 'Wprowadź nazwę';

  @override
  String get enterTheIpFromTheServerSettings => 'Wprowadź IP z ustawień serwera';

  @override
  String get error => 'Błąd';

  @override
  String errorWithMessage(Object message) {
    return 'Błąd: $message';
  }

  @override
  String get exitApplication => 'Wyjście z aplikacji';

  @override
  String get fontSize => 'Wielkość czcionki';

  @override
  String get fontSizeMustBeGreaterThan5 => 'Wielkość czcionki musi być większa od 5';

  @override
  String get ipIsRequired => 'IP jest wymagane';

  @override
  String get language => 'Język:';

  @override
  String get leave => 'Wyjdź';

  @override
  String get loading => 'Ładowanie...';

  @override
  String get name => 'Nazwa';

  @override
  String get nameIsRequired => 'Nazwa jest wymagana';

  @override
  String get noActiveInternetConnection => 'Brak aktywnego połączenia internetowego';

  @override
  String get noConnection => 'Brak połączenia';

  @override
  String get noPlaylists => 'Brak list odtwarzania';

  @override
  String get noPlaylistsSelected => 'Brak zaznaczonych list odtwarzania';

  @override
  String get noSongs => 'Brak utworów';

  @override
  String get noSongsAssigned => 'Brak przypisanych utworów';

  @override
  String get noSongsSelected => 'Brak zaznaczonych utworów';

  @override
  String get noTextToDisplay => 'Brak tekstu do wyświetlenia';

  @override
  String numberOfConnectedDevices(Object number) {
    return 'Liczba podłączonych urządzeń: $number';
  }

  @override
  String numberOfPlaylists(Object number) {
    return 'Liczba list: $number';
  }

  @override
  String numberOfSongs(Object number) {
    return 'Liczba utworów: $number';
  }

  @override
  String get ok => 'Ok';

  @override
  String get parametersProvidedAreIncorrect => 'Podane parametry są niepoprawne';

  @override
  String get playlists => 'Listy odtwarzania';

  @override
  String get playlistsToWhichSongHasBeenAdded => 'Listy odtwarzania do których dodano utwór';

  @override
  String get pleaseSelectOnlyOneListForPresentation => 'Należy zaznaczyć tylko jedną listę do prezentacji';

  @override
  String get pleaseSelectPlaylistForPresentation => 'Należy zaznaczyć listę do prezentacji';

  @override
  String position(Object position) {
    return 'Pozycja: $position';
  }

  @override
  String get presentiaton => 'Prezentacja';

  @override
  String get presentationIsOnlyPossibleForOneList => 'Prezentacja możliwa tylko dla jednej listy';

  @override
  String get presentationScreen => 'Ekran prezentacji';

  @override
  String get presentationSettings => 'Ustawienia prezentacji';

  @override
  String get privacyPolicy => 'Polityka prywatności';

  @override
  String get removingSongFromPlaylist => 'Usuwanie utworu z listy odtwarzania';

  @override
  String get reuseThisAddress => 'Czy ponownie użyć tego adresu?';

  @override
  String get search => 'Wyszukaj';

  @override
  String get searchInProgress => 'Trwa wyszukiwanie';

  @override
  String get searching => 'Searching';

  @override
  String get selectSong => 'Wybierz utwór';

  @override
  String get serverDown => 'Serwer wyłączony';

  @override
  String get serverSettings => 'Ustawienia serwera';

  @override
  String get settingsHaveBeenSaved => 'Ustawienia zostały zapisane';

  @override
  String get singersAssistant => 'Pomocnik wokalisty';

  @override
  String get songSelection => 'Wybór utworu';

  @override
  String get songsAddedToPlaylist => 'Utwory dodane do listy odtwarzania';

  @override
  String get songsList => 'Lista utworów';

  @override
  String songMustHaveTextDividedIntoLines(Object title) {
    return 'Utwór $title musi miec tekst podzielony na linie. Wstrzymano tworzenie prezentacji.';
  }

  @override
  String get termsAndConditions => 'Zasady i warunki';

  @override
  String get text => 'Tekst';

  @override
  String get textFound => 'Znaleziono tekst';

  @override
  String get textIsRequired => 'Tekst jest wymagany';

  @override
  String get thisWillBeTheFontSize => 'Taka będzie wielkość czcionki';

  @override
  String get theAddressOfTheLastServerUsedIs => 'Adres ostatnio użytego serwera to:';

  @override
  String get thePlaylistDoesNotContainAnySongs => 'Playlista nie zawiera utworów';

  @override
  String get thereIsAlreadyPlaylistWithThisName => 'Istnieje już lista odtwarzania z tą nazwą';

  @override
  String get thereIsAlreadySongWithThisTitle => 'Istnieje już utwór z tym tytułem';

  @override
  String get thereWasProblemWithConnection => 'Wystąpił problem z połączeniem';

  @override
  String get theValueEnteredIsNotNumber => 'Wprowadzona wartość nie jest liczbą';

  @override
  String get title => 'Tytuł';

  @override
  String get titleIsRequired => 'Tytuł jest wymagany';

  @override
  String get toCreatePlaylistYouNeedToSelectSongs => 'By utworzyć playlistę należy wybrać utwory';

  @override
  String get tooManyMatchingArtistsFoundPleaseSpecifyArtistName => 'Znaleziono zbyt wielu pasujących artystów, proszę podać dokładniejszą nazwę artysty';

  @override
  String get toAddToPlaylistSelectSongs => 'Aby dodać do listy odtwarzania wybierz utwory';

  @override
  String get toRunPresentationSelectSongs => 'Aby uruchomić prezentację wybierz utwory';

  @override
  String get toSearchForTextYouNeedAtLeastTitleOrAuthor => 'Aby wyszukać tekst potrzebujesz co najmniej tytułu lub autora';

  @override
  String get wifiHotspotDisabled => 'Hotspot Wifi wyłączony';

  @override
  String get yes => 'Tak';

  @override
  String get youMustMarkSongsToBeDeleted => 'Musisz oznaczyć utwory do usunięcia';

  @override
  String get youShouldMarkThePlaylistsToBeDeleted => 'Należy zaznaczyć listy do usunięcia';

  @override
  String get yourPrivacyChoisesHasBeenUpdated => 'Your privacy choises has been updated';
}
