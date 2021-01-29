/// State management for streamed [ProductModel]s.
///
/// This is the version where all the products are received by a single stream
/// with all the updates (i.e the products are not paginated).
// class ProductsStateNotifier
//     extends SingleStreamItemsStateNotifier<ProductModel> {
//   ProductsStateNotifier(
//     Stream<ItemsStateStreamBatch> Function() createStream,
//   ) : super(
//           createStream,
//           ProductsItemsHandler(),
//         );
// }
//
// /// The items are ordered based on the price ascending.
// /// The unique representation of the item is the [ProductModel.uniqueId].
// class ProductsItemsHandler extends ItemsHandler<ProductModel, String> {
//   ProductsItemsHandler()
//       : super(
//           (a, b) => a.price.compareTo(b.price),
//           (a) => a.uniqueId,
//         );
// }
