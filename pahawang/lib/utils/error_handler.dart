import 'package:dio/dio.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      final response = error.response;
      if (response != null && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final message = data['message'];
          if (message is List) {
            return message.join(', ');
          } else if (message != null) {
            return message.toString();
          }
          final err = data['error'];
          if (err != null) {
            return err.toString();
          }
        }
      }
      return error.message ?? 'Terjadi kesalahan koneksi internet.';
    }
    return error.toString().replaceAll('Exception: ', '');
  }
}
