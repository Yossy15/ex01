import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app_ex1/src/service/apiProvider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app_ex1/src/utils/dateUtils.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  _buildFeaturedArticleImage(article) {
    return article.urlToImage != null && article.urlToImage!.isNotEmpty
        ? Image.network(
            article.urlToImage!,
            fit: BoxFit.cover,
          )
        : Center(child: Icon(Icons.image, color: Colors.grey[600], size: 60));
  }

  void _onRefresh() async {
    await ref.read(newsListProvider.future);
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await ref.read(newsListProvider.future);
    _refreshController.loadComplete();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final news = ref.watch(newsListProvider);
    final selectedSourceName = ref.watch(selectedSourceNameProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset('assets/logo.png', height: 45),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Colors.grey[300],
            ),
            child: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                context.pushNamed('searchPage');
              },
            ),
          )
        ],
      ),
      body: news.when(
        data: (newsList) {
          final uniqueSources = newsList.articles
              .map((article) => article.source.name)
              .where((name) => name.isNotEmpty)
              .toSet()
              .toList()
            ..sort();

          final filteredArticles = selectedSourceName == null
              ? newsList.articles
              : newsList.articles
                  .where((article) => article.source.name == selectedSourceName)
                  .toList();

          return Column(
            children: [
              ..._headText(),
              ..._detailImgScrolll(newsList),
              ..._sourceScroll(uniqueSources, selectedSourceName),
              Expanded(
                child: SmartRefresher(
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
                      return SizedBox(height: 55.0, child: Center(child: body));
                    },
                  ),
                  child: filteredArticles.isEmpty
                      ? Center(
                          child: Text(
                            'ไม่พบข่าวจากแหล่งข่าวนี้',
                            style: GoogleFonts.anuphan(
                              textStyle: const TextStyle(
                                  fontSize: 16, color: Colors.grey),
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredArticles.length,
                          itemBuilder: (context, index) {
                            final newsItem = filteredArticles[index];
                            final formattedDate = ThaiDateUtils.formatThaiDate(
                                newsItem.publishedAt);

                            return GestureDetector(
                              onTap: () {
                                context.pushNamed('detailPage',
                                    extra: newsItem);
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                child: IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _buildArticleImage(newsItem),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                                                      textStyle:
                                                          const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    newsItem.title,
                                                    style: GoogleFonts.anuphan(
                                                      textStyle:
                                                          const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  if (newsItem.author != null &&
                                                      newsItem
                                                          .author!.isNotEmpty)
                                                    CircleAvatar(
                                                      radius: 10,
                                                      child: Text(
                                                        newsItem.author![0]
                                                            .toUpperCase(),
                                                        style:
                                                            GoogleFonts.anuphan(
                                                          textStyle:
                                                              const TextStyle(
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
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        if (newsItem.author !=
                                                            null)
                                                          Flexible(
                                                            child: Text(
                                                              newsItem.author!,
                                                              style: GoogleFonts
                                                                  .anuphan(
                                                                textStyle:
                                                                    const TextStyle(
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        Text(
                                                          formattedDate,
                                                          style: GoogleFonts
                                                              .anuphan(
                                                            textStyle:
                                                                const TextStyle(
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
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  _categoryTab(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.deepPurple : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.anuphan(
          textStyle: TextStyle(
            color: isActive ? Colors.white : Colors.black,
            fontSize: 13,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  _headText() {
    return [
      Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "ข่าวล่าสุด",
              style: GoogleFonts.anuphan(
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }
  
  _detailImgScrolll(newsList) {
    return [
      SizedBox(
                height: 220,
                child: PageView.builder(
                  itemCount: newsList.articles.length > 5
                      ? 5
                      : newsList.articles.length,
                  itemBuilder: (context, index) {
                    final article = newsList.articles[index];
                    final formattedDate =
                        ThaiDateUtils.formatThaiDate(article.publishedAt);
                    return GestureDetector(
                      onTap: () {
                        context.pushNamed('detailPage', extra: article);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[300],
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _buildFeaturedArticleImage(article),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Text(
                                      article.source.name,
                                      style: GoogleFonts.anuphan(
                                        textStyle: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 80),
                                  Text(
                                    article.title,
                                    style: GoogleFonts.anuphan(
                                      textStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      if (article.author != null &&
                                          article.author!.isNotEmpty)
                                        CircleAvatar(
                                          radius: 10,
                                          child: Text(
                                            article.author![0].toUpperCase(),
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
                                            if (article.author != null)
                                              Flexible(
                                                child: Text(
                                                  article.author!,
                                                  style: GoogleFonts.anuphan(
                                                    textStyle: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.white),
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
                                                    color: Colors.white),
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
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
    ];
  }
  
  _sourceScroll(uniqueSources, selectedSourceName) {
    return [
      SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          ref
                              .read(selectedSourceNameProvider.notifier)
                              .setSelectedSource(null);
                        },
                        child:
                            _categoryTab('ทั้งหมด', selectedSourceName == null),
                      ),
                      const SizedBox(width: 8),
                      ...uniqueSources.map((sourceName) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {
                              ref
                                  .read(selectedSourceNameProvider.notifier)
                                  .setSelectedSource(sourceName);
                            },
                            child: _categoryTab(
                                sourceName, selectedSourceName == sourceName),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
    ];
  }
}

_buildArticleImage(newsItem) {
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
