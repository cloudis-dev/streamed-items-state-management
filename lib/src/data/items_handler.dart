import 'package:collection/collection.dart';
import 'package:streamed_items_state_management/src/utils/distinct_extension.dart';

/// Used for handling the pagination items.
/// Functionality for removing, updating and adding items to pagination's state.
///
/// The items are compared based on the [uniqueSelector].
class ItemsHandler<T, E> {
  ItemsHandler(
    this.sortCompare,
    this.uniqueSelector, {
    this.itemFilterTest,
  });

  /// This function serves as an additional filter
  /// for items after the add/update/delete change.
  ///
  /// Return false to remove the item or otherwise return true.
  ///
  /// By default, no filter is applied.
  final bool Function(T item) itemFilterTest;

  final int Function(T a, T b) sortCompare;

  /// Selects unique element of the Object. Can be identity function, too.
  final E Function(T a) uniqueSelector;

  bool _areEqual(T a, T b) => const DeepCollectionEquality().equals(
        uniqueSelector(a),
        uniqueSelector(b),
      );

  List<T> removeItems(
    List<T> items,
    List<T> itemsToRemove,
  ) {
    if (itemsToRemove.isEmpty) {
      return items.where(itemFilterTest ?? (_) => true).toList()
        ..sort(sortCompare);
    } else {
      return List.unmodifiable(
        items
            .where(
                (element) => itemsToRemove.every((e) => !_areEqual(element, e)))
            .where(itemFilterTest ?? (_) => true)
            .toList(),
      );
    }
  }

  List<T> updateItems(
    List<T> items,
    List<T> updatedItems,
  ) {
    if (updatedItems.isEmpty) {
      return items.where(itemFilterTest ?? (_) => true).toList()
        ..sort(sortCompare);
    } else {
      return List.unmodifiable(
        items
            .where(
                (element) => updatedItems.every((e) => !_areEqual(element, e)))
            .followedBy(updatedItems)
            .distinct(uniqueSelector)
            .where(itemFilterTest ?? (_) => true)
            .toList()
              ..sort(sortCompare),
      );
    }
  }

  List<T> addItems(
    List<T> items,
    List<T> newItems,
  ) {
    return updateItems(items, newItems);
  }
}
