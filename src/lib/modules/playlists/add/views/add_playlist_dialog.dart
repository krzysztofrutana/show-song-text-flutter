import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/helpers/bloc_text_form_field.dart';
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';
import 'package:pomocnik_wokalisty/modules/playlists/add/bloc/add_playlist_bloc.dart';
import 'package:pomocnik_wokalisty/modules/playlists/list/partials/list/bloc/playlists_list_component_bloc.dart';

class AddPlaylistDialog extends StatelessWidget {
  AddPlaylistDialog({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return BlocBuilder<AddPlaylistBloc, AddPlaylistState>(
      builder: (context, state) {
        return AlertDialog(
          title: Text(localizations.addingPlaylist),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              autovalidateMode: state.autovalidateMode,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BlocTextFormField<AddPlaylistBloc, AddPlaylistState>(
                    bloc: context.read<AddPlaylistBloc>(),
                    selector: (state) => state.playlist.name,
                    decoration: InputDecoration(
                      hintText: localizations.enterName,
                      labelText: localizations.name,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return localizations.nameIsRequired;
                      }
                      return null;
                    },
                    onChanged:
                        (value) => context.read<AddPlaylistBloc>().add(
                          PlaylistAddNameChange(value),
                        ),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _onSave(context),
                    autofocus: true,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(localizations.cancel),
              onPressed: () {
                context.read<AddPlaylistBloc>().add(AddPlaylistReset());
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(localizations.yes),
              onPressed: () => _onSave(context),
            ),
          ],
        );
      },
    );
  }

  void _onSave(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final addPlaylistBloc = context.read<AddPlaylistBloc>();
      final playlistId = addPlaylistBloc.state.playlist.uuid;

      addPlaylistBloc.add(AddPlaylistSave());
      addPlaylistBloc.add(AddPlaylistReset());

      context.read<PlaylistsListComponentBloc>().add(ReloadListEvent());

      Navigator.of(context).pop(playlistId);
    } else {
      context.read<AddPlaylistBloc>().add(
        const AddPlaylistUpdateAutovalidateMode(AutovalidateMode.always),
      );
    }
  }
}
