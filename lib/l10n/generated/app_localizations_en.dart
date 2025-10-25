// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get addingPlaylist => 'Adding a playlist';

  @override
  String get addSong => 'Add a song';

  @override
  String get addTo => 'Add to';

  @override
  String get addToPlaylistSentence => 'Add to playlist';

  @override
  String get addingToPlaylist => 'Adding to playlist';

  @override
  String get and => 'and';

  @override
  String get anErrorOccurredWhileTryingToChangeYourPrivacyPreferences => 'An error ocurred while trying to change your privacy preferences';

  @override
  String get anErrorOccurredWhileRetrievingListInformation => 'An error occurred while retrieving list information.';

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
  String get author => 'Author';

  @override
  String get authorIsRequired => 'Author is required';

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
  String get couldntFindMatchingArtist => 'Couldn\'t find a matching artist';

  @override
  String get couldntFindMatchingSong => 'Couldn\'t find a matching song';

  @override
  String get couldNotFindTextForGivenParameters => 'Could not find text for the given parameters';

  @override
  String get create => 'Create';

  @override
  String get createPlaylist => 'Create playlist';

  @override
  String get currentIP => 'Current IP:';

  @override
  String get delete => 'Delete';

  @override
  String get deletingPlaylists => 'Deleting playlists';

  @override
  String get deletingSongs => 'Deleting songs';

  @override
  String get editPlaylist => 'Edit playlist';

  @override
  String get editSong => 'Edit song';

  @override
  String get enterName => 'Enter a name';

  @override
  String get enterTheIpFromTheServerSettings => 'Enter the IP from the server settings';

  @override
  String get error => 'Error';

  @override
  String errorWithMessage(Object message) {
    return 'Error: $message';
  }

  @override
  String get fontSize => 'Font size';

  @override
  String get fontSizeMustBeGreaterThan5 => 'Font size must be greater than 5';

  @override
  String get ipIsRequired => 'IP is required';

  @override
  String get language => 'Language:';

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
  String get noPlaylists => 'No playlists';

  @override
  String get noPlaylistsSelected => 'No playlists selected';

  @override
  String get noSongs => 'No songs';

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
  String get presentiaton => 'Presentation';

  @override
  String get presentationIsOnlyPossibleForOneList => 'Presentation is only possible for one playlist';

  @override
  String get presentationScreen => 'Presentation screen';

  @override
  String get presentationSettings => 'Presentation settings';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get removingSongFromPlaylist => 'Removing a song from a playlist';

  @override
  String get reuseThisAddress => 'Reuse this address?';

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
  String get singersAssistant => 'Singer assistant';

  @override
  String get songSelection => 'Song selection';

  @override
  String get songsAddedToPlaylist => 'Songs added to playlist';

  @override
  String get songsList => 'Songs list';

  @override
  String get termsAndConditions => 'Terms and conditions';

  @override
  String get text => 'Text';

  @override
  String get textFound => 'Text found';

  @override
  String get textIsRequired => 'Text is required';

  @override
  String get thisWillBeTheFontSize => 'This will be the font size';

  @override
  String get theAddressOfTheLastServerUsedIs => 'The address of the last server used is:';

  @override
  String get thePlaylistDoesNotContainAnySongs => 'The playlist does not contain any songs';

  @override
  String get thereIsAlreadyPlaylistWithThisName => 'There is already a playlist with this name';

  @override
  String get thereIsAlreadySongWithThisTitle => 'There is already a song with this title';

  @override
  String get thereWasProblemWithConnection => 'There was a problem with the connection';

  @override
  String get theValueEnteredIsNotNumber => 'The value entered is not a number';

  @override
  String get title => 'Title';

  @override
  String get titleIsRequired => 'Title is required';

  @override
  String get toCreatePlaylistYouNeedToSelectSongs => 'To create a playlist you need to select songs.';

  @override
  String get tooManyMatchingArtistsFoundPleaseSpecifyArtistName => 'Too many matching artists found, please specify the artist name';

  @override
  String get toAddToPlaylistSelectSongs => 'To add to the playlist you need to select songs.';

  @override
  String get toRunPresentationSelectSongs => 'To start presentation you need to select songs.';

  @override
  String get toSearchForTextYouNeedAtLeastTitleOrAuthor => 'To search for a text you need at least the title or author';

  @override
  String get wifiHotspotDisabled => 'Wifi hotspot disabled';

  @override
  String get yes => 'Yes';

  @override
  String get youMustMarkSongsToBeDeleted => 'You must mark the songs to be deleted';

  @override
  String get youShouldMarkThePlaylistsToBeDeleted => 'You should mark the playlists to be deleted';

  @override
  String get yourPrivacyChoisesHasBeenUpdated => 'Your privacy choises has been updated';
}
