import 'package:flutter/material.dart';
import 'package:hooks_riverpod/all.dart';

import 'src/presentation/my_app.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}
