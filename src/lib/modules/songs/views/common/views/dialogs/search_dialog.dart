import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/common/cubit/song_search_cubit.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/common/models/search_dialog_result_model.dart';
import 'package:pomocnik_wokalisty/webscraping/models/search_result_model.dart';
import 'package:pomocnik_wokalisty/webscraping/models/song_to_find_model.dart';

enum SearchSourceViewEnum { songEditForm, songAddForm }

class SearchDialog extends StatefulWidget {
  const SearchDialog(
      {super.key, required this.songToFind, required this.sourceView});

  final SongToFindModel songToFind;
  final SearchSourceViewEnum sourceView;

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
    final localizations = AppLocalizations.of(context)!;
    return BlocBuilder<SongSearchCubit, SongSearchState>(
        builder: (context, state) => AlertDialog(
              title: Text(state.status != ResultState.textFinded
                  ? localizations.searching
                  : localizations.textFound),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    Visibility(
                        visible: state.status != ResultState.textFinded,
                        child: Text(
                            _getTextByStatus(state.status, localizations))),
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
                      child: Text(localizations.confirm),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(localizations.cancel),
                ),
              ],
            ));
  }

  String _getTextByStatus(ResultState status, AppLocalizations localizations) {
    switch (status) {
      case ResultState.toManyArtistOnList:
        return localizations.tooManyMatchingArtistsFoundPleaseSpecifyArtistName;
      case ResultState.cannotFindAnyArtists:
        return localizations.couldntFindMatchingArtist;
      case ResultState.cannotFindAnySongs:
        return localizations.couldntFindMatchingSong;
      case ResultState.cannotFindText:
        return localizations.couldNotFindTextForGivenParameters;
      case ResultState.connectionError:
        return localizations.thereWasProblemWithConnection;
      case ResultState.invalidRequestData:
        return localizations.parametersProvidedAreIncorrect;
      case ResultState.searchStarted:
        return localizations.searchInProgress;
      case ResultState.textFinded:
        return localizations.textFound;
      case ResultState.songsToChooseFinded:
      case ResultState.chooseSongFromList:
        return localizations.songSelection;
      default:
        return '';
    }
  }

  void initSearch(BuildContext context) {
    final searchCubitState = context.read<SongSearchCubit>().state;
    final songToFind = searchCubitState.song;

    if (songToFind!.title != null &&
        songToFind.title!.isNotEmpty &&
        songToFind.artist != null &&
        songToFind.artist!.isNotEmpty) {
      _getChooseDialog(context,
          context.read<SongSearchCubit>().searchSongByArtistAndTitle());
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

  _getChooseDialog(BuildContext parentContext, Future<bool> future) {
    return future.then((data) async => parentContext.mounted
        ? data == true
            ? _showChooseDialog(parentContext)
            : {}
        : {});
  }

  _showChooseDialog(BuildContext parentContext) async {
    final localizations = AppLocalizations.of(parentContext)!;
    final result = await showDialog<FindedSongModel>(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
            title: Text(localizations.selectSong),
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
    final result = <Widget>[];
    final searchCubitState = parentContext.read<SongSearchCubit>().state;

    for (var song in searchCubitState.songsToChoose) {
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
    final localizations = AppLocalizations.of(parentContext)!;
    final searchFuture =
        parentContext.read<SongSearchCubit>().searchByChoosenSong();

    await showDialog<void>(
      context: parentContext,
      builder: (BuildContext context) {
        return FutureProgressDialog(searchFuture,
            message: Text(localizations.searchInProgress));
      },
    );
  }
}
