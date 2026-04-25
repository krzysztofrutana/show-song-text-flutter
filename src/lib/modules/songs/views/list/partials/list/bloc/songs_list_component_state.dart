part of 'songs_list_component_bloc.dart';

enum SongsListStatus { initial, loading, success, error }

enum SongsSortOption { latest, oldest, artistAndTitle, title }

class SongsListComponentState extends Equatable {
  const SongsListComponentState({
    required this.data,
    required this.chooseSongs,
    required this.selectedSongs,
    this.status = SongsListStatus.initial,
    this.errorMessage = '',
    this.searchQuery = '',
    this.sortOption = SongsSortOption.latest,
  });

  final List<String> selectedSongs;
  final bool chooseSongs;
  final List<Song> data;
  final SongsListStatus status;
  final String errorMessage;
  final String searchQuery;
  final SongsSortOption sortOption;

  SongsListComponentState copyWith({
    List<String>? selectedSongs,
    bool? chooseSongs,
    List<Song>? data,
    SongsListStatus? status,
    String? errorMessage,
    String? searchQuery,
    SongsSortOption? sortOption,
  }) {
    return SongsListComponentState(
      data: data ?? this.data,
      chooseSongs: chooseSongs ?? this.chooseSongs,
      selectedSongs: selectedSongs ?? this.selectedSongs,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
    );
  }

  @override
  List<Object?> get props => [
    data,
    chooseSongs,
    selectedSongs,
    status,
    errorMessage,
    searchQuery,
    sortOption,
  ];
}

final class SongsListComponentInitialState extends SongsListComponentState {
  const SongsListComponentInitialState()
    : super(
        data: const [],
        chooseSongs: false,
        selectedSongs: const [],
        status: SongsListStatus.initial,
      );
}
