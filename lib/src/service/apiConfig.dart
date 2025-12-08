import 'package:dio/dio.dart';
import 'package:test_app_ex1/src/config/config.dart' as config;
import 'package:test_app_ex1/src/model/NewsModel.dart';

class ApiService {
  final Dio _dio = Dio();
  int _currentPage = 1;

  Future<News> fetchNews({int? page}) async {
    if (page != null) {
      _currentPage = page;
    }
    final response = await _dio.get('${config.url}&pageSize=10&page=$_currentPage');
    if (response.statusCode == 200) {
      // log((response.data));
      print(_currentPage);
      return News.fromJson(response.data);
    } else {
      throw Exception('Fail');
    }
  }

  void nextPage() {
    _currentPage++;
  }

  void resetPage() {
    _currentPage = 1;
  }
}
