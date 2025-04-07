import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
    var box = Hive.box<Playlist>('playlists');
    var allData = box.values.toList();

    context
        .read<PlaylistsListComponentBloc>()
        .add(FilterPlaylistsListComponentEvent(filteredList: allData));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaylistsListComponentBloc, PlaylistsListComponentState>(
        builder: (context, state) {
      final list = context.read<PlaylistsListComponentBloc>().state.data;
      return Column(
        children: [
          searchAppBar(context),
          Flexible(
              flex: 1,
              child: list.isEmpty
                  ? const SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: Text("Brak list odtwarzania",
                          textAlign: TextAlign.center),
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
                          final playlist = list[index];

                          return state.choosePlaylists
                              ? CheckboxListTile(
                                  value: playlist.selected,
                                  onChanged: (newValue) => setState(() =>
                                      _onPlaylistCheckboxClick(
                                          playlist, newValue)),
                                  title: DefaultTextStyle(
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.black),
                                      child: Text(playlist.name)))
                              : ListTile(
                                  title: Text(playlist.name),
                                  titleTextStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black),
                                  onLongPress: () => context
                                      .read<PlaylistsListComponentBloc>()
                                      .add(ChoosePlaylistChangeEvent(
                                          value: true)),
                                );
                        },
                      ),
                    )),
        ],
      );
    });
  }

  bool _onPlaylistCheckboxClick(Playlist playlist, bool? newValue) {
    if (newValue == true) {
      BlocProvider.of<PlaylistsListComponentBloc>(context)
          .add(SelectPlaylistEvent(playlist: playlist));
    } else {
      BlocProvider.of<PlaylistsListComponentBloc>(context)
          .add(UnelectPlaylistEvent(playlist: playlist));
    }

    return playlist.selected = newValue ?? false;
  }
}

Widget searchAppBar(BuildContext context) {
  final PlaylistListController searchController =
      PlaylistListController(context: context);

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

class PlaylistListController {
  //We need a buildContext to interact with our bloc
  final BuildContext context;

  late List<Playlist> allData;
  PlaylistListController({required this.context}) {
    var box = Hive.box<Playlist>('playlists');
    allData = box.values.toList();
  }

  onChange(String value) {
    value = value.toLowerCase();

    if (value.isEmpty) {
      context
          .read<PlaylistsListComponentBloc>()
          .add(FilterPlaylistsListComponentEvent(filteredList: allData));
      return;
    }

    List<Playlist> filteredList = allData
        .where((playlist) => playlist.name.toLowerCase().contains(value))
        .toList();

    context
        .read<PlaylistsListComponentBloc>()
        .add(FilterPlaylistsListComponentEvent(filteredList: filteredList));
  }
}
