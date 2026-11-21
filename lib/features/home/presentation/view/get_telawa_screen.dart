import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_app/features/home/data/models/get_telawa_model.dart';
import 'package:quran_app/features/home/presentation/view_model/get_telawa_cubit.dart';
import 'package:quran_app/features/home/presentation/view_model/get_telawa_state.dart';



class GetTelawaScreen extends StatelessWidget {
  const GetTelawaScreen({super.key});

  // ألوان متناسقة مع ذوقك (أوف وايت، كحلي، ولمسات عنبرية/ورمية هادية)
  static const Color _bgColor = Color(0xFFF8F9FA);
  static const Color _navyColor = Color(0xFF161D23);
  static const Color _accentColor = Color(0xFFD97706);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bgColor,
        appBar: AppBar(
          backgroundColor: _bgColor,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'تلاوات الشيخ عبد الباسط',
            style: TextStyle(
              color: _navyColor,
              fontWeight: FontWeight.bold,
              fontSize: 19,
            ),
          ),
        ),
        body: BlocConsumer<GetTelawaCubit, GetTelawaState>(
          listener: (context, state) {
            // لو حابب تعمل حاجة لحظية عند حدوث خطأ مثلاً
            if (state is GetTelawaError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is GetTelawaLoading || state is GetTelawaInitial) {
              return const Center(
                child: CircularProgressIndicator(color: _accentColor),
              );
            }

            if (state is GetTelawaError) {
              return _ErrorView(
                message: state.message,
                onRetry: () {
                  context.read<GetTelawaCubit>().getTelawa();
                },
              );
            }

            if (state is GetTelawaLoaded) {
              // بنستخرج قائمة المصاحف الخاصة بالشيخ من الموديل[cite: 1]
              final reciter = state.telawaModel.reciters?.isNotEmpty == true
                  ? state.telawaModel.reciters!.first
                  : null;
              final List<Moshaf> moshafList = reciter?.moshaf ?? [];

              if (moshafList.isEmpty) {
                return const Center(
                  child: Text(
                    'لا توجد تلاوات متاحة حالياً',
                    style: TextStyle(color: _navyColor, fontSize: 16),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reciter?.name ?? 'الشيخ عبد الباسط عبد الصمد',
                      style: const TextStyle(
                        color: _navyColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'اختر الرواية أو نوع التلاوة للانتقال إلى السور',
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      child: ListView.separated(
                        itemCount: moshafList.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final moshaf = moshafList[index];
                          final isSelected =
                              state.selectedMoshaf?.id == moshaf.id &&
                              state.selectedMoshaf?.server == moshaf.server;

                          return _TelawaCard(
                            moshaf: moshaf,
                            isSelected: isSelected,
                            onTap: () {
                              // 1. بنخزن التلاوة المختارة (بكل بياناتها ومنها server و surahList) جوه الكيوبيد[cite: 1]
                              context.read<GetTelawaCubit>().selectMoshaf(
                                moshaf,
                              );

                              // 2. هنا بننتقل لشاشة السور ونمرر السيرفر/المصحف المختار[cite: 1]
                              // مثال (بدله باسم شاشة السور الفعلية عندك):
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (_) => SuwarScreen(selectedMoshaf: moshaf),
                              //   ),
                              // );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _TelawaCard extends StatelessWidget {
  final Moshaf moshaf;
  final bool isSelected;
  final VoidCallback onTap;

  const _TelawaCard({
    required this.moshaf,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final surahCount = moshaf.surahTotal ?? 114;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? GetTelawaScreen._accentColor
                : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: GetTelawaScreen._navyColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.headphones_rounded,
                color: GetTelawaScreen._accentColor,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    moshaf.name ?? 'تلاوة بدون اسم',
                    style: const TextStyle(
                      color: GetTelawaScreen._navyColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'عدد السور: $surahCount',
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: GetTelawaScreen._navyColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color: GetTelawaScreen._accentColor,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: GetTelawaScreen._navyColor,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: GetTelawaScreen._navyColor,
                foregroundColor: Colors.white,
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
