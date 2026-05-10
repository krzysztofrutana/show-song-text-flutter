import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/list/partials/list/bloc/songs_list_component_bloc.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/list/partials/list/sort_menu.dart';

class SongSelectionDialog extends StatelessWidget {
  const SongSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return BlocProvider(
      create:
          (context) =>
              SongsListComponentBloc()
                ..add(LoadSongsEvent())
                ..add(ChooseSongChangeEvent(value: true)),
      child: BlocBuilder<SongsListComponentBloc, SongsListComponentState>(
        builder: (context, state) {
          return AlertDialog(
            title: Text(localizations.songSelection),
            contentPadding: const EdgeInsets.only(top: 20),
            content: SizedBox(
              width: double.maxFinite,
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged:
                                (value) => context
                                    .read<SongsListComponentBloc>()
                                    .add(SearchSongsEvent(value)),
                            decoration: InputDecoration(
                              labelText: localizations.search,
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(25),
                                ),
                              ),
                              prefixIcon: const Icon(Icons.search),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const SortMenu(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child:
                        state.status == SongsListStatus.loading
                            ? const Center(child: CircularProgressIndicator())
                            : state.data.isEmpty
                            ? Center(child: Text(localizations.noSongs))
                            : ListView.separated(
                              shrinkWrap: true,
                              itemCount: state.data.length,
                              separatorBuilder:
                                  (context, index) => const Divider(),
                              itemBuilder: (context, index) {
                                final song = state.data[index];
                                final songAuthor =
                                    song.author.isEmpty ? "-" : song.author;
                                final songTitle =
                                    song.title.isEmpty ? "-" : song.title;

                                return CheckboxListTile(
                                  activeColor: Colors.red,
                                  value: state.selectedSongs.contains(
                                    song.uuid,
                                  ),
                                  onChanged: (newValue) {
                                    if (newValue == true) {
                                      context
                                          .read<SongsListComponentBloc>()
                                          .add(SelectSongEvent(song: song));
                                    } else {
                                      context
                                          .read<SongsListComponentBloc>()
                                          .add(UnselectSongEvent(song: song));
                                    }
                                  },
                                  title: Text(
                                    songTitle,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  subtitle: Text(songAuthor),
                                );
                              },
                            ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(localizations.cancel),
              ),
              TextButton(
                onPressed:
                    state.selectedSongs.isEmpty
                        ? null
                        : () {
                          Navigator.of(context).pop(state.selectedSongs);
                        },
                child: Text(localizations.confirm),
              ),
            ],
          );
        },
      ),
    );
  }
}
