import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app_ex1/src/service/apiProvider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final news = ref.watch(newsListProvider);
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
          return Column(
            children: [
              // Carousel
              SizedBox(
                height: 220,
                child: PageView.builder(
                  itemCount: newsList.articles.length > 5
                      ? 5
                      : newsList.articles.length,
                  itemBuilder: (context, index) {
                    final article = newsList.articles[index];
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
                              child: article.urlToImage != null &&
                                      article.urlToImage!.isNotEmpty
                                  ? Image.network(
                                      article.urlToImage!,
                                      fit: BoxFit.cover,
                                    )
                                  : Center(
                                      child: Icon(
                                        Icons.image,
                                        color: Colors.grey[600],
                                        size: 60,
                                      ),
                                    ),
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
                            Positioned(
                              bottom: 12,
                              left: 12,
                              right: 12,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      article.source.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    article.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
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

              // Category Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    children: [
                      ...newsList.articles.map((article) {
                        if (article.source.name.isNotEmpty) {
                          return _categoryTab(article.source.name, true);
                        }
                        return const SizedBox.shrink();
                      }).toList(),
                    ],
                  ),
                ),
              ),

              // News List
              Expanded(
                child: ListView.builder(
                  itemCount: newsList.articles.length,
                  itemBuilder: (context, index) {
                    final newsItem = newsList.articles[index];
                    final publishedDate = newsItem.publishedAt;
                    const thaiMonthAbbreviations = [
                      '',
                      'ม.ค.',
                      'ก.พ.',
                      'มี.ค.',
                      'เม.ย.',
                      'พ.ค.',
                      'มิ.ย.',
                      'ก.ค.',
                      'ส.ค.',
                      'ก.ย.',
                      'ต.ค.',
                      'พ.ย.',
                      'ธ.ค.'
                    ];

                    final thaiMonthAbbreviation =
                        thaiMonthAbbreviations[publishedDate.month];
                    final formattedDate =
                        '${publishedDate.day} $thaiMonthAbbreviation ${publishedDate.year} ${publishedDate.hour.toString().padLeft(2, '0')}:${publishedDate.minute.toString().padLeft(2, '0')} น.';

                    return GestureDetector(
                      onTap: () {
                        context.pushNamed('detailPage', extra: newsItem);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: newsItem.urlToImage != null &&
                                        newsItem.urlToImage!.isNotEmpty
                                    ? Image.network(
                                        newsItem.urlToImage!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Center(
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
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    newsItem.source.name,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    newsItem.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      if (newsItem.author != null &&
                                          newsItem.author!.isNotEmpty)
                                        Flexible(
                                          child: Text(
                                            newsItem.author!,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      const Spacer(),
                                      Text(
                                        formattedDate,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
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
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _categoryTab(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.deepPurple : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.black,
          fontSize: 13,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
