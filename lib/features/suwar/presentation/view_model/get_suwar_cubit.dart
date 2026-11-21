import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_app/core/network/api_result.dart';
import 'package:quran_app/features/suwar/data/api/get_suwar_api.dart';
import 'package:quran_app/features/suwar/data/models/get_suwar_model.dart';

import 'get_suwar_state.dart';

class GetSuwarCubit extends Cubit<GetSuwarState> {
  GetSuwarCubit() : super(GetSuwarInitial());

  Future<void> getSuwar({String? surahList}) async {
    emit(GetSuwarLoading());

    final result = await GetSuwarApi.getSuwar();

    if (result is ApiSuccess<GetSuwarModel>) {
      final allSuwar = result.data.suwar ?? [];

      if (surahList != null && surahList.trim().isNotEmpty) {
        final allowedIds = surahList
            .split(',')
            .map((id) => int.tryParse(id.trim()))
            .whereType<int>()
            .toSet();

        final filteredSuwar = allSuwar
            .where((surah) => allowedIds.contains(surah.id))
            .toList();

        emit(GetSuwarLoaded(suwarList: filteredSuwar));
      } else {
        emit(GetSuwarLoaded(suwarList: allSuwar));
      }
    } else if (result is ApiError) {
      emit(GetSuwarError(result.message));
    }
  }
}
