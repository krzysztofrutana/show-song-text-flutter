import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';
import 'package:pomocnik_wokalisty/modules/playlists/edit/playlist_edit.dart';
import 'package:pomocnik_wokalisty/modules/playlists/list/partials/list/bloc/playlists_list_component_bloc.dart';
import 'package:pomocnik_wokalisty/modules/playlists/models/playlist_model.dart';
import 'package:pomocnik_wokalisty/modules/presentation/bloc/presentation_bloc.dart';
import 'package:pomocnik_wokalisty/modules/presentation/views/presentation_view.dart';

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

        if (state.status == PlaylistsListStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  localizations.errorLoadingPlaylists,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    context.read<PlaylistsListComponentBloc>().add(
                      LoadPlaylistsEvent(),
                    );
                  },
                  child: Text(localizations.tryAgain),
                ),
              ],
            ),
          );
        }

        final list = state.data;
        return Column(
          children: [
            const SearchAppBar(),
            Flexible(
              child:
                  list.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              localizations.noPlaylists,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
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
                                value: state.selectedPlaylists.contains(
                                  playlist.uuid,
                                ),
                                onChanged:
                                    (newValue) => _onPlaylistCheckboxClick(
                                      playlist,
                                      newValue,
                                    ),
                                contentPadding: const EdgeInsets.only(
                                  left: 12,
                                  right: 10,
                                ),
                                title: Text(
                                  playlist.name,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              );
                            } else {
                              return ListTile(
                                title: Text(playlist.name),
                                titleTextStyle: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                onTap:
                                    () => _redirectToPlaylistEdit(
                                      context,
                                      playlist,
                                    ),
                                onLongPress: () {
                                  final bloc =
                                      context
                                          .read<PlaylistsListComponentBloc>();
                                  bloc.add(
                                    ChoosePlaylistChangeEvent(value: true),
                                  );
                                  bloc.add(
                                    SelectPlaylistEvent(playlist: playlist),
                                  );
                                },
                                contentPadding: const EdgeInsets.only(
                                  left: 12,
                                  right: 10,
                                ),
                                trailing: IconButton(
                                  tooltip: localizations.presentationScreen,
                                  icon: const ImageIcon(
                                    AssetImage(
                                      'assets/images/icons/presentation.png',
                                    ),
                                    size: 24,
                                  ),
                                  onPressed:
                                      () => _runPresentation(context, playlist),
                                ),
                              );
                            }
                          },
                        ),
                      ),
            ),
          ],
        );
      },
    );
  }

  void _onPlaylistCheckboxClick(Playlist playlist, bool? newValue) {
    if (newValue == true) {
      context.read<PlaylistsListComponentBloc>().add(
        SelectPlaylistEvent(playlist: playlist),
      );
    } else {
      context.read<PlaylistsListComponentBloc>().add(
        UnelectPlaylistEvent(playlist: playlist),
      );
    }
  }

  void _redirectToPlaylistEdit(BuildContext context, Playlist playlist) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => PlaylistEdit(playlistId: playlist.uuid),
          ),
        )
        .then((_) {
          if (context.mounted) {
            context.read<PlaylistsListComponentBloc>().add(
              LoadPlaylistsEvent(),
            );
          }
        });
  }

  void _runPresentation(BuildContext context, Playlist playlist) {
    if (playlist.songsIds.isEmpty) {
      final localizations = AppLocalizations.of(context)!;
      showDialog<void>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(localizations.noSongsAssigned),
              content: Text(localizations.thePlaylistDoesNotContainAnySongs),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(localizations.cancel),
                ),
              ],
            ),
      );
      return;
    }

    context.read<PresentationBloc>().add(
      PlaylistPresentation(playlist: playlist),
    );

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const PresentationView()));
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
        onChanged:
            (value) => context.read<PlaylistsListComponentBloc>().add(
              SearchPlaylistsEvent(value),
            ),
        decoration: InputDecoration(
          labelText: localizations.search,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(25)),
          ),
          prefixIcon: const Icon(Icons.search),
        ),
      ),
    );
  }
}
