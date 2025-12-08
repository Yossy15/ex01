import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:test_app_ex1/src/service/apiProvider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app_ex1/src/utils/dateUtils.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final TextEditingController controller = TextEditingController();

  void _onRefresh() async {
    try {
      await ref.read(searchArticleListProvider.notifier).refresh();
      _refreshController.refreshCompleted();
    } catch (_) {
      _refreshController.refreshFailed();
    }
  }

  void _onLoading() async {
    try {
      await ref.read(searchArticleListProvider.notifier).loadMore();
      _refreshController.loadComplete();
    } catch (_) {
      _refreshController.loadFailed();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    _refreshController.dispose();
    Future.microtask(() {
      if (mounted) {
        ref.read(searchKeywordProvider.notifier).setSearchKeyword('');
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final search = ref.watch(searchArticleListProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop('homePage');
          },
        ),
        title: Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(50),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        controller.clear();
                        ref
                            .read(searchKeywordProvider.notifier)
                            .setSearchKeyword('');
                        ref.read(searchArticleListProvider.notifier).refresh();
                      },
                    )
                  : null,
              border: InputBorder.none,
              hintText: "ค้นหา",
            ),
            onChanged: (value) {
              ref.read(searchKeywordProvider.notifier).setSearchKeyword(value);
              ref.read(searchArticleListProvider.notifier).refresh();
            },
          ),
        ),
      ),
      body: search.when(
        data: (articles) {
          return SmartRefresher(
            controller: _refreshController,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            enablePullDown: true,
            enablePullUp: true,
            header: const MaterialClassicHeader(),
            footer: CustomFooter(
              builder: (BuildContext context, LoadStatus? mode) {
                Widget body;
                if (mode == LoadStatus.idle) {
                  body = const Text("pull up load");
                } else if (mode == LoadStatus.loading) {
                  body = const CircularProgressIndicator();
                } else if (mode == LoadStatus.failed) {
                  body = const Text("Load Failed!Click retry!");
                } else if (mode == LoadStatus.canLoading) {
                  body = const Text("release to load more");
                } else {
                  body = const Text("No more Data");
                }
                return SizedBox(
                  height: 55.0,
                  child: Center(child: body),
                );
              },
            ),
            child: ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final newsItem = articles[index];
                final publishedDate = newsItem.publishedAt;
                final formattedDate =
                    ThaiDateUtils.formatThaiDate(publishedDate);

                return GestureDetector(
                  onTap: () {
                    context.pushNamed('detailPage', extra: newsItem);
                  },
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildArticleImage(newsItem),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        newsItem.source.name,
                                        style: GoogleFonts.anuphan(
                                          textStyle: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        newsItem.title,
                                        style: GoogleFonts.anuphan(
                                          textStyle: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      if (newsItem.author != null &&
                                          newsItem.author!.isNotEmpty)
                                        CircleAvatar(
                                          radius: 10,
                                          child: Text(
                                            newsItem.author![0].toUpperCase(),
                                            style: GoogleFonts.anuphan(
                                              textStyle: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            if (newsItem.author != null)
                                              Flexible(
                                                child: Text(
                                                  newsItem.author!,
                                                  style: GoogleFonts.anuphan(
                                                    textStyle: const TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            Text(
                                              formattedDate,
                                              style: GoogleFonts.anuphan(
                                                textStyle: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // _inofData(newsItem),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

Widget _buildArticleImage(dynamic newsItem) {
  return Container(
    width: 105,
    decoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: const BorderRadius.all(Radius.circular(5)),
    ),
    child: ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(5)),
      child: newsItem.urlToImage != null && newsItem.urlToImage!.isNotEmpty
          ? Image.network(
              newsItem.urlToImage!,
              fit: BoxFit.cover,
              width: 105,
              errorBuilder: (context, error, stackTrace) => Center(
                child: Icon(
                  Icons.image,
                  color: Colors.grey[600],
                  size: 40,
                ),
              ),
            )
          : Center(
              child: Icon(
                Icons.image,
                color: Colors.grey[600],
                size: 40,
              ),
            ),
    ),
  );
}
