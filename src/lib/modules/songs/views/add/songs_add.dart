import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pomocnik_wokalisty/ads/ads_mixin.dart';
import 'package:pomocnik_wokalisty/ads/interstitial_ads_mixin.dart';
import 'package:pomocnik_wokalisty/helpers/connection_helper.dart';
import 'package:pomocnik_wokalisty/helpers/localization_manager.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/add/cubic/songs_add_cubit.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/add/helpers/song_add_validator.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/common/cubic/song_search_cubit.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/common/models/search_dialog_result_model.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/common/views/dialogs/search_dialog.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/list/partials/list/bloc/songs_list_component_bloc.dart';
import 'package:pomocnik_wokalisty/webscraping/models/song_to_find_model.dart';

class SongsAdd extends StatefulWidget with SongAddValidator {
  SongsAdd({super.key});

  @override
  State<SongsAdd> createState() => _SongsAddState();
}

class _SongsAddState extends State<SongsAdd>
    with SongAddValidator, Ads, InterstitialAds {
  final SongsAddCubit _songAddCubit = SongsAddCubit();

  final _formKey = GlobalKey<FormState>();

  TextEditingController textController = TextEditingController();
  TextEditingController authorController = TextEditingController();
  TextEditingController titleController = TextEditingController();

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
    return BlocBuilder<SongsAddCubit, SongsAddState>(
      builder: (context, state) {
        return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(LocalizationManager.instance.appLocalization.addSong),
              centerTitle: true,
              actions: [
                IconButton(
                    padding: EdgeInsets.all(10),
                    iconSize: 30,
                    icon: const Icon(Icons.search),
                    onPressed: () => _onSearchClick(context)),
                IconButton(
                  padding: EdgeInsets.all(10),
                  iconSize: 30,
                  icon: const Icon(Icons.save),
                  onPressed: () => {
                    if (_formKey.currentState!.validate())
                      {_saveSong(context, _songAddCubit)}
                    else
                      {
                        _songAddCubit
                            .updateAutovalidateMode(AutovalidateMode.always)
                      }
                  },
                )
              ],
            ),
            body: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 1,
                    child: SingleChildScrollView(
                      child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              BlocSelector<SongsAddCubit, SongsAddState,
                                  AutovalidateMode>(
                                bloc: _songAddCubit,
                                selector: (state) => state.autovalidateMode,
                                builder: (context,
                                    AutovalidateMode autovalidateMode) {
                                  return Form(
                                    key: _formKey,
                                    autovalidateMode: autovalidateMode,
                                    child: Column(
                                      children: [
                                        TextFormField(
                                          controller: authorController,
                                          validator: validateAuthor,
                                          onChanged: _songAddCubit.updateAuthor,
                                          decoration: InputDecoration(
                                              labelText: LocalizationManager
                                                  .instance
                                                  .appLocalization
                                                  .author,
                                              border: OutlineInputBorder()),
                                        ),
                                        const SizedBox(height: 8.0),
                                        TextFormField(
                                          controller: titleController,
                                          validator: validateTitle,
                                          onChanged: _songAddCubit.updateTitle,
                                          decoration: InputDecoration(
                                              labelText: LocalizationManager
                                                  .instance
                                                  .appLocalization
                                                  .title,
                                              border: OutlineInputBorder()),
                                        ),
                                        const SizedBox(height: 8.0),
                                        TextFormField(
                                          controller: textController,
                                          validator: validateText,
                                          onChanged: _songAddCubit.updateText,
                                          minLines: 12,
                                          maxLines: null,
                                          decoration: InputDecoration(
                                              labelText: LocalizationManager
                                                  .instance
                                                  .appLocalization
                                                  .text,
                                              alignLabelWithHint: true,
                                              border: OutlineInputBorder()),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          )),
                    ),
                  ),
                  getBanerWidget()
                ],
              ),
            ));
      },
    );
  }

  void _saveSong(BuildContext context, SongsAddCubit songAddCubit) {
    songAddCubit.save();

    context.read<SongsListComponentBloc>().add(ReloadListEvent());

    return Navigator.of(context).pop();
  }

  Future<void> _onSearchClick(BuildContext builderContext) async {
    if (!await ConnectionHelper.checkIfDeviceIsConnectedToInternet()) {
      _showNotConnectedInfo();
      return;
    }

    if (_songAddCubit.state.author.isEmpty &&
        _songAddCubit.state.title.isEmpty) {
      return _showInvalidSearchData();
    }

    var songToFind =
        SongToFindModel(_songAddCubit.state.author, _songAddCubit.state.title);

    if (builderContext.mounted) {
      var searchResult = await showDialog<SearchDialogResultModel>(
        context: builderContext,
        builder: (_) {
          return BlocProvider.value(
            value: builderContext.read<SongSearchCubit>(),
            child: SearchDialog(
                songToFind: songToFind,
                sourceView: SearchSourceViewEnum.songAddForm),
          );
        },
      );

      if (searchResult != null) {
        showInterstitialAds();

        setState(() {
          _songAddCubit.updateText(searchResult.text);
          textController.value = TextEditingValue(text: searchResult.text!);

          if (_songAddCubit.state.author.isEmpty &&
              (searchResult.author != null &&
                  searchResult.author!.isNotEmpty)) {
            _songAddCubit.updateAuthor(searchResult.author);
            authorController.value =
                TextEditingValue(text: searchResult.author!);
          }

          if (_songAddCubit.state.title.isEmpty &&
              (searchResult.title != null && searchResult.title!.isNotEmpty)) {
            _songAddCubit.updateTitle(searchResult.title);
            titleController.value = TextEditingValue(text: searchResult.title!);
          }
        });
      }
    }
  }

  void _showNotConnectedInfo() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(LocalizationManager
          .instance.appLocalization.noActiveInternetConnection),
    ));
  }

  void _showInvalidSearchData() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(LocalizationManager
          .instance.appLocalization.toSearchForTextYouNeedAtLeastTitleOrAuthor),
    ));
  }
}
