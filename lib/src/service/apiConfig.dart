import 'package:dio/dio.dart';
import 'package:test_app_ex1/src/config/config.dart' as config;
import 'package:test_app_ex1/src/model/NewsModel.dart';

class ApiService {
  final Dio _dio = Dio();

  Future<News> fetchNews() async {
    try {
      final response = await _dio.get(config.url);
      if (response.statusCode == 200) {
        return News.fromJson(response.data);
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      throw Exception('Failed to load news: $e');
    }
  }
}