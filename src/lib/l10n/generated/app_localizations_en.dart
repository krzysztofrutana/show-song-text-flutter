// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get addSong => 'Add a song';

  @override
  String get addTo => 'Add to';

  @override
  String get addToPlaylistSentence => 'Add to playlist';

  @override
  String get addedToPlaylist => 'Added song to playlist';

  @override
  String get addedSelectedToPlaylist => 'Added selected songs to playlist';

  @override
  String get addingPlaylist => 'Adding a playlist';

  @override
  String get addingToPlaylist => 'Adding to playlist';

  @override
  String get anErrorOccurredWhileRetrievingListInformation => 'An error occurred while retrieving list information.';

  @override
  String get anErrorOccurredWhileTryingToChangeYourPrivacyPreferences => 'An error occurred while trying to change your privacy preferences';

  @override
  String get and => 'and';

  @override
  String get areYouSureYouWantDeletSelectedLists => 'Are you sure you want to delete the selected lists?';

  @override
  String get areYouSureYouWantDeleteSelectedSongs => 'Are you sure you want to delete the selected songs?';

  @override
  String areYouSureYouWantRemoveCurrentSongFromPlaylistAtPosition(Object name, Object position) {
    return 'Are you sure you want to remove the song from the playlist $name at position $position?';
  }

  @override
  String areYouSureYouWantRemoveSongFromPlaylistAtPosition(Object author, Object index, Object title) {
    return 'Are you sure you want to remove the song $author - $title from the playlist at position $index?';
  }

  @override
  String get areYouSureYouWantToDeleteThisPlaylist => 'Are you sure you want to delete this playlist?';

  @override
  String get areYouSureYouWantToDeleteThisSong => 'Are you sure you want to delete this song?';

  @override
  String get areYouSureYouWantToExitWithoutSaving => 'Are you sure you want to exit without saving changes?';

  @override
  String get areYouSureYouWantToLeaveTheApplication => 'Are you sure you want to leave the application?';

  @override
  String get author => 'Author';

  @override
  String get authorIsRequired => 'Author is required';

  @override
  String get backToList => 'Back to list';

  @override
  String get byArtistAndTitle => 'By artist and title';

  @override
  String get byTitle => 'By title';

  @override
  String get cancel => 'Cancel';

  @override
  String get changePrivacyPolicy => 'Change privacy preferences';

  @override
  String get changesWillBeImplementedAfterSavingTheForm => 'Changes will be implemented after saving the form';

  @override
  String get clientMode => 'Client mode';

  @override
  String get confirm => 'Confirm';

  @override
  String get confirmDeletion => 'Confirm deletion';

  @override
  String get connecting => 'Connecting';

  @override
  String connectionError(Object error) {
    return 'Connection error: $error';
  }

  @override
  String get connectionFailed => 'Connection failed';

  @override
  String get connectionFailedCheckIp => 'Connection failed, check IP';

  @override
  String get connectionFailedPleaseReenterIp => 'Connection failed, please re-enter IP';

  @override
  String get connectionToTheServer => 'Connection to the server';

  @override
  String get couldNotFindTextForGivenParameters => 'Could not find text for the given parameters';

  @override
  String get couldntFindMatchingArtist => 'Couldn\'t find a matching artist';

  @override
  String get couldntFindMatchingSong => 'Couldn\'t find a matching song';

  @override
  String get create => 'Create';

  @override
  String get createPlaylist => 'Create playlist';

  @override
  String get createPresentationError => 'Presentation launch error';

  @override
  String get createdPlaylist => 'Created new playlist';

  @override
  String get currentIP => 'Current IP:';

  @override
  String get delete => 'Delete';

  @override
  String get deletePlaylist => 'Delete playlist';

  @override
  String get deleteSong => 'Delete song';

  @override
  String get deletedSuccessfully => 'Successfully deleted';

  @override
  String get deletingPlaylists => 'Deleting playlists';

  @override
  String get deletingSongs => 'Deleting songs';

  @override
  String get editPlaylist => 'Edit playlist';

  @override
  String get editSong => 'Edit song';

  @override
  String get enterAuthor => 'Enter author';

  @override
  String get enterName => 'Enter a name';

  @override
  String get enterTheIpFromTheServerSettings => 'Enter the IP from the server settings';

  @override
  String get enterTitle => 'Enter title';

  @override
  String get error => 'Error';

  @override
  String get errorLoadingPlaylists => 'An error occurred while loading playlists. Please try again.';

  @override
  String get errorLoadingSongs => 'An error occurred while loading songs. Please try again.';

  @override
  String errorWithMessage(Object message) {
    return 'Error: $message';
  }

  @override
  String get exit => 'Exit';

  @override
  String get exitApplication => 'Exit the application';

  @override
  String get fontSize => 'Font size';

  @override
  String get fontSizeMustBeGreaterThan5 => 'Font size must be greater than 5';

  @override
  String get help => 'Help';

  @override
  String get helpClientDescription => 'To connect as a client, enter the server\'s IP address or scan the QR code displayed on the main device. Once connected, you will see the lyrics of the song currently being presented.';

  @override
  String get helpClientTitle => 'Client mode';

  @override
  String get helpPlaylistsDescription => 'Playlists allow you to group songs into sets. You can create new playlists, edit their names, and add or remove songs. The order of songs on the list can be changed by dragging them using the handle icon.';

  @override
  String get helpPlaylistsTitle => 'Playlists';

  @override
  String get helpPresentationDescription => 'Presentation mode allows you to display song lyrics on other devices. In the presentation settings, you can configure the server parameters and see a QR code to facilitate connection.';

  @override
  String get helpPresentationTitle => 'Presentation mode';

  @override
  String get helpSongsDescription => 'You can add songs manually or search for their lyrics. To add a song, click the \'+\' button on the song list. In the form, you can enter the title, author, and lyrics. Use the search button to automatically download the text.';

  @override
  String get helpSongsTitle => 'Songs management';

  @override
  String get ipIsRequired => 'IP is required';

  @override
  String get language => 'Language:';

  @override
  String get latest => 'Latest';

  @override
  String get leave => 'Leave';

  @override
  String get loading => 'Loading...';

  @override
  String get name => 'Name';

  @override
  String get nameIsRequired => 'Name is required';

  @override
  String get noActiveInternetConnection => 'No active internet connection';

  @override
  String get noConnection => 'No connection';

  @override
  String get noPlaylists => 'Add your first playlist';

  @override
  String get noPlaylistsSelected => 'No playlists selected';

  @override
  String get noSongs => 'Add your first song';

  @override
  String get noSongsAssigned => 'No songs assigned';

  @override
  String get noSongsSelected => 'No songs selected';

  @override
  String get noTextToDisplay => 'No text to display';

  @override
  String numberOfConnectedDevices(Object number) {
    return 'Number of connected devices: $number';
  }

  @override
  String numberOfPlaylists(Object number) {
    return 'Number of playlists: $number';
  }

  @override
  String numberOfSongs(Object number) {
    return 'Number of songs: $number';
  }

  @override
  String get ok => 'Ok';

  @override
  String get oldest => 'Oldest';

  @override
  String get parametersProvidedAreIncorrect => 'The parameters provided are incorrect';

  @override
  String get playlists => 'Playlists';

  @override
  String get playlistsToWhichSongHasBeenAdded => 'Playlists to which the song has been added';

  @override
  String get pleaseSelectOnlyOneListForPresentation => 'Please select only one list for presentation';

  @override
  String get pleaseSelectPlaylistForPresentation => 'Please select the playlist for presentation';

  @override
  String position(Object position) {
    return 'Position: $position';
  }

  @override
  String get presentationIsOnlyPossibleForOneList => 'Presentation is only possible for one playlist';

  @override
  String get presentationScreen => 'Present';

  @override
  String get presentationSettings => 'Presentation settings';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get quickSearch => 'Quick search';

  @override
  String get removingSongFromPlaylist => 'Removing a song from a playlist';

  @override
  String get reuseThisAddress => 'Reuse this address?';

  @override
  String get save => 'Save';

  @override
  String get saveAndContinue => 'Save and continue';

  @override
  String get saveAndExit => 'Save and exit';

  @override
  String get saveAndLunchPresentation => 'Save and launch presentation';

  @override
  String get savedSuccessfully => 'Saved successfully';

  @override
  String get search => 'Search';

  @override
  String get searchInProgress => 'Search in progress';

  @override
  String get searching => 'Searching';

  @override
  String get selectSong => 'Select a song';

  @override
  String get serverDown => 'Server down';

  @override
  String get serverSettings => 'Server settings';

  @override
  String get settingsHaveBeenSaved => 'The settings have been saved';

  @override
  String get showText => 'Show text';

  @override
  String get singersAssistant => 'Singer assistant';

  @override
  String songMustHaveTextDividedIntoLines(Object title) {
    return 'The song $title must have text divided into lines. Presentation creation has been suspended.';
  }

  @override
  String get songSelection => 'Song selection';

  @override
  String get songsAddedToPlaylist => 'Songs added to playlist';

  @override
  String get songsList => 'Songs list';

  @override
  String get sortBy => 'Sort by';

  @override
  String get startServer => 'Start server';

  @override
  String get stopServer => 'Stop server';

  @override
  String get termsAndConditions => 'Terms and conditions';

  @override
  String get text => 'Text';

  @override
  String get textFound => 'Text found';

  @override
  String get textIsRequired => 'Text is required';

  @override
  String get theAddressOfTheLastServerUsedIs => 'The address of the last server used is:';

  @override
  String get thePlaylistDoesNotContainAnySongs => 'The playlist does not contain any songs';

  @override
  String get theValueEnteredIsNotNumber => 'The value entered is not a number';

  @override
  String get thereIsAlreadyPlaylistWithThisName => 'There is already a playlist with this name';

  @override
  String get thereIsAlreadySongWithThisTitle => 'There is already a song with this title';

  @override
  String get thereWasProblemWithConnection => 'There was a problem with the connection';

  @override
  String get thisWillBeTheFontSize => 'This will be the font size';

  @override
  String get title => 'Title';

  @override
  String get titleIsRequired => 'Title is required';

  @override
  String get toAddToPlaylistSelectSongs => 'To add to the playlist you need to select songs.';

  @override
  String get toCreatePlaylistYouNeedToSelectSongs => 'To create a playlist you need to select songs.';

  @override
  String get toExistingPlaylist => 'To existing playlist';

  @override
  String get toNewPlaylist => 'Create new playlist';

  @override
  String get toRunPresentationSelectSongs => 'To start presentation you need to select songs.';

  @override
  String get toSearchForTextYouNeedAtLeastTitleOrAuthor => 'To search for a text you need at least the title or author';

  @override
  String get tooManyMatchingArtistsFoundPleaseSpecifyArtistName => 'Too many matching artists found, please specify the artist name';

  @override
  String get textScrollMode => 'Text scroll mode';

  @override
  String get textScrollModeHorizontal => 'Horizontal';

  @override
  String get textScrollModeVertical => 'Vertical';

  @override
  String get theme => 'Theme:';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get systemTheme => 'System';

  @override
  String get tryAgain => 'Try again';

  @override
  String get unsavedChanges => 'Unsaved changes';

  @override
  String get unsavedChangesInPlaylist => 'There are unsaved changes in the playlist. Do you want to save them before starting the presentation?';

  @override
  String get wifiHotspotDisabled => 'Wifi hotspot disabled';

  @override
  String get yes => 'Yes';

  @override
  String get youMustMarkSongsToBeDeleted => 'You must mark the songs to be deleted';

  @override
  String get youShouldMarkThePlaylistsToBeDeleted => 'You should mark the playlists to be deleted';

  @override
  String get yourPrivacyChoicesHaveBeenUpdated => 'Your privacy choices have been updated';
}
