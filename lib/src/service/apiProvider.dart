import 'package:test_app_ex1/src/model/NewsModel.dart';
import 'package:test_app_ex1/src/service/apiConfig.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final newsListProvider = FutureProvider.autoDispose<News>((ref) async {
  return ref.watch(apiServiceProvider).fetchNews();
});

class SearchNotifier extends StateNotifier<String> {
  SearchNotifier() : super('');

  void setSearchKeyword(String keyword) {
    state = keyword;
  }
}

final searchKeywordProvider = StateNotifierProvider.autoDispose<SearchNotifier, String>((ref) {
  return SearchNotifier();
});

final searchNewsProvider = FutureProvider.autoDispose<News>((ref) async {
  final query = ref.watch(searchKeywordProvider);
  final allNews = await ref.watch(apiServiceProvider).fetchNews();

  if (query.isEmpty) {
    return allNews;
  } else {
    final filteredArticles = allNews.articles
        .where((article) =>
            article.title.toLowerCase().contains(query.toLowerCase()) ||
            (article.description != null && article.description!.toLowerCase().contains(query.toLowerCase()))
        )
        .toList();
        
    return News(
      status: allNews.status,
      totalResults: filteredArticles.length,
      articles: filteredArticles,
    );
  }
});

class SourceNotifier extends StateNotifier<String?> {
  SourceNotifier() : super(null);

  void setSelectedSource(String? sourceName) {
    state = sourceName;
  }
}

final selectedSourceNameProvider = StateNotifierProvider.autoDispose<SourceNotifier, String?>((ref) {
  return SourceNotifier();
});