import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:test_app_ex1/src/model/NewsModel.dart';
import 'package:test_app_ex1/src/utils/dateUtils.dart';

class DetailPage extends ConsumerStatefulWidget {
  final Article article;

  const DetailPage({super.key, required this.article});

  @override
  ConsumerState<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends ConsumerState<DetailPage> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;
    final formattedDate = ThaiDateUtils.formatThaiDate(article.publishedAt);

    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          context.pop();
        },
      )),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        enablePullUp: false,
        enablePullDown: true,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton(
                          onPressed: () => {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                          ),
                          child: Text(
                            article.source.name,
                            style: GoogleFonts.anuphan(
                              textStyle: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article.title,
                      style: GoogleFonts.anuphan(
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (article.urlToImage != null &&
                        article.urlToImage!.isNotEmpty)
                      Container(
                        width: double.infinity,
                        height: 250,
                        color: Colors.grey[300],
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          child: article.urlToImage != null &&
                                  article.urlToImage!.isNotEmpty
                              ? Image.network(
                                  article.urlToImage!,
                                  fit: BoxFit.cover,
                                  width: 105,
                                  errorBuilder: (context, error, stackTrace) =>
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
                    const SizedBox(height: 16),
                    if (article.description != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description',
                            style: GoogleFonts.anuphan(
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            article.description!,
                            style: GoogleFonts.anuphan(
                              textStyle: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    if (article.content != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Content',
                            style: GoogleFonts.anuphan(
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            article.content!,
                            style: GoogleFonts.anuphan(
                              textStyle: const TextStyle(
                                fontSize: 15,
                                height: 1.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    Row(
                      children: [
                        if (article.author != null &&
                            article.author!.isNotEmpty)
                          CircleAvatar(
                            radius: 16,
                            child: Text(article.author![0].toUpperCase()),
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (article.author != null &&
                                  article.author!.isNotEmpty)
                                Text(
                                  article.author!,
                                  style: GoogleFonts.anuphan(
                                    textStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              Text(
                                formattedDate,
                                style: GoogleFonts.anuphan(
                                  textStyle: const TextStyle(
                                    fontSize: 12,
                                    // color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
