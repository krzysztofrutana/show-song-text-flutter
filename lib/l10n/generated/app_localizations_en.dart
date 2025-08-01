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
  String get anErrorOccurredWhileRetrievingListInformation => 'An error occurred while retrieving list information.';

  @override
  String get areYouSureYouWantDeletSelectedLists => 'Are you sure you want to delete the selected lists?';

  @override
  String areYouSureYouWantRemoveSongFromPlaylistAtPosition(Object author, Object index, Object title) {
    return 'Are you sure you want to remove the song $author - $title from the playlist at position $index?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get changesWillBeImplementedAfterSavingTheForm => 'Changes will be implemented after saving the form';

  @override
  String get clientMode => 'Client mode';

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
  String get deletingPlaylists => 'Deleting playlists';

  @override
  String get editPlaylist => 'Edit playlist';

  @override
  String get enterName => 'Enter a name';

  @override
  String get enterTheIpFromTheServerSettings => 'Enter the IP from the server settings';

  @override
  String get error => 'Error';

  @override
  String get fontSize => 'Font size';

  @override
  String get fontSizeMustBeGreaterThan5 => 'Font size must be greater than 5';

  @override
  String get ipIsRequired => 'IP is required';

  @override
  String get name => 'Name';

  @override
  String get nameIsRequired => 'Name is required';

  @override
  String get noConnection => 'No connection';

  @override
  String get noPlaylists => 'No playlists';

  @override
  String get noPlaylistsSelected => 'No playlists selected';

  @override
  String get noSongsAssigned => 'No songs assigned';

  @override
  String get noTextToDisplay => 'No text to display';

  @override
  String numberOfPlaylists(Object number) {
    return 'Number of playlists: $number';
  }

  @override
  String get ok => 'Ok';

  @override
  String get playlists => 'Playlists';

  @override
  String get pleaseSelectOnlyOneListForPresentation => 'Please select only one list for presentation';

  @override
  String get pleaseSelectPlaylistForPresentation => 'Please select the playlist for presentation';

  @override
  String get presentiaton => 'Presentation';

  @override
  String get presentationIsOnlyPossibleForOneList => 'Presentation is only possible for one playlist';

  @override
  String get presentationScreen => 'Presentation screen';

  @override
  String get presentationSettings => 'Presentation settings';

  @override
  String get removingSongFromPlaylist => 'Removing a song from a playlist';

  @override
  String get reuseThisAddress => 'Reuse this address?';

  @override
  String get search => 'Search';

  @override
  String get serverSettings => 'Server settings';

  @override
  String get singersAssistant => 'Singer\'s assistant';

  @override
  String get songsAddedToPlaylist => 'Songs added to playlist';

  @override
  String get songsList => 'Songs list';

  @override
  String get thisWillBeTheFontSize => 'This will be the font size';

  @override
  String get theAddressOfTheLastServerUsedIs => 'The address of the last server used is:';

  @override
  String get thereIsAlreadyPlaylistWithThisName => 'There is already a playlist with this name';

  @override
  String get theValueEnteredIsNotNumber => 'The value entered is not a number';

  @override
  String get yes => 'Yes';

  @override
  String get youShouldMarkThePlaylistsToBeDeleted => 'You should mark the playlists to be deleted';
}
