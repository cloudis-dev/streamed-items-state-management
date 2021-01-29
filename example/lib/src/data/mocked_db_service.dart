class MockedDbService {
  /// Get all the products stream.
  /// There are 2 mocked products (`A`, `B`).
  /// Every 3 seconds an update of the price of the `A` product is created.
  /// The price is set randomly from 0 to 100.
  // Stream<ItemsStateStreamBatch<ProductModel>> getAllProductsStream() {
  //   final mockedData = [ProductModel('A', 5), ProductModel('B', 6)];
  //
  //   final streamCtrl = StreamController<ItemsStateStreamBatch<ProductModel>>();
  //
  //   streamCtrl.onListen = () {
  //     // Adding the initial batch
  //     streamCtrl.add(
  //       ItemsStateStreamBatch(
  //         mockedData.map((e) => Tuple2(DocumentChangeType.added, e)).toList(),
  //       ),
  //     );
  //   };
  //
  //   // Update the 'A' product's price every 3 seconds to a random number from 0 to 100
  //   final random = Random();
  //   final sub = Stream.periodic(Duration(seconds: 3)).listen(
  //     (event) {
  //       streamCtrl.add(
  //         ItemsStateStreamBatch(
  //           [
  //             Tuple2(
  //               DocumentChangeType.modified,
  //               ProductModel('A', random.nextDouble() * 100),
  //             )
  //           ],
  //         ),
  //       );
  //     },
  //   );
  //
  //   streamCtrl.onCancel = () async {
  //     await streamCtrl.close();
  //     await sub.cancel();
  //   };
  //
  //   return streamCtrl.stream;
  // }
}
