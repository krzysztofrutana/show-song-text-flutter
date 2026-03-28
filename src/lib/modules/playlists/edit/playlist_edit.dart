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
      create: (context) => PlaylistEditCubit()..initForm(widget.playlistId),
      child: BlocBuilder<PlaylistEditCubit, PlaylistEditState>(
        builder: (context, state) {
          final cubit = context.read<PlaylistEditCubit>();
          return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Text(localizations.editPlaylist),
                centerTitle: true,
                actions: [
                  IconButton(
                    padding: const EdgeInsets.all(10),
                    iconSize: 35,
                    icon: const ImageIcon(
                      AssetImage('assets/images/icons/presentation.png'),
                      size: 30,
                    ),
                    onPressed: () =>
                        _runPresentationForSelected(context, cubit),
                  ),
                  IconButton(
                    padding: const EdgeInsets.all(10),
                    iconSize: 35,
                    icon: const Icon(Icons.save),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _savePlaylist(context, cubit);
                      } else {
                        cubit.updateAutovalidateMode(AutovalidateMode.always);
                      }
                    },
                  )
                ],
              ),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: SingleChildScrollView(
                      child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Form(
                                key: _formKey,
                                autovalidateMode: state.autovalidateMode,
                                child: Column(
                                  children: [
                                    BlocTextFormField<PlaylistEditCubit,
                                        PlaylistEditState>(
                                      bloc: cubit,
                                      selector: (state) => state.name,
                                      validator: (value) => validateName(
                                          value, state.uuid, localizations),
                                      onChanged: cubit.updateName,
                                      textInputAction: TextInputAction.done,
                                      onFieldSubmitted: (_) {
                                        if (_formKey.currentState!.validate()) {
                                          _savePlaylist(context, cubit);
                                        } else {
                                          cubit.updateAutovalidateMode(
                                              AutovalidateMode.always);
                                        }
                                      },
                                      decoration: InputDecoration(
                                          labelText: localizations.name,
                                          border: const OutlineInputBorder()),
                                    ),
                                    const SizedBox(height: 8.0),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              PlaylistSongsListComponent(
                                  playlistEditCubit: cubit)
                            ],
                          )),
                    ),
                  ),
                  getBanerWidget()
                ],
              ));
        },
      ),
    );
  }

  void _savePlaylist(
      BuildContext context, PlaylistEditCubit playlistEditCubit) {
    playlistEditCubit.save();

    context.read<PlaylistsListComponentBloc>().add(ReloadListEvent());

    return Navigator.of(context).pop();
  }

  void _runPresentationForSelected(
      BuildContext parentContext, PlaylistEditCubit cubit) async {
    final localizations = AppLocalizations.of(parentContext)!;
    final selectedSongs = cubit.state.songsIds;

    if (selectedSongs.isEmpty) {
      return showNoSongsAssignedDialog(
          localizations.thePlaylistDoesNotContainAnySongs);
    }
    final playlist = sl<PlaylistsRepository>().getPlaylist(cubit.state.uuid);

    parentContext
        .read<PresentationBloc>()
        .add(PlaylistPresentation(playlist: playlist!));

    showInterstitialAds();

    Navigator.of(parentContext).push(
      MaterialPageRoute(
        builder: (parentContext) => const PresentationView(),
      ),
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
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
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
}
