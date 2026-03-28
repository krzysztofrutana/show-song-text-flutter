part of 'playlists_list_component_bloc.dart';

enum PlaylistsListStatus { initial, loading, success, error }

class PlaylistsListComponentState extends Equatable {
  const PlaylistsListComponentState({
    required this.data,
    required this.choosePlaylists,
    required this.selectedPlaylists,
    this.status = PlaylistsListStatus.initial,
    this.errorMessage = '',
    this.searchQuery = '',
  });

  final List<String> selectedPlaylists;
  final bool choosePlaylists;
  final List<Playlist> data;
  final PlaylistsListStatus status;
  final String errorMessage;
  final String searchQuery;

  PlaylistsListComponentState copyWith({
    List<String>? selectedPlaylists,
    bool? choosePlaylists,
    List<Playlist>? data,
    PlaylistsListStatus? status,
    String? errorMessage,
    String? searchQuery,
  }) {
    return PlaylistsListComponentState(
      data: data ?? this.data,
      choosePlaylists: choosePlaylists ?? this.choosePlaylists,
      selectedPlaylists: selectedPlaylists ?? this.selectedPlaylists,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        data,
        choosePlaylists,
        selectedPlaylists,
        status,
        errorMessage,
        searchQuery
      ];
}

final class PlaylistsListComponentInitialState
    extends PlaylistsListComponentState {
  const PlaylistsListComponentInitialState()
      : super(
          data: const [],
          choosePlaylists: false,
          selectedPlaylists: const [],
          status: PlaylistsListStatus.initial,
        );
}
