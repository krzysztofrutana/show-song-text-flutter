import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:pomocnik_wokalisty/helpers/localization_manager.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/common/cubic/song_search_cubit.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/common/models/search_dialog_result_model.dart';
import 'package:pomocnik_wokalisty/webscraping/models/search_result_model.dart';
import 'package:pomocnik_wokalisty/webscraping/models/song_to_find_model.dart';

enum SearchSourceViewEnum { songEditForm, songAddForm }

class SearchDialog extends StatefulWidget {
  final SongToFindModel songToFind;
  final SearchSourceViewEnum sourceView;

  const SearchDialog(
      {super.key, required this.songToFind, required this.sourceView});

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  @override
  void initState() {
    context.read<SongSearchCubit>().initSearch(widget.songToFind);
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      initSearch(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongSearchCubit, SongSearchState>(
        builder: (context, state) => AlertDialog(
              title: Text(state.status != ResultState.textFinded
                  ? LocalizationManager.instance.appLocalization.searching
                  : LocalizationManager.instance.appLocalization.textFound),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    Visibility(
                        visible: state.status != ResultState.textFinded,
                        child: Text(_getTextByStatus(state.status))),
                    Visibility(
                        visible: state.status == ResultState.textFinded,
                        child: SingleChildScrollView(
                          child: Text(state.findedText ?? ''),
                        ))
                  ],
                ),
              ),
              actions: [
                BlocBuilder<SongSearchCubit, SongSearchState>(
                  builder: (context, state) => Visibility(
                    visible: state.status == ResultState.textFinded,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(SearchDialogResultModel(
                            text: state.findedText,
                            author: state.choosenSong?.artist,
                            title: state.choosenSong?.title));
                      },
                      child: Text(
                          LocalizationManager.instance.appLocalization.confirm),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child:
                      Text(LocalizationManager.instance.appLocalization.cancel),
                ),
              ],
            ));
  }

  String _getTextByStatus(ResultState status) {
    switch (status) {
      case ResultState.toManyArtistOnList:
        return LocalizationManager.instance.appLocalization
            .tooManyMatchingArtistsFoundPleaseSpecifyArtistName;
      case ResultState.cannotFindAnyArtists:
        return LocalizationManager
            .instance.appLocalization.couldntFindMatchingArtist;
      case ResultState.cannotFindAnySongs:
        return LocalizationManager
            .instance.appLocalization.couldntFindMatchingSong;
      case ResultState.cannotFindText:
        return LocalizationManager
            .instance.appLocalization.couldNotFindTextForGivenParameters;
      case ResultState.connectionError:
        return LocalizationManager
            .instance.appLocalization.thereWasProblemWithConnection;
      case ResultState.invalidRequestData:
        return LocalizationManager
            .instance.appLocalization.parametersProvidedAreIncorrect;
      case ResultState.searchStarted:
        return LocalizationManager.instance.appLocalization.searchInProgress;
      case ResultState.textFinded:
        return LocalizationManager.instance.appLocalization.textFound;
      case ResultState.songsToChooseFinded:
      case ResultState.chooseSongFromList:
        return LocalizationManager.instance.appLocalization.songSelection;
      default:
        return '';
    }
  }

  void initSearch(BuildContext context) {
    var searchCubicState = context.read<SongSearchCubit>().state;
    var songToFind = searchCubicState.song;

    if (songToFind!.title != null &&
        songToFind.title!.isNotEmpty &&
        songToFind.artist != null &&
        songToFind.artist!.isNotEmpty) {
      _getSearchByArtistAndTitleDialog(context);
      return;
    } else if (songToFind.artist != null &&
        songToFind.artist!.isNotEmpty &&
        (songToFind.title == null || songToFind.title!.isEmpty)) {
      _getChooseDialog(
          context, context.read<SongSearchCubit>().searchByArtists());
      return;
    } else if (songToFind.title != null &&
        songToFind.title!.isNotEmpty &&
        (songToFind.artist == null || songToFind.artist!.isEmpty)) {
      _getChooseDialog(
          context, context.read<SongSearchCubit>().searchSongByTitle());
      return;
    }
  }

  _getSearchByArtistAndTitleDialog(BuildContext parentContext) {
    var searchFuture =
        parentContext.read<SongSearchCubit>().searchSongByArtistAndTitle();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return FutureProgressDialog(searchFuture,
            message: Text(
                LocalizationManager.instance.appLocalization.searchInProgress));
      },
    );
  }

  _getChooseDialog(BuildContext parentContext, Future<bool> future) {
    return future.then((data) async => parentContext.mounted
        ? data == true
            ? _showChooseDialog(parentContext)
            : {}
        : {});
  }

  _showChooseDialog(BuildContext parentContext) async {
    var result = await showDialog<FindedSongModel>(
      barrierDismissible: true,
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
            title:
                Text(LocalizationManager.instance.appLocalization.selectSong),
            children: _getSongsLists(parentContext, context));
      },
    );

    if (parentContext.mounted) {
      if (result == null) {
        Navigator.of(parentContext).pop();
      }
    }
  }

  List<Widget> _getSongsLists(
      BuildContext parentContext, BuildContext dialogContext) {
    List<Widget> result = [];
    var searchCubicState = parentContext.read<SongSearchCubit>().state;

    for (var song in searchCubicState.songsToChoose) {
      result.add(SimpleDialogOption(
        child: Text(song.fullName),
        onPressed: () {
          setState(() {
            parentContext.read<SongSearchCubit>().setChoosenSong(song);
            _getSearchByChoosenSongDialog(parentContext);
            Navigator.of(dialogContext).pop(song);
            Navigator.of(dialogContext).pop(song);
          });
        },
      ));
    }

    return result;
  }

  _getSearchByChoosenSongDialog(BuildContext parentContext) async {
    var searchFuture =
        parentContext.read<SongSearchCubit>().searchByChoosenSong();

    await showDialog<void>(
      context: parentContext,
      builder: (BuildContext context) {
        return FutureProgressDialog(searchFuture,
            message: Text(
                LocalizationManager.instance.appLocalization.searchInProgress));
      },
    );
  }
}
