import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:paginated_text/paginated_text.dart';
import 'package:pomocnik_wokalisty/helpers/LocalStorage.dart';
import 'package:pomocnik_wokalisty/modules/presentation/bloc/presentation_bloc.dart';
import 'package:pomocnik_wokalisty/modules/songs/models/song_model.dart';
import 'package:pomocnik_wokalisty/socket_connection/cubic/server_cubic/server_cubit.dart';

class PresentationView extends StatefulWidget {
  const PresentationView({super.key});

  @override
  State<PresentationView> createState() => _PresentationViewState();
}

class _PresentationViewState extends State<PresentationView> {
  final Throttler _throttler = Throttler();

  int _currentSongIndex = 0;
  late Song _currentSong;
  int _allSongsCount = 0;
  late PaginatedController _controller;

  bool _setLastPageFromSong = false;

  @override
  void initState() {
    _currentSong =
        context.read<PresentatationBloc>().state.songs[_currentSongIndex];
    _allSongsCount = context.read<PresentatationBloc>().state.songs.length;

    _controller = _getController(_currentSong.text);

    super.initState();

    _sendTextToClients(context);
  }

  PaginatedController _getController(String text) {
    var fontSize = LocalStorage.instance.getInt('fontSize') ?? 15;

    var controller = PaginatedController(PaginateData(
      text: text,
      dropCapLines: 0,
      style: TextStyle(
        color: Colors.black,
        fontSize: fontSize.toDouble(),
      ),
      pageBreakType: PageBreakType.word,
      breakLines: 1,
      resizeTolerance: 3,
      parseInlineMarkdown: true,
    ));

    controller.onPaginate = _onPaginate;

    return controller;
  }

  _onPaginate(PaginatedController controller) {
    if (_setLastPageFromSong) {
      controller.setPageIndex(controller.numPages - 1);
    }

    _sendTextToClients(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    context.read<PresentatationBloc>().add(ClearPresentationStore());
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      child: Focus(
        onKeyEvent: (node, event) {
          _throttler.throttle(
              duration: Duration(milliseconds: 200),
              onThrottle: () {
                if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                  if (!_controller.isLast) {
                    _handleNextPage(context);
                  } else if (_controller.isLast &&
                      _allSongsCount > 1 &&
                      _currentSongIndex < _allSongsCount - 1) {
                    _handleNextSong(context);
                  }

                  return KeyEventResult.handled;
                } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                  if (!_controller.isFirst) {
                    _handlePreviousPage(context);
                  } else if (_controller.isFirst &&
                      _allSongsCount > 1 &&
                      _currentSongIndex > 0) {
                    _handlePreviousSong(context, false);
                  }

                  return KeyEventResult.handled;
                } else if (event.logicalKey == LogicalKeyboardKey.exit) {
                  Navigator.of(context).pop();

                  return KeyEventResult.handled;
                }

                return KeyEventResult.handled;
              });

          return KeyEventResult.ignored;
        },
        child: Scaffold(
          appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_currentSong.title),
                  Visibility(
                      visible: _allSongsCount > 1,
                      child: Text('${_currentSongIndex + 1}/$_allSongsCount',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          )))
                ],
              ),
              centerTitle: true),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: PaginatedText(
              _controller,
              builder: (context, child) {
                var fontSize = LocalStorage.instance.getInt('fontSize') ?? 15;

                return DefaultTextStyle(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: fontSize.toDouble(),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: SizedBox.expand(
                          child: Dismissible(
                              resizeDuration: null,
                              key: Key(
                                  '$_currentSongIndex/${_controller.currentPage.pageIndex}'),
                              onDismissed: (DismissDirection direction) {
                                // Swiping in left direction.
                                if (direction == DismissDirection.startToEnd) {
                                  if (!_controller.isFirst) {
                                    _handlePreviousPage(context);
                                  } else if (_controller.isFirst &&
                                      _allSongsCount > 1 &&
                                      _currentSongIndex > 0) {
                                    _handlePreviousSong(context, false);
                                  }
                                }
                                // Swiping in right direction.
                                if (direction == DismissDirection.endToStart) {
                                  if (!_controller.isLast) {
                                    _handleNextPage(context);
                                  } else if (_controller.isLast &&
                                      _allSongsCount > 1 &&
                                      _currentSongIndex < _allSongsCount - 1) {
                                    _handleNextSong(context);
                                  }
                                }
                              },
                              child: child),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(Icons.first_page),
                            onPressed:
                                _allSongsCount > 1 && _currentSongIndex > 0
                                    ? () => _handlePreviousSong(context, true)
                                    : null,
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.first_page),
                                onPressed: () {
                                  _handleFirstPage(context);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.navigate_before),
                                onPressed: () {
                                  _handlePreviousPage(context);
                                },
                              ),
                              Text(
                                _controller.numPages > 0
                                    ? '${_controller.pageNumber}/${_controller.numPages}'
                                    : '',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.navigate_next),
                                onPressed: () {
                                  _handleNextPage(context);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.last_page),
                                onPressed: () {
                                  _handleLastPage(context);
                                },
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.last_page_sharp),
                            onPressed: _allSongsCount > 1 &&
                                    _currentSongIndex < _allSongsCount - 1
                                ? () => _handleNextSong(context)
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _handleFirstPage(BuildContext context) {
    setState(() {
      _controller.setPageIndex(0);
    });

    _sendTextToClients(context);
  }

  void _handleLastPage(BuildContext context) {
    setState(() {
      _controller.setPageIndex(_controller.numPages - 1);
    });

    _sendTextToClients(context);
  }

  void _handlePreviousPage(BuildContext context) {
    if (!_controller.isFirst) {
      setState(() {
        _controller.previous();
      });

      _sendTextToClients(context);
    }
  }

  void _handlePreviousSong(BuildContext context, bool returnToFirstIndex) {
    setState(() {
      _currentSongIndex -= 1;
      _currentSong =
          context.read<PresentatationBloc>().state.songs[_currentSongIndex];
      _controller = _getController(_currentSong.text);

      if (!returnToFirstIndex) _setLastPageFromSong = true;
    });
  }

  void _handleNextPage(BuildContext context) {
    if (!_controller.isLast) {
      setState(() {
        _controller.next();
      });
      _sendTextToClients(context);
    }
  }

  void _handleNextSong(BuildContext context) {
    setState(() {
      _currentSongIndex += 1;
      _currentSong =
          context.read<PresentatationBloc>().state.songs[_currentSongIndex];
      _controller = _getController(_currentSong.text);
    });
  }

  void _sendTextToClients(BuildContext context) {
    if (context.read<ServerCubit>().state.server.serverStarted) {
      context.read<ServerCubit>().send(_controller.currentPage.text);
    }
  }
}
