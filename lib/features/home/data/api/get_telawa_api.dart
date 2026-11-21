import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quran_app/core/constants/api_constant.dart';
import 'package:quran_app/core/network/api_result.dart';
import 'package:quran_app/features/home/data/models/get_telawa_model.dart';

abstract class GetTelawaApi {
  static Future<ApiResult<GetTelawaModel>> getTelawa() async {
    try {
      final url = Uri.parse(
        '${ApiConstantClass.baseUrl}${ApiConstantClass.getTelawa}',
      );
      final response = await http.get(url);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> json =
            jsonDecode(response.body) as Map<String, dynamic>;
        final model = GetTelawaModel.fromJson(json);
        return ApiSuccess<GetTelawaModel>(model);
      } else {
        String errorMessage = 'Something went wrong';
        try {
          final errorJson = jsonDecode(response.body);
          if (errorJson is Map<String, dynamic> &&
              errorJson['message'] != null) {
            errorMessage = errorJson['message'].toString();
          }
        } catch (_) {}
        return ApiError(errorMessage);
      }
    } catch (e) {
      return ApiError(e.toString());
    }
  }
}
