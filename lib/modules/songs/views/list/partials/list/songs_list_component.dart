import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pomocnik_wokalisty/helpers/data_collections.dart';
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
  Widget build(BuildContext context) {
    return BlocBuilder<SongsListComponentBloc, SongsListComponentState>(
        builder: (context, state) {
      final list = context.read<SongsListComponentBloc>().state.data;
      return Column(
        children: [
          searchAppBar(context),
          Flexible(
              flex: 1,
              child: list.isEmpty
                  ? const SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: Text("Brak utworów", textAlign: TextAlign.center),
                    )
                  : Container(
                      padding: const EdgeInsets.all(16),
                      child: ListView.separated(
                        separatorBuilder: (context, index) => const Divider(),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: list.length,
                        physics: const ScrollPhysics(),
                        itemBuilder: (context, index) {
                          final song = list[index];
                          var songAuthor = song.author;
                          var songTitle = song.title;

                          if (songAuthor == '') {
                            songAuthor = "-";
                          }

                          if (songTitle == '') {
                            songTitle = "-";
                          }

                          return state.chooseSongs
                              ? CheckboxListTile(
                                  value: song.selected,
                                  onChanged: (newValue) => setState(() =>
                                      _onSongCheckboxClick(song, newValue)),
                                  title: DefaultTextStyle(
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.black),
                                      child: Text(songTitle)),
                                  subtitle: Text(songAuthor),
                                )
                              : ListTile(
                                  title: Text(songTitle),
                                  subtitle: Text(songAuthor),
                                  titleTextStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black),
                                  onTap: () =>
                                      _redirectToSongsEdit(context, song),
                                  onLongPress: () => context
                                      .read<SongsListComponentBloc>()
                                      .add(ChooseSongChangeEvent(value: true)),
                                );
                        },
                      ),
                    )),
        ],
      );
    });
  }

  bool _onSongCheckboxClick(Song song, bool? newValue) {
    if (newValue == true) {
      BlocProvider.of<SongsListComponentBloc>(context)
          .add(SelectSongEvent(song: song));
    } else {
      BlocProvider.of<SongsListComponentBloc>(context)
          .add(UnelectSongEvent(song: song));
    }

    return song.selected = newValue ?? false;
  }

  void _redirectToSongsEdit(BuildContext context, Song song) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SongsEdit(songId: song.uuid),
      ),
    );
  }
}

Widget searchAppBar(BuildContext context) {
  final SongListController searchController =
      SongListController(context: context);

  return Container(
    padding: const EdgeInsets.all(16),
    child: TextField(
      onChanged: (value) => searchController.onChange(value),
      decoration: const InputDecoration(
        labelText: 'Wyszukaj',
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(25))),
        prefixIcon: Icon(Icons.search),
      ),
    ),
  );
}

class SongListController {
  final BuildContext context;

  late List<Song> allData;
  SongListController({required this.context}) {
    var box = DataCollections.songs();
    allData = box.values.toList();
  }

  onChange(String value) {
    value = value.toLowerCase();

    if (value.isEmpty) {
      context
          .read<SongsListComponentBloc>()
          .add(FilterSongListComponentEvent(filteredList: allData));
      return;
    }

    List<Song> filteredList = allData
        .where((song) =>
            song.author.toLowerCase().contains(value) ||
            song.title.toLowerCase().contains(value))
        .toList();

    context
        .read<SongsListComponentBloc>()
        .add(FilterSongListComponentEvent(filteredList: filteredList));
  }
}
