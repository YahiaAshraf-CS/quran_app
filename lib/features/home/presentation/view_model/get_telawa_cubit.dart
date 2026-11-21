import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_app/core/network/api_result.dart';
import 'package:quran_app/features/home/data/api/get_telawa_api.dart';
import 'package:quran_app/features/home/data/models/get_telawa_model.dart';

import 'get_telawa_state.dart';

class GetTelawaCubit extends Cubit<GetTelawaState> {
  GetTelawaCubit() : super(GetTelawaInitial());

  Future<void> getTelawa() async {
    emit(GetTelawaLoading());

    final result = await GetTelawaApi.getTelawa();

    if (result is ApiSuccess<GetTelawaModel>) {
      emit(GetTelawaLoaded(telawaModel: result.data));
    } else if (result is ApiError) {
      emit(GetTelawaError(result.message));
    }
  }

  void selectMoshaf(Moshaf moshaf) {
    final currentState = state;
    if (currentState is GetTelawaLoaded) {
      emit(
        GetTelawaLoaded(
          telawaModel: currentState.telawaModel,
          selectedMoshaf: moshaf,
        ),
      );
    }
  }
}
