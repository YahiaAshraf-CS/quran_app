import 'package:quran_app/features/suwar/data/models/get_suwar_model.dart';

enum AudioDownloadStatus { idle, downloading, downloaded, error }

class PlayerState {
  final String server;
  final List<Suwar> suwarList;
  final int currentIndex;
  final bool isPlaying;
  final bool isBuffering;
  final Duration position;
  final Duration duration;
  final AudioDownloadStatus downloadStatus;
  final String? downloadedFilePath;
  final String? errorMessage;

  const PlayerState({
    required this.server,
    required this.suwarList,
    required this.currentIndex,
    this.isPlaying = false,
    this.isBuffering = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.downloadStatus = AudioDownloadStatus.idle,
    this.downloadedFilePath,
    this.errorMessage,
  });

  Suwar? get currentSurah {
    if (suwarList.isEmpty ||
        currentIndex < 0 ||
        currentIndex >= suwarList.length) {
      return null;
    }
    return suwarList[currentIndex];
  }

  bool get hasPrevious => currentIndex > 0;

  bool get hasNext =>
      suwarList.isNotEmpty && currentIndex < suwarList.length - 1;

  PlayerState copyWith({
    String? server,
    List<Suwar>? suwarList,
    int? currentIndex,
    bool? isPlaying,
    bool? isBuffering,
    Duration? position,
    Duration? duration,
    AudioDownloadStatus? downloadStatus,
    String? downloadedFilePath,
    String? errorMessage,
    bool clearError = false,
    bool clearDownloadedPath = false,
  }) {
    return PlayerState(
      server: server ?? this.server,
      suwarList: suwarList ?? this.suwarList,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      downloadStatus: downloadStatus ?? this.downloadStatus,
      downloadedFilePath: clearDownloadedPath
          ? null
          : (downloadedFilePath ?? this.downloadedFilePath),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
