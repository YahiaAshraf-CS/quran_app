import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart' as ja;
import 'package:path_provider/path_provider.dart';
import 'package:quran_app/features/suwar/data/models/get_suwar_model.dart';

import 'player_state.dart';

class PlayerCubit extends Cubit<PlayerState> {
  final ja.AudioPlayer _audioPlayer = ja.AudioPlayer();

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<ja.PlayerState>? _playerStateSub;

  PlayerCubit({
    required String server,
    required List<Suwar> suwarList,
    required int initialIndex,
  }) : super(
         PlayerState(
           server: server,
           suwarList: suwarList,
           currentIndex: suwarList.isEmpty
               ? 0
               : initialIndex.clamp(0, suwarList.length - 1),
         ),
       ) {
    _listenToPlayerStreams();
    initAndPlay();
  }

  String buildAudioUrl(int surahId) {
    final cleanServer = state.server.endsWith('/')
        ? state.server
        : '${state.server}/';
    final paddedId = surahId.toString().padLeft(3, '0');
    return '$cleanServer$paddedId.mp3';
  }

  void _listenToPlayerStreams() {
    _positionSub = _audioPlayer.positionStream.listen((pos) {
      if (!isClosed) {
        emit(state.copyWith(position: pos));
      }
    });

    _durationSub = _audioPlayer.durationStream.listen((dur) {
      if (!isClosed && dur != null) {
        emit(state.copyWith(duration: dur));
      }
    });

    _playerStateSub = _audioPlayer.playerStateStream.listen((justAudioState) {
      if (!isClosed) {
        final buffering =
            justAudioState.processingState == ja.ProcessingState.loading ||
            justAudioState.processingState == ja.ProcessingState.buffering;

        emit(
          state.copyWith(
            isPlaying: justAudioState.playing,
            isBuffering: buffering,
          ),
        );

        if (justAudioState.processingState == ja.ProcessingState.completed &&
            state.hasNext) {
          playNext();
        }
      }
    });
  }

  Future<void> initAndPlay() async {
    final surah = state.currentSurah;
    if (surah == null) return;

    final surahId = surah.id ?? (state.currentIndex + 1);
    final url = buildAudioUrl(surahId);

    emit(
      state.copyWith(
        isBuffering: true,
        position: Duration.zero,
        downloadStatus: AudioDownloadStatus.idle,
        clearError: true,
        clearDownloadedPath: true,
      ),
    );

    try {
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isBuffering: false,
            isPlaying: false,
            errorMessage: 'تعذر تشغيل السورة، تأكد من الاتصال بالإنترنت',
          ),
        );
      }
    }
  }

  Future<void> togglePlayPause() async {
    try {
      if (_audioPlayer.playing) {
        await _audioPlayer.pause();
      } else {
        if (_audioPlayer.processingState == ja.ProcessingState.completed) {
          await _audioPlayer.seek(Duration.zero);
        }
        await _audioPlayer.play();
      }
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(errorMessage: 'حدث خطأ أثناء التحكم بالتشغيل'));
      }
    }
  }

  Future<void> seekTo(Duration newPosition) async {
    await _audioPlayer.seek(newPosition);
  }

  Future<void> playNext() async {
    if (!state.hasNext) return;
    emit(state.copyWith(currentIndex: state.currentIndex + 1));
    await initAndPlay();
  }

  Future<void> playPrevious() async {
    if (!state.hasPrevious) return;
    emit(state.copyWith(currentIndex: state.currentIndex - 1));
    await initAndPlay();
  }

  Future<void> playSurahAt(int index) async {
    if (index < 0 || index >= state.suwarList.length) return;
    emit(state.copyWith(currentIndex: index));
    await initAndPlay();
  }

  Future<void> downloadCurrentSurah() async {
    final surah = state.currentSurah;
    if (surah == null) return;

    final surahId = surah.id ?? (state.currentIndex + 1);
    final url = buildAudioUrl(surahId);
    final paddedId = surahId.toString().padLeft(3, '0');

    emit(
      state.copyWith(
        downloadStatus: AudioDownloadStatus.downloading,
        clearError: true,
      ),
    );

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dir = await getApplicationDocumentsDirectory();
        final quranDir = Directory('${dir.path}/quran_downloads');
        if (!await quranDir.exists()) {
          await quranDir.create(recursive: true);
        }

        final file = File('${quranDir.path}/surah_$paddedId.mp3');
        await file.writeAsBytes(response.bodyBytes);

        if (!isClosed) {
          emit(
            state.copyWith(
              downloadStatus: AudioDownloadStatus.downloaded,
              downloadedFilePath: file.path,
            ),
          );
        }
      } else {
        if (!isClosed) {
          emit(
            state.copyWith(
              downloadStatus: AudioDownloadStatus.error,
              errorMessage: 'فشل تحميل السورة من السيرفر',
            ),
          );
        }
      }
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            downloadStatus: AudioDownloadStatus.error,
            errorMessage: 'حدث خطأ أثناء تحميل السورة',
          ),
        );
      }
    }
  }

  @override
  Future<void> close() async {
    await _positionSub?.cancel();
    await _durationSub?.cancel();
    await _playerStateSub?.cancel();
    await _audioPlayer.dispose();
    return super.close();
  }
}
