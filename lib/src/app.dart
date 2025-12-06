import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app_ex1/src/model/NewsModel.dart';
import 'package:test_app_ex1/src/page/detail/DetailPage.dart';
import 'package:test_app_ex1/src/page/home/HomePage.dart';
import 'package:test_app_ex1/src/page/search/SearchPage.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/homePage',
  routes: <RouteBase>[
    GoRoute(
      name: 'homePage',
      path: '/homePage',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      name: 'searchPage',
      path: '/searchPage',
      builder: (context, state) => const SearchPage(),
    ),
    GoRoute(
      name: 'detailPage',
      path: '/detailPage',
      builder: (context, state) {
        final article = state.extra as Article;
        return DetailPage(article: article);
      },
    ),
  ],
);