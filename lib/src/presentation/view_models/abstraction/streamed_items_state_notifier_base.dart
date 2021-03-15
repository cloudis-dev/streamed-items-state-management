import 'package:flutter/foundation.dart';
import 'package:streamed_items_state_management/src/data/items_handler.dart';
import 'package:streamed_items_state_management/src/data/items_state.dart';
import 'package:streamed_items_state_management/src/data/items_state_stream_batch.dart';
import 'package:streamed_items_state_management/src/data/items_stream_handler.dart';

/// [E] is the item unique selector type.
/// The field's type based on which is the distinction of items preserved.
abstract class StreamedItemsStateNotifierBase<T, E> extends ChangeNotifier {
  StreamedItemsStateNotifierBase(this._itemsHandler);

  ItemsState<T> _itemsState = ItemsState.empty();

  @protected
  set itemsState(ItemsState<T> value) => _itemsState = value;
  ItemsState<T> get itemsState => _itemsState;

  final ItemsHandler<T, E> _itemsHandler;

  final List<ItemsStreamHandler<T, E>> _handlersList = [];

  @protected
  Stream<ItemsStateStreamBatch<T>> createStream();

  /// Request the data.
  @mustCallSuper
  void requestData() {
    if (itemsState.status == ItemsStateStatus.allLoaded) {
      return;
    }

    // This is being processed in a microtask to make it possible to be called in the UI.
    // It is because of the [notifyListeners()] call
    Future.microtask(
      () {
        itemsState = itemsState.copyWith(status: ItemsStateStatus.loading);
        notifyListeners();

        _handlersList.add(
          ItemsStreamHandler.listen(
            getCurrentItemsState: () => itemsState,
            itemsHandler: _itemsHandler,
            createStream: createStream,
            onItemsStateUpdated: onDataUpdate,
          ),
        );
      },
    );
  }

  @override
  void dispose() async {
    super.dispose();
    await Future.wait(_handlersList.map((e) => e.dispose()));
  }

  /// Callback that is called when the current [ItemsState] is updated.
  /// It can be an update of items but also of the status.
  @mustCallSuper
  @protected
  void onDataUpdate(
    ItemsState<T> newItemsState, {
    required bool isInitialStreamBatch,
    required bool hasError,
  }) {
    itemsState = newItemsState;
    notifyListeners();
  }
}
