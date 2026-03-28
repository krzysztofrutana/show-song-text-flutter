import 'package:chaleno/chaleno.dart';
import 'package:pomocnik_wokalisty/webscraping/helpers/text_helper.dart';
import 'package:pomocnik_wokalisty/webscraping/models/search_result_model.dart';
import 'package:pomocnik_wokalisty/webscraping/models/song_to_find_model.dart';

class TekstowoHelper {
  static Future<SearchResultModel> searchByArtistAndTitle(
      SongToFindModel songToFind, bool useLinkFromObject) async {
    Parser? parser;
    String url;

    try {
      if (songToFind.normalizedArtist != null &&
          songToFind.normalizedArtist!.isNotEmpty &&
          songToFind.normalizedTitle != null &&
          songToFind.normalizedTitle!.isNotEmpty) {
        url =
            "https://www.tekstowo.pl/szukaj?search-query=${songToFind.normalizedArtist}+-+${songToFind.normalizedTitle}.html";
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

    final findedSongs =
        await getSongsListFromHtmlDocument(url, parser, songToFind);

    if (findedSongs.isNotEmpty) {
      final result = SearchResultModel(
          song: songToFind, state: ResultState.artistsToChooseFinded);
      result.songsToChoose = findedSongs;
      return result;
    }

    return SearchResultModel(
        song: songToFind, state: ResultState.cannotFindAnyArtists);
  }

  static Future<SearchResultModel> searchByArtist(
      SongToFindModel songToFind) async {
    final encodedArtist = songToFind.normalizedArtist!;
    Parser? parser;
    String? url;

    try {
      if (encodedArtist.isNotEmpty) {
        url = "https://www.tekstowo.pl/szukaj?search-query=$encodedArtist.html";

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

    final findedSongs =
        await getSongsListFromHtmlDocument(url!, parser, songToFind);

    if (findedSongs.isNotEmpty) {
      final result = SearchResultModel(
          song: songToFind, state: ResultState.artistsToChooseFinded);
      result.songsToChoose = findedSongs;
      return result;
    }

    return SearchResultModel(
        song: songToFind, state: ResultState.cannotFindAnyArtists);
  }

  static Future<SearchResultModel> searchByTitle(
      SongToFindModel songToFind) async {
    Parser? parser;
    String? url;

    try {
      final encodedTitle = songToFind.normalizedTitle!;

      if (encodedTitle.isNotEmpty) {
        url = "https://www.tekstowo.pl/szukaj?search-query=$encodedTitle.html";
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

    final findedSongs =
        await getSongsListFromHtmlDocument(url, parser, songToFind);

    if (findedSongs.isNotEmpty) {
      final result = SearchResultModel(
          song: songToFind, state: ResultState.songsToChooseFinded);
      result.songsToChoose = findedSongs;
      return result;
    }

    return SearchResultModel(
        song: songToFind, state: ResultState.cannotFindAnySongs);
  }

  static Future<SearchResultModel> searchTextByLink(
      SongToFindModel songToFind, bool useLinkFromObject) async {
    Parser? parser;
    String? text;
    String url;

    try {
      if (useLinkFromObject &&
          songToFind.linkToSong != null &&
          songToFind.linkToSong!.isNotEmpty) {
        url = "https://www.tekstowo.pl/${songToFind.linkToSong}";
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

    final result =
        SearchResultModel(song: songToFind, state: ResultState.textFinded);
    result.text = text;

    return result;
  }

  static Future<List<FindedSongModel>> getSongsListFromHtmlDocument(
      String url, Parser parser, SongToFindModel songToFind) async {
    final findedSongs = <FindedSongModel>[];

    final temp = parser.querySelector(".content > .card");
    final pagesIndexResult = temp.querySelectorAll(".page-item");

    if (pagesIndexResult != null && pagesIndexResult.length > 1) {
      final pagesHTMLLink = <String>[];
      if (url.isNotEmpty) {
        pagesHTMLLink.add(url);
      }

      for (var pageIndex in pagesIndexResult.skip(1)) {
        final indexStartLink = pageIndex.html!.indexOf("href") + 7;
        final indexEndLink = pageIndex.html!.indexOf("title=") - 2;
        final checkIndexOfNextPageButtonElement =
            pageIndex.html!.indexOf("tabindex=");

        if (checkIndexOfNextPageButtonElement != -1) {
          continue;
        }

        if (indexStartLink != 0 && indexEndLink != 0) {
          final link = pageIndex.html!.substring(indexStartLink, indexEndLink);
          if (link.isNotEmpty) {
            if (!pagesHTMLLink.contains("https://www.tekstowo.pl/$link")) {
              pagesHTMLLink.add("https://www.tekstowo.pl/$link");
            }
          }
        }
      }

      for (var pageLink in pagesHTMLLink) {
        try {
          final pageParser = await Chaleno().load(pageLink);
          final songsFromPage = getSongsFromCurrentPage(pageParser!);

          findedSongs.addAll(songsFromPage);
        } catch (e) {
          continue;
        }
      }
    } else {
      final songsFromPage = getSongsFromCurrentPage(parser);

      findedSongs.addAll(songsFromPage);
    }

    return findedSongs;
  }

  static List<FindedSongModel> getSongsFromCurrentPage(Parser parser) {
    final result = <FindedSongModel>[];

    final query = parser.querySelectorAll(".box-przeboje > .flex-group a");

    for (var div in query) {
      final indexStartLink = div.html!.indexOf("<a href") + 10;
      final indexEndLink = div.html!.indexOf("class=\"title\" title=") - 2;
      final indexStartTitle = div.html!.indexOf("title=\"") + 7;
      final tempTitle = div.html!.substring(indexStartTitle);
      final indexEndTitle = tempTitle.indexOf("\">");
      var songName = tempTitle.substring(0, indexEndTitle);
      final link = div.html!.substring(indexStartLink, indexEndLink);

      if (songName.isNotEmpty) {
        songName = songName.trim();
        songName = TextHelper.decodeFromUri(songName);

        final splitted = songName.split("-");
        final artist = splitted[0].trim();
        final title = splitted[1].trim();

        result.add(FindedSongModel(
            fullName: songName, title: title, artist: artist, link: link));
      }
    }
    return result;
  }

  static bool validateIfToManyResultsOnPage(Parser parser) {
    final toManyResults = parser.getElementsByClassName("page-item disbled");

    if (toManyResults.isNotEmpty) return true;

    return false;
  }
}
