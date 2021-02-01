import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamed_items_state_management/src/data/change_status.dart';
import 'package:streamed_items_state_management/src/data/items_handler.dart';
import 'package:streamed_items_state_management/src/data/items_state.dart';
import 'package:streamed_items_state_management/src/data/items_state_stream_batch.dart';
import 'package:streamed_items_state_management/src/data/items_stream_handler.dart';
import 'package:tuple/tuple.dart';

class _StreamCreator<T> {
  final Function(StreamController<ItemsStateStreamBatch<T>> streamCtrl)
      onListenCallback;

  _StreamCreator(this.onListenCallback);

  Stream<ItemsStateStreamBatch<T>> createStream() {
    final streamCtrl = StreamController<ItemsStateStreamBatch<T>>();
    streamCtrl.onCancel = () async => await streamCtrl.close();
    // ignore: cascade_invocations
    streamCtrl.onListen = () => onListenCallback(streamCtrl);

    return streamCtrl.stream;
  }
}

void main() {
  test(
    'ItemsStreamHandler basic scenario - stream initial batch, updated state, empty state',
    () {
      final streamCreator = _StreamCreator<Tuple2<String, int>>((streamCtrl) {
        streamCtrl
          ..add(
            ItemsStateStreamBatch(
              [
                Tuple2(ChangeStatus.added, Tuple2('B', 1)),
                Tuple2(ChangeStatus.added, Tuple2('A', 1)),
              ],
            ),
          )
          ..add(
            ItemsStateStreamBatch(
              [
                Tuple2(ChangeStatus.removed, Tuple2('B', 1)),
                Tuple2(ChangeStatus.added, Tuple2('C', 1)),
                Tuple2(ChangeStatus.modified, Tuple2('A', 2)),
              ],
            ),
          )
          ..add(ItemsStateStreamBatch([]));
      });

      final itemsHandler = ItemsHandler<Tuple2<String, int>, String>(
          (a, b) => a.item1.compareTo(b.item1), (a) => a.item1);
      var itemsState = ItemsState<Tuple2<String, int>>.empty();

      var counter = 0;
      void onDataUpdate(
        ItemsState<Tuple2<String, int>> newItemsState, {
        @required bool isInitialStreamBatch,
        @required bool hasError,
      }) {
        itemsState = newItemsState;

        if (counter == 0) {
          expect(newItemsState.items, [
            Tuple2('A', 1),
            Tuple2('B', 1),
          ]);
          expect(newItemsState.isDoneAndEmpty, false);
          expect(itemsState.status, ItemsStateStatus.waiting);
          expect(isInitialStreamBatch, true);
          expect(hasError, false);
        } else if (counter == 1) {
          expect(newItemsState.items, [
            Tuple2('A', 2),
            Tuple2('C', 1),
          ]);
          expect(newItemsState.isDoneAndEmpty, false);
          expect(itemsState.status, ItemsStateStatus.waiting);
          expect(isInitialStreamBatch, false);
          expect(hasError, false);
        } else if (counter == 2) {
          expect(newItemsState.items, [
            Tuple2('A', 2),
            Tuple2('C', 1),
          ]);
          expect(newItemsState.isDoneAndEmpty, false);
          expect(itemsState.status, ItemsStateStatus.allLoaded);
          expect(isInitialStreamBatch, false);
          expect(hasError, false);
        }

        counter++;
      }

      ItemsStreamHandler<Tuple2<String, int>>.listen(
        getCurrentItemsState: () => itemsState,
        itemsHandler: itemsHandler,
        createStream: streamCreator.createStream,
        onItemsStateUpdated: onDataUpdate,
      );

      expect(itemsState.items, []);
      expect(itemsState.isDoneAndEmpty, false);
      expect(itemsState.status, ItemsStateStatus.waiting);
    },
  );

  test(
    'ItemsStreamHandler error recovery',
    () {},
  );
}
