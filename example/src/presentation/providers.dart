import 'package:hooks_riverpod/all.dart';

import '../data/mocked_db_service.dart';
import 'products_state_notifier.dart';

final mockedDbServiceProvider = Provider((_) => MockedDbService());

final allProductsStateProvider =
    ChangeNotifierProvider.autoDispose<ProductsStateNotifier>(
  (ref) {
    final dbService = ref.watch(mockedDbServiceProvider);

    return ProductsStateNotifier(dbService.getAllProductsStream)..requestData();
  },
);
