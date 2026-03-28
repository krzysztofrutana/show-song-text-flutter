import 'package:pomocnik_wokalisty/webscraping/models/search_result_model.dart';
import 'package:pomocnik_wokalisty/webscraping/models/song_to_find_model.dart';
import 'package:pomocnik_wokalisty/webscraping/sources/tekstowo_helper.dart';

class TekstowoService {
  Future<SearchResultModel> searchByArtistAndTitle(
      SongToFindModel songToFind, bool useLinkFromObject) {
    return TekstowoHelper.searchByArtistAndTitle(songToFind, useLinkFromObject);
  }

  Future<SearchResultModel> searchByArtist(SongToFindModel songToFind) {
    return TekstowoHelper.searchByArtist(songToFind);
  }

  Future<SearchResultModel> searchByTitle(SongToFindModel songToFind) {
    return TekstowoHelper.searchByTitle(songToFind);
  }

  Future<SearchResultModel> searchTextByLink(
      SongToFindModel songToFind, bool useLinkFromObject) {
    return TekstowoHelper.searchTextByLink(songToFind, useLinkFromObject);
  }
}
