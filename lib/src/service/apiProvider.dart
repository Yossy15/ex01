import 'package:test_app_ex1/src/model/NewsModel.dart';
import 'package:test_app_ex1/src/service/apiConfig.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final newsListProvider = FutureProvider.autoDispose<News>((ref) async {
  return ref.watch(apiServiceProvider).fetchNews();
});

abstract class BaseArticleListNotifier
    extends StateNotifier<AsyncValue<List<Article>>> {
  BaseArticleListNotifier(this.ref) : super(const AsyncLoading()) {
    refresh();
  }

  final Ref ref;

  List<Article> transform(List<Article> articles) => articles;

  Future<void> refresh() async {
    state = const AsyncLoading();
    final api = ref.read(apiServiceProvider);
    api.resetPage();
    try {
      final news = await api.fetchNews();
      state = AsyncData(transform(news.articles));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> loadMore() async {
    final api = ref.read(apiServiceProvider);
    api.nextPage();
    try {
      final news = await api.fetchNews();
      state = state.whenData((current) {
        final appended = [...current, ...news.articles];
        return transform(appended);
      });
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

class ArticleListNotifier extends BaseArticleListNotifier {
  ArticleListNotifier(super.ref);
}

final articleListProvider = StateNotifierProvider.autoDispose<ArticleListNotifier,
    AsyncValue<List<Article>>>((ref) {
  return ArticleListNotifier(ref);
});

class SearchNotifier extends StateNotifier<String> {
  SearchNotifier() : super('');

  void setSearchKeyword(String keyword) {
    state = keyword;
  }
}

final searchKeywordProvider =
    StateNotifierProvider<SearchNotifier, String>((ref) {
  return SearchNotifier();
});

class SearchArticleListNotifier extends BaseArticleListNotifier {
  SearchArticleListNotifier(super.ref);

  List<Article> _filter(List<Article> articles, String keyword) {
    if (keyword.isEmpty) return articles;
    final lowered = keyword.toLowerCase();
    return articles
        .where((article) =>
            article.title.toLowerCase().contains(lowered) ||
            (article.description ?? '').toLowerCase().contains(lowered))
        .toList();
  }

  @override
  List<Article> transform(List<Article> articles) {
    final keyword = ref.read(searchKeywordProvider);
    return _filter(articles, keyword);
  }
}

final searchArticleListProvider =
    StateNotifierProvider.autoDispose<SearchArticleListNotifier,
        AsyncValue<List<Article>>>((ref) {
  return SearchArticleListNotifier(ref);
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