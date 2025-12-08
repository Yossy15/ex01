import 'package:dio/dio.dart';
import 'package:test_app_ex1/src/config/config.dart' as config;
import 'package:test_app_ex1/src/model/NewsModel.dart';

class ApiService {
  final Dio _dio = Dio();

  Future<News> fetchNews() async {
    final response = await _dio.get(config.url);
      if (response.statusCode == 200) {
        // log((response.data));
        return News.fromJson(response.data);
      } else {
        throw Exception('Fail');
      }
  }
}
