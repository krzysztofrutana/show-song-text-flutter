import 'package:flutter/material.dart';
import 'package:pomocnik_wokalisty/modules/songs/models/song_model.dart';

class PresentationSongInfo {
  PresentationSongInfo(
      {required this.title,
      required this.songNumber,
      required this.totalSongsCount,
      required this.pageIndex,
      required this.pageIndexInSongContext,
      required this.totalPagesCountForSong,
      required this.pageWidget,
      required this.pageText,
      required this.song});

  String title;
  int songNumber;
  int totalSongsCount;
  int pageIndex;
  int pageIndexInSongContext;
  int totalPagesCountForSong;
  Widget pageWidget;
  String pageText;
  Song song;

  int get pageNumberInSongContext {
    return pageIndexInSongContext + 1;
  }

  bool get lastPageForSong {
    return pageNumberInSongContext == totalPagesCountForSong;
  }

  bool get firstPageForSong {
    return pageIndexInSongContext == 0;
  }

  bool get nextSongExist {
    return songNumber < totalSongsCount;
  }

  bool get previewSongExist {
    return songNumber > 1;
  }

  bool get nextPageExist {
    return pageNumberInSongContext < totalPagesCountForSong;
  }

  bool get previewPageExist {
    return pageNumberInSongContext > 1;
  }
}
