import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:streamed_items_state_management/src/data/items_handler.dart';
import 'package:streamed_items_state_management/src/data/items_state.dart';
import 'package:streamed_items_state_management/src/data/items_state_stream_batch.dart';
import 'package:tuple/tuple.dart';

/// Callback used to notify about the [ItemsState] update.
/// The update happens when a stream sends new data.
typedef OnItemsStateUpdated<T> = void Function(
  ItemsState<T> newItemsState, {
  @required bool isInitialStreamBatch,
  @required bool hasError,
});

/// Takes care of the stream handling.
/// Handles the stream subscription, [ItemsState] updates and stream error handling.
class ItemsStreamHandler<T> {
  StreamSubscription<ItemsStateStreamBatch<T>> _streamSubscription;

  /// This is used in case the recovery attempt occurs after the dispose.
  bool _isDisposed = false;

  /// Create the stream and listen to it.
  ///
  /// In case an error occurs when not even a single stream batch has been processed,
  /// then the [ItemsState] update is set to error status.
  ///
  /// All the batches after the initial one are the update batches.
  /// The [ItemsState] status is not changed when an error occurs in the update batches.
  ///
  /// The parameter [streamUpdateFailRecoveryAttemptsCount] sets the number of recovery attempts
  /// in case of an error in the update batches.
  /// When all the recovery attempts fail, the stream is canceled and updates are disabled.
  ItemsStreamHandler.listen({
    @required ItemsState<T> Function() getCurrentItemsState,
    @required ItemsHandler itemsHandler,
    @required Stream<ItemsStateStreamBatch<T>> Function() createStream,
    @required OnItemsStateUpdated onItemsStateUpdated,
    final int streamUpdateFailRecoveryAttemptsCount = 2,
    final int recoveryAttemptDelaySeconds = 5,
  }) {
    var isInitialBatch = true;
    var remainingRecoveryAttempts = streamUpdateFailRecoveryAttemptsCount;

    /// Stream onData handler.
    void onData(ItemsStateStreamBatch<T> batch) {
      final newState = _createUpdatedState(
        getCurrentItemsState(),
        batch.batch,
        itemsHandler,
      );
      onItemsStateUpdated(
        newState,
        isInitialStreamBatch: isInitialBatch,
        hasError: false,
      );
      isInitialBatch = false;
      remainingRecoveryAttempts = streamUpdateFailRecoveryAttemptsCount;
    }

    /// Stream onError handler.
    /// Handles the initial batch errors and also the recovering in update batches.
    void onError(
      dynamic err,
      StreamSubscription<ItemsStateStreamBatch<T>> Function()
          createSubscription,
    ) async {
      if (isInitialBatch) {
        onItemsStateUpdated(
          getCurrentItemsState().copyWith(status: ItemsStateStatus.error),
          isInitialStreamBatch: isInitialBatch,
          hasError: true,
        );
      } else {
        if (remainingRecoveryAttempts <= 0) {
          print(
            '''There was an error when the items stream received updates.
            No more recovery attempts remaining.
            Stream will receive no updates anymore.
            Error: $err''',
          );
          return;
        }

        remainingRecoveryAttempts--;
        await _streamSubscription.cancel();

        print(
          '''There was an error when the items stream received updates.
            Trying to recover in $recoveryAttemptDelaySeconds seconds.
            Recovery attempts remaining $remainingRecoveryAttempts.
            Error: $err''',
        );

        await Future.delayed(
          Duration(seconds: recoveryAttemptDelaySeconds),
        ).then(
          (value) {
            if (_isDisposed) return;
            _streamSubscription = createSubscription();
          },
        );
      }
    }

    StreamSubscription<ItemsStateStreamBatch<T>> createSubscription() {
      return createStream().listen(
        onData,
        onError: (err) => onError(err, createSubscription),
      );
    }

    _streamSubscription = createSubscription();
  }

  Future<void> dispose() async {
    _isDisposed = true;
    return _streamSubscription.cancel();
  }

  ItemsState<T> _createUpdatedState(
    ItemsState<T> currentItemsState,
    List<Tuple2<DocumentChangeType, T>> data,
    ItemsHandler itemsHandler,
  ) {
    if (data == null || data.isEmpty) {
      currentItemsState =
          currentItemsState.copyWith(status: ItemsStateStatus.allLoaded);
    } else {
      final removedItems =
          _getItemsByChangeType(data, DocumentChangeType.removed);
      currentItemsState = currentItemsState.copyWith(
          items:
              itemsHandler.removeItems(currentItemsState.items, removedItems));

      final modifiedItems =
          _getItemsByChangeType(data, DocumentChangeType.modified);
      currentItemsState = currentItemsState.copyWith(
          items:
              itemsHandler.updateItems(currentItemsState.items, modifiedItems));

      final addedItems = _getItemsByChangeType(data, DocumentChangeType.added);
      currentItemsState = currentItemsState.copyWith(
        items: itemsHandler.addItems(currentItemsState.items, addedItems),
      );

      currentItemsState =
          currentItemsState.copyWith(status: ItemsStateStatus.waiting);
    }

    return currentItemsState;
  }

  /// Get items from the payload of the given changeType.
  List<T> _getItemsByChangeType(
    List<Tuple2<DocumentChangeType, T>> data,
    DocumentChangeType changeType,
  ) =>
      data
          .where((element) => element.item1 == changeType)
          .map((e) => e.item2)
          .toList();
}
