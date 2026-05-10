import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/ads/interstitial_ads_mixin.dart';
import 'package:pomocnik_wokalisty/helpers/connection_helper.dart';
import 'package:pomocnik_wokalisty/injection_container.dart';
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';
import 'package:pomocnik_wokalisty/modules/presentation/bloc/presentation_bloc.dart';
import 'package:pomocnik_wokalisty/modules/presentation/views/presentation_view.dart';
import 'package:pomocnik_wokalisty/modules/songs/helpers/songs_ui_helper.dart';
import 'package:pomocnik_wokalisty/modules/songs/models/song_model.dart';
import 'package:pomocnik_wokalisty/modules/songs/repositories/songs_repository.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/add/songs_add.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/common/cubit/song_search_cubit.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/common/models/search_dialog_result_model.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/common/views/dialogs/search_dialog.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/list/partials/list/bloc/songs_list_component_bloc.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/list/partials/list/songs_list_component.dart';
import 'package:pomocnik_wokalisty/webscraping/models/song_to_find_model.dart';
import 'package:uuid/uuid.dart';

class SongsList extends StatefulWidget {
  const SongsList({super.key});

  @override
  State<SongsList> createState() => _SongsListState();
}

class _SongsListState extends State<SongsList> with InterstitialAds {
  final _quickSearchFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    initializeInterstitialMobileAdsSDK();
  }

  @override
  void dispose() {
    interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SongsListComponent(
        onAddPressed: () => _redirectToSongsAdd(context),
      ),
      floatingActionButton:
          BlocBuilder<SongsListComponentBloc, SongsListComponentState>(
            builder:
                (context, state) => Visibility(
                  visible: state.chooseSongs == false,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    spacing: 10,
                    children: [
                      FloatingActionButton(
                        heroTag: "quickSearch",
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        child: const Icon(Icons.manage_search, size: 30),
                        onPressed: () => _showQuickAddModal(context),
                      ),
                      Visibility(
                        visible: state.data.isNotEmpty,
                        child: FloatingActionButton(
                          heroTag: "add",
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          child: const Icon(Icons.add, size: 30),
                          onPressed: () => _redirectToSongsAdd(context),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
      bottomNavigationBar: BlocBuilder<
        SongsListComponentBloc,
        SongsListComponentState
      >(
        builder: (internalContext, state) {
          final localizations = AppLocalizations.of(context)!;
          const double iconSize = 18;

          return Visibility(
            visible: state.chooseSongs == true,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        internalContext.read<SongsListComponentBloc>().add(
                          ClearSelectedSongs(),
                        );

                        internalContext.read<SongsListComponentBloc>().add(
                          ChooseSongChangeEvent(value: false),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        foregroundColor:
                            Theme.of(context).colorScheme.onSurface,
                        elevation: 0,
                        shape: const RoundedRectangleBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Icon(Icons.cancel_outlined, size: iconSize),
                          const SizedBox(height: 5),
                          Text(
                            localizations.cancel,
                            style: Theme.of(context).textTheme.labelMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showDeleteConfirmModal(internalContext),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        foregroundColor: Colors.red,
                        elevation: 0,
                        shape: const RoundedRectangleBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ImageIcon(
                            const AssetImage('assets/images/icons/delete.png'),
                            size: iconSize,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            localizations.delete,
                            style: Theme.of(context).textTheme.labelMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        SongsUIHelper.showAddSongsToPlaylistModal(
                          context: context,
                          selectedSongsIds:
                              internalContext
                                  .read<SongsListComponentBloc>()
                                  .state
                                  .selectedSongs,
                          onSuccess: () {
                            internalContext.read<SongsListComponentBloc>().add(
                              ClearSelectedSongs(),
                            );
                            internalContext.read<SongsListComponentBloc>().add(
                              ChooseSongChangeEvent(value: false),
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        foregroundColor:
                            Theme.of(context).colorScheme.onSurface,
                        elevation: 0,
                        shape: const RoundedRectangleBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ImageIcon(
                            const AssetImage(
                              'assets/images/icons/playlist.png',
                            ),
                            size: iconSize,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            localizations.addToPlaylistSentence,
                            style: Theme.of(context).textTheme.labelMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          () => _runPresentationForSelected(internalContext),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        foregroundColor:
                            Theme.of(context).colorScheme.onSurface,
                        elevation: 0,
                        shape: const RoundedRectangleBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ImageIcon(
                            const AssetImage(
                              'assets/images/icons/presentation.png',
                            ),
                            size: iconSize,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            localizations.presentationScreen,
                            style: Theme.of(context).textTheme.labelMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _redirectToSongsAdd(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SongsAdd())).then((_) {
      if (context.mounted) {
        context.read<SongsListComponentBloc>().add(LoadSongsEvent());
      }
    });
  }

  Future<void> _showDeleteConfirmModal(BuildContext parentContext) async {
    final localizations = AppLocalizations.of(context)!;
    final selectedSongsLength =
        parentContext.read<SongsListComponentBloc>().state.selectedSongs.length;

    if (selectedSongsLength == 0) {
      return SongsUIHelper.showNoSongsSelectedDialog(context);
    } else {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(localizations.deletingSongs),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(localizations.areYouSureYouWantDeleteSelectedSongs),
                  Text(localizations.numberOfSongs(selectedSongsLength)),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(localizations.cancel),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text(localizations.yes),
                onPressed: () {
                  parentContext.read<SongsListComponentBloc>().add(
                    RemoveSelectedSongsEvent(),
                  );

                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(localizations.deletedSuccessfully)),
                  );
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _runPresentationForSelected(BuildContext parentContext) async {
    final selectedSongs =
        parentContext.read<SongsListComponentBloc>().state.selectedSongs;

    if (selectedSongs.isEmpty) {
      return SongsUIHelper.showNoSongsSelectedDialog(context);
    }
    final songsRepository = sl<SongsRepository>();
    final allSongs = songsRepository.getAllSongs();

    final toPresentation = List<Song>.empty(growable: true);

    for (var selectedSongId in selectedSongs) {
      final song = allSongs.firstWhereOrNull((x) => x.uuid == selectedSongId);
      if (song != null) {
        toPresentation.add(song);
      }
    }

    parentContext.read<PresentationBloc>().add(
      SongsPresentation(songs: toPresentation),
    );

    showInterstitialAds();

    Navigator.of(parentContext).push(
      MaterialPageRoute(builder: (parentContext) => const PresentationView()),
    );
  }

  Future<void> _showQuickAddModal(BuildContext parentContext) async {
    final localizations = AppLocalizations.of(context)!;
    var newSong = Song(
      uuid: const Uuid().v8(),
      author: "",
      title: "",
      text: "",
    );
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(localizations.quickSearch),
              content: SingleChildScrollView(
                child: Form(
                  key: _quickSearchFormKey,
                  child: Column(
                    children: [
                      ListBody(
                        children: <Widget>[
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: localizations.enterAuthor,
                              labelText: localizations.author,
                            ),
                            validator: (value) {
                              if (newSong.author.isEmpty &&
                                  newSong.title.isEmpty) {
                                return localizations
                                    .toSearchForTextYouNeedAtLeastTitleOrAuthor;
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                newSong = newSong.copyWith(author: value);
                              });
                              _quickSearchFormKey.currentState!.validate();
                            },
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: localizations.enterTitle,
                              labelText: localizations.title,
                            ),
                            validator: (value) {
                              if (newSong.author.isEmpty &&
                                  newSong.title.isEmpty) {
                                return localizations
                                    .toSearchForTextYouNeedAtLeastTitleOrAuthor;
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                newSong = newSong.copyWith(title: value);
                              });
                              _quickSearchFormKey.currentState!.validate();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(localizations.cancel),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text(localizations.search),
                  onPressed: () {
                    if (_quickSearchFormKey.currentState!.validate()) {
                      _onSearchClick(parentContext, newSong);
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _onSearchClick(BuildContext builderContext, Song newSong) async {
    final localizations = AppLocalizations.of(builderContext)!;
    if (!await ConnectionHelper.checkIfDeviceIsConnectedToInternet()) {
      _showNotConnectedInfo(localizations);
      return;
    }

    if (newSong.author.isEmpty && newSong.title.isEmpty) {
      _showInvalidSearchData(localizations);
      return;
    }

    final songToFind = SongToFindModel(newSong.author, newSong.title);

    if (builderContext.mounted) {
      final searchResult = await showDialog<SearchDialogResultModel>(
        context: builderContext,
        builder: (_) {
          return BlocProvider.value(
            value: builderContext.read<SongSearchCubit>(),
            child: SearchDialog(
              songToFind: songToFind,
              sourceView: SearchSourceViewEnum.songAddForm,
            ),
          );
        },
      );

      if (searchResult != null) {
        showInterstitialAds();

        if (searchResult.author != null &&
            searchResult.author!.isNotEmpty &&
            newSong.author != searchResult.author) {
          newSong = newSong.copyWith(author: searchResult.author);
        }

        if (searchResult.title != null &&
            searchResult.title!.isNotEmpty &&
            newSong.title != searchResult.title) {
          newSong = newSong.copyWith(title: searchResult.title);
        }

        newSong = newSong.copyWith(text: searchResult.text);

        if (builderContext.mounted) {
          _quickSearchResultPreviewModal(builderContext, newSong);
        }
      }
    }
  }

  void _showNotConnectedInfo(AppLocalizations localizations) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(localizations.noActiveInternetConnection)),
    );
  }

  void _showInvalidSearchData(AppLocalizations localizations) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localizations.toSearchForTextYouNeedAtLeastTitleOrAuthor),
      ),
    );
  }

  final _previewFormKey = GlobalKey<FormState>();

  Future<void> _quickSearchResultPreviewModal(
    BuildContext parentContext,
    Song newSong,
  ) async {
    final localizations = AppLocalizations.of(context)!;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.quickSearch),
          content: SingleChildScrollView(
            child: Form(
              key: _previewFormKey,
              child: Column(
                children: [
                  ListBody(
                    children: <Widget>[
                      TextFormField(
                        initialValue: newSong.author,
                        decoration: InputDecoration(
                          labelText: localizations.author,
                        ),
                        validator: (value) {
                          if (newSong.title.isEmpty &&
                              (value == null || value.trim().isEmpty)) {
                            return localizations.authorIsRequired;
                          }
                          return null;
                        },
                        onChanged:
                            (value) =>
                                newSong = newSong.copyWith(author: value),
                      ),
                      TextFormField(
                        initialValue: newSong.title,
                        decoration: InputDecoration(
                          labelText: localizations.title,
                        ),
                        validator: (value) {
                          if (newSong.author.isEmpty &&
                              (value == null || value.trim().isEmpty)) {
                            return localizations.titleIsRequired;
                          }
                          return null;
                        },
                        onChanged:
                            (value) => newSong = newSong.copyWith(title: value),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        initialValue: newSong.text,
                        minLines: 12,
                        maxLines: null,
                        decoration: InputDecoration(
                          labelText: localizations.text,
                          alignLabelWithHint: true,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return localizations.textIsRequired;
                          }
                          return null;
                        },
                        onChanged:
                            (value) => newSong = newSong.copyWith(text: value),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(localizations.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(localizations.save),
              onPressed: () {
                if (_previewFormKey.currentState!.validate()) {
                  _saveSong(newSong);
                  parentContext.read<SongsListComponentBloc>().add(
                    ReloadListEvent(),
                  );
                  Navigator.of(context).pop();
                }
              },
            ),
            TextButton(
              child: Text(localizations.saveAndLunchPresentation),
              onPressed: () {
                if (_previewFormKey.currentState!.validate()) {
                  _saveSong(newSong);
                  parentContext.read<SongsListComponentBloc>().add(
                    ReloadListEvent(),
                  );
                  parentContext.read<PresentationBloc>().add(
                    SongsPresentation(songs: [newSong]),
                  );

                  Navigator.of(context).pop();

                  Navigator.of(parentContext).push(
                    MaterialPageRoute(
                      builder: (parentContext) => const PresentationView(),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _saveSong(Song newSong) {
    sl<SongsRepository>().addSong(newSong);
  }
}
