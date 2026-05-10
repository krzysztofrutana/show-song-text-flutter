import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl')
  ];

  /// No description provided for @addSong.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj utwór'**
  String get addSong;

  /// No description provided for @addTo.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj do'**
  String get addTo;

  /// No description provided for @addToPlaylistSentence.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj do playlisty'**
  String get addToPlaylistSentence;

  /// No description provided for @addedToPlaylist.
  ///
  /// In pl, this message translates to:
  /// **'Dodano utwór do playlisty'**
  String get addedToPlaylist;

  /// No description provided for @addedSelectedToPlaylist.
  ///
  /// In pl, this message translates to:
  /// **'Dodano zaznaczone utwory do playlisty'**
  String get addedSelectedToPlaylist;

  /// No description provided for @addingPlaylist.
  ///
  /// In pl, this message translates to:
  /// **'Dodawanie playlisty'**
  String get addingPlaylist;

  /// No description provided for @addingToPlaylist.
  ///
  /// In pl, this message translates to:
  /// **'Dodawanie do playlisty'**
  String get addingToPlaylist;

  /// No description provided for @anErrorOccurredWhileRetrievingListInformation.
  ///
  /// In pl, this message translates to:
  /// **'Wystąpił błąd przy pobieraniu informacji o liście'**
  String get anErrorOccurredWhileRetrievingListInformation;

  /// No description provided for @anErrorOccurredWhileTryingToChangeYourPrivacyPreferences.
  ///
  /// In pl, this message translates to:
  /// **'Wystąpił błąd podczas próby zmiany preferencji prywatności'**
  String get anErrorOccurredWhileTryingToChangeYourPrivacyPreferences;

  /// No description provided for @and.
  ///
  /// In pl, this message translates to:
  /// **'i'**
  String get and;

  /// No description provided for @areYouSureYouWantDeletSelectedLists.
  ///
  /// In pl, this message translates to:
  /// **'Czy na pewno chcesz usunąć zaznaczone listy?'**
  String get areYouSureYouWantDeletSelectedLists;

  /// No description provided for @areYouSureYouWantDeleteSelectedSongs.
  ///
  /// In pl, this message translates to:
  /// **'Czy na pewno chcesz usunąć zaznaczone utwory?'**
  String get areYouSureYouWantDeleteSelectedSongs;

  /// No description provided for @areYouSureYouWantRemoveCurrentSongFromPlaylistAtPosition.
  ///
  /// In pl, this message translates to:
  /// **'Czy na pewno chcesz usunąć utwór z listy odtwarzania {name} z pozycji {position}?'**
  String areYouSureYouWantRemoveCurrentSongFromPlaylistAtPosition(Object name, Object position);

  /// No description provided for @areYouSureYouWantRemoveSongFromPlaylistAtPosition.
  ///
  /// In pl, this message translates to:
  /// **'Czy na pewno chcesz usunąć utwór {author} - {title} z listy odtwarzania z pozycji {index}?'**
  String areYouSureYouWantRemoveSongFromPlaylistAtPosition(Object author, Object index, Object title);

  /// No description provided for @areYouSureYouWantToDeleteThisPlaylist.
  ///
  /// In pl, this message translates to:
  /// **'Czy na pewno chcesz usunąć tę playlistę?'**
  String get areYouSureYouWantToDeleteThisPlaylist;

  /// No description provided for @areYouSureYouWantToDeleteThisSong.
  ///
  /// In pl, this message translates to:
  /// **'Czy na pewno chcesz usunąć ten utwór?'**
  String get areYouSureYouWantToDeleteThisSong;

  /// No description provided for @areYouSureYouWantToExitWithoutSaving.
  ///
  /// In pl, this message translates to:
  /// **'Czy na pewno chcesz wyjść bez zapisywania zmian?'**
  String get areYouSureYouWantToExitWithoutSaving;

  /// No description provided for @areYouSureYouWantToLeaveTheApplication.
  ///
  /// In pl, this message translates to:
  /// **'Czy na pewno chcesz opuścić aplikację?'**
  String get areYouSureYouWantToLeaveTheApplication;

  /// No description provided for @author.
  ///
  /// In pl, this message translates to:
  /// **'Autor'**
  String get author;

  /// No description provided for @authorIsRequired.
  ///
  /// In pl, this message translates to:
  /// **'Autor jest wymagany'**
  String get authorIsRequired;

  /// No description provided for @backToList.
  ///
  /// In pl, this message translates to:
  /// **'Wróć do listy'**
  String get backToList;

  /// No description provided for @byArtistAndTitle.
  ///
  /// In pl, this message translates to:
  /// **'Po artyście i tytule'**
  String get byArtistAndTitle;

  /// No description provided for @byTitle.
  ///
  /// In pl, this message translates to:
  /// **'Po tytule'**
  String get byTitle;

  /// No description provided for @cancel.
  ///
  /// In pl, this message translates to:
  /// **'Anuluj'**
  String get cancel;

  /// No description provided for @changePrivacyPolicy.
  ///
  /// In pl, this message translates to:
  /// **'Zmień preferencje prywatności'**
  String get changePrivacyPolicy;

  /// No description provided for @changesWillBeImplementedAfterSavingTheForm.
  ///
  /// In pl, this message translates to:
  /// **'Zmiany zostaną wprowadzone po zapisaniu formularza'**
  String get changesWillBeImplementedAfterSavingTheForm;

  /// No description provided for @clientMode.
  ///
  /// In pl, this message translates to:
  /// **'Tryb klienta'**
  String get clientMode;

  /// No description provided for @confirm.
  ///
  /// In pl, this message translates to:
  /// **'Zatwierdź'**
  String get confirm;

  /// No description provided for @confirmDeletion.
  ///
  /// In pl, this message translates to:
  /// **'Potwierdź usunięcie'**
  String get confirmDeletion;

  /// No description provided for @connecting.
  ///
  /// In pl, this message translates to:
  /// **'Trwa łączenie'**
  String get connecting;

  /// No description provided for @connectionError.
  ///
  /// In pl, this message translates to:
  /// **'Błąd połączenia: {error}'**
  String connectionError(Object error);

  /// No description provided for @connectionFailed.
  ///
  /// In pl, this message translates to:
  /// **'Połączenie nieudane'**
  String get connectionFailed;

  /// No description provided for @connectionFailedCheckIp.
  ///
  /// In pl, this message translates to:
  /// **'Połączenie nieudane, sprawdź IP'**
  String get connectionFailedCheckIp;

  /// No description provided for @connectionFailedPleaseReenterIp.
  ///
  /// In pl, this message translates to:
  /// **'Połączenie nieudane, wprowadź ponownie IP'**
  String get connectionFailedPleaseReenterIp;

  /// No description provided for @connectionToTheServer.
  ///
  /// In pl, this message translates to:
  /// **'Podłączenie do serwera'**
  String get connectionToTheServer;

  /// No description provided for @couldNotFindTextForGivenParameters.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się znaleźć tekstu do podanych parametrów'**
  String get couldNotFindTextForGivenParameters;

  /// No description provided for @couldntFindMatchingArtist.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się znaleźć pasującego artysty'**
  String get couldntFindMatchingArtist;

  /// No description provided for @couldntFindMatchingSong.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się znaleźć pasującego utworu'**
  String get couldntFindMatchingSong;

  /// No description provided for @create.
  ///
  /// In pl, this message translates to:
  /// **'Utwórz'**
  String get create;

  /// No description provided for @createPlaylist.
  ///
  /// In pl, this message translates to:
  /// **'Utwórz playlistę'**
  String get createPlaylist;

  /// No description provided for @createPresentationError.
  ///
  /// In pl, this message translates to:
  /// **'Błąd uruchamiania prezentacji'**
  String get createPresentationError;

  /// No description provided for @createdPlaylist.
  ///
  /// In pl, this message translates to:
  /// **'Utworzono nową playlistę'**
  String get createdPlaylist;

  /// No description provided for @currentIP.
  ///
  /// In pl, this message translates to:
  /// **'Aktualne IP:'**
  String get currentIP;

  /// No description provided for @delete.
  ///
  /// In pl, this message translates to:
  /// **'Usuń'**
  String get delete;

  /// No description provided for @deletePlaylist.
  ///
  /// In pl, this message translates to:
  /// **'Usuń playlistę'**
  String get deletePlaylist;

  /// No description provided for @deleteSong.
  ///
  /// In pl, this message translates to:
  /// **'Usuń utwór'**
  String get deleteSong;

  /// No description provided for @deletedSuccessfully.
  ///
  /// In pl, this message translates to:
  /// **'Usunięto pomyślnie'**
  String get deletedSuccessfully;

  /// No description provided for @deletingPlaylists.
  ///
  /// In pl, this message translates to:
  /// **'Usuwanie list odtwarzania'**
  String get deletingPlaylists;

  /// No description provided for @deletingSongs.
  ///
  /// In pl, this message translates to:
  /// **'Usuwanie utworów'**
  String get deletingSongs;

  /// No description provided for @editPlaylist.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj listę odtwarzania'**
  String get editPlaylist;

  /// No description provided for @editSong.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj utwór'**
  String get editSong;

  /// No description provided for @enterAuthor.
  ///
  /// In pl, this message translates to:
  /// **'Wprowadz wykonawcę'**
  String get enterAuthor;

  /// No description provided for @enterName.
  ///
  /// In pl, this message translates to:
  /// **'Wprowadź nazwę'**
  String get enterName;

  /// No description provided for @enterTheIpFromTheServerSettings.
  ///
  /// In pl, this message translates to:
  /// **'Wprowadź IP z ustawień serwera'**
  String get enterTheIpFromTheServerSettings;

  /// No description provided for @enterTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wprowadź tytuł'**
  String get enterTitle;

  /// No description provided for @error.
  ///
  /// In pl, this message translates to:
  /// **'Błąd'**
  String get error;

  /// No description provided for @errorLoadingPlaylists.
  ///
  /// In pl, this message translates to:
  /// **'Wystąpił błąd podczas ładowania playlist. Spróbuj ponownie.'**
  String get errorLoadingPlaylists;

  /// No description provided for @errorLoadingSongs.
  ///
  /// In pl, this message translates to:
  /// **'Wystąpił błąd podczas ładowania utworów. Spróbuj ponownie.'**
  String get errorLoadingSongs;

  /// No description provided for @errorWithMessage.
  ///
  /// In pl, this message translates to:
  /// **'Błąd: {message}'**
  String errorWithMessage(Object message);

  /// No description provided for @exit.
  ///
  /// In pl, this message translates to:
  /// **'Wyjdź'**
  String get exit;

  /// No description provided for @exitApplication.
  ///
  /// In pl, this message translates to:
  /// **'Wyjście z aplikacji'**
  String get exitApplication;

  /// No description provided for @fontSize.
  ///
  /// In pl, this message translates to:
  /// **'Wielkość czcionki'**
  String get fontSize;

  /// No description provided for @fontSizeMustBeGreaterThan5.
  ///
  /// In pl, this message translates to:
  /// **'Wielkość czcionki musi być większa od 5'**
  String get fontSizeMustBeGreaterThan5;

  /// No description provided for @help.
  ///
  /// In pl, this message translates to:
  /// **'Pomoc'**
  String get help;

  /// No description provided for @helpClientDescription.
  ///
  /// In pl, this message translates to:
  /// **'Aby połączyć się jako klient, wprowadź adres IP serwera lub zeskanuj kod QR wyświetlony na urządzeniu głównym. Po połączeniu będziesz widzieć tekst aktualnie prezentowanego utworu.'**
  String get helpClientDescription;

  /// No description provided for @helpClientTitle.
  ///
  /// In pl, this message translates to:
  /// **'Tryb klienta'**
  String get helpClientTitle;

  /// No description provided for @helpPlaylistsDescription.
  ///
  /// In pl, this message translates to:
  /// **'Playlisty pozwalają grupować utwory w zestawy. Możesz tworzyć nowe playlisty, edytować ich nazwy oraz dodawać i usuwać utwory. Kolejność utworów na liście można zmieniać poprzez przeciąganie ich za ikonę uchwytu.'**
  String get helpPlaylistsDescription;

  /// No description provided for @helpPlaylistsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Playlisty'**
  String get helpPlaylistsTitle;

  /// No description provided for @helpPresentationDescription.
  ///
  /// In pl, this message translates to:
  /// **'Tryb prezentacji umożliwia wyświetlanie tekstów utworów na innych urządzeniach. W ustawieniach prezentacji możesz skonfigurować parametry serwera i zobaczyć kod QR ułatwiający połączenie.'**
  String get helpPresentationDescription;

  /// No description provided for @helpPresentationTitle.
  ///
  /// In pl, this message translates to:
  /// **'Tryb prezentacji'**
  String get helpPresentationTitle;

  /// No description provided for @helpSongsDescription.
  ///
  /// In pl, this message translates to:
  /// **'Możesz dodawać utwory ręcznie lub wyszukiwać ich teksty. Aby dodać utwór, kliknij przycisk \'+\' na liście utworów. W formularzu możesz wpisać tytuł, autora oraz tekst utworu. Użyj przycisku wyszukiwania, aby automatycznie pobrać tekst.'**
  String get helpSongsDescription;

  /// No description provided for @helpSongsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zarządzanie utworami'**
  String get helpSongsTitle;

  /// No description provided for @ipIsRequired.
  ///
  /// In pl, this message translates to:
  /// **'IP jest wymagane'**
  String get ipIsRequired;

  /// No description provided for @language.
  ///
  /// In pl, this message translates to:
  /// **'Język:'**
  String get language;

  /// No description provided for @latest.
  ///
  /// In pl, this message translates to:
  /// **'Najnowsze'**
  String get latest;

  /// No description provided for @leave.
  ///
  /// In pl, this message translates to:
  /// **'Wyjdź'**
  String get leave;

  /// No description provided for @loading.
  ///
  /// In pl, this message translates to:
  /// **'Ładowanie...'**
  String get loading;

  /// No description provided for @name.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa'**
  String get name;

  /// No description provided for @nameIsRequired.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa jest wymagana'**
  String get nameIsRequired;

  /// No description provided for @noActiveInternetConnection.
  ///
  /// In pl, this message translates to:
  /// **'Brak aktywnego połączenia internetowego'**
  String get noActiveInternetConnection;

  /// No description provided for @noConnection.
  ///
  /// In pl, this message translates to:
  /// **'Brak połączenia'**
  String get noConnection;

  /// No description provided for @noPlaylists.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj pierwszą playlistę'**
  String get noPlaylists;

  /// No description provided for @noPlaylistsSelected.
  ///
  /// In pl, this message translates to:
  /// **'Brak zaznaczonych list odtwarzania'**
  String get noPlaylistsSelected;

  /// No description provided for @noSongs.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj pierwszy utwór'**
  String get noSongs;

  /// No description provided for @noSongsAssigned.
  ///
  /// In pl, this message translates to:
  /// **'Brak przypisanych utworów'**
  String get noSongsAssigned;

  /// No description provided for @noSongsSelected.
  ///
  /// In pl, this message translates to:
  /// **'Brak zaznaczonych utworów'**
  String get noSongsSelected;

  /// No description provided for @noTextToDisplay.
  ///
  /// In pl, this message translates to:
  /// **'Brak tekstu do wyświetlenia'**
  String get noTextToDisplay;

  /// No description provided for @numberOfConnectedDevices.
  ///
  /// In pl, this message translates to:
  /// **'Liczba podłączonych urządzeń: {number}'**
  String numberOfConnectedDevices(Object number);

  /// No description provided for @numberOfPlaylists.
  ///
  /// In pl, this message translates to:
  /// **'Liczba list: {number}'**
  String numberOfPlaylists(Object number);

  /// No description provided for @numberOfSongs.
  ///
  /// In pl, this message translates to:
  /// **'Liczba utworów: {number}'**
  String numberOfSongs(Object number);

  /// No description provided for @ok.
  ///
  /// In pl, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @oldest.
  ///
  /// In pl, this message translates to:
  /// **'Najstarsze'**
  String get oldest;

  /// No description provided for @parametersProvidedAreIncorrect.
  ///
  /// In pl, this message translates to:
  /// **'Podane parametry są niepoprawne'**
  String get parametersProvidedAreIncorrect;

  /// No description provided for @playlists.
  ///
  /// In pl, this message translates to:
  /// **'Listy odtwarzania'**
  String get playlists;

  /// No description provided for @playlistsToWhichSongHasBeenAdded.
  ///
  /// In pl, this message translates to:
  /// **'Listy odtwarzania do których dodano utwór'**
  String get playlistsToWhichSongHasBeenAdded;

  /// No description provided for @pleaseSelectOnlyOneListForPresentation.
  ///
  /// In pl, this message translates to:
  /// **'Należy zaznaczyć tylko jedną listę do prezentacji'**
  String get pleaseSelectOnlyOneListForPresentation;

  /// No description provided for @pleaseSelectPlaylistForPresentation.
  ///
  /// In pl, this message translates to:
  /// **'Należy zaznaczyć listę do prezentacji'**
  String get pleaseSelectPlaylistForPresentation;

  /// No description provided for @position.
  ///
  /// In pl, this message translates to:
  /// **'Pozycja: {position}'**
  String position(Object position);

  /// No description provided for @presentationIsOnlyPossibleForOneList.
  ///
  /// In pl, this message translates to:
  /// **'Prezentacja możliwa tylko dla jednej listy'**
  String get presentationIsOnlyPossibleForOneList;

  /// No description provided for @presentationScreen.
  ///
  /// In pl, this message translates to:
  /// **'Prezentuj'**
  String get presentationScreen;

  /// No description provided for @presentationSettings.
  ///
  /// In pl, this message translates to:
  /// **'Ustawienia prezentacji'**
  String get presentationSettings;

  /// No description provided for @privacyPolicy.
  ///
  /// In pl, this message translates to:
  /// **'Polityka prywatności'**
  String get privacyPolicy;

  /// No description provided for @quickSearch.
  ///
  /// In pl, this message translates to:
  /// **'Szybkie wyszukiwanie'**
  String get quickSearch;

  /// No description provided for @removingSongFromPlaylist.
  ///
  /// In pl, this message translates to:
  /// **'Usuwanie utworu z listy odtwarzania'**
  String get removingSongFromPlaylist;

  /// No description provided for @reuseThisAddress.
  ///
  /// In pl, this message translates to:
  /// **'Czy ponownie użyć tego adresu?'**
  String get reuseThisAddress;

  /// No description provided for @save.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz'**
  String get save;

  /// No description provided for @saveAndContinue.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz i kontynuuj'**
  String get saveAndContinue;

  /// No description provided for @saveAndExit.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz i wyjdź'**
  String get saveAndExit;

  /// No description provided for @saveAndLunchPresentation.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz i prezentuj'**
  String get saveAndLunchPresentation;

  /// No description provided for @savedSuccessfully.
  ///
  /// In pl, this message translates to:
  /// **'Zapisano pomyślnie'**
  String get savedSuccessfully;

  /// No description provided for @search.
  ///
  /// In pl, this message translates to:
  /// **'Wyszukaj'**
  String get search;

  /// No description provided for @searchInProgress.
  ///
  /// In pl, this message translates to:
  /// **'Trwa wyszukiwanie'**
  String get searchInProgress;

  /// No description provided for @searching.
  ///
  /// In pl, this message translates to:
  /// **'Wyszukiwanie'**
  String get searching;

  /// No description provided for @selectSong.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz utwór'**
  String get selectSong;

  /// No description provided for @serverDown.
  ///
  /// In pl, this message translates to:
  /// **'Serwer wyłączony'**
  String get serverDown;

  /// No description provided for @serverSettings.
  ///
  /// In pl, this message translates to:
  /// **'Ustawienia serwera'**
  String get serverSettings;

  /// No description provided for @settingsHaveBeenSaved.
  ///
  /// In pl, this message translates to:
  /// **'Ustawienia zostały zapisane'**
  String get settingsHaveBeenSaved;

  /// No description provided for @showText.
  ///
  /// In pl, this message translates to:
  /// **'Wyświetl tekst'**
  String get showText;

  /// No description provided for @singersAssistant.
  ///
  /// In pl, this message translates to:
  /// **'Pomocnik wokalisty'**
  String get singersAssistant;

  /// No description provided for @songMustHaveTextDividedIntoLines.
  ///
  /// In pl, this message translates to:
  /// **'Utwór {title} musi miec tekst podzielony na linie. Wstrzymano tworzenie prezentacji.'**
  String songMustHaveTextDividedIntoLines(Object title);

  /// No description provided for @songSelection.
  ///
  /// In pl, this message translates to:
  /// **'Wybór utworu'**
  String get songSelection;

  /// No description provided for @songsAddedToPlaylist.
  ///
  /// In pl, this message translates to:
  /// **'Utwory dodane do listy odtwarzania'**
  String get songsAddedToPlaylist;

  /// No description provided for @songsList.
  ///
  /// In pl, this message translates to:
  /// **'Lista utworów'**
  String get songsList;

  /// No description provided for @sortBy.
  ///
  /// In pl, this message translates to:
  /// **'Sortuj według'**
  String get sortBy;

  /// No description provided for @startServer.
  ///
  /// In pl, this message translates to:
  /// **'Uruchom serwer'**
  String get startServer;

  /// No description provided for @stopServer.
  ///
  /// In pl, this message translates to:
  /// **'Zatrzymaj serwer'**
  String get stopServer;

  /// No description provided for @termsAndConditions.
  ///
  /// In pl, this message translates to:
  /// **'Zasady i warunki'**
  String get termsAndConditions;

  /// No description provided for @text.
  ///
  /// In pl, this message translates to:
  /// **'Tekst'**
  String get text;

  /// No description provided for @textFound.
  ///
  /// In pl, this message translates to:
  /// **'Znaleziono tekst'**
  String get textFound;

  /// No description provided for @textIsRequired.
  ///
  /// In pl, this message translates to:
  /// **'Tekst jest wymagany'**
  String get textIsRequired;

  /// No description provided for @theAddressOfTheLastServerUsedIs.
  ///
  /// In pl, this message translates to:
  /// **'Adres ostatnio użytego serwera to:'**
  String get theAddressOfTheLastServerUsedIs;

  /// No description provided for @thePlaylistDoesNotContainAnySongs.
  ///
  /// In pl, this message translates to:
  /// **'Playlista nie zawiera utworów'**
  String get thePlaylistDoesNotContainAnySongs;

  /// No description provided for @theValueEnteredIsNotNumber.
  ///
  /// In pl, this message translates to:
  /// **'Wprowadzona wartość nie jest liczbą'**
  String get theValueEnteredIsNotNumber;

  /// No description provided for @thereIsAlreadyPlaylistWithThisName.
  ///
  /// In pl, this message translates to:
  /// **'Istnieje już lista odtwarzania z tą nazwą'**
  String get thereIsAlreadyPlaylistWithThisName;

  /// No description provided for @thereIsAlreadySongWithThisTitle.
  ///
  /// In pl, this message translates to:
  /// **'Istnieje już utwór z tym tytułem'**
  String get thereIsAlreadySongWithThisTitle;

  /// No description provided for @thereWasProblemWithConnection.
  ///
  /// In pl, this message translates to:
  /// **'Wystąpił problem z połączeniem'**
  String get thereWasProblemWithConnection;

  /// No description provided for @thisWillBeTheFontSize.
  ///
  /// In pl, this message translates to:
  /// **'Taka będzie wielkość czcionki'**
  String get thisWillBeTheFontSize;

  /// No description provided for @title.
  ///
  /// In pl, this message translates to:
  /// **'Tytuł'**
  String get title;

  /// No description provided for @titleIsRequired.
  ///
  /// In pl, this message translates to:
  /// **'Tytuł jest wymagany'**
  String get titleIsRequired;

  /// No description provided for @toAddToPlaylistSelectSongs.
  ///
  /// In pl, this message translates to:
  /// **'Aby dodać do listy odtwarzania wybierz utwory'**
  String get toAddToPlaylistSelectSongs;

  /// No description provided for @toCreatePlaylistYouNeedToSelectSongs.
  ///
  /// In pl, this message translates to:
  /// **'By utworzyć playlistę należy wybrać utwory'**
  String get toCreatePlaylistYouNeedToSelectSongs;

  /// No description provided for @toExistingPlaylist.
  ///
  /// In pl, this message translates to:
  /// **'Do istniejącej listy'**
  String get toExistingPlaylist;

  /// No description provided for @toNewPlaylist.
  ///
  /// In pl, this message translates to:
  /// **'Utwórz nową playlistę'**
  String get toNewPlaylist;

  /// No description provided for @toRunPresentationSelectSongs.
  ///
  /// In pl, this message translates to:
  /// **'Aby uruchomić prezentację wybierz utwory'**
  String get toRunPresentationSelectSongs;

  /// No description provided for @toSearchForTextYouNeedAtLeastTitleOrAuthor.
  ///
  /// In pl, this message translates to:
  /// **'Aby wyszukać tekst potrzebujesz co najmniej tytułu lub autora'**
  String get toSearchForTextYouNeedAtLeastTitleOrAuthor;

  /// No description provided for @tooManyMatchingArtistsFoundPleaseSpecifyArtistName.
  ///
  /// In pl, this message translates to:
  /// **'Znaleziono zbyt wielu pasujących artystów, proszę podać dokładniejszą nazwę artysty'**
  String get tooManyMatchingArtistsFoundPleaseSpecifyArtistName;

  /// No description provided for @tryAgain.
  ///
  /// In pl, this message translates to:
  /// **'Spróbuj ponownie'**
  String get tryAgain;

  /// No description provided for @unsavedChanges.
  ///
  /// In pl, this message translates to:
  /// **'Niezapisane zmiany'**
  String get unsavedChanges;

  /// No description provided for @unsavedChangesInPlaylist.
  ///
  /// In pl, this message translates to:
  /// **'W liście odtwarzania znajdują się niezapisane zmiany. Czy chcesz je zapisać przed uruchomieniem prezentacji?'**
  String get unsavedChangesInPlaylist;

  /// No description provided for @wifiHotspotDisabled.
  ///
  /// In pl, this message translates to:
  /// **'Hotspot Wifi wyłączony'**
  String get wifiHotspotDisabled;

  /// No description provided for @yes.
  ///
  /// In pl, this message translates to:
  /// **'Tak'**
  String get yes;

  /// No description provided for @youMustMarkSongsToBeDeleted.
  ///
  /// In pl, this message translates to:
  /// **'Musisz oznaczyć utwory do usunięcia'**
  String get youMustMarkSongsToBeDeleted;

  /// No description provided for @youShouldMarkThePlaylistsToBeDeleted.
  ///
  /// In pl, this message translates to:
  /// **'Należy zaznaczyć listy do usunięcia'**
  String get youShouldMarkThePlaylistsToBeDeleted;

  /// No description provided for @yourPrivacyChoisesHasBeenUpdated.
  ///
  /// In pl, this message translates to:
  /// **'Twoje ustawienia prywatności zostały zaktualizowane'**
  String get yourPrivacyChoisesHasBeenUpdated;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'pl': return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
