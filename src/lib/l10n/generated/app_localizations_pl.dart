// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get addSong => 'Dodaj utwór';

  @override
  String get addTo => 'Dodaj do';

  @override
  String get addToPlaylistSentence => 'Dodaj do playlisty';

  @override
  String get addedToPlaylist => 'Dodano utwór do playlisty';

  @override
  String get addedSelectedToPlaylist => 'Dodano zaznaczone utwory do playlisty';

  @override
  String get addingPlaylist => 'Dodawanie playlisty';

  @override
  String get addingToPlaylist => 'Dodawanie do playlisty';

  @override
  String get anErrorOccurredWhileRetrievingListInformation => 'Wystąpił błąd przy pobieraniu informacji o liście';

  @override
  String get anErrorOccurredWhileTryingToChangeYourPrivacyPreferences => 'Wystąpił błąd podczas próby zmiany preferencji prywatności';

  @override
  String get and => 'i';

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
  String get areYouSureYouWantToDeleteThisPlaylist => 'Czy na pewno chcesz usunąć tę playlistę?';

  @override
  String get areYouSureYouWantToDeleteThisSong => 'Czy na pewno chcesz usunąć ten utwór?';

  @override
  String get areYouSureYouWantToExitWithoutSaving => 'Czy na pewno chcesz wyjść bez zapisywania zmian?';

  @override
  String get areYouSureYouWantToLeaveTheApplication => 'Czy na pewno chcesz opuścić aplikację?';

  @override
  String get author => 'Autor';

  @override
  String get authorIsRequired => 'Autor jest wymagany';

  @override
  String get backToList => 'Wróć do listy';

  @override
  String get byArtistAndTitle => 'Po artyście i tytule';

  @override
  String get byTitle => 'Po tytule';

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
  String get confirmDeletion => 'Potwierdź usunięcie';

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
  String get couldNotFindTextForGivenParameters => 'Nie udało się znaleźć tekstu do podanych parametrów';

  @override
  String get couldntFindMatchingArtist => 'Nie udało się znaleźć pasującego artysty';

  @override
  String get couldntFindMatchingSong => 'Nie udało się znaleźć pasującego utworu';

  @override
  String get create => 'Utwórz';

  @override
  String get createPlaylist => 'Utwórz playlistę';

  @override
  String get createPresentationError => 'Błąd uruchamiania prezentacji';

  @override
  String get createdPlaylist => 'Utworzono nową playlistę';

  @override
  String get currentIP => 'Aktualne IP:';

  @override
  String get delete => 'Usuń';

  @override
  String get deletePlaylist => 'Usuń playlistę';

  @override
  String get deleteSong => 'Usuń utwór';

  @override
  String get deletedSuccessfully => 'Usunięto pomyślnie';

  @override
  String get deletingPlaylists => 'Usuwanie list odtwarzania';

  @override
  String get deletingSongs => 'Usuwanie utworów';

  @override
  String get editPlaylist => 'Edytuj listę odtwarzania';

  @override
  String get editSong => 'Edytuj utwór';

  @override
  String get enterAuthor => 'Wprowadz wykonawcę';

  @override
  String get enterName => 'Wprowadź nazwę';

  @override
  String get enterTheIpFromTheServerSettings => 'Wprowadź IP z ustawień serwera';

  @override
  String get enterTitle => 'Wprowadź tytuł';

  @override
  String get error => 'Błąd';

  @override
  String get errorLoadingPlaylists => 'Wystąpił błąd podczas ładowania playlist. Spróbuj ponownie.';

  @override
  String get errorLoadingSongs => 'Wystąpił błąd podczas ładowania utworów. Spróbuj ponownie.';

  @override
  String errorWithMessage(Object message) {
    return 'Błąd: $message';
  }

  @override
  String get exit => 'Wyjdź';

  @override
  String get exitApplication => 'Wyjście z aplikacji';

  @override
  String get fontSize => 'Wielkość czcionki';

  @override
  String get fontSizeMustBeGreaterThan5 => 'Wielkość czcionki musi być większa od 5';

  @override
  String get help => 'Pomoc';

  @override
  String get helpClientDescription => 'Aby połączyć się jako klient, wprowadź adres IP serwera lub zeskanuj kod QR wyświetlony na urządzeniu głównym. Po połączeniu będziesz widzieć tekst aktualnie prezentowanego utworu.';

  @override
  String get helpClientTitle => 'Tryb klienta';

  @override
  String get helpPlaylistsDescription => 'Playlisty pozwalają grupować utwory w zestawy. Możesz tworzyć nowe playlisty, edytować ich nazwy oraz dodawać i usuwać utwory. Kolejność utworów na liście można zmieniać poprzez przeciąganie ich za ikonę uchwytu.';

  @override
  String get helpPlaylistsTitle => 'Playlisty';

  @override
  String get helpPresentationDescription => 'Tryb prezentacji umożliwia wyświetlanie tekstów utworów na innych urządzeniach. W ustawieniach prezentacji możesz skonfigurować parametry serwera i zobaczyć kod QR ułatwiający połączenie.';

  @override
  String get helpPresentationTitle => 'Tryb prezentacji';

  @override
  String get helpSongsDescription => 'Możesz dodawać utwory ręcznie lub wyszukiwać ich teksty. Aby dodać utwór, kliknij przycisk \'+\' na liście utworów. W formularzu możesz wpisać tytuł, autora oraz tekst utworu. Użyj przycisku wyszukiwania, aby automatycznie pobrać tekst.';

  @override
  String get helpSongsTitle => 'Zarządzanie utworami';

  @override
  String get ipIsRequired => 'IP jest wymagane';

  @override
  String get language => 'Język:';

  @override
  String get latest => 'Najnowsze';

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
  String get noPlaylists => 'Dodaj pierwszą playlistę';

  @override
  String get noPlaylistsSelected => 'Brak zaznaczonych list odtwarzania';

  @override
  String get noSongs => 'Dodaj pierwszy utwór';

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
  String get oldest => 'Najstarsze';

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
  String get presentationIsOnlyPossibleForOneList => 'Prezentacja możliwa tylko dla jednej listy';

  @override
  String get presentationScreen => 'Prezentuj';

  @override
  String get presentationSettings => 'Ustawienia prezentacji';

  @override
  String get privacyPolicy => 'Polityka prywatności';

  @override
  String get quickSearch => 'Szybkie wyszukiwanie';

  @override
  String get removingSongFromPlaylist => 'Usuwanie utworu z listy odtwarzania';

  @override
  String get reuseThisAddress => 'Czy ponownie użyć tego adresu?';

  @override
  String get save => 'Zapisz';

  @override
  String get saveAndContinue => 'Zapisz i kontynuuj';

  @override
  String get saveAndExit => 'Zapisz i wyjdź';

  @override
  String get saveAndLunchPresentation => 'Zapisz i prezentuj';

  @override
  String get savedSuccessfully => 'Zapisano pomyślnie';

  @override
  String get search => 'Wyszukaj';

  @override
  String get searchInProgress => 'Trwa wyszukiwanie';

  @override
  String get searching => 'Wyszukiwanie';

  @override
  String get selectSong => 'Wybierz utwór';

  @override
  String get serverDown => 'Serwer wyłączony';

  @override
  String get serverSettings => 'Ustawienia serwera';

  @override
  String get settingsHaveBeenSaved => 'Ustawienia zostały zapisane';

  @override
  String get showText => 'Wyświetl tekst';

  @override
  String get singersAssistant => 'Pomocnik wokalisty';

  @override
  String songMustHaveTextDividedIntoLines(Object title) {
    return 'Utwór $title musi miec tekst podzielony na linie. Wstrzymano tworzenie prezentacji.';
  }

  @override
  String get songSelection => 'Wybór utworu';

  @override
  String get songsAddedToPlaylist => 'Utwory dodane do listy odtwarzania';

  @override
  String get songsList => 'Lista utworów';

  @override
  String get sortBy => 'Sortuj według';

  @override
  String get startServer => 'Uruchom serwer';

  @override
  String get stopServer => 'Zatrzymaj serwer';

  @override
  String get termsAndConditions => 'Zasady i warunki';

  @override
  String get text => 'Tekst';

  @override
  String get textFound => 'Znaleziono tekst';

  @override
  String get textIsRequired => 'Tekst jest wymagany';

  @override
  String get theAddressOfTheLastServerUsedIs => 'Adres ostatnio użytego serwera to:';

  @override
  String get thePlaylistDoesNotContainAnySongs => 'Playlista nie zawiera utworów';

  @override
  String get theValueEnteredIsNotNumber => 'Wprowadzona wartość nie jest liczbą';

  @override
  String get thereIsAlreadyPlaylistWithThisName => 'Istnieje już lista odtwarzania z tą nazwą';

  @override
  String get thereIsAlreadySongWithThisTitle => 'Istnieje już utwór z tym tytułem';

  @override
  String get thereWasProblemWithConnection => 'Wystąpił problem z połączeniem';

  @override
  String get thisWillBeTheFontSize => 'Taka będzie wielkość czcionki';

  @override
  String get title => 'Tytuł';

  @override
  String get titleIsRequired => 'Tytuł jest wymagany';

  @override
  String get toAddToPlaylistSelectSongs => 'Aby dodać do listy odtwarzania wybierz utwory';

  @override
  String get toCreatePlaylistYouNeedToSelectSongs => 'By utworzyć playlistę należy wybrać utwory';

  @override
  String get toExistingPlaylist => 'Do istniejącej listy';

  @override
  String get toNewPlaylist => 'Utwórz nową playlistę';

  @override
  String get toRunPresentationSelectSongs => 'Aby uruchomić prezentację wybierz utwory';

  @override
  String get toSearchForTextYouNeedAtLeastTitleOrAuthor => 'Aby wyszukać tekst potrzebujesz co najmniej tytułu lub autora';

  @override
  String get tooManyMatchingArtistsFoundPleaseSpecifyArtistName => 'Znaleziono zbyt wielu pasujących artystów, proszę podać dokładniejszą nazwę artysty';

  @override
  String get theme => 'Motyw';

  @override
  String get lightTheme => 'Jasny';

  @override
  String get darkTheme => 'Ciemny';

  @override
  String get systemTheme => 'Systemowy';

  @override
  String get tryAgain => 'Spróbuj ponownie';

  @override
  String get unsavedChanges => 'Niezapisane zmiany';

  @override
  String get unsavedChangesInPlaylist => 'W liście odtwarzania znajdują się niezapisane zmiany. Czy chcesz je zapisać przed uruchomieniem prezentacji?';

  @override
  String get wifiHotspotDisabled => 'Hotspot Wifi wyłączony';

  @override
  String get yes => 'Tak';

  @override
  String get youMustMarkSongsToBeDeleted => 'Musisz oznaczyć utwory do usunięcia';

  @override
  String get youShouldMarkThePlaylistsToBeDeleted => 'Należy zaznaczyć listy do usunięcia';

  @override
  String get yourPrivacyChoisesHasBeenUpdated => 'Twoje ustawienia prywatności zostały zaktualizowane';
}
