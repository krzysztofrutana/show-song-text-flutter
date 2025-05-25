import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/modules/playlists/edit/cubic/playlist_edit_cubit.dart';
import 'package:pomocnik_wokalisty/modules/playlists/edit/helpers/playlist_edit_validator.dart';
import 'package:pomocnik_wokalisty/modules/playlists/edit/partials/playlist_songs_list_component.dart';
import 'package:pomocnik_wokalisty/modules/playlists/list/partials/list/bloc/playlists_list_component_bloc.dart';

class PlaylistEdit extends StatefulWidget with PlaylistEditValidator {
  PlaylistEdit({super.key, required this.playlistId});

  final String playlistId;

  @override
  State<PlaylistEdit> createState() => _PlaylistEditState();
}

class _PlaylistEditState extends State<PlaylistEdit>
    with PlaylistEditValidator {
  final PlaylistEditCubit _playlistEditCubit = PlaylistEditCubit();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _playlistEditCubit.initForm(widget.playlistId);
    super.initState();
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
              title: const Text("Edytuj listę odtwarzania"),
              centerTitle: true,
              actions: [
                IconButton(
                  padding: EdgeInsets.all(10),
                  iconSize: 35,
                  icon: const Icon(Icons.save),
                  color: Colors.red,
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
            body: SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      BlocSelector<PlaylistEditCubit, PlaylistEditState,
                          AutovalidateMode>(
                        bloc: _playlistEditCubit,
                        selector: (state) => state.autovalidateMode,
                        builder: (context, AutovalidateMode autovalidateMode) {
                          return Form(
                            key: _formKey,
                            autovalidateMode: autovalidateMode,
                            child: Column(
                              children: [
                                TextFormField(
                                  initialValue: _playlistEditCubit.state.name,
                                  validator: (value) => validateName(
                                      value, _playlistEditCubit.state.uuid),
                                  onChanged: _playlistEditCubit.updateName,
                                  decoration: const InputDecoration(
                                      labelText: 'Nazwa',
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
}
