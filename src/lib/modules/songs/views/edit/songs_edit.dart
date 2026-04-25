import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pomocnik_wokalisty/ads/ads_mixin.dart';
import 'package:pomocnik_wokalisty/ads/interstitial_ads_mixin.dart';
import 'package:pomocnik_wokalisty/helpers/bloc_text_form_field.dart';
import 'package:pomocnik_wokalisty/helpers/connection_helper.dart';
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/add/helpers/song_add_validator.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/common/cubit/song_search_cubit.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/common/models/search_dialog_result_model.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/common/views/dialogs/search_dialog.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/edit/cubit/songs_edit_cubit.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/edit/helpers/song_edit_validator.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/edit/partials/playlistsList/song_playlists_list_component.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/list/partials/list/bloc/songs_list_component_bloc.dart';
import 'package:pomocnik_wokalisty/webscraping/models/song_to_find_model.dart';

class SongsEdit extends StatefulWidget with SongAddValidator {
  SongsEdit({super.key, required this.songId, this.cubit});

  final String songId;
  final SongsEditCubit? cubit;

  @override
  State<SongsEdit> createState() => _SongsEditState();
}

class _SongsEditState extends State<SongsEdit>
    with SongEditValidator, Ads, InterstitialAds {
  final _formKey = GlobalKey<FormState>();

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
        final cubit = widget.cubit ?? SongsEditCubit();
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
                  localizations.editSong,
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
                                          () => _onSearchClick(context, cubit),
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
                                          const Icon(Icons.search),
                                          const SizedBox(height: 4),
                                          FittedBox(
                                            child: Text(
                                              localizations.search,
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
                                          _saveSong(context, cubit);
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
                                    SongsEditCubit,
                                    SongsEditState
                                  >(
                                    bloc: cubit,
                                    selector: (state) => state.author,
                                    validator:
                                        (value) => validateAuthor(
                                          value,
                                          localizations,
                                        ),
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
                                    validator:
                                        (value) => validateTitle(
                                          value,
                                          state.uuid,
                                          localizations,
                                        ),
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
                                    validator:
                                        (value) =>
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
                            const SizedBox(height: 8.0),
                            SongPlaylistsListComponent(songId: widget.songId),
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

  void _saveSong(BuildContext context, SongsEditCubit songAddCubit) {
    songAddCubit.save();

    context.read<SongsListComponentBloc>().add(ReloadListEvent());

    return Navigator.of(context).pop();
  }

  void _confirmDelete(BuildContext context, SongsEditCubit cubit) async {
    final localizations = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(localizations.deleteSong),
            content: Text(localizations.areYouSureYouWantToDeleteThisSong),
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

        if (songEditCubit.state.author.isEmpty &&
            (searchResult.author != null && searchResult.author!.isNotEmpty)) {
          songEditCubit.updateAuthor(searchResult.author);
        }

        if (songEditCubit.state.title.isEmpty &&
            (searchResult.title != null && searchResult.title!.isNotEmpty)) {
          songEditCubit.updateTitle(searchResult.title);
        }
      }
    }
  }

  void _showNotConnectedInfo(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(localizations.noActiveInternetConnection)),
    );
  }

  void _showInvalidSearchData(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localizations.toSearchForTextYouNeedAtLeastTitleOrAuthor),
      ),
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
}
