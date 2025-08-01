import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/helpers/connection_helper.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/add/helpers/song_add_validator.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/common/cubic/song_search_cubit.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/common/models/search_dialog_result_model.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/common/views/dialogs/search_dialog.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/edit/cubic/songs_edit_cubit.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/edit/helpers/song_edit_validator.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/edit/partials/playlistsList/song_playlists_list_component.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/list/partials/list/bloc/songs_list_component_bloc.dart';
import 'package:pomocnik_wokalisty/webscraping/models/song_to_find_model.dart';

class SongsEdit extends StatefulWidget with SongAddValidator {
  SongsEdit({super.key, required this.songId});

  final String songId;

  @override
  State<SongsEdit> createState() => _SongsEditState();
}

class _SongsEditState extends State<SongsEdit> with SongEditValidator {
  final SongsEditCubit _songEditCubit = SongsEditCubit();

  final _formKey = GlobalKey<FormState>();

  TextEditingController textController = TextEditingController();
  TextEditingController authorController = TextEditingController();
  TextEditingController titleController = TextEditingController();

  @override
  void initState() {
    _songEditCubit.initForm(widget.songId);

    textController.value = TextEditingValue(text: _songEditCubit.state.text);
    authorController.value =
        TextEditingValue(text: _songEditCubit.state.author);
    titleController.value = TextEditingValue(text: _songEditCubit.state.title);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongsEditCubit, SongsEditState>(
      builder: (context, state) {
        return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text("Edytuj utwór"),
              centerTitle: true,
              actions: [
                IconButton(
                    padding: EdgeInsets.all(10),
                    iconSize: 35,
                    icon: const Icon(Icons.search),
                    onPressed: () => _onSearchClick(context)),
                IconButton(
                  padding: EdgeInsets.all(10),
                  iconSize: 35,
                  icon: const Icon(Icons.save),
                  color: Colors.red,
                  onPressed: () => {
                    if (_formKey.currentState!.validate())
                      {_saveSong(context, _songEditCubit)}
                    else
                      {
                        _songEditCubit
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
                      BlocSelector<SongsEditCubit, SongsEditState,
                          AutovalidateMode>(
                        bloc: _songEditCubit,
                        selector: (state) => state.autovalidateMode,
                        builder: (context, AutovalidateMode autovalidateMode) {
                          return Form(
                            key: _formKey,
                            autovalidateMode: autovalidateMode,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: authorController,
                                  validator: validateAuthor,
                                  onChanged: _songEditCubit.updateAuthor,
                                  decoration: const InputDecoration(
                                      labelText: 'Autor',
                                      border: OutlineInputBorder()),
                                ),
                                const SizedBox(height: 8.0),
                                TextFormField(
                                  controller: titleController,
                                  validator: (value) => validateTitle(
                                      value, _songEditCubit.state.uuid),
                                  onChanged: _songEditCubit.updateTitle,
                                  decoration: const InputDecoration(
                                      labelText: 'Tytuł',
                                      border: OutlineInputBorder()),
                                ),
                                const SizedBox(height: 8.0),
                                TextFormField(
                                  controller: textController,
                                  validator: validateText,
                                  onChanged: _songEditCubit.updateText,
                                  minLines: 12,
                                  maxLines: null,
                                  decoration: const InputDecoration(
                                      labelText: 'Tekst',
                                      alignLabelWithHint: true,
                                      border: OutlineInputBorder()),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8.0),
                      SongPlaylistsListComponent(songId: widget.songId)
                    ],
                  )),
            ));
      },
    );
  }

  void _saveSong(BuildContext context, SongsEditCubit songAddCubit) {
    songAddCubit.save();

    context.read<SongsListComponentBloc>().add(ReloadListEvent());

    return Navigator.of(context).pop();
  }

  Future<void> _onSearchClick(BuildContext builderContext) async {
    if (!await ConnectionHelper.checkIfDeviceIsConnectedToInternet()) {
      _showNotConnectedInfo();
      return;
    }

    if (_songEditCubit.state.author.isEmpty &&
        _songEditCubit.state.title.isEmpty) {
      return _showInvalidSearchData();
    }

    var songToFind = SongToFindModel(
        _songEditCubit.state.author, _songEditCubit.state.title);

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
        setState(() {
          _songEditCubit.updateText(searchResult.text);
          textController.value = TextEditingValue(text: searchResult.text!);

          if (_songEditCubit.state.author.isEmpty &&
              (searchResult.author != null &&
                  searchResult.author!.isNotEmpty)) {
            _songEditCubit.updateAuthor(searchResult.author);
            authorController.value =
                TextEditingValue(text: searchResult.author!);
          }

          if (_songEditCubit.state.title.isEmpty &&
              (searchResult.title != null && searchResult.title!.isNotEmpty)) {
            _songEditCubit.updateTitle(searchResult.title);
            titleController.value = TextEditingValue(text: searchResult.title!);
          }
        });
      }
    }
  }

  void _showNotConnectedInfo() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Brak aktywnego połączenia internetowego'),
    ));
  }

  void _showInvalidSearchData() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text(
          'Do wyszukania tekstu potrzeba przynajmniej tytułu lub autora'),
    ));
  }
}
