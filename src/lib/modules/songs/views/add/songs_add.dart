import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pomocnik_wokalisty/ads/ads_mixin.dart';
import 'package:pomocnik_wokalisty/ads/interstitial_ads_mixin.dart';
import 'package:pomocnik_wokalisty/helpers/bloc_text_form_field.dart';
import 'package:pomocnik_wokalisty/helpers/connection_helper.dart';
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/add/cubit/songs_add_cubit.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/add/helpers/song_add_validator.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/common/cubit/song_search_cubit.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/common/models/search_dialog_result_model.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/common/views/dialogs/search_dialog.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/list/partials/list/bloc/songs_list_component_bloc.dart';
import 'package:pomocnik_wokalisty/webscraping/models/song_to_find_model.dart';

class SongsAdd extends StatefulWidget with SongAddValidator {
  SongsAdd({super.key, this.cubit});

  final SongsAddCubit? cubit;

  @override
  State<SongsAdd> createState() => _SongsAddState();
}

class _SongsAddState extends State<SongsAdd>
    with SongAddValidator, Ads, InterstitialAds {
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
      create: (context) => widget.cubit ?? SongsAddCubit(),
      child: BlocBuilder<SongsAddCubit, SongsAddState>(
        builder: (context, state) {
          final cubit = context.read<SongsAddCubit>();
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
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                title: Text(
                  localizations.addSong,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              body: SafeArea(
                child: Column(
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed:
                                            () => _onSearchClick(
                                              context,
                                              cubit,
                                              localizations,
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
                                          if (_formKey.currentState!
                                              .validate()) {
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
                                            () =>
                                                Navigator.of(
                                                  context,
                                                ).maybePop(),
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
                                      SongsAddCubit,
                                      SongsAddState
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
                                      SongsAddCubit,
                                      SongsAddState
                                    >(
                                      bloc: cubit,
                                      selector: (state) => state.title,
                                      validator:
                                          (value) => validateTitle(
                                            value,
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
                                      SongsAddCubit,
                                      SongsAddState
                                    >(
                                      bloc: cubit,
                                      selector: (state) => state.text,
                                      validator:
                                          (value) => validateText(
                                            value,
                                            localizations,
                                          ),
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
                            ],
                          ),
                        ),
                      ),
                    ),
                    getBanerWidget(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _saveSong(BuildContext context, SongsAddCubit songAddCubit) {
    songAddCubit.save();

    context.read<SongsListComponentBloc>().add(ReloadListEvent());

    return Navigator.of(context).pop();
  }

  Future<void> _onSearchClick(
    BuildContext builderContext,
    SongsAddCubit songAddCubit,
    AppLocalizations localizations,
  ) async {
    if (!await ConnectionHelper.checkIfDeviceIsConnectedToInternet()) {
      _showNotConnectedInfo(localizations);
      return;
    }

    if (songAddCubit.state.author.isEmpty && songAddCubit.state.title.isEmpty) {
      return _showInvalidSearchData(localizations);
    }

    final songToFind = SongToFindModel(
      songAddCubit.state.author,
      songAddCubit.state.title,
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

        songAddCubit.updateText(searchResult.text);

        if (songAddCubit.state.author.isEmpty &&
            (searchResult.author != null && searchResult.author!.isNotEmpty)) {
          songAddCubit.updateAuthor(searchResult.author);
        }

        if (songAddCubit.state.title.isEmpty &&
            (searchResult.title != null && searchResult.title!.isNotEmpty)) {
          songAddCubit.updateTitle(searchResult.title);
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
