import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';
import 'package:pomocnik_wokalisty/modules/presentation/bloc/presentation_bloc.dart';
import 'package:pomocnik_wokalisty/modules/presentation/views/presentation_view.dart';
import 'package:pomocnik_wokalisty/modules/songs/models/song_model.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/edit/songs_edit.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/list/partials/list/bloc/songs_list_component_bloc.dart';
import 'package:pomocnik_wokalisty/modules/songs/views/list/partials/list/sort_menu.dart';

class SongsListComponent extends StatefulWidget {
  const SongsListComponent({
    super.key,
    this.onAddPressed,
    this.onQuickSearchPressed,
    this.onIsAtEndChanged,
  });
  final VoidCallback? onAddPressed;
  final VoidCallback? onQuickSearchPressed;
  final ValueChanged<bool>? onIsAtEndChanged;

  @override
  State<SongsListComponent> createState() => _SongsListComponentState();
}

class _SongsListComponentState extends State<SongsListComponent> {
  final ScrollController _scrollController = ScrollController();
  bool _isAtEnd = false;

  @override
  void initState() {
    super.initState();
    context.read<SongsListComponentBloc>().add(LoadSongsEvent());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final isAtEnd = currentScroll >= maxScroll - 50;

    if (isAtEnd != _isAtEnd) {
      setState(() => _isAtEnd = isAtEnd);
      widget.onIsAtEndChanged?.call(isAtEnd);
    }
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

        if (state.status == SongsListStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  localizations.errorLoadingSongs,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    context.read<SongsListComponentBloc>().add(
                      LoadSongsEvent(),
                    );
                  },
                  child: Text(localizations.tryAgain),
                ),
              ],
            ),
          );
        }

        final list = state.data;
        return Column(
          children: [
            const SearchAppBar(),
            Flexible(
              child:
                  list.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              localizations.noSongs,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (widget.onAddPressed != null)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: FloatingActionButton(
                                      heroTag: "addEmpty",
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      onPressed: widget.onAddPressed,
                                      child: const Icon(Icons.add, size: 30),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      )
                      : Container(
                        padding: const EdgeInsets.all(16),
                        child: ListView.separated(
                          controller: _scrollController,
                          separatorBuilder: (context, index) => const Divider(),
                          itemCount: list.length + 1,
                          itemBuilder: (context, index) {
                            if (index == list.length) {
                              return AnimatedOpacity(
                                opacity: _isAtEnd ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 200),
                                child: Align(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      top: 16,
                                      bottom: 16,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      spacing: 20,
                                      children: [
                                        SizedBox(
                                          width: 56,
                                          height: 56,
                                          child: FloatingActionButton(
                                            heroTag: "quickSearchEnd",
                                            backgroundColor: Colors.orange,
                                            foregroundColor: Colors.white,
                                            onPressed:
                                                widget.onQuickSearchPressed,
                                            child: const Icon(
                                              Icons.manage_search,
                                              size: 30,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 56,
                                          height: 56,
                                          child: FloatingActionButton(
                                            heroTag: "addEnd",
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                            onPressed: widget.onAddPressed,
                                            child: const Icon(
                                              Icons.add,
                                              size: 30,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }

                            final song = list[index];
                            final songAuthor =
                                song.author.isEmpty ? "-" : song.author;
                            final songTitle =
                                song.title.isEmpty ? "-" : song.title;

                            if (state.chooseSongs) {
                              return CheckboxListTile(
                                activeColor: Colors.red,
                                value: state.selectedSongs.contains(song.uuid),
                                onChanged:
                                    (newValue) =>
                                        _onSongCheckboxClick(song, newValue),
                                title: Text(
                                  songTitle,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                subtitle: Text(songAuthor),
                                contentPadding: const EdgeInsets.only(
                                  left: 6,
                                  right: 10,
                                ),
                              );
                            } else {
                              return ListTile(
                                title: Text(songTitle),
                                subtitle: Text(songAuthor),
                                titleTextStyle: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                                onTap:
                                    () => _redirectToSongsEdit(context, song),
                                onLongPress: () {
                                  final bloc =
                                      context.read<SongsListComponentBloc>();
                                  bloc.add(ChooseSongChangeEvent(value: true));
                                  bloc.add(SelectSongEvent(song: song));
                                },
                                contentPadding: const EdgeInsets.only(
                                  left: 6,
                                  right: 10,
                                ),
                                trailing: IconButton(
                                  tooltip: localizations.presentationScreen,
                                  icon: const ImageIcon(
                                    AssetImage(
                                      'assets/images/icons/presentation.png',
                                    ),
                                    size: 24,
                                  ),
                                  onPressed:
                                      () => _runPresentation(context, song),
                                ),
                              );
                            }
                          },
                        ),
                      ),
            ),
          ],
        );
      },
    );
  }

  void _onSongCheckboxClick(Song song, bool? newValue) {
    if (newValue == true) {
      context.read<SongsListComponentBloc>().add(SelectSongEvent(song: song));
    } else {
      context.read<SongsListComponentBloc>().add(UnselectSongEvent(song: song));
    }
  }

  void _redirectToSongsEdit(BuildContext context, Song song) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(builder: (context) => SongsEdit(songId: song.uuid)),
        )
        .then((_) {
          if (context.mounted) {
            context.read<SongsListComponentBloc>().add(LoadSongsEvent());
          }
        });
  }

  void _runPresentation(BuildContext context, Song song) {
    context.read<PresentationBloc>().add(SongPresentation(song: song));

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const PresentationView()));
  }
}

class SearchAppBar extends StatelessWidget {
  const SearchAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged:
                  (value) => context.read<SongsListComponentBloc>().add(
                    SearchSongsEvent(value),
                  ),
              decoration: InputDecoration(
                labelText: localizations.search,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const SortMenu(),
        ],
      ),
    );
  }
}
