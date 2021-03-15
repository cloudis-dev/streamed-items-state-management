import 'package:flutter/material.dart';
import 'package:streamed_items_state_management/src/data/change_status.dart';
import 'package:streamed_items_state_management/src/data/items_handler.dart';
import 'package:streamed_items_state_management/src/data/items_state.dart';
import 'package:streamed_items_state_management/src/data/items_state_stream_batch.dart';
import 'package:streamed_items_state_management/src/presentation/slivers/abstraction/paged_scroll_view_base.dart';
import 'package:streamed_items_state_management/src/presentation/view_models/abstraction/streamed_items_state_notifier_base.dart';
import 'package:tuple/tuple.dart';

/// Representation of a batch received by a stream that can be paginated.
class PagedItemsStateStreamBatch<T, E> {
  final List<Tuple3<ChangeStatus, E, T>> batch;

  PagedItemsStateStreamBatch(this.batch);
}

/// This is used for paginated scroll views.
///
/// [E] is the paging parameter type.
/// E.g it can be [int] representing the last fetched page index.
///
/// [Q] is the item unique selector type.
/// The field's type based on which is the distinction of items preserved.
///
/// The proposed usage is with any [PagedScrollViewBase] instance.
class PagedStreamsItemsStateNotifier<T, E, Q>
    extends StreamedItemsStateNotifierBase<T, Q> {
  PagedStreamsItemsStateNotifier(
    this._createStream,
    ItemsHandler<T, Q> itemsHandler,
  ) : super(itemsHandler);

  final Stream<PagedItemsStateStreamBatch<T, E>> Function(E fromPageKey)
      _createStream;

  bool _isFetchingPage = false;
  E _pageKeyCurrentlyBeingFetched;
  E _lastFetchedPageKey;

  @override
  void requestData() {
    if (_isFetchingPage) return;
    _isFetchingPage = true;

    super.requestData();
  }

  @override
  void onDataUpdate(
    ItemsState<T> newItemsState, {
    @required bool isInitialStreamBatch,
    @required bool hasError,
  }) {
    if (!hasError && isInitialStreamBatch) {
      _lastFetchedPageKey = _pageKeyCurrentlyBeingFetched;
    }

    _isFetchingPage = false;
    super.onDataUpdate(
      newItemsState,
      isInitialStreamBatch: isInitialStreamBatch,
      hasError: hasError,
    );
  }

  @override
  Stream<ItemsStateStreamBatch<T>> createStream() {
    return _createStream(_lastFetchedPageKey).map(
      (batch) {
        if (batch.batch.isNotEmpty) {
          _pageKeyCurrentlyBeingFetched = batch.batch.last.item2;
        }
        return ItemsStateStreamBatch(
          batch.batch.map((e) => Tuple2(e.item1, e.item3)).toList(),
        );
      },
    );
  }
}
