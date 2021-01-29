import 'package:example/src/data/mocked_db_service.dart';
import 'package:example/src/presentation/products_state_notifier.dart';
import 'package:hooks_riverpod/all.dart';

final mockedDbServiceProvider = Provider((_) => MockedDbService());

final allProductsStateProvider = ChangeNotifierProvider.autoDispose<
        ProductsStateNotifier>((_) => null
    // (ref) {
    //   final dbService = ref.watch(mockedDbServiceProvider);
    //
    //   // return ProductsStateNotifier(dbService.getAllProductsStream)..requestData();
    // },
    );
