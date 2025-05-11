import 'package:chaleno/chaleno.dart';
import 'package:pomocnik_wokalisty/webscraping/helpers/text_helper.dart';
import 'package:pomocnik_wokalisty/webscraping/models/search_result_model.dart';
import 'package:pomocnik_wokalisty/webscraping/models/song_to_find_model.dart';

class TekstowoHelper {
  static Future<SearchResultModel> findTextFromArtistAndTitle(
      SongToFindModel songToFind, bool useLinkFromObject) async {
    Parser? parser;
    String? text;

    try {
      String url;
      if (useLinkFromObject &&
          songToFind.linkToSong != null &&
          songToFind.linkToSong!.isNotEmpty) {
        url = "https://www.tekstowo.pl/${songToFind.linkToSong}";
      } else if (songToFind.normalizedArtist != null &&
          songToFind.normalizedArtist!.isNotEmpty &&
          songToFind.normalizedTitle != null &&
          songToFind.normalizedTitle!.isNotEmpty) {
        url =
            "https://www.tekstowo.pl/piosenka,${songToFind.normalizedArtist},${songToFind.normalizedTitle}.html";
      } else {
        return SearchResultModel(
            song: songToFind, state: ResultState.invalidRequestData);
      }

      parser = await Chaleno().load(url);
    } catch (e) {
      return SearchResultModel(
          song: songToFind, state: ResultState.connectionError);
    }

    text = parser?.querySelector("#songText > .inner-text").text;

    if (text == null || text.isEmpty) {
      return SearchResultModel(
          song: songToFind, state: ResultState.cannotFindText);
    }

    text = TextHelper.deleteStartAndEndEmptyLines(text);

    var result =
        SearchResultModel(song: songToFind, state: ResultState.textFinded);
    result.text = text;

    return result;
  }

  static Future<SearchResultModel> searchByArtist(
      SongToFindModel songToFind) async {
    var encodedArtist = songToFind.normalizedArtist!
        .replaceAll("_", "+")
        .replaceAll("/", "_")
        .replaceAll("'", "%27");
    Parser? parser;
    String? url;

    try {
      if (encodedArtist.isNotEmpty) {
        url =
            "https://www.tekstowo.pl/szukaj,wykonawca,$encodedArtist,tytul.html";

        parser = await Chaleno().load(url);
      }
    } catch (e) {
      return SearchResultModel(
          song: songToFind, state: ResultState.connectionError);
    }

    if (validateIfToManyResultsOnPage(parser!)) {
      return SearchResultModel(
          song: songToFind, state: ResultState.toManyArtistOnList);
    }

    var findedSongs =
        await getSongsListFromHtmlDocument(url!, parser, songToFind);

    if (findedSongs.isNotEmpty) {
      var result = SearchResultModel(
          song: songToFind, state: ResultState.artistsToChooseFinded);
      result.songsToChoose = findedSongs;
      return result;
    }

    return SearchResultModel(
        song: songToFind, state: ResultState.cannotFindAnyArtists);
  }

  static Future<SearchResultModel> searchSong(
      SongToFindModel songToFind) async {
    Parser? parser;
    String? url;

    try {
      var encodedTitle = songToFind.normalizedTitle!
          .replaceAll("_", "+")
          .replaceAll("'", "%27");

      if (encodedTitle.isNotEmpty) {
        url =
            "https://www.tekstowo.pl/szukaj,wykonawca,,tytul,$encodedTitle.html";
      } else {
        return SearchResultModel(
            song: songToFind, state: ResultState.invalidRequestData);
      }

      parser = await Chaleno().load(url);
    } catch (e) {
      return SearchResultModel(
          song: songToFind, state: ResultState.connectionError);
    }

    if (validateIfToManyResultsOnPage(parser!)) {
      return SearchResultModel(
          song: songToFind, state: ResultState.toManyArtistOnList);
    }

    var findedSongs =
        await getSongsListFromHtmlDocument(url, parser, songToFind);

    if (findedSongs.isNotEmpty) {
      var result = SearchResultModel(
          song: songToFind, state: ResultState.songsToChooseFinded);
      result.songsToChoose = findedSongs;
      return result;
    }

    return SearchResultModel(
        song: songToFind, state: ResultState.cannotFindAnySongs);
  }

  static Future<List<FindedSongModel>> getSongsListFromHtmlDocument(
      String url, Parser parser, SongToFindModel songToFind) async {
    List<FindedSongModel> findedSongs = [];

    var temp = parser.querySelector(".content > .card");
    var pagesIndexResult = temp.querySelectorAll(".page-item");

    if (pagesIndexResult != null && pagesIndexResult.length > 1) {
      List<String> pagesHTMLLink = [];
      if (url.isNotEmpty) {
        pagesHTMLLink.add(url);
      }

      for (var pageIndex in pagesIndexResult.skip(1)) {
        var indexStartLink = pageIndex.html!.indexOf("href") + 7;
        var indexEndLink = pageIndex.html!.indexOf("title=") - 2;
        var checkIndexOfNextPageButtonElement =
            pageIndex.html!.indexOf("tabindex=");

        if (checkIndexOfNextPageButtonElement != -1) {
          continue;
        }

        if (indexStartLink != 0 && indexEndLink != 0) {
          String link = pageIndex.html!.substring(indexStartLink, indexEndLink);
          if (link.isNotEmpty) {
            if (!pagesHTMLLink.contains("https://www.tekstowo.pl/$link")) {
              pagesHTMLLink.add("https://www.tekstowo.pl/$link");
            }
          }
        }
      }

      for (var pageLink in pagesHTMLLink) {
        try {
          var pageParser = await Chaleno().load(pageLink);
          var songsFromPage = getSongsFromCurrentPage(pageParser!);

          findedSongs.addAll(songsFromPage);
        } catch (e) {
          continue;
        }
      }
    } else {
      var songsFromPage = getSongsFromCurrentPage(parser);

      findedSongs.addAll(songsFromPage);
    }

    return findedSongs;
  }

  static List<FindedSongModel> getSongsFromCurrentPage(Parser parser) {
    List<FindedSongModel> result = [];

    var query = parser.querySelectorAll(".box-przeboje > .flex-group a");

    for (var div in query) {
      var indexStartLink = div.html!.indexOf("<a href") + 10;
      var indexEndLink = div.html!.indexOf("class=\"title\" title=") - 2;
      var indexStartTitle = div.html!.indexOf("title=\"") + 7;
      var tempTitle = div.html!.substring(indexStartTitle);
      var indexEndTitle = tempTitle.indexOf("\">");
      var songName = tempTitle.substring(0, indexEndTitle);
      var link = div.html!.substring(indexStartLink, indexEndLink);

      if (songName.isNotEmpty) {
        songName = songName.trim();
        songName = TextHelper.decodeFromUri(songName);

        var splitted = songName.split("-");
        var artist = splitted[0].trim();
        var title = splitted[1].trim();

        result.add(FindedSongModel(
            fullName: songName, title: title, artist: artist, link: link));
      }
    }
    return result;
  }

  static bool validateIfToManyResultsOnPage(Parser parser) {
    var toManyResults = parser.getElementsByClassName("page-item disbled");

    if (toManyResults.isNotEmpty) return true;

    return false;
  }
}
