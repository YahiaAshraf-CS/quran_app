import 'package:quran_app/features/suwar/data/models/get_suwar_model.dart';

abstract class GetSuwarState {}

class GetSuwarInitial extends GetSuwarState {}

class GetSuwarLoading extends GetSuwarState {}

class GetSuwarLoaded extends GetSuwarState {
  final List<Suwar> suwarList;

  GetSuwarLoaded({required this.suwarList});
}

class GetSuwarError extends GetSuwarState {
  final String message;

  GetSuwarError(this.message);
}
