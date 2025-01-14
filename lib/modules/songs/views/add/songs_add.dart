import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/add/cubic/songs_add_cubit.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/add/helpers/SongAddValidator.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/list/partials/list/bloc/songs_list_component_bloc.dart';

class SongsAdd extends StatelessWidget with SongAddValidator {
  SongsAdd({super.key});

  final SongsAddCubit _songAddCubit = SongsAddCubit();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongsAddCubit, SongsAddState>(
      builder: (context, state) {
        return Scaffold(
            appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: const Text("Dodaj utwór"),
                centerTitle: true),
            floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                onPressed: () => {
                      if (_formKey.currentState!.validate())
                        {_saveSong(context, _songAddCubit)}
                      else
                        {
                          _songAddCubit
                              .updateAutovalidateMode(AutovalidateMode.always)
                        }
                    },
                child: const Icon(Icons.save)),
            body: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    BlocSelector<SongsAddCubit, SongsAddState,
                        AutovalidateMode>(
                      bloc: _songAddCubit,
                      selector: (state) => state.autovalidateMode,
                      builder: (context, AutovalidateMode autovalidateMode) {
                        return Form(
                          key: _formKey,
                          autovalidateMode: autovalidateMode,
                          child: Column(
                            children: [
                              TextFormField(
                                validator: validateAuthor,
                                onChanged: _songAddCubit.updateAuthor,
                                decoration: const InputDecoration(
                                    labelText: 'Autor',
                                    border: OutlineInputBorder()),
                              ),
                              const SizedBox(height: 8.0),
                              TextFormField(
                                validator: validateTitle,
                                onChanged: _songAddCubit.updateTitle,
                                decoration: const InputDecoration(
                                    labelText: 'Tytuł',
                                    border: OutlineInputBorder()),
                              ),
                              const SizedBox(height: 8.0),
                              TextFormField(
                                onChanged: _songAddCubit.updateKey,
                                decoration: const InputDecoration(
                                    labelText: 'Tonacja',
                                    border: OutlineInputBorder()),
                              ),
                              const SizedBox(height: 8.0),
                              TextFormField(
                                validator: validateText,
                                onChanged: _songAddCubit.updateText,
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
                )));
      },
    );
  }

  void _saveSong(BuildContext context, SongsAddCubit songAddCubit) {
    songAddCubit.save();

    context.read<SongsListComponentBloc>().add(ReloadListEvent());

    return Navigator.of(context).pop();
  }
}
