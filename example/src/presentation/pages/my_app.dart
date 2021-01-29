import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:streamed_items_state_management/src/presentation/slivers/implementations/sliver_paged_list.dart';

import '../../data/product_model.dart';
import '../providers/providers.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

/// Scroll list view with products.
/// The items are updated.
class MyApp extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final itemsState = useProvider(
        allProductsStateProvider.select((value) => value.itemsState));

    return MaterialApp(
      home: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverPagedList<ProductModel>(
              itemsState: itemsState,
              itemBuilder: (context, item) => ListTile(
                title: Text(item.uniqueId),
                subtitle: Text('Price: ${item.price}'),
              ),
              requestData: context.read(allProductsStateProvider).requestData,
            )
          ],
        ),
      ),
    );
  }
}
