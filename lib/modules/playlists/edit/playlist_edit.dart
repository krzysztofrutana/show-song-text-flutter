import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pomocnik_wokalisty/ads/ads_mixin.dart';
import 'package:pomocnik_wokalisty/ads/interstitial_ads_mixin.dart';
import 'package:pomocnik_wokalisty/helpers/data_collections.dart';
import 'package:pomocnik_wokalisty/helpers/localization_manager.dart';
import 'package:pomocnik_wokalisty/modules/playlists/edit/cubic/playlist_edit_cubit.dart';
import 'package:pomocnik_wokalisty/modules/playlists/edit/helpers/playlist_edit_validator.dart';
import 'package:pomocnik_wokalisty/modules/playlists/edit/partials/playlist_songs_list_component.dart';
import 'package:pomocnik_wokalisty/modules/playlists/list/partials/list/bloc/playlists_list_component_bloc.dart';
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
  final PlaylistEditCubit _playlistEditCubit = PlaylistEditCubit();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _playlistEditCubit.initForm(widget.playlistId);
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
    return BlocBuilder<PlaylistEditCubit, PlaylistEditState>(
      builder: (context, state) {
        return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                  LocalizationManager.instance.appLocalization.editPlaylist),
              centerTitle: true,
              actions: [
                IconButton(
                  padding: EdgeInsets.all(10),
                  iconSize: 35,
                  icon: ImageIcon(
                    AssetImage('assets/images/icons/presentation.png'),
                    size: 30,
                  ),
                  onPressed: () => {_runPresentationForSelected(context)},
                ),
                IconButton(
                  padding: EdgeInsets.all(10),
                  iconSize: 35,
                  icon: const Icon(Icons.save),
                  onPressed: () => {
                    if (_formKey.currentState!.validate())
                      {_savePlaylist(context, _playlistEditCubit)}
                    else
                      {
                        _playlistEditCubit
                            .updateAutovalidateMode(AutovalidateMode.always)
                      }
                  },
                )
              ],
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            BlocSelector<PlaylistEditCubit, PlaylistEditState,
                                AutovalidateMode>(
                              bloc: _playlistEditCubit,
                              selector: (state) => state.autovalidateMode,
                              builder:
                                  (context, AutovalidateMode autovalidateMode) {
                                return Form(
                                  key: _formKey,
                                  autovalidateMode: autovalidateMode,
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        initialValue:
                                            _playlistEditCubit.state.name,
                                        validator: (value) => validateName(
                                            value,
                                            _playlistEditCubit.state.uuid),
                                        onChanged:
                                            _playlistEditCubit.updateName,
                                        decoration: InputDecoration(
                                            labelText: LocalizationManager
                                                .instance.appLocalization.name,
                                            border: OutlineInputBorder()),
                                      ),
                                      const SizedBox(height: 8.0),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8.0),
                            PlaylistSongsListComponent(
                                playlistEditCubit: _playlistEditCubit)
                          ],
                        )),
                  ),
                ),
                getBanerWidget()
              ],
            ));
      },
    );
  }

  void _savePlaylist(
      BuildContext context, PlaylistEditCubit playlistEditCubit) {
    playlistEditCubit.save();

    context.read<PlaylistsListComponentBloc>().add(ReloadListEvent());

    return Navigator.of(context).pop();
  }

  void _runPresentationForSelected(BuildContext parentContext) async {
    var selectedSongs = _playlistEditCubit.state.songsIds;

    if (selectedSongs.isEmpty) {
      return showNoSongsAssignedDialog(LocalizationManager
          .instance.appLocalization.thePlaylistDoesNotContainAnySongs);
    }
    var box = DataCollections.playlists();
    var playlist = box.get(_playlistEditCubit.state.uuid);

    parentContext
        .read<PresentatationBloc>()
        .add(PlaylistPresentation(playlist: playlist!));

    showInterstitialAds();

    Navigator.of(parentContext).push(
      MaterialPageRoute(
        builder: (parentContext) => PresentationView(),
      ),
    );
  }

  Future<void> showNoSongsAssignedDialog(String message) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            LocalizationManager.instance.appLocalization.noSongsAssigned,
            style: TextStyle(fontSize: 20),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(LocalizationManager.instance.appLocalization.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
