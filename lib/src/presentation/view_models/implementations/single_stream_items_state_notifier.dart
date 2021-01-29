import 'package:flutter/material.dart';
import 'package:streamed_items_state_management/src/data/items_handler.dart';
import 'package:streamed_items_state_management/src/data/items_state.dart';
import 'package:streamed_items_state_management/src/data/items_state_stream_batch.dart';
import 'package:streamed_items_state_management/src/presentation/view_models/abstraction/streamed_items_state_notifier_base.dart';

/// This is used for managing the items
/// that are received and updated by a single stream.
class SingleStreamItemsStateNotifier<T>
    extends StreamedItemsStateNotifierBase<T> {
  SingleStreamItemsStateNotifier(
    this._createStream,
    ItemsHandler itemsHandler,
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
