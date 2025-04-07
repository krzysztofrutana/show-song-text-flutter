import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/add/helpers/SongAddValidator.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/edit/cubic/songs_edit_cubit.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/edit/helpers/SongEditValidator.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/list/partials/list/bloc/songs_list_component_bloc.dart';

class SongsEdit extends StatefulWidget with SongAddValidator {
  SongsEdit({super.key, required this.songId});

  final String songId;

  @override
  State<SongsEdit> createState() => _SongsEditState();
}

class _SongsEditState extends State<SongsEdit> with SongEditValidator {
  final SongsEditCubit _songEditCubit = SongsEditCubit();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _songEditCubit.initForm(widget.songId);
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
                centerTitle: true),
            floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                onPressed: () => {
                      if (_formKey.currentState!.validate())
                        {_saveSong(context, _songEditCubit)}
                      else
                        {
                          _songEditCubit
                              .updateAutovalidateMode(AutovalidateMode.always)
                        }
                    },
                child: const Icon(Icons.save)),
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
                                  initialValue: _songEditCubit.state.author,
                                  validator: validateAuthor,
                                  onChanged: _songEditCubit.updateAuthor,
                                  decoration: const InputDecoration(
                                      labelText: 'Autor',
                                      border: OutlineInputBorder()),
                                ),
                                const SizedBox(height: 8.0),
                                TextFormField(
                                  initialValue: _songEditCubit.state.title,
                                  validator: (value) => validateTitle(
                                      value, _songEditCubit.state.uuid),
                                  onChanged: _songEditCubit.updateTitle,
                                  decoration: const InputDecoration(
                                      labelText: 'Tytuł',
                                      border: OutlineInputBorder()),
                                ),
                                const SizedBox(height: 8.0),
                                TextFormField(
                                  initialValue: _songEditCubit.state.key,
                                  onChanged: _songEditCubit.updateKey,
                                  decoration: const InputDecoration(
                                      labelText: 'Tonacja',
                                      border: OutlineInputBorder()),
                                ),
                                const SizedBox(height: 8.0),
                                TextFormField(
                                  initialValue: _songEditCubit.state.text,
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
}
