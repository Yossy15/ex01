import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app_ex1/src/service/apiProvider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    Future.microtask(() {
      if (mounted) {
        ref.read(searchKeywordProvider.notifier).setSearchKeyword('');
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final search = ref.watch(searchNewsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.goNamed('homePage');
          },
        ),
        title: TextField(
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
                    },
                  )
                : null,
            border: InputBorder.none,
            hintText: "ค้นหา",
          ),
          onChanged: (value) {
            ref.read(searchKeywordProvider.notifier).setSearchKeyword(value);
          },
        ),
      ),
      body: search.when(
        data: (newsList) {
          return ListView.builder(
            itemCount: newsList.articles.length,
            itemBuilder: (context, index) {
              final newsItem = newsList.articles[index];
              final publishedDate = newsItem.publishedAt;
              const thaiMonthAbbreviations = [
                '', 
                'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
                'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
              ];

              final thaiMonthAbbreviation = thaiMonthAbbreviations[publishedDate.month];
              final formattedDate = '${publishedDate.day} $thaiMonthAbbreviation ${publishedDate.year} ${publishedDate.hour.toString().padLeft(2, '0')}:${publishedDate.minute.toString().padLeft(2, '0')} น.';

              return GestureDetector(
                onTap: () {
                  context.pushNamed('detailPage', extra: newsItem);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _imageData(newsItem),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    newsItem.source.name,
                                    style: 
                                      const TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue,
                                      ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    newsItem.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
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
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
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
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        Text(
                                          formattedDate,
                                          style: const TextStyle(
                                            fontSize: 12,
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

_imageData(newsItem) {
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