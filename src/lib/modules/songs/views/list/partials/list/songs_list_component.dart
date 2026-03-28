import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';
import 'package:pomocnik_wokalisty/modules/songs/models/song_model.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/edit/songs_edit.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/list/partials/list/bloc/songs_list_component_bloc.dart';

class SongsListComponent extends StatefulWidget {
  const SongsListComponent({super.key});

  @override
  State<SongsListComponent> createState() => _SongsListComponentState();
}

class _SongsListComponentState extends State<SongsListComponent> {
  @override
  void initState() {
    super.initState();
    context.read<SongsListComponentBloc>().add(LoadSongsEvent());
  }

  @override
  void deactivate() {
    context.read<SongsListComponentBloc>().add(ClearSelectedSongs());
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return BlocBuilder<SongsListComponentBloc, SongsListComponentState>(
        builder: (context, state) {
      if (state.status == SongsListStatus.loading) {
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
                      child: Text(localizations.noSongs,
                          textAlign: TextAlign.center),
                    )
                  : Container(
                      padding: const EdgeInsets.all(16),
                      child: ListView.separated(
                        separatorBuilder: (context, index) => const Divider(),
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final song = list[index];
                          final songAuthor =
                              song.author.isEmpty ? "-" : song.author;
                          final songTitle =
                              song.title.isEmpty ? "-" : song.title;

                          if (state.chooseSongs) {
                            return CheckboxListTile(
                              activeColor: Colors.red,
                              value: state.selectedSongs.contains(song.uuid),
                              onChanged: (newValue) =>
                                  _onSongCheckboxClick(song, newValue),
                              title: Text(
                                songTitle,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black),
                              ),
                              subtitle: Text(songAuthor),
                            );
                          } else {
                            return ListTile(
                              title: Text(songTitle),
                              subtitle: Text(songAuthor),
                              titleTextStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black),
                              onTap: () => _redirectToSongsEdit(context, song),
                              onLongPress: () => context
                                  .read<SongsListComponentBloc>()
                                  .add(ChooseSongChangeEvent(value: true)),
                            );
                          }
                        },
                      ),
                    )),
        ],
      );
    });
  }

  void _onSongCheckboxClick(Song song, bool? newValue) {
    if (newValue == true) {
      context.read<SongsListComponentBloc>().add(SelectSongEvent(song: song));
    } else {
      context.read<SongsListComponentBloc>().add(UnselectSongEvent(song: song));
    }
  }

  void _redirectToSongsEdit(BuildContext context, Song song) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SongsEdit(songId: song.uuid),
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
        onChanged: (value) =>
            context.read<SongsListComponentBloc>().add(SearchSongsEvent(value)),
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
