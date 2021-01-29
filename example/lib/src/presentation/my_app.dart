/// Scroll list view with products.
/// The items are updated.
// class MyApp extends HookWidget {
//   @override
//   Widget build(BuildContext context) {
//     final itemsState = useProvider(
//         allProductsStateProvider.select((value) => value.itemsState));
//
//     return MaterialApp(
//       home: Scaffold(
//         body: CustomScrollView(
//           slivers: [
//             // SliverPagedList<ProductModel>(
//             //   itemsState: itemsState,
//             //   itemBuilder: (context, item) => ListTile(
//             //     title: Text(item.uniqueId),
//             //     subtitle: Text('Price: ${item.price}'),
//             //   ),
//             //   requestData: context.read(allProductsStateProvider).requestData,
//             // )
//           ],
//         ),
//       ),
//     );
//   }
// }
