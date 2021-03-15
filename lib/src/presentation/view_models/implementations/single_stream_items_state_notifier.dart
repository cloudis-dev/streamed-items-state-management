import 'package:flutter/material.dart';
import 'package:streamed_items_state_management/src/data/items_handler.dart';
import 'package:streamed_items_state_management/src/data/items_state.dart';
import 'package:streamed_items_state_management/src/data/items_state_stream_batch.dart';
import 'package:streamed_items_state_management/src/presentation/view_models/abstraction/streamed_items_state_notifier_base.dart';

/// This is used for managing the items
/// that are received and updated by a single stream.
///
/// [E] is the item unique selector type.
/// The field's type based on which is the distinction of items preserved.
class SingleStreamItemsStateNotifier<T, E>
    extends StreamedItemsStateNotifierBase<T, E> {
  SingleStreamItemsStateNotifier(
    this._createStream,
    ItemsHandler<T, E> itemsHandler,
  ) : super(itemsHandler);

  final Stream<ItemsStateStreamBatch<T>> Function() _createStream;
  bool _hasRequestedData = false;

  @override
  void requestData() {
    if (_hasRequestedData) {
      print('requestData() multiple times has no effect.');
      return;
    }
    _hasRequestedData = true;

    super.requestData();
  }

  @override
  Stream<ItemsStateStreamBatch<T>> createStream() {
    return _createStream();
  }

  @override
  void onDataUpdate(
    ItemsState<T> newItemsState, {
    @required bool isInitialStreamBatch,
    @required bool hasError,
  }) {
    if (!hasError) {
      newItemsState =
          newItemsState.copyWith(status: ItemsStateStatus.allLoaded);
    }

    super.onDataUpdate(
      newItemsState,
      isInitialStreamBatch: isInitialStreamBatch,
      hasError: hasError,
    );
  }
}
