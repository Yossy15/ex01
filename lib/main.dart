import 'package:flutter/material.dart';
import 'package:test_app_ex1/src/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}