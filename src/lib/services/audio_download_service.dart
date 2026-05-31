import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pomocnik_wokalisty/modules/songs/models/song_model.dart';
import 'package:pomocnik_wokalisty/modules/songs/repositories/songs_repository.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class AudioDownloadService {
  AudioDownloadService({SongsRepository? songsRepository})
    : _songsRepository = songsRepository ?? SongsRepository();

  final SongsRepository _songsRepository;

  bool isYoutubeUrl(String url) {
    return url.contains('youtube.com/watch') ||
        url.contains('youtu.be/') ||
        url.contains('m.youtube.com');
  }

  Future<bool> downloadAudio(Song song) async {
    final sourceUrl = song.audioUrl;
    if (sourceUrl == null) return false;

    final dir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${dir.path}/yt_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    final cachePath = '${cacheDir.path}/${song.uuid}.m4a';

    if (isYoutubeUrl(sourceUrl)) {
      await _downloadFromYoutubeExplode(sourceUrl, cachePath);
    } else {
      await _downloadDirectly(sourceUrl, cachePath);
    }

    final updated = song.copyWith(
      audioCachePath: cachePath,
      audioCachedUrl: sourceUrl,
    );
    await _songsRepository.updateSong(updated);
    return true;
  }

  Future<void> _downloadFromYoutubeExplode(String url, String cachePath) async {
    final yt = YoutubeExplode();
    try {
      final manifest = await yt.videos.streams.getManifest(
        url,
        ytClients: [YoutubeApiClient.androidVr],
      );
      final audio = manifest.audioOnly.withHighestBitrate();
      final total = audio.size.totalBytes;

      const chunkSize = 512 * 1024;
      final file = File(cachePath);
      final sink = file.openWrite();
      var offset = 0;

      try {
        while (offset < total) {
          final end = (offset + chunkSize - 1).clamp(0, total - 1);
          final range = 'bytes=$offset-$end';
          final request = http.Request('GET', audio.url);
          request.headers['User-Agent'] =
              'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 '
              '(KHTML, like Gecko) Chrome/131.0.6778.135 Mobile Safari/537.36';
          request.headers['Cookie'] = 'CONSENT=YES+cb';
          request.headers['Range'] = range;

          final response = await http.Client().send(request);
          if (response.statusCode != 206 && response.statusCode != 200) {
            throw Exception(
              'Chunk download failed: HTTP ${response.statusCode}',
            );
          }
          await for (final chunk in response.stream) {
            sink.add(chunk);
          }
          offset = end + 1;
        }
      } finally {
        await sink.flush();
        await sink.close();
      }
    } finally {
      yt.close();
    }
  }

  Future<void> _downloadDirectly(String url, String cachePath) async {
    final client = http.Client();
    try {
      final request = http.Request('GET', Uri.parse(url));
      final response = await client.send(request);
      if (response.statusCode != 200) {
        throw Exception('Download failed: HTTP ${response.statusCode}');
      }
      final file = File(cachePath);
      await response.stream.pipe(file.openWrite());
    } finally {
      client.close();
    }
  }
}
