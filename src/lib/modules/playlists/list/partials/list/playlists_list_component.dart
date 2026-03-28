import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';
import 'package:pomocnik_wokalisty/modules/playlists/edit/playlist_edit.dart';
import 'package:pomocnik_wokalisty/modules/playlists/list/partials/list/bloc/playlists_list_component_bloc.dart';
import 'package:pomocnik_wokalisty/modules/playlists/models/playlist_model.dart';

class PlaylistsListComponent extends StatefulWidget {
  const PlaylistsListComponent({super.key});

  @override
  State<PlaylistsListComponent> createState() => _PlaylistsListComponentState();
}

class _PlaylistsListComponentState extends State<PlaylistsListComponent> {
  @override
  void initState() {
    super.initState();
    context.read<PlaylistsListComponentBloc>().add(LoadPlaylistsEvent());
  }

  @override
  void deactivate() {
    context.read<PlaylistsListComponentBloc>().add(ClearSelectedPlaylists());
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return BlocBuilder<PlaylistsListComponentBloc, PlaylistsListComponentState>(
        builder: (context, state) {
      if (state.status == PlaylistsListStatus.loading) {
        return const Center(child: CircularProgressIndicator());
      }

      final list = state.data;
      return Column(
        children: [
          const SearchAppBar(),
          Flexible(
              child: list.isEmpty
                  ? SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: Text(localizations.noPlaylists,
                          textAlign: TextAlign.center),
                    )
                  : Container(
                      padding: const EdgeInsets.all(16),
                      child: ListView.separated(
                        separatorBuilder: (context, index) => const Divider(),
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final playlist = list[index];

                          if (state.choosePlaylists) {
                            return CheckboxListTile(
                              activeColor: Colors.red,
                              value: state.selectedPlaylists
                                  .contains(playlist.uuid),
                              onChanged: (newValue) =>
                                  _onPlaylistCheckboxClick(playlist, newValue),
                              title: Text(
                                playlist.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black),
                              ),
                            );
                          } else {
                            return ListTile(
                              title: Text(playlist.name),
                              titleTextStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black),
                              onTap: () =>
                                  _redirectToPlaylistEdit(context, playlist),
                              onLongPress: () => context
                                  .read<PlaylistsListComponentBloc>()
                                  .add(ChoosePlaylistChangeEvent(value: true)),
                            );
                          }
                        },
                      ),
                    )),
        ],
      );
    });
  }

  void _onPlaylistCheckboxClick(Playlist playlist, bool? newValue) {
    if (newValue == true) {
      context
          .read<PlaylistsListComponentBloc>()
          .add(SelectPlaylistEvent(playlist: playlist));
    } else {
      context
          .read<PlaylistsListComponentBloc>()
          .add(UnelectPlaylistEvent(playlist: playlist));
    }
  }

  void _redirectToPlaylistEdit(BuildContext context, Playlist playlist) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlaylistEdit(playlistId: playlist.uuid),
      ),
    );
  }
}

class SearchAppBar extends StatelessWidget {
  const SearchAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) => context
            .read<PlaylistsListComponentBloc>()
            .add(SearchPlaylistsEvent(value)),
        decoration: InputDecoration(
          labelText: localizations.search,
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(25))),
          prefixIcon: const Icon(Icons.search),
        ),
      ),
    );
  }
}
