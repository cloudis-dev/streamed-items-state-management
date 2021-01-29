import 'dart:collection';

import 'package:collection/collection.dart';

extension DistinctExtension<T> on Iterable<T> {
  /// Returns only distinct elements of an iterable according to the selector parameter.
  /// The first occurence of the element remains in the list, the others go away.
  ///
  /// The order of the items is preserved.
  List<T> distinct<E>(E Function(T element) selectorForEqualityComparison) {
    // Load all the unique keys into the linked hash set remaining its ordering.
    final set = LinkedHashSet<E>(
      equals: const DeepCollectionEquality().equals,
      hashCode: const DeepCollectionEquality().hash,
    )..addAll(
        map(
          (e) => selectorForEqualityComparison(e),
        ),
      );

    return set
        .map(
          (e) => firstWhere(
            (element) => const DeepCollectionEquality()
                .equals(selectorForEqualityComparison(element), e),
          ),
        )
        .toList();
  }
}
