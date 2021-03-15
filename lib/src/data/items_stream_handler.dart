import 'dart:async';

import 'package:flutter/material.dart';
import 'package:streamed_items_state_management/src/data/change_status.dart';
import 'package:streamed_items_state_management/src/data/items_handler.dart';
import 'package:streamed_items_state_management/src/data/items_state.dart';
import 'package:streamed_items_state_management/src/data/items_state_stream_batch.dart';
import 'package:tuple/tuple.dart';

class CreateStreamMustCreateNewInstanceException implements Exception {
  final String message;
  CreateStreamMustCreateNewInstanceException(
      {this.message = 'createStream method have to create a new stream!'})
      : super();

  @override
  String toString() {
    return 'CreateStreamMustCreateNewInstanceException{message: $message}';
  }
}

/// Callback used to notify about the [ItemsState] update.
/// The update happens when a stream sends new data.
typedef OnItemsStateUpdated<T> = void Function(
  ItemsState<T> newItemsState, {
  @required bool isInitialStreamBatch,
  @required bool hasError,
});

/// Takes care of the stream handling.
/// Handles the stream subscription, [ItemsState] updates and stream error handling.
///
/// [E] is the item unique selector type.
/// The field's type based on which is the distinction of items preserved.
class ItemsStreamHandler<T, E> {
  StreamSubscription<ItemsStateStreamBatch<T>> _streamSubscription;
  Stream<ItemsStateStreamBatch<T>> _lastStream;

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
    @required ItemsHandler<T, E> itemsHandler,
    @required Stream<ItemsStateStreamBatch<T>> Function() createStream,
    @required OnItemsStateUpdated<T> onItemsStateUpdated,
    final int streamUpdateFailRecoveryAttemptsCount = 2,
    final int recoveryAttemptDelaySeconds = 5,
  }) {
    var isInitialBatch = true;
    var remainingRecoveryAttempts = streamUpdateFailRecoveryAttemptsCount;

    /// Stream onData handler.
    /// [shouldReplaceState] parameter is used in case the new data
    /// should replace the current state.
    ///
    /// It is in the case when an update error recovery succeeds.
    /// The new stream's initial batch has the last version of the items,
    /// so there is no need to update the current state (also there are cases where this is incorrect).
    /// Replacement is needed in this case.
    void onData(
      ItemsStateStreamBatch<T> batch, {
      @required bool shouldReplaceState,
    }) {
      final newState = shouldReplaceState
          ? _createUpdatedState(
              ItemsState<T>.empty(),
              batch.batch,
              itemsHandler,
            )
          : _createUpdatedState(
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
      dynamic stacktrace,
      StreamSubscription<ItemsStateStreamBatch<T>> Function(
              bool shouldReplaceState)
          createSubscription,
    ) async {
      if (isInitialBatch) {
        print('''An error occured when fetching the initial items batch. 
            Error: $err.
            Stacktrace: $stacktrace
            ''');

        onItemsStateUpdated(
          getCurrentItemsState().copyWith(status: ItemsStateStatus.error),
          isInitialStreamBatch: isInitialBatch,
          hasError: true,
        );
      } else {
        if (remainingRecoveryAttempts <= 0) {
          try {
            try {
              print(
                  '''There was an error when the items stream received updates.
                No more recovery attempts remaining.
                Stream will receive no updates anymore.
                Error: $err
                Stacktrace: $stacktrace
                ''');
            } catch (e, s) {
              print(s);
            }
          } catch (e, s) {
            print(s);
          }
          return;
        }

        remainingRecoveryAttempts--;
        await _streamSubscription.cancel();

        print(
          '''There was an error when the items stream received updates.
            Trying to recover in $recoveryAttemptDelaySeconds seconds.
            Recovery attempts remaining $remainingRecoveryAttempts.
            Error: $err
            Stacktrace: $stacktrace
            ''',
        );

        await Future.delayed(
          Duration(seconds: recoveryAttemptDelaySeconds),
        ).then(
          (value) {
            if (_isDisposed) return;
            _streamSubscription = createSubscription(true);
          },
        );
      }
    }

    StreamSubscription<ItemsStateStreamBatch<T>> createSubscription(
      // ignore: avoid_positional_boolean_parameters
      bool shouldReplaceState,
    ) {
      final stream = createStream();
      if (_lastStream != null && identical(stream, _lastStream)) {
        throw CreateStreamMustCreateNewInstanceException();
      }

      _lastStream = stream;
      return stream.listen(
        (data) {
          onData(data, shouldReplaceState: shouldReplaceState);
          shouldReplaceState = false;
        },
        onError: (err, stacktrace) =>
            onError(err, stacktrace, createSubscription),
      );
    }

    _streamSubscription = createSubscription(false);
  }

  Future<void> dispose() async {
    _isDisposed = true;
    return _streamSubscription.cancel();
  }

  /// Process the incomming data with current [ItemsState]
  /// and return the updated [ItemsState].
  ItemsState<T> _createUpdatedState(
    ItemsState<T> currentItemsState,
    List<Tuple2<ChangeStatus, T>> data,
    ItemsHandler<T, E> itemsHandler,
  ) {
    if (data == null || data.isEmpty) {
      currentItemsState =
          currentItemsState.copyWith(status: ItemsStateStatus.allLoaded);
    } else {
      final removedItems = _getItemsByChangeType(data, ChangeStatus.removed);
      currentItemsState = currentItemsState.copyWith(
          items:
              itemsHandler.removeItems(currentItemsState.items, removedItems));

      final modifiedItems = _getItemsByChangeType(data, ChangeStatus.modified);
      currentItemsState = currentItemsState.copyWith(
          items:
              itemsHandler.updateItems(currentItemsState.items, modifiedItems));

      final addedItems = _getItemsByChangeType(data, ChangeStatus.added);
      currentItemsState = currentItemsState.copyWith(
        items: itemsHandler.addItems(currentItemsState.items, addedItems),
      );

      currentItemsState =
          currentItemsState.copyWith(status: ItemsStateStatus.waiting);
    }

    return currentItemsState;
  }

  /// Get items from the batch of the given changeType.
  List<T> _getItemsByChangeType(
    List<Tuple2<ChangeStatus, T>> data,
    ChangeStatus changeType,
  ) =>
      data
          .where((element) => element.item1 == changeType)
          .map((e) => e.item2)
          .toList();
}
