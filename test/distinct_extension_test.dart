import 'package:flutter_test/flutter_test.dart';
import 'package:streamed_items_state_management/src/utils/distinct_extension.dart';
import 'package:tuple/tuple.dart';

void main() {
  test('Basic type distinct', () {
    final lst = [1, 2, 3, 3, 2, 1];
    final stringLst = ['Abc', 'Abc', 'abc', 'Hello'];

    expect(lst.distinct((element) => element), [1, 2, 3]);
    expect(stringLst.distinct((element) => element), ['Abc', 'abc', 'Hello']);
  });

  test('List type distinct', () {
    final lst = [
      [1, 2],
      [1, 2],
      [1, 3],
      [2, 3],
      [3, 2]
    ];

    expect(lst.distinct((element) => element), [
      [1, 2],
      [1, 3],
      [2, 3],
      [3, 2]
    ]);
  });

  test('Nested list type distinct', () {
    final lst = [
      [
        1,
        [1, 2]
      ],
      [
        1,
        [2, 3]
      ],
      [
        1,
        [1, 2]
      ],
      [
        2,
        [1, 1]
      ],
      [
        3,
        [1]
      ],
      [
        1,
        [2, 3]
      ]
    ];

    expect(lst.distinct((element) => element), [
      [
        1,
        [1, 2]
      ],
      [
        1,
        [2, 3]
      ],
      [
        2,
        [1, 1]
      ],
      [
        3,
        [1]
      ],
    ]);
  });

  test('part equivalence', () {
    final lst = [
      const Tuple2('A', 1),
      const Tuple2('B', 1),
      const Tuple2('A', 2),
      const Tuple2('B', 2),
      const Tuple2('B', 3)
    ];

    expect(lst.distinct((element) => element.item1), [
      const Tuple2('A', 1),
      const Tuple2('B', 1),
    ]);
  });
}
