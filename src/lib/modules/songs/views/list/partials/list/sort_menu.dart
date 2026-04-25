import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/list/partials/list/bloc/songs_list_component_bloc.dart';

class SortMenu extends StatelessWidget {
  const SortMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return BlocBuilder<SongsListComponentBloc, SongsListComponentState>(
      builder: (context, state) {
        return PopupMenuButton<SongsSortOption>(
          tooltip: localizations.sortBy,
          icon: const Icon(Icons.sort),
          onSelected: (SongsSortOption result) {
            context.read<SongsListComponentBloc>().add(ChangeSortEvent(result));
          },
          itemBuilder:
              (BuildContext context) => <PopupMenuEntry<SongsSortOption>>[
                PopupMenuItem<SongsSortOption>(
                  value: SongsSortOption.latest,
                  child: Row(
                    children: [
                      Icon(
                        Icons.check,
                        color:
                            state.sortOption == SongsSortOption.latest
                                ? Colors.red
                                : Colors.transparent,
                      ),
                      const SizedBox(width: 8),
                      Text(localizations.latest),
                    ],
                  ),
                ),
                PopupMenuItem<SongsSortOption>(
                  value: SongsSortOption.oldest,
                  child: Row(
                    children: [
                      Icon(
                        Icons.check,
                        color:
                            state.sortOption == SongsSortOption.oldest
                                ? Colors.red
                                : Colors.transparent,
                      ),
                      const SizedBox(width: 8),
                      Text(localizations.oldest),
                    ],
                  ),
                ),
                PopupMenuItem<SongsSortOption>(
                  value: SongsSortOption.artistAndTitle,
                  child: Row(
                    children: [
                      Icon(
                        Icons.check,
                        color:
                            state.sortOption == SongsSortOption.artistAndTitle
                                ? Colors.red
                                : Colors.transparent,
                      ),
                      const SizedBox(width: 8),
                      Text(localizations.byArtistAndTitle),
                    ],
                  ),
                ),
                PopupMenuItem<SongsSortOption>(
                  value: SongsSortOption.title,
                  child: Row(
                    children: [
                      Icon(
                        Icons.check,
                        color:
                            state.sortOption == SongsSortOption.title
                                ? Colors.red
                                : Colors.transparent,
                      ),
                      const SizedBox(width: 8),
                      Text(localizations.byTitle),
                    ],
                  ),
                ),
              ],
        );
      },
    );
  }
}
