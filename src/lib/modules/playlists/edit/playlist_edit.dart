import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pomocnik_wokalisty/ads/ads_mixin.dart';
import 'package:pomocnik_wokalisty/ads/interstitial_ads_mixin.dart';
import 'package:pomocnik_wokalisty/helpers/bloc_text_form_field.dart';
import 'package:pomocnik_wokalisty/injection_container.dart';
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';
import 'package:pomocnik_wokalisty/modules/playlists/edit/cubit/playlist_edit_cubit.dart';
import 'package:pomocnik_wokalisty/modules/playlists/edit/helpers/playlist_edit_validator.dart';
import 'package:pomocnik_wokalisty/modules/playlists/edit/partials/playlist_songs_list_component.dart';
import 'package:pomocnik_wokalisty/modules/playlists/edit/views/dialogs/song_selection_dialog.dart';
import 'package:pomocnik_wokalisty/modules/playlists/list/partials/list/bloc/playlists_list_component_bloc.dart';
import 'package:pomocnik_wokalisty/modules/playlists/repositories/playlists_repository.dart';
import 'package:pomocnik_wokalisty/modules/presentation/bloc/presentation_bloc.dart';
import 'package:pomocnik_wokalisty/modules/presentation/views/presentation_view.dart';

class PlaylistEdit extends StatefulWidget with PlaylistEditValidator {
  PlaylistEdit({super.key, required this.playlistId});

  final String playlistId;

  @override
  State<PlaylistEdit> createState() => _PlaylistEditState();
}

class _PlaylistEditState extends State<PlaylistEdit>
    with PlaylistEditValidator, Ads, InterstitialAds {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    initAds(_getWidth, _setBannerAdd);
    initializeInterstitialMobileAdsSDK();
  }

  @override
  void dispose() {
    bannerAd?.dispose();
    interstitialAd?.dispose();
    super.dispose();
  }

  void _setBannerAdd(BannerAd? banner) {
    setState(() {
      bannerAd = banner;
    });
  }

  int _getWidth() {
    return MediaQuery.sizeOf(context).width.truncate();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => PlaylistEditCubit()..initForm(widget.playlistId),
      child: BlocBuilder<PlaylistEditCubit, PlaylistEditState>(
        builder: (context, state) {
          final cubit = context.read<PlaylistEditCubit>();
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (bool didPop, dynamic result) async {
              if (didPop) return;

              if (!cubit.isModified) {
                Navigator.of(context).pop();
                return;
              }

              final shouldPop =
                  await _showExitConfirmationDialog(context) ?? false;
              if (shouldPop && context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.maybePop(context),
                ),
                title: Text(
                  localizations.editPlaylist,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: Column(
                          children: [
                            IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed:
                                          () => _showSongSelectionDialog(
                                            context,
                                            cubit,
                                          ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Theme.of(
                                              context,
                                            ).scaffoldBackgroundColor,
                                        foregroundColor: Colors.black,
                                        elevation: 0,
                                        shape: const RoundedRectangleBorder(),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.queue_music),
                                          const SizedBox(height: 4),
                                          FittedBox(
                                            child: Text(
                                              localizations.addSong,
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed:
                                          () => _runPresentationForSelected(
                                            context,
                                            cubit,
                                          ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Theme.of(
                                              context,
                                            ).scaffoldBackgroundColor,
                                        foregroundColor: Colors.black,
                                        elevation: 0,
                                        shape: const RoundedRectangleBorder(),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const ImageIcon(
                                            AssetImage(
                                              'assets/images/icons/presentation.png',
                                            ),
                                            size: 18,
                                          ),
                                          const SizedBox(height: 4),
                                          FittedBox(
                                            child: Text(
                                              localizations.presentationScreen,
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          _savePlaylist(context, cubit);
                                        } else {
                                          cubit.updateAutovalidateMode(
                                            AutovalidateMode.always,
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Theme.of(
                                              context,
                                            ).scaffoldBackgroundColor,
                                        foregroundColor: Colors.black,
                                        elevation: 0,
                                        shape: const RoundedRectangleBorder(),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.save),
                                          const SizedBox(height: 4),
                                          FittedBox(
                                            child: Text(
                                              localizations.save,
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed:
                                          () => _confirmDelete(context, cubit),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Theme.of(
                                              context,
                                            ).scaffoldBackgroundColor,
                                        foregroundColor: Colors.red,
                                        elevation: 0,
                                        shape: const RoundedRectangleBorder(),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.delete),
                                          const SizedBox(height: 4),
                                          FittedBox(
                                            child: Text(
                                              localizations.delete,
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            Form(
                              key: _formKey,
                              autovalidateMode: state.autovalidateMode,
                              child: Column(
                                children: [
                                  BlocTextFormField<
                                    PlaylistEditCubit,
                                    PlaylistEditState
                                  >(
                                    bloc: cubit,
                                    selector: (state) => state.name,
                                    validator:
                                        (value) => validateName(
                                          value,
                                          state.uuid,
                                          localizations,
                                        ),
                                    onChanged: cubit.updateName,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) {
                                      if (_formKey.currentState!.validate()) {
                                        _savePlaylist(context, cubit);
                                      } else {
                                        cubit.updateAutovalidateMode(
                                          AutovalidateMode.always,
                                        );
                                      }
                                    },
                                    decoration: InputDecoration(
                                      labelText: localizations.name,
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            PlaylistSongsListComponent(
                              playlistEditCubit: cubit,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  getBanerWidget(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, PlaylistEditCubit cubit) async {
    final localizations = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(localizations.deletePlaylist),
            content: Text(localizations.areYouSureYouWantToDeleteThisPlaylist),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(localizations.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  localizations.delete,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true && context.mounted) {
      await cubit.delete();
      if (context.mounted) {
        context.read<PlaylistsListComponentBloc>().add(ReloadListEvent());
        Navigator.of(context).pop();
      }
    }
  }

  void _savePlaylist(
    BuildContext context,
    PlaylistEditCubit playlistEditCubit,
  ) {
    playlistEditCubit.save();

    context.read<PlaylistsListComponentBloc>().add(ReloadListEvent());

    return Navigator.of(context).pop();
  }

  void _runPresentationForSelected(
    BuildContext parentContext,
    PlaylistEditCubit cubit,
  ) async {
    final localizations = AppLocalizations.of(parentContext)!;
    final selectedSongs = cubit.state.songsIds;

    if (selectedSongs.isEmpty) {
      return showNoSongsAssignedDialog(
        localizations.thePlaylistDoesNotContainAnySongs,
      );
    }
    final playlist = sl<PlaylistsRepository>().getPlaylist(cubit.state.uuid);

    parentContext.read<PresentationBloc>().add(
      PlaylistPresentation(playlist: playlist!),
    );

    showInterstitialAds();

    Navigator.of(parentContext).push(
      MaterialPageRoute(builder: (parentContext) => const PresentationView()),
    );
  }

  Future<void> showNoSongsAssignedDialog(String message) {
    final localizations = AppLocalizations.of(context)!;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            localizations.noSongsAssigned,
            style: const TextStyle(fontSize: 20),
          ),
          content: SingleChildScrollView(
            child: ListBody(children: <Widget>[Text(message)]),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(localizations.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showExitConfirmationDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(localizations.areYouSureYouWantToLeaveTheApplication),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(localizations.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(localizations.leave),
              ),
            ],
          ),
    );
  }

  Future<void> _showSongSelectionDialog(
    BuildContext context,
    PlaylistEditCubit cubit,
  ) async {
    final selectedSongsIds = await showDialog<List<String>>(
      context: context,
      builder: (context) => const SongSelectionDialog(),
    );

    if (selectedSongsIds != null && selectedSongsIds.isNotEmpty) {
      cubit.addSongs(selectedSongsIds);
    }
  }
}
