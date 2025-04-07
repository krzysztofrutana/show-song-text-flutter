import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
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

  final List<String> _pageTexts = [];
  int _currentIndex = 0;
  int _currentSongIndex = 0;
  bool _needPaging = true;
  bool _isPaging = false;
  final _pageKey = GlobalKey();
  final _rowKey = GlobalKey();
  late Song _currentSong;
  int _allSongsCount = 0;

  @override
  void initState() {
    _currentSong =
        context.read<PresentatationBloc>().state.songs[_currentSongIndex];
    _allSongsCount = context.read<PresentatationBloc>().state.songs.length;
    super.initState();
  }

  @override
  void deactivate() {
    context.read<PresentatationBloc>().add(ClearPresentationStore());
    super.deactivate();
  }

  void _paginate() {
    var pageSize =
        (_pageKey.currentContext?.findRenderObject() as RenderBox).size;

    final rowSize =
        (_rowKey.currentContext?.findRenderObject() as RenderBox).size;

    var appBarHeight =
        Scaffold.of(_pageKey.currentContext!).appBarMaxHeight ?? 0;

    _pageTexts.clear();

    var fontSize = LocalStorage.instance.getInt('fontSize') ?? 15;

    final textSpan = TextSpan(
      text: _currentSong.text,
      style: TextStyle(
        color: Colors.black,
        fontSize: fontSize.toDouble(),
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(
      minWidth: 0,
      maxWidth: pageSize.width,
    );

    // https://medium.com/swlh/flutter-line-metrics-fd98ab180a64
    List<LineMetrics> lines = textPainter.computeLineMetrics();
    int currentPageStartIndex = 0;
    int currentPageEndIndex = 0;
    double currentHeight = 0;

    String pageText = '';
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      final left = line.left;
      final top = line.baseline - line.ascent;
      // final bottom = line.baseline + line.descent;

      // Current line overflow page
      if (currentHeight + line.height > pageSize.height) {
        // https://stackoverflow.com/questions/56943994/how-to-get-the-raw-text-from-a-flutter-textbox/56943995#56943995
        currentPageEndIndex =
            textPainter.getPositionForOffset(Offset(left, top)).offset;

        final pageText = _currentSong.text
            .substring(currentPageStartIndex, currentPageEndIndex);

        _pageTexts.add(pageText);

        currentPageStartIndex = currentPageEndIndex;
        currentHeight = 0;
      } else {
        currentHeight += line.height;
      }
    }

    final lastPageText = _currentSong.text.substring(currentPageStartIndex);
    _pageTexts.add(lastPageText);

    setState(() {
      _currentIndex = 0;
      _needPaging = false;
      _isPaging = false;
    });

    _sendTextToClients(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_needPaging && !_isPaging) {
      _isPaging = true;

      SchedulerBinding.instance.addPostFrameCallback((_) {
        _paginate();
      });
    }

    var fontSize = LocalStorage.instance.getInt('fontSize') ?? 15;

    return FocusScope(
      child: Focus(
        onKeyEvent: (node, event) {
          _throttler.throttle(
              duration: Duration(milliseconds: 200),
              onThrottle: () {
                if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                  if (_currentIndex < _pageTexts.length - 1) {
                    _handleNextPage(context);
                  } else if (_currentIndex == _pageTexts.length - 1 &&
                      _allSongsCount > 1 &&
                      _currentSongIndex < _allSongsCount - 1) {
                    _handleNextSong(context);
                  }

                  return KeyEventResult.handled;
                } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                  if (_currentIndex > 0) {
                    _handlePreviousPage(context);
                  } else if (_currentIndex == 0 &&
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
                      child: Text('${_currentSongIndex + 1}/$_allSongsCount'))
                ],
              ),
              centerTitle: true),
          body: SafeArea(
            child: SizedBox.expand(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: SizedBox.expand(
                            key: _pageKey,
                            child: Dismissible(
                              resizeDuration: null,
                              key: Key('$_currentSongIndex/$_currentIndex'),
                              onDismissed: (DismissDirection direction) {
                                // Swiping in left direction.
                                if (direction == DismissDirection.startToEnd) {
                                  if (_currentIndex > 0) {
                                    _handlePreviousPage(context);
                                  } else if (_currentIndex == 0 &&
                                      _allSongsCount > 1 &&
                                      _currentSongIndex > 0) {
                                    _handlePreviousSong(context, false);
                                  }
                                }
                                // Swiping in right direction.
                                if (direction == DismissDirection.endToStart) {
                                  if (_currentIndex < _pageTexts.length - 1) {
                                    _handleNextPage(context);
                                  } else if (_currentIndex ==
                                          _pageTexts.length - 1 &&
                                      _allSongsCount > 1 &&
                                      _currentSongIndex < _allSongsCount - 1) {
                                    _handleNextSong(context);
                                  }
                                }
                              },
                              child: Text(
                                _isPaging ? ' ' : _pageTexts[_currentIndex],
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: fontSize.toDouble(),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          key: _rowKey,
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
                                  _isPaging
                                      ? ''
                                      : '${_currentIndex + 1}/${_pageTexts.length}',
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
                    if (_isPaging)
                      Center(
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleFirstPage(BuildContext context) {
    setState(() {
      _currentIndex = 0;
    });

    _sendTextToClients(context);
  }

  void _handleLastPage(BuildContext context) {
    setState(() {
      _currentIndex = _pageTexts.length - 1;
    });

    _sendTextToClients(context);
  }

  void _handlePreviousPage(BuildContext context) {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });

      _sendTextToClients(context);
    }
  }

  void _handlePreviousSong(BuildContext context, bool returnToFirstIndex) {
    setState(() {
      _currentSongIndex -= 1;
      _currentSong =
          context.read<PresentatationBloc>().state.songs[_currentSongIndex];
      _paginate();

      if (!returnToFirstIndex) {
        _currentIndex = _pageTexts.length - 1;
      }
    });

    _sendTextToClients(context);
  }

  void _handleNextPage(BuildContext context) {
    if (_currentIndex < _pageTexts.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _sendTextToClients(context);
    }
  }

  void _handleNextSong(BuildContext context) {
    setState(() {
      _currentSongIndex += 1;
      _currentSong =
          context.read<PresentatationBloc>().state.songs[_currentSongIndex];
      _paginate();
    });

    _sendTextToClients(context);
  }

  void _sendTextToClients(BuildContext context) {
    if (context.read<ServerCubit>().state.server.serverStarted) {
      context.read<ServerCubit>().send(_pageTexts[_currentIndex]);
    }
  }
}
