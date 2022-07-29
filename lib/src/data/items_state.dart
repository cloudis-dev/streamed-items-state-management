import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';

enum ItemsStateStatus {
  /// This is the status, when no items are currently being loaded
  /// but not all the items have been loaded yet.
  waiting,

  /// When new items are being currently loaded.
  loading,

  /// When all the items are loaded.
  allLoaded,

  /// When an error occured while loading new items.
  error,
}

/// This is the state of the pagination.
/// It stores the list of all fetched items.
@immutable
class ItemsState<T> {
  final List<T> items;
  final ItemsStateStatus status;

  ItemsState.empty()
      : items = List.unmodifiable([]),
        status = ItemsStateStatus.waiting;

  const ItemsState._(this.items, this.status);

  /// When everything is fetched and there are no items.
  bool get isDoneAndEmpty =>
      status == ItemsStateStatus.allLoaded && items.isEmpty;

  @override
  bool operator ==(other) =>
      other is ItemsState<T> &&
      const DeepCollectionEquality().equals(other.items, items) &&
      other.status == status;

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(items) ^ status.hashCode;

  ItemsState<T> copyWith({
    List<T>? items,
    ItemsStateStatus? status,
  }) =>
      ItemsState._(
        items == null ? this.items : List.unmodifiable(items),
        status ?? this.status,
      );
}
