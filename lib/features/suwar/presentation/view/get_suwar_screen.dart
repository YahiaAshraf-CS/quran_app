import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_app/core/constants/app_assets.dart';
import 'package:quran_app/core/themes/app_color.dart';
import 'package:quran_app/features/suwar/data/models/get_suwar_model.dart';
import 'package:quran_app/features/suwar/presentation/view_model/get_suwar_cubit.dart';
import 'package:quran_app/features/suwar/presentation/view_model/get_suwar_state.dart';

class GetSuwarScreen extends StatefulWidget {
  final dynamic selectedMoshaf;

  const GetSuwarScreen({super.key, this.selectedMoshaf});

  @override
  State<GetSuwarScreen> createState() => _GetSuwarScreenState();
}

class _GetSuwarScreenState extends State<GetSuwarScreen> {
  String _buildAudioUrl(String server, int surahId) {
    final cleanServer = server.endsWith('/') ? server : '$server/';
    final paddedId = surahId.toString().padLeft(3, '0');
    return '$cleanServer$paddedId.mp3';
  }

  String? _extractSurahList() {
    try {
      if (widget.selectedMoshaf != null &&
          widget.selectedMoshaf.surahList != null) {
        return widget.selectedMoshaf.surahList.toString();
      }
    } catch (_) {}
    return null;
  }

  String? _extractServer() {
    try {
      if (widget.selectedMoshaf != null &&
          widget.selectedMoshaf.server != null) {
        return widget.selectedMoshaf.server.toString();
      }
    } catch (_) {}
    return null;
  }

  String _extractSubtitle() {
    try {
      if (widget.selectedMoshaf != null &&
          widget.selectedMoshaf.name != null &&
          widget.selectedMoshaf.name.toString().trim().isNotEmpty) {
        return 'اختيار السورة - ${widget.selectedMoshaf.name}';
      }
    } catch (_) {}
    return 'اختيار السورة';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocConsumer<GetSuwarCubit, GetSuwarState>(
          listener: (context, state) {
            if (state is GetSuwarError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.primaryDark,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is GetSuwarLoading || state is GetSuwarInitial) {
              return Column(
                children: [
                  _SuwarHeader(subtitle: _extractSubtitle()),
                  Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              );
            }

            if (state is GetSuwarError) {
              return Column(
                children: [
                  _SuwarHeader(subtitle: _extractSubtitle()),
                  Expanded(
                    child: _SuwarErrorView(
                      message: state.message,
                      onRetry: () {
                        context.read<GetSuwarCubit>().getSuwar(
                          surahList: _extractSurahList(),
                        );
                      },
                    ),
                  ),
                ],
              );
            }

            if (state is GetSuwarLoaded) {
              return Column(
                children: [
                  _SuwarHeader(subtitle: _extractSubtitle()),
                  Expanded(
                    child: state.suwarList.isEmpty
                        ? Center(
                            child: Text(
                              'لا توجد سور متاحة',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                            itemCount: state.suwarList.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final surah = state.suwarList[index];
                              return _SurahCard(
                                surah: surah,
                                onTap: () {
                                  final server = _extractServer();
                                  final surahId = surah.id ?? (index + 1);
                                  final audioUrl = server != null
                                      ? _buildAudioUrl(server, surahId)
                                      : null;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        audioUrl != null
                                            ? 'سورة ${surah.name ?? ''} - جاهز للتشغيل'
                                            : 'تم اختيار سورة ${surah.name ?? ''}',
                                      ),
                                      duration: const Duration(
                                        milliseconds: 900,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
class _SuwarHeader extends StatelessWidget {
  final String subtitle;

  const _SuwarHeader({required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: topPadding + 18,
            bottom: 28,
            left: 20,
            right: 20,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.elliptical(240, 65),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                AppAssets.quranImage,
                height: 120,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
              Text(
                'عبد الباسط عبد الصمد',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textOnPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textOnPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // زرار الرجوع
        PositionedDirectional(
          top: topPadding + 8,
          start: 12,
          child: Material(
            color: Colors.white.withValues(alpha: 0.2),
            shape: const CircleBorder(),
            child: IconButton(
              tooltip: 'رجوع',
              icon: const Icon(Icons.arrow_back_rounded),
              color: AppColors.textOnPrimary,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ),
      ],
    );
  }
}
class _SurahCard extends StatelessWidget {
  final Suwar surah;
  final VoidCallback onTap;

  const _SurahCard({required this.surah, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final surahNumber = surah.id ?? 1;
    final placeType = surah.makkia == 1 ? 'مكية' : 'مدنية';

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$surahNumber',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surah.name ?? '',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$placeType - Sura $surahNumber',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _SuwarErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _SuwarErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 46,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 15),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onRetry,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
