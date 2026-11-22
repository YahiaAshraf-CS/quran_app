import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_app/core/constants/app_assets.dart';
import 'package:quran_app/core/themes/app_color.dart';
 
import 'package:quran_app/features/sura/presentation/view_model/player_cubit.dart';
import 'package:quran_app/features/sura/presentation/view_model/player_state.dart' as app_player;

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  String _formatDuration(Duration d) {
    final totalSeconds = d.inSeconds < 0 ? 0 : d.inSeconds;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _openSurahListSheet(BuildContext context, app_player.PlayerState state) {
    final playerCubit = context.read<PlayerCubit>();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'اختر سورة للتشغيل',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Divider(color: AppColors.border, height: 1),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: state.suwarList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final surah = state.suwarList[index];
                      final isCurrent = index == state.currentIndex;
                      final surahNumber = surah.id ?? (index + 1);

                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: isCurrent
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                        ),
                        tileColor: isCurrent
                            ? AppColors.primaryLight
                            : AppColors.surface,
                        leading: CircleAvatar(
                          backgroundColor: isCurrent
                              ? AppColors.primary
                              : AppColors.primaryLight,
                          child: Text(
                            '$surahNumber',
                            style: TextStyle(
                              color: isCurrent
                                  ? AppColors.textOnPrimary
                                  : AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          surah.name ?? '',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Sura $surahNumber',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        trailing: Icon(
                          isCurrent
                              ? Icons.graphic_eq_rounded
                              : Icons.play_arrow_rounded,
                          color: AppColors.primary,
                        ),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          playerCubit.playSurahAt(index);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<PlayerCubit, app_player.PlayerState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.primaryDark,
              ),
            );
          } else if (state.downloadStatus ==
              app_player.AudioDownloadStatus.downloaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('تم تحميل السورة على الجهاز بنجاح'),
                backgroundColor: AppColors.primaryDark,
              ),
            );
          }
        },
        builder: (context, state) {
          final currentSurah = state.currentSurah;
          final surahName = currentSurah?.name ?? 'سورة';
          final surahNumber = currentSurah?.id ?? (state.currentIndex + 1);

          final totalMs = state.duration.inMilliseconds;
          final currentMs = state.position.inMilliseconds.clamp(
            0,
            totalMs > 0 ? totalMs : 1,
          );
          final progress = totalMs > 0 ? (currentMs / totalMs) : 0.0;

          return Column(
            children: [
              // الهيدر العلوي الدائري من الأسفل مع زر الرجوع وقائمة السور
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 10,
                  bottom: 34,
                  left: 16,
                  right: 16,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.headerGradient,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.elliptical(230, 110),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // أوبشن 4: الرجوع لصفحة السور
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.textOnPrimary,
                          ),
                          tooltip: 'الرجوع للسور',
                        ),
                        Text(
                          'Now Playing',
                          style: TextStyle(
                            color: AppColors.textOnPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // أوبشن 5: فتح قائمة السور السريعة
                        IconButton(
                          onPressed: () => _openSurahListSheet(context, state),
                          icon: Icon(
                            Icons.queue_music_rounded,
                            color: AppColors.textOnPrimary,
                            size: 26,
                          ),
                          tooltip: 'قائمة السور',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Image.asset(
                      AppAssets.quranImage,
                      height: 155,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // اسم السورة ورقمها
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Text(
                      surahName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sura $surahNumber',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // شريط الموجات الصوتية والوقت الحالي والكلي
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  children: [
                    Text(
                      _formatDuration(state.position),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _WaveformProgressBar(
                        progress: progress.clamp(0.0, 1.0),
                        onSeekFraction: (fraction) {
                          if (state.duration > Duration.zero) {
                            final targetMs =
                                (state.duration.inMilliseconds * fraction)
                                    .round();
                            context.read<PlayerCubit>().seekTo(
                              Duration(milliseconds: targetMs),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _formatDuration(state.duration),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // أزرار التحكم: تحميل - سابق - تشغيل/إيقاف - تالي - قائمة السور
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // أوبشن 3: تحميل السورة
                    state.downloadStatus ==
                            app_player.AudioDownloadStatus.downloading
                        ? SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: AppColors.primary,
                            ),
                          )
                        : IconButton(
                            onPressed: () => context
                                .read<PlayerCubit>()
                                .downloadCurrentSurah(),
                            icon: Icon(
                              state.downloadStatus ==
                                      app_player.AudioDownloadStatus.downloaded
                                  ? Icons.cloud_done_rounded
                                  : Icons.cloud_download_outlined,
                              color:
                                  state.downloadStatus ==
                                      app_player.AudioDownloadStatus.downloaded
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              size: 28,
                            ),
                            tooltip: 'تحميل السورة',
                          ),

                    // أوبشن 2: السورة السابقة
                    IconButton(
                      onPressed: state.hasPrevious
                          ? () => context.read<PlayerCubit>().playPrevious()
                          : null,
                      icon: Icon(
                        Icons.skip_previous_rounded,
                        size: 34,
                        color: state.hasPrevious
                            ? AppColors.textSecondary
                            : AppColors.inactiveTrack,
                      ),
                      tooltip: 'السورة السابقة',
                    ),

                    // أوبشن 1: تشغيل / إيقاف مؤقت
                    GestureDetector(
                      onTap: () =>
                          context.read<PlayerCubit>().togglePlayPause(),
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: state.isBuffering
                            ? Padding(
                                padding: const EdgeInsets.all(20),
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: AppColors.textOnPrimary,
                                ),
                              )
                            : Icon(
                                state.isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: AppColors.textOnPrimary,
                                size: 38,
                              ),
                      ),
                    ),

                    // أوبشن 2: السورة التالية
                    IconButton(
                      onPressed: state.hasNext
                          ? () => context.read<PlayerCubit>().playNext()
                          : null,
                      icon: Icon(
                        Icons.skip_next_rounded,
                        size: 34,
                        color: state.hasNext
                            ? AppColors.textSecondary
                            : AppColors.inactiveTrack,
                      ),
                      tooltip: 'السورة التالية',
                    ),

                    // أوبشن 5: فتح قائمة السور السريعة
                    IconButton(
                      onPressed: () => _openSurahListSheet(context, state),
                      icon: Icon(
                        Icons.format_list_bulleted_rounded,
                        color: AppColors.textSecondary,
                        size: 28,
                      ),
                      tooltip: 'قائمة السور',
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),
            ],
          );
        },
      ),
    );
  }
}

class _WaveformProgressBar extends StatelessWidget {
  final double progress;
  final ValueChanged<double> onSeekFraction;

  const _WaveformProgressBar({
    required this.progress,
    required this.onSeekFraction,
  });

  static const List<double> _heightsFactor = [
    0.35,
    0.55,
    0.45,
    0.75,
    0.60,
    0.90,
    0.50,
    0.80,
    0.40,
    0.70,
    0.95,
    0.65,
    0.50,
    0.85,
    0.45,
    0.75,
    1.00,
    0.60,
    0.85,
    0.55,
    0.70,
    0.90,
    0.45,
    0.65,
    0.80,
    0.50,
    0.75,
    0.60,
    0.45,
    0.70,
    0.55,
    0.40,
    0.65,
    0.50,
    0.35,
    0.60,
    0.45,
    0.30,
  ];

  void _handleTouch(BuildContext context, Offset localPosition) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || box.size.width <= 0) return;
    final fraction = (localPosition.dx / box.size.width).clamp(0.0, 1.0);
    onSeekFraction(fraction);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (details) => _handleTouch(context, details.localPosition),
      onHorizontalDragUpdate: (details) =>
          _handleTouch(context, details.localPosition),
      child: SizedBox(
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(_heightsFactor.length, (i) {
            final barFraction = i / (_heightsFactor.length - 1);
            final isActive = barFraction <= progress;
            final barHeight = (34 * _heightsFactor[i]).clamp(8.0, 34.0);

            return Container(
              width: 3,
              height: barHeight,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.inactiveTrack,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ),
    );
  }
}
