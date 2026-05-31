import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pomocnik_wokalisty/ads/ads_mixin.dart';
import 'package:pomocnik_wokalisty/ads/interstitial_ads_mixin.dart';
import 'package:pomocnik_wokalisty/helpers/bloc_text_form_field.dart';
import 'package:pomocnik_wokalisty/helpers/connection_helper.dart';
import 'package:pomocnik_wokalisty/helpers/recording_mixin.dart';
import 'package:pomocnik_wokalisty/helpers/ui_helper.dart';
import 'package:pomocnik_wokalisty/injection_container.dart';
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';
import 'package:pomocnik_wokalisty/modules/songs/helpers/songs_ui_helper.dart';
import 'package:pomocnik_wokalisty/modules/songs/repositories/songs_repository.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/common/cubit/song_search_cubit.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/common/models/search_dialog_result_model.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/common/views/dialogs/search_dialog.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/edit/cubit/songs_edit_cubit.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/edit/helpers/song_edit_validator.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/edit/partials/playlistsList/song_playlists_list_component.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/edit/partials/recordingsList/song_recordings_list_component.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/list/partials/list/bloc/songs_list_component_bloc.dart';
import 'package:pomocnik_wokalisty/services/audio_download_service.dart';
import 'package:pomocnik_wokalisty/webscraping/models/song_to_find_model.dart';

class SongsEdit extends StatefulWidget {
  const SongsEdit({super.key, required this.songId, this.cubit});

  final String songId;
  final SongsEditCubit? cubit;

  @override
  State<SongsEdit> createState() => _SongsEditState();
}

class _SongsEditState extends State<SongsEdit>
    with SongEditValidator, Ads, InterstitialAds, RecordingMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    initAds(_getWidth, _setBanerAdd);
    initializeInterstitialMobileAdsSDK();
  }

  @override
  void dispose() {
    bannerAd?.dispose();
    interstitialAd?.dispose();
    cancelRecording();
    super.dispose();
  }

  void _setBanerAdd(BannerAd? banner) {
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
      create: (context) {
        final cubit = widget.cubit ?? sl<SongsEditCubit>();
        cubit.initForm(widget.songId);
        return cubit;
      },
      child: BlocBuilder<SongsEditCubit, SongsEditState>(
        builder: (context, state) {
          final cubit = context.read<SongsEditCubit>();
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (bool didPop, dynamic result) async {
              if (didPop) return;

              if (!cubit.isModified) {
                Navigator.of(context).pop();
                return;
              }

              final action = await UIHelper.showExitConfirmationDialog(context);

              if (action == ExitAction.cancel) return;

              if (context.mounted) {
                if (action == ExitAction.saveAndExit) {
                  await cubit.save();
                }
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.maybePop(context),
                ),
                title: Text(
                  localizations.editSong,
                  style: Theme.of(context).textTheme.titleLarge,
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
                            if (isRecording)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: buildRecordingProgressIndicator(),
                              ),
                            IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          _onSearchClick(context, cubit),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(
                                          context,
                                        ).scaffoldBackgroundColor,
                                        foregroundColor: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                        elevation: 0,
                                        shape: const RoundedRectangleBorder(),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          const Icon(Icons.search),
                                          const SizedBox(height: 4),
                                          Text(
                                            localizations.search,
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.visible,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.labelMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _showAddToPlaylistModal(
                                        context,
                                        cubit,
                                        state.uuid,
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(
                                          context,
                                        ).scaffoldBackgroundColor,
                                        foregroundColor: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                        elevation: 0,
                                        shape: const RoundedRectangleBorder(),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          const Icon(Icons.playlist_add),
                                          const SizedBox(height: 4),
                                          Text(
                                            localizations.addToPlaylistSentence,
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.visible,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.labelMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: isRecording
                                          ? () => stopRecording(state.uuid)
                                          : () => startRecording(state.uuid),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(
                                          context,
                                        ).scaffoldBackgroundColor,
                                        foregroundColor: isRecording
                                            ? Colors.red
                                            : Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                        elevation: 0,
                                        shape: const RoundedRectangleBorder(),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            isRecording
                                                ? Icons.stop_circle_outlined
                                                : Icons.mic,
                                            color: isRecording
                                                ? Colors.red
                                                : null,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            isRecording
                                                ? localizations.stopRecording
                                                : localizations.record,
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.visible,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelMedium
                                                ?.copyWith(
                                                  color: isRecording
                                                      ? Colors.red
                                                      : null,
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
                                          _saveSong(context, cubit);
                                        } else {
                                          cubit.updateAutovalidateMode(
                                            AutovalidateMode.always,
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(
                                          context,
                                        ).scaffoldBackgroundColor,
                                        foregroundColor: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                        elevation: 0,
                                        shape: const RoundedRectangleBorder(),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          const Icon(Icons.save),
                                          const SizedBox(height: 4),
                                          Text(
                                            localizations.save,
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.visible,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.labelMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          _confirmDelete(context, cubit),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(
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
                                        children: [
                                          const Icon(Icons.delete),
                                          const SizedBox(height: 4),
                                          Text(
                                            localizations.delete,
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.visible,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.labelMedium,
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
                                    SongsEditCubit,
                                    SongsEditState
                                  >(
                                    bloc: cubit,
                                    selector: (state) => state.author,
                                    validator: (value) =>
                                        validateAuthor(value, localizations),
                                    onChanged: cubit.updateAuthor,
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      labelText: localizations.author,
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  BlocTextFormField<
                                    SongsEditCubit,
                                    SongsEditState
                                  >(
                                    bloc: cubit,
                                    selector: (state) => state.title,
                                    validator: (value) =>
                                        validateTitle(value, localizations),
                                    onChanged: cubit.updateTitle,
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      labelText: localizations.title,
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  BlocTextFormField<
                                    SongsEditCubit,
                                    SongsEditState
                                  >(
                                    bloc: cubit,
                                    selector: (state) => state.text,
                                    validator: (value) =>
                                        validateText(value, localizations),
                                    onChanged: cubit.updateText,
                                    minLines: 12,
                                    maxLines: null,
                                    textInputAction: TextInputAction.newline,
                                    decoration: InputDecoration(
                                      labelText: localizations.text,
                                      alignLabelWithHint: true,
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            _buildAudioSection(cubit, localizations),
                            const SizedBox(height: 8.0),
                            SongPlaylistsListComponent(
                              songId: widget.songId,
                              onAddToPlaylist: () => _showAddToPlaylistModal(
                                context,
                                cubit,
                                state.uuid,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            SongRecordingsListComponent(songId: widget.songId),
                            const SizedBox(height: 8.0),
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

  Widget _buildAudioSection(SongsEditCubit cubit, AppLocalizations loc) {
    return BlocBuilder<SongsEditCubit, SongsEditState>(
      bloc: cubit,
      builder: (context, state) {
        final hasFile = state.audioFilePath != null;
        final hasUrl = state.audioUrl != null && state.audioUrl!.isNotEmpty;
        final existingSong = sl<SongsRepository>().getSong(state.uuid);
        final alreadyDownloaded =
            existingSong != null &&
            existingSong.audioCachedUrl == state.audioUrl &&
            existingSong.audioCachePath != null &&
            File(existingSong.audioCachePath!).existsSync();

        return InputDecorator(
          decoration: InputDecoration(
            labelText: loc.audioUrl,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
            contentPadding: const EdgeInsets.only(
              top: 20,
              left: 10,
              right: 10,
              bottom: 30,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: state.audioUrl ?? '',
                      enabled: !hasFile,
                      keyboardType: TextInputType.url,
                      decoration: InputDecoration(
                        labelText: loc.audioYouTubeHint,
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (value) =>
                          cubit.updateAudioUrl(value.isEmpty ? null : value),
                    ),
                  ),
                  if (hasUrl && !hasFile)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: alreadyDownloaded
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : IconButton(
                              icon: _isDownloading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.download),
                              onPressed: _isDownloading
                                  ? null
                                  : () => _downloadAudio(cubit, loc),
                              tooltip: loc.audioFile,
                            ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      hasFile
                          ? loc.audioFileSelected(
                              state.audioFilePath!
                                  .split(Platform.pathSeparator)
                                  .last,
                            )
                          : loc.audioNoFile,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.folder_open),
                    onPressed: hasUrl ? null : () => _pickAudioFile(cubit),
                    tooltip: loc.audioFile,
                  ),
                  if (hasFile)
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.red),
                      onPressed: () => cubit.updateAudioFilePath(null),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _downloadAudio(
    SongsEditCubit cubit,
    AppLocalizations loc,
  ) async {
    final song = sl<SongsRepository>().getSong(cubit.state.uuid);
    if (song == null) return;

    setState(() => _isDownloading = true);
    try {
      final success = await sl<AudioDownloadService>().downloadAudio(song);
      if (mounted) {
        if (success) {
          UIHelper.showSuccessSnackBar(context, loc.audioDownloadedToCache);
        } else {
          UIHelper.showErrorSnackBar(
            context,
            loc.errorWithMessage('Failed to download audio'),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        UIHelper.showErrorSnackBar(context, loc.errorWithMessage('$e'));
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _pickAudioFile(SongsEditCubit cubit) async {
    final result = await FilePicker.pickFiles(type: FileType.audio);

    if (result != null && result.files.single.path != null) {
      cubit.updateAudioFilePath(result.files.single.path);
    }
  }

  Future<void> _saveSong(
    BuildContext context,
    SongsEditCubit songAddCubit,
  ) async {
    await songAddCubit.save();

    if (context.mounted) {
      context.read<SongsListComponentBloc>().add(ReloadListEvent());
      UIHelper.showSuccessSnackBar(
        context,
        AppLocalizations.of(context)!.savedSuccessfully,
      );
    }
  }

  void _confirmDelete(BuildContext context, SongsEditCubit cubit) async {
    final localizations = AppLocalizations.of(context)!;
    final confirmed = await UIHelper.showConfirmDialog(
      context: context,
      title: localizations.confirmDeletion,
      content: localizations.areYouSureYouWantToDeleteThisSong,
      confirmLabel: localizations.delete,
    );

    if (confirmed == true && context.mounted) {
      await cubit.delete();
      if (context.mounted) {
        context.read<SongsListComponentBloc>().add(ReloadListEvent());
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _onSearchClick(
    BuildContext builderContext,
    SongsEditCubit songEditCubit,
  ) async {
    final localizations = AppLocalizations.of(builderContext)!;

    if (!await ConnectionHelper.checkIfDeviceIsConnectedToInternet()) {
      if (builderContext.mounted) {
        _showNotConnectedInfo(builderContext, localizations);
      }
      return;
    }

    if (!builderContext.mounted) return;

    if (songEditCubit.state.author.isEmpty &&
        songEditCubit.state.title.isEmpty) {
      if (builderContext.mounted) {
        _showInvalidSearchData(builderContext, localizations);
      }
      return;
    }

    final songToFind = SongToFindModel(
      songEditCubit.state.author,
      songEditCubit.state.title,
    );

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
        songEditCubit.updateText(searchResult.text);

        if (searchResult.author != null &&
            searchResult.author!.isNotEmpty &&
            searchResult.author != songEditCubit.state.author) {
          songEditCubit.updateAuthor(searchResult.author);
        }

        if (searchResult.title != null &&
            searchResult.title!.isNotEmpty &&
            searchResult.title != songEditCubit.state.title) {
          songEditCubit.updateTitle(searchResult.title);
        }
      }
    }
  }

  void _showNotConnectedInfo(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    UIHelper.showErrorSnackBar(
      context,
      localizations.noActiveInternetConnection,
    );
  }

  void _showInvalidSearchData(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    UIHelper.showErrorSnackBar(
      context,
      localizations.toSearchForTextYouNeedAtLeastTitleOrAuthor,
    );
  }

  Future<void> _showAddToPlaylistModal(
    BuildContext context,
    SongsEditCubit cubit,
    String songId,
  ) async {
    if (cubit.isModified) {
      final shouldSave = await UIHelper.showSaveBeforeActionDialog(context);
      if (shouldSave == true) {
        cubit.save();
        if (context.mounted) {
          context.read<SongsListComponentBloc>().add(ReloadListEvent());
        }
      } else {
        return;
      }
    }

    if (!context.mounted) return;

    if (context.mounted) {
      await SongsUIHelper.showAddSongsToPlaylistModal(
        context: context,
        selectedSongsIds: [songId],
        successMessage: AppLocalizations.of(context)!.addedToPlaylist,
        onSuccess: () {
          if (mounted) setState(() {});
        },
      );
    }
  }
}
