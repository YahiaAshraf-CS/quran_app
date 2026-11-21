import 'package:quran_app/features/home/data/models/get_telawa_model.dart';

abstract class GetTelawaState {}

class GetTelawaInitial extends GetTelawaState {}

class GetTelawaLoading extends GetTelawaState {}

class GetTelawaLoaded extends GetTelawaState {
  final GetTelawaModel telawaModel;
  final Moshaf? selectedMoshaf;

  GetTelawaLoaded({required this.telawaModel, this.selectedMoshaf});
}

class GetTelawaError extends GetTelawaState {
  final String message;

  GetTelawaError(this.message);
}
