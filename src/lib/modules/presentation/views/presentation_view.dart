import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';
import 'package:pomocnik_wokalisty/helpers/full_screen_helper.dart';
import 'package:pomocnik_wokalisty/injection_container.dart';
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';
import 'package:pomocnik_wokalisty/modules/presentation/bloc/presentation_bloc.dart';
import 'package:pomocnik_wokalisty/modules/presentation/models/presentation_song_info.dart';
import 'package:pomocnik_wokalisty/modules/presentation/models/send_to_client_model.dart';
import 'package:pomocnik_wokalisty/modules/songs/models/song_model.dart';
import 'package:pomocnik_wokalisty/socket_connection/cubit/server_cubit/server_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PresentationView extends StatefulWidget {
  const PresentationView({super.key});

  @override
  State<PresentationView> createState() => _PresentationViewState();
}

class _PresentationViewState extends State<PresentationView>
    with FullScreenListener {
  final Throttler _throttler = Throttler();

  late PageController _pageViewController;
  final List<PresentationSongInfo> _presentationPages = List.empty(
    growable: true,
  );
  PresentationSongInfo? _currentPageInfo;
  int _fontSize = 12;
  late List<Song> songs;
  int _allSongsCount = 0;

  bool _isInitialized = false;

  @override
  void initState() {
    songs = context.read<PresentationBloc>().state.songs;
    _allSongsCount = songs.length;
    _pageViewController = PageController();
    FullScreenHelper.instance.addListener(this);
    FullScreenHelper.instance.setFullScreen(true);
    _fontSize = sl<SharedPreferences>().getInt('fontSize') ?? 15;

    super.initState();
  }

  @override
  void onFullScreenChanged(bool enabled, SystemUiMode? systemUiMode) {
    if (context.mounted) {
      setState(() {
        _isInitialized = enabled;
        _presentationPages.clear();
      });
    }
  }

  @override
  void dispose() {
    FullScreenHelper.instance.removeListener(this);
    FullScreenHelper.instance.setFullScreen(false);
    _pageViewController.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    context.read<PresentationBloc>().add(ClearPresentationStore());
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      child: Focus(
        onKeyEvent: (node, event) {
          _throttler.throttle(
            duration: const Duration(milliseconds: 200),
            onThrottle: () {
              if (_currentPageInfo == null) {
                return KeyEventResult.ignored;
              }

              if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                if (_currentPageInfo!.nextPageExist) {
                  _handleNextPage(context);
                } else if (!_currentPageInfo!.nextPageExist &&
                    _currentPageInfo!.nextSongExist) {
                  _handleNextSong(context);
                }

                return KeyEventResult.handled;
              } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                if (_currentPageInfo!.previewPageExist) {
                  _handlePreviousPage(context);
                } else if (!_currentPageInfo!.previewPageExist &&
                    _currentPageInfo!.previewSongExist) {
                  _handlePreviousSong(context, false);
                }

                return KeyEventResult.handled;
              } else if (event.logicalKey == LogicalKeyboardKey.exit) {
                Navigator.of(context).pop();

                return KeyEventResult.handled;
              }

              return KeyEventResult.handled;
            },
          );

          return KeyEventResult.ignored;
        },
        child: SafeArea(
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _currentPageInfo?.title ?? "",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Visibility(
                    visible: _allSongsCount > 1 && _currentPageInfo != null,
                    child: Text(
                      _currentPageInfo != null
                          ? '${_currentPageInfo!.songNumber}/${_currentPageInfo!.totalSongsCount}'
                          : "",
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child:
                        _presentationPages.isNotEmpty
                            ? PageView(
                              controller: _pageViewController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentPageInfo = _presentationPages[index];
                                });
                                _sendTextToClients(context);
                              },
                              children: [
                                for (var songPage in _presentationPages)
                                  songPage.pageWidget,
                              ],
                            )
                            : LayoutBuilder(
                              builder: (ctx, constraints) {
                                Future.delayed(Duration.zero, () {
                                  if (ctx.mounted && _isInitialized) {
                                    _setPages(ctx, constraints);
                                  }
                                  setState(() {});
                                });
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.first_page),
                  onPressed:
                      _currentPageInfo?.previewSongExist ?? false
                          ? () => _handlePreviousSong(context, true)
                          : null,
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.first_page),
                      onPressed: () {
                        _handleFirstPage(context);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.navigate_before),
                      onPressed: () {
                        _handlePreviousPage(context);
                      },
                    ),
                    Text(
                      _currentPageInfo != null
                          ? '${_currentPageInfo!.pageNumberInSongContext}/${_currentPageInfo!.totalPagesCountForSong}'
                          : '',
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                    ),
                    IconButton(
                      icon: const Icon(Icons.navigate_next),
                      onPressed: () {
                        _handleNextPage(context);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.last_page),
                      onPressed: () {
                        _handleLastPage(context);
                      },
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.last_page_sharp),
                  onPressed:
                      _currentPageInfo?.nextSongExist ?? false
                          ? () => _handleNextSong(context)
                          : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleFirstPage(BuildContext context) {
    setState(() {
      final firstIndexForSong = _presentationPages.firstWhere(
        (songInfo) =>
            songInfo.songNumber == _currentPageInfo!.songNumber &&
            songInfo.pageIndexInSongContext == 0,
      );

      _pageViewController.jumpToPage(firstIndexForSong.pageIndex);
    });
  }

  void _handleLastPage(BuildContext context) {
    setState(() {
      final lastIndexForSong = _presentationPages.firstWhere(
        (songInfo) =>
            songInfo.songNumber == _currentPageInfo!.songNumber &&
            songInfo.pageIndexInSongContext ==
                songInfo.totalPagesCountForSong - 1,
      );
      _pageViewController.jumpToPage(lastIndexForSong.pageIndex);
    });
  }

  void _handlePreviousPage(BuildContext context) {
    setState(() {
      _pageViewController.previousPage(
        duration: const Duration(microseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _handlePreviousSong(BuildContext context, bool returnToFirstIndex) {
    if (returnToFirstIndex) {
      setState(() {
        final lastIndexForSongPrevious = _presentationPages.firstWhere(
          (songInfo) =>
              songInfo.songNumber == _currentPageInfo!.songNumber - 1 &&
              songInfo.pageIndexInSongContext == 0,
        );
        _pageViewController.jumpToPage(lastIndexForSongPrevious.pageIndex);
      });
    } else {
      _handlePreviousPage(context);
    }
  }

  void _handleNextPage(BuildContext context) {
    setState(() {
      _pageViewController.nextPage(
        duration: const Duration(microseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _handleNextSong(BuildContext context) {
    if (_currentPageInfo!.nextSongExist &&
        _currentPageInfo!.pageIndexInSongContext ==
            _currentPageInfo!.totalPagesCountForSong - 1) {
      _handleNextPage(context);
    } else {
      final firstIndexForNextSong = _presentationPages.firstWhere(
        (songInfo) =>
            songInfo.songNumber == _currentPageInfo!.songNumber + 1 &&
            songInfo.pageIndexInSongContext == 0,
      );
      _pageViewController.jumpToPage(firstIndexForNextSong.pageIndex);
    }
  }

  void _sendTextToClients(BuildContext context) {
    if (context.read<ServerCubit>().state.serverStarted &&
        _currentPageInfo != null) {
      final modelToSend =
          SendToClientModel(
            text: _currentPageInfo!.pageText,
            title: _currentPageInfo!.title,
          ).toJson();

      context.read<ServerCubit>().send(jsonEncode(modelToSend));
    }
  }

  _setPages(BuildContext context, BoxConstraints constraints) {
    _presentationPages.clear();
    final totalSongsCount = songs.length;

    for (var i = 0; i < songs.length; i++) {
      final song = songs[i];
      final title = song.title;
      final songNumber = i + 1;

      final text = song.text.trim();

      final scaledFontSize = MediaQuery.textScalerOf(
        context,
      ).scale(_fontSize.toDouble());

      final defaultTextStyle = DefaultTextStyle.of(context);

      final style = defaultTextStyle.style.merge(
        TextStyle(fontSize: scaledFontSize),
      );

      final span = TextSpan(text: text, style: style);

      final templatePainter = TextPainter(
        text: span,
        textScaler: MediaQuery.textScalerOf(context),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left,
        locale: Locale(Platform.localeName),
      );

      templatePainter.layout(maxWidth: constraints.maxWidth);

      final overflowH = templatePainter.height > constraints.maxHeight;

      if (!overflowH) {
        final newPage = SingleChildScrollView(
          child: Text.rich(
            span,
            style: style,
            textAlign: TextAlign.left,
            locale: Locale(Platform.localeName),
            textScaler: TextScaler.linear(scaledFontSize / _fontSize),
          ),
        );

        _presentationPages.add(
          PresentationSongInfo(
            title: title,
            songNumber: songNumber,
            totalSongsCount: totalSongsCount,
            pageIndex:
                _presentationPages.isNotEmpty ? _presentationPages.length : 0,
            pageIndexInSongContext: 0,
            totalPagesCountForSong: 1,
            pageWidget: newPage,
            pageText: text,
            song: song,
          ),
        );
        continue;
      }

      final ls = const LineSplitter();
      var textLinesToCheck = ls.convert(text);
      if (textLinesToCheck.isEmpty || textLinesToCheck.length == 1) {
        if (_presentationPages.isEmpty) {
          final newPage = SingleChildScrollView(
            child: Text.rich(
              span,
              style: style,
              textAlign: TextAlign.left,
              locale: Locale(Platform.localeName),
              textScaler: TextScaler.linear(scaledFontSize / _fontSize),
            ),
          );

          _presentationPages.add(
            PresentationSongInfo(
              title: "",
              songNumber: 1,
              totalSongsCount: 1,
              pageIndex: 0,
              pageIndexInSongContext: 0,
              totalPagesCountForSong: 1,
              pageWidget: newPage,
              pageText: "",
              song: song,
            ),
          );
        }
        _showTextErrorModal(song);

        return;
      }

      final charHeight = templatePainter.preferredLineHeight;
      if (charHeight <= 0) {
        _showTextErrorModal(song);
        continue;
      }
      final linesInPage = constraints.maxHeight ~/ charHeight;
      if (linesInPage <= 0) {
        _showTextErrorModal(song);
        continue;
      }

      var iteration = 0;
      while (textLinesToCheck.isNotEmpty) {
        var linesForPageForLeftTextLines = linesInPage;

        if (linesForPageForLeftTextLines > textLinesToCheck.length) {
          linesForPageForLeftTextLines = textLinesToCheck.length;
        }

        textLinesToCheck = removeFirstLineIfEmpty(textLinesToCheck);

        for (var i = linesForPageForLeftTextLines; i > 0; i--) {
          final textLinesForPage = textLinesToCheck.take(i);

          final checkSpan = TextSpan(
            text: textLinesForPage.join("\n").trim(),
            style: style,
          );

          final checkPainter = TextPainter(
            text: checkSpan,
            textScaler: MediaQuery.textScalerOf(context),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.left,
            locale: Locale(Platform.localeName),
          );

          checkPainter.layout(maxWidth: constraints.maxWidth);

          final checkPainterOverflow =
              checkPainter.height > constraints.maxHeight;

          if (!checkPainterOverflow) {
            textLinesToCheck = textLinesToCheck.skip(i).toList();

            final newPage = SingleChildScrollView(
              child: Text.rich(
                checkSpan,
                style: style,
                locale: Locale(Platform.localeName),
                textScaler: TextScaler.linear(scaledFontSize / _fontSize),
              ),
            );

            _presentationPages.add(
              PresentationSongInfo(
                title: title,
                songNumber: songNumber,
                totalSongsCount: totalSongsCount,
                pageIndex:
                    _presentationPages.isNotEmpty
                        ? _presentationPages.length
                        : 0,
                pageIndexInSongContext: iteration,
                totalPagesCountForSong: -1,
                pageWidget: newPage,
                pageText: checkSpan.text ?? "",
                song: song,
              ),
            );

            iteration++;
            break;
          }
        }
      }
    }

    for (var songInfo in _presentationPages.where(
      (songInfo) => songInfo.totalPagesCountForSong == -1,
    )) {
      songInfo.totalPagesCountForSong =
          _presentationPages
              .where((x) => x.songNumber == songInfo.songNumber)
              .length;
    }

    _currentPageInfo = _presentationPages.firstOrNull;

    _sendTextToClients(context);
  }

  List<String> removeFirstLineIfEmpty(List<String> textLines) {
    if (textLines.isEmpty) return textLines;

    if (textLines[0].isEmpty) {
      final newTextLines = textLines.skip(1).toList();
      return removeFirstLineIfEmpty(newTextLines);
    }

    return textLines;
  }

  Future<void> _showTextErrorModal(Song song) {
    final localizations = AppLocalizations.of(context)!;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            localizations.createPresentationError,
            style: const TextStyle(fontSize: 20),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  localizations.songMustHaveTextDividedIntoLines(song.title),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(localizations.ok),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
