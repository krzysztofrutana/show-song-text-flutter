import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';
import 'package:paginated_text/paginated_text.dart';
import 'package:pomocnik_wokalisty/helpers/local_storage.dart';
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

  DismissDirection _dismissDirection = DismissDirection.none;

  @override
  void initState() {
    _currentSong =
        context.read<PresentatationBloc>().state.songs[_currentSongIndex];
    _allSongsCount = context.read<PresentatationBloc>().state.songs.length;

    _controller = _getController(_currentSong.text);

    FullScreen.setFullScreen(true);

    super.initState();

    _sendTextToClients(context);
  }

  PaginatedController _getController(String text) {
    var fontSize = LocalStorage.instance.getInt('fontSize') ?? 15;

    var controller = PaginatedController(PaginateData(
      text: text,
      dropCapLines: 0,
      style: TextStyle(
          color: Colors.black, fontSize: fontSize.toDouble(), height: 1.2),
      pageBreakType: PageBreakType.paragraph,
      breakLines: 2,
    ));

    controller.onPaginate = _onPaginate;

    return controller;
  }

  _onPaginate(PaginatedController controller) {
    setState(() {
      _controller = controller;

      if (_setLastPageFromSong) {
        controller.setPageIndex(controller.numPages - 1);
        _setLastPageFromSong = false;
      }

      _setDismissDirection();
    });

    _sendTextToClients(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    FullScreen.setFullScreen(false);
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
          body: Column(
            children: [
              Expanded(
                child: SizedBox.expand(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: PaginatedText(
                      _controller,
                      builder: (context, child) {
                        return Column(
                          children: [
                            Expanded(
                              child: SizedBox.expand(
                                child: SafeArea(
                                  child: Dismissible(
                                      direction: _dismissDirection,
                                      resizeDuration: null,
                                      key: Key(
                                          '$_currentSongIndex/${_controller.currentPage.pageIndex}'),
                                      onDismissed:
                                          (DismissDirection direction) {
                                        // Swiping in left direction.
                                        if (direction ==
                                            DismissDirection.startToEnd) {
                                          if (!_controller.isFirst) {
                                            _handlePreviousPage(context);
                                          } else if (_controller.isFirst &&
                                              _allSongsCount > 1 &&
                                              _currentSongIndex > 0) {
                                            _handlePreviousSong(context, false);
                                          }
                                        }
                                        // Swiping in right direction.
                                        else if (direction ==
                                            DismissDirection.endToStart) {
                                          if (!_controller.isLast) {
                                            _handleNextPage(context);
                                          } else if (_controller.isLast &&
                                              _allSongsCount > 1 &&
                                              _currentSongIndex <
                                                  _allSongsCount - 1) {
                                            _handleNextSong(context);
                                          }
                                        } else {
                                          setState(() {
                                            _controller = _controller;
                                          });
                                        }
                                      },
                                      child: child),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.first_page),
                    onPressed: _allSongsCount > 1 && _currentSongIndex > 0
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
        ),
      ),
    );
  }

  void _handleFirstPage(BuildContext context) {
    setState(() {
      _controller.setPageIndex(0);
      _setDismissDirection();
    });

    _sendTextToClients(context);
  }

  void _handleLastPage(BuildContext context) {
    setState(() {
      _controller.setPageIndex(_controller.numPages - 1);
      _setDismissDirection();
    });

    _sendTextToClients(context);
  }

  void _handlePreviousPage(BuildContext context) {
    if (!_controller.isFirst) {
      setState(() {
        _controller.previous();
        _setDismissDirection();
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

      _setDismissDirection();
    });
  }

  void _handleNextPage(BuildContext context) {
    if (!_controller.isLast) {
      setState(() {
        _controller.next();
        _setDismissDirection();
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
      _setDismissDirection();
    });
  }

  void _sendTextToClients(BuildContext context) {
    if (context.read<ServerCubit>().state.server.serverStarted) {
      context.read<ServerCubit>().send(_controller.currentPage.text);
    }
  }

  void _setDismissDirection() {
    setState(() {
      if (_allSongsCount > 1) {
        if (_currentSongIndex == 0) {
          if (_controller.isFirst) {
            _dismissDirection = DismissDirection.endToStart;
          } else {
            _dismissDirection = DismissDirection.horizontal;
          }
        } else if (_currentSongIndex == _allSongsCount - 1) {
          if (_controller.isLast) {
            _dismissDirection = DismissDirection.startToEnd;
          } else {
            _dismissDirection = DismissDirection.horizontal;
          }
        } else {
          _dismissDirection = DismissDirection.horizontal;
        }
      } else {
        if (_controller.isFirst && _controller.pages.length == 1) {
          _dismissDirection = DismissDirection.none;
        } else if (_controller.isFirst) {
          _dismissDirection = DismissDirection.endToStart;
        } else if (_controller.isLast) {
          _dismissDirection = DismissDirection.startToEnd;
        } else {
          _dismissDirection = DismissDirection.horizontal;
        }
      }
    });
  }
}
