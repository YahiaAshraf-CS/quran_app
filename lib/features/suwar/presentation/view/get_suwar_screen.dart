import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_app/core/constants/app_assets.dart';
import 'package:quran_app/core/themes/app_color.dart';
import 'package:quran_app/features/sura/presentation/view/player_screen.dart';
import 'package:quran_app/features/sura/presentation/view_model/player_cubit.dart';
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
                  const Expanded(
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
                        ? const Center(
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
                                  if (server == null || server.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'رابط السيرفر غير متاح لهذه التلاوة',
                                        ),
                                        backgroundColor: AppColors.primaryDark,
                                      ),
                                    );
                                    return;
                                  }

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BlocProvider<PlayerCubit>(
                                        create: (_) => PlayerCubit(
                                          server: server,
                                          suwarList: state.suwarList,
                                          initialIndex: index,
                                        ),
                                        child: const PlayerScreen(),
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
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 28,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.elliptical(240, 65)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.textOnPrimary,
                ),
                tooltip: 'اختيار التلاوة',
              ),
              const SizedBox(width: 48),
            ],
          ),
          Image.asset(AppAssets.quranImage, height: 92, fit: BoxFit.contain),
          const SizedBox(height: 10),
          const Text(
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
            style: const TextStyle(
              color: AppColors.textOnPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$surahNumber',
                style: const TextStyle(
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
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$placeType - Sura $surahNumber',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
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
            const Icon(
              Icons.error_outline_rounded,
              size: 46,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
              ),
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
