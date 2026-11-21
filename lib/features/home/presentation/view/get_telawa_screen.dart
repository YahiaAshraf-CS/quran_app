import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_app/core/constants/app_assets.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:quran_app/core/routes/app_routes.dart';
import 'package:quran_app/core/themes/app_color.dart';
import 'package:quran_app/features/home/data/models/get_telawa_model.dart';
import 'package:quran_app/features/home/presentation/view_model/get_telawa_cubit.dart';
import 'package:quran_app/features/home/presentation/view_model/get_telawa_state.dart';
import 'package:quran_app/features/suwar/presentation/view_model/get_suwar_cubit.dart';

class GetTelawaScreen extends StatelessWidget {
  const GetTelawaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocConsumer<GetTelawaCubit, GetTelawaState>(
          listener: (context, state) {
            if (state is GetTelawaError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.primaryDark,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is GetTelawaLoading || state is GetTelawaInitial) {
              return Column(
                children: [
                  const _TelawaHeader(
                    reciterName: 'عبد الباسط عبد الصمد',
                    subtitle: 'اختيار التلاوة',
                  ),
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

            if (state is GetTelawaError) {
              return Column(
                children: [
                  const _TelawaHeader(
                    reciterName: 'عبد الباسط عبد الصمد',
                    subtitle: 'اختيار التلاوة',
                  ),
                  Expanded(
                    child: _TelawaErrorView(
                      message: state.message,
                      onRetry: () {
                        context.read<GetTelawaCubit>().getTelawa();
                      },
                    ),
                  ),
                ],
              );
            }

            if (state is GetTelawaLoaded) {
              final reciter = state.telawaModel.reciters?.isNotEmpty == true
                  ? state.telawaModel.reciters!.first
                  : null;
              final reciterName = reciter?.name ?? 'عبد الباسط عبد الصمد';
              final List<Moshaf> moshafList = reciter?.moshaf ?? [];

              return Column(
                children: [
                  _TelawaHeader(
                    reciterName: reciterName,
                    subtitle: 'اختيار التلاوة',
                  ),
                  Expanded(
                    child: moshafList.isEmpty
                        ? Center(
                            child: Text(
                              'لا توجد تلاوات متاحة حالياً',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                            itemCount: moshafList.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final moshaf = moshafList[index];
                              final isSelected =
                                  state.selectedMoshaf?.id == moshaf.id &&
                                  state.selectedMoshaf?.server == moshaf.server;

                              return _TelawaCard(
                                moshaf: moshaf,
                                index: index,
                                isSelected: isSelected,
                                onTap: () {
                                  context.read<GetTelawaCubit>().selectMoshaf(
                                    moshaf,
                                  );
                                  context.read<GetSuwarCubit>().getSuwar(
                                    surahList: moshaf.surahList,
                                  );

                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.getSuwar,
                                    arguments: moshaf,
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

class _TelawaHeader extends StatelessWidget {
  final String reciterName;
  final String subtitle;

  const _TelawaHeader({required this.reciterName, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 18,
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
          Image.asset("assets/images/quran.png", height: 92, fit: BoxFit.contain),
          const SizedBox(height: 10),
          Text(
            reciterName,
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
    );
  }
}

class _TelawaCard extends StatelessWidget {
  final Moshaf moshaf;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const _TelawaCard({
    required this.moshaf,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  IconData _iconForIndex(int idx) {
    switch (idx % 3) {
      
       
      default:
        return FlutterIslamicIcons.mosque;
    }
  }

  @override
  Widget build(BuildContext context) {
    final surahCountText = moshaf.surahTotal != null
        ? 'عدد السور: ${moshaf.surahTotal}'
        : 'تلاوة قرآنية';

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.8 : 1,
          ),
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
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _iconForIndex(index),
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    moshaf.name ?? 'تلاوة بدون اسم',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    surahCountText,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'select',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TelawaErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _TelawaErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 46, color: AppColors.primary),
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
