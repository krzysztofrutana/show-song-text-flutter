import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';
import 'package:just_audio/just_audio.dart';
import 'package:pomocnik_wokalisty/helpers/full_screen_helper.dart';
import 'package:pomocnik_wokalisty/helpers/recording_mixin.dart';
import 'package:pomocnik_wokalisty/helpers/text_scroll_mode_helper.dart';
import 'package:pomocnik_wokalisty/helpers/ui_helper.dart';
import 'package:pomocnik_wokalisty/helpers/wakelock_helper.dart';
import 'package:pomocnik_wokalisty/injection_container.dart';
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';
import 'package:pomocnik_wokalisty/modules/presentation/bloc/presentation_bloc.dart';
import 'package:pomocnik_wokalisty/modules/presentation/models/presentation_song_info.dart';
import 'package:pomocnik_wokalisty/modules/presentation/models/send_to_client_model.dart';
import 'package:pomocnik_wokalisty/modules/presentation/views/dialogs/recordings_dialog.dart';
import 'package:pomocnik_wokalisty/modules/presentation/widgets/audio_player_bar.dart';
import 'package:pomocnik_wokalisty/modules/songs/models/song_model.dart';
import 'package:pomocnik_wokalisty/socket_connection/cubit/server_cubit/server_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class PresentationView extends StatefulWidget {
  const PresentationView({super.key});

  @override
  State<PresentationView> createState() => _PresentationViewState();
}

class _PresentationViewState extends State<PresentationView>
    with FullScreenListener, RecordingMixin {
  final Throttler _throttler = Throttler();

  late PageController _pageViewController;
  final List<PresentationSongInfo> _presentationPages = List.empty(
    growable: true,
  );
  PresentationSongInfo? _currentPageInfo;
  int _fontSize = 12;
  String _textScrollMode = 'vertical';
  late List<Song> songs;
  int _allSongsCount = 0;

  bool _isInitialized = false;

  AudioPlayer? _audioPlayer;
  String? _lastSongId;
  bool _isPlayerLoading = false;
  bool _showRecordingPanel = false;

  @override
  void initState() {
    songs = context.read<PresentationBloc>().state.songs;
    _allSongsCount = songs.length;
    _pageViewController = PageController();
    FullScreenHelper.instance.addListener(this);
    FullScreenHelper.instance.setFullScreen(true);
    WakelockHelper.instance.enable();
    _fontSize = sl<SharedPreferences>().getInt('fontSize') ?? 15;
    _textScrollMode = TextScrollModeHelper.effectiveMode(
      sl<SharedPreferences>().getString('textScrollMode'),
    );

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
    _disposeAudioPlayer();
    cancelRecording();
    FullScreenHelper.instance.removeListener(this);
    FullScreenHelper.instance.setFullScreen(false);
    WakelockHelper.instance.disable();
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
                icon: const Icon(Icons.arrow_back),
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
                      style: const TextStyle(fontSize: 18),
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
                    child: _presentationPages.isNotEmpty
                        ? PageView(
                            controller: _pageViewController,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPageInfo = _presentationPages[index];
                              });
                              _onSongChanged();
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
                _buildAudioSection(),
              ],
            ),
            bottomNavigationBar: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.first_page),
                  onPressed: _currentPageInfo?.previewSongExist ?? false
                      ? () => _handlePreviousSong(context, true)
                      : null,
                ),
                Visibility(
                  visible: _textScrollMode == 'horizontal',
                  child: Row(
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
                        style: const TextStyle(fontSize: 18),
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
                ),
                IconButton(
                  icon: const Icon(Icons.last_page_sharp),
                  onPressed: _currentPageInfo?.nextSongExist ?? false
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

  void _onSongChanged() {
    if (_currentPageInfo == null) return;
    final songId = _currentPageInfo!.song.uuid;
    if (songId == _lastSongId) return;
    _disposeAudioPlayer();
    _initAudioPlayer(_currentPageInfo!.song);
    _lastSongId = songId;
  }

  Future<void> _initAudioPlayer(Song song) async {
    final sourceUrl = song.audioUrl;
    final sourceFile = song.audioFilePath;

    if (sourceUrl == null && sourceFile == null) return;

    _isPlayerLoading = true;
    if (mounted) setState(() {});

    if (song.audioCachePath != null) {
      final cachedFile = File(song.audioCachePath!);
      if (await cachedFile.exists()) {
        final player = AudioPlayer();
        await player.setAudioSource(AudioSource.file(song.audioCachePath!));
        _audioPlayer?.dispose();
        _audioPlayer = player;
        _isPlayerLoading = false;
        if (mounted) setState(() {});
        return;
      }
    }

    if (sourceFile != null) {
      final fileUri = sourceFile.startsWith('content://')
          ? Uri.parse(sourceFile)
          : Uri.file(sourceFile);
      final player = AudioPlayer();
      await player.setAudioSource(AudioSource.uri(fileUri));
      _audioPlayer?.dispose();
      _audioPlayer = player;
      _isPlayerLoading = false;
      if (mounted) setState(() {});
      return;
    }

    if (sourceUrl != null && _isYoutubeUrl(sourceUrl)) {
      try {
        final yt = YoutubeExplode();
        try {
          final manifest = await yt.videos.streams.getManifest(
            sourceUrl,
            ytClients: [YoutubeApiClient.androidVr],
          );
          final audio = manifest.audioOnly.withHighestBitrate();
          final player = AudioPlayer();
          await player.setAudioSource(AudioSource.uri(audio.url));
          _audioPlayer?.dispose();
          _audioPlayer = player;
          _isPlayerLoading = false;
          if (mounted) setState(() {});
          return;
        } finally {
          yt.close();
        }
      } catch (e) {
        _isPlayerLoading = false;
        if (mounted) {
          UIHelper.showErrorSnackBar(
            context,
            AppLocalizations.of(context)!.errorWithMessage(
              AppLocalizations.of(context)!.cannotPlayAudioFromSavedLink,
            ),
          );
        }
        return;
      }
    }

    if (sourceUrl != null) {
      final player = AudioPlayer();
      await player.setAudioSource(AudioSource.uri(Uri.parse(sourceUrl)));
      _audioPlayer?.dispose();
      _audioPlayer = player;
      _isPlayerLoading = false;
      if (mounted) setState(() {});
    }
  }

  void _disposeAudioPlayer() {
    _audioPlayer?.stop();
    _audioPlayer?.dispose();
    _audioPlayer = null;
    _isPlayerLoading = false;
  }

  bool _isYoutubeUrl(String url) {
    return url.contains('youtube.com/watch') ||
        url.contains('youtu.be/') ||
        url.contains('m.youtube.com');
  }

  Widget _buildAudioSection() {
    if (_currentPageInfo == null) return const SizedBox(height: 48);

    final song = _currentPageInfo!.song;
    final hasAudio = song.audioUrl != null || song.audioFilePath != null;
    final loc = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: hasAudio
          ? MainAxisAlignment.start
          : MainAxisAlignment.end,
      children: [
        if (hasAudio)
          Expanded(
            child: _audioPlayer != null
                ? AudioPlayerBar(player: _audioPlayer!)
                : _isPlayerLoading
                ? Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 8),
                        Text(loc.playerLoading),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        IconButton(
          icon: const Icon(Icons.mic, size: 28),
          onPressed: () =>
              setState(() => _showRecordingPanel = !_showRecordingPanel),
          tooltip: loc.recordings,
        ),
        if (_showRecordingPanel) ...[
          IconButton(
            icon: Icon(
              isRecording
                  ? Icons.stop_circle_outlined
                  : Icons.fiber_manual_record,
              color: Colors.red,
            ),
            onPressed: isRecording
                ? () => stopRecording(song.uuid)
                : () => startRecording(song.uuid),
            tooltip: isRecording ? loc.stopRecording : loc.record,
          ),
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => RecordingsDialog(songUuid: song.uuid),
            ),
            tooltip: loc.recordingsList,
          ),
        ],
      ],
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
      final modelToSend = SendToClientModel(
        text: _currentPageInfo!.pageText,
        title: _currentPageInfo!.title,
      ).toJson();

      context.read<ServerCubit>().send(jsonEncode(modelToSend));
    }
  }

  void _setPages(BuildContext context, BoxConstraints constraints) {
    _presentationPages.clear();
    final totalSongsCount = songs.length;

    if (_textScrollMode == 'vertical') {
      _buildVerticalPages(context, totalSongsCount);
    } else {
      _buildHorizontalPages(context, totalSongsCount, constraints);
    }

    _currentPageInfo = _presentationPages.firstOrNull;
    _sendTextToClients(context);
    _onSongChanged();
  }

  void _buildHorizontalPages(
    BuildContext context,
    int totalSongsCount,
    BoxConstraints constraints,
  ) {
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
        final newPage = Text.rich(
          span,
          style: style,
          textAlign: TextAlign.left,
          locale: Locale(Platform.localeName),
          textScaler: TextScaler.linear(scaledFontSize / _fontSize),
        );

        _presentationPages.add(
          PresentationSongInfo(
            title: title,
            songNumber: songNumber,
            totalSongsCount: totalSongsCount,
            pageIndex: _presentationPages.isNotEmpty
                ? _presentationPages.length
                : 0,
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
          final newPage = Text.rich(
            span,
            style: style,
            textAlign: TextAlign.left,
            locale: Locale(Platform.localeName),
            textScaler: TextScaler.linear(scaledFontSize / _fontSize),
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

            final newPage = Text.rich(
              checkSpan,
              style: style,
              locale: Locale(Platform.localeName),
              textScaler: TextScaler.linear(scaledFontSize / _fontSize),
            );

            _presentationPages.add(
              PresentationSongInfo(
                title: title,
                songNumber: songNumber,
                totalSongsCount: totalSongsCount,
                pageIndex: _presentationPages.isNotEmpty
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
      songInfo.totalPagesCountForSong = _presentationPages
          .where((x) => x.songNumber == songInfo.songNumber)
          .length;
    }
  }

  void _buildVerticalPages(BuildContext context, int totalSongsCount) {
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
          pageIndex: _presentationPages.isNotEmpty
              ? _presentationPages.length
              : 0,
          pageIndexInSongContext: 0,
          totalPagesCountForSong: 1,
          pageWidget: newPage,
          pageText: text,
          song: song,
        ),
      );
    }
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
