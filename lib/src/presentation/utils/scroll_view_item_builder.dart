import 'package:flutter/material.dart';

/// Builder of a widget inside the scroll view representing a single item.
typedef ScrollViewItemBuilder<T> = Widget Function(
  BuildContext context,
  T item,
);
