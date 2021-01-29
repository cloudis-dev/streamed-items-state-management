import 'package:example/src/presentation/my_app.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/all.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}
