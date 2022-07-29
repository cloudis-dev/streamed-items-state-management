import 'package:flutter_test/flutter_test.dart';
import 'package:streamed_items_state_management/src/data/items_handler.dart';
import 'package:tuple/tuple.dart';

void main() {
  group('simple unique key', () {
    final handler = ItemsHandler<Tuple2<String, int>, String>(
      (a, b) => a.item1.compareTo(b.item1),
      (a) => a.item1,
      itemFilterTest: (a) => a.item2 < 5,
    );

    final lst = [
      const Tuple2('B', 1),
      const Tuple2('A', 1),
      const Tuple2('C', 1),
    ];

    test('empty addition', () {
      expect(handler.addItems(lst, []), [
        const Tuple2('A', 1),
        const Tuple2('B', 1),
        const Tuple2('C', 1),
      ]);
    });

    test('empty remove', () {
      expect(handler.removeItems(lst, []), [
        const Tuple2('A', 1),
        const Tuple2('B', 1),
        const Tuple2('C', 1),
      ]);
    });

    test('empty update', () {
      expect(handler.removeItems(lst, []), [
        const Tuple2('A', 1),
        const Tuple2('B', 1),
        const Tuple2('C', 1),
      ]);
    });

    test('remove items test', () {
      expect(
        handler.removeItems(lst, [
          const Tuple2('C', 1),
          const Tuple2('X', 1),
          const Tuple2('B', 2),
        ]),
        [const Tuple2('A', 1)],
      );
    });

    test('update items test', () {
      expect(
        handler.updateItems(lst, [
          const Tuple2('C', 2),
          const Tuple2('B', 1),
          const Tuple2('X', 1),
        ]),
        [
          const Tuple2('A', 1),
          const Tuple2('B', 1),
          const Tuple2('C', 2),
          const Tuple2('X', 1),
        ],
      );
    });

    test('add items test', () {
      expect(
        handler.addItems(lst, [
          const Tuple2('C', 2),
          const Tuple2('B', 1),
          const Tuple2('X', 1),
        ]),
        [
          const Tuple2('A', 1),
          const Tuple2('B', 1),
          const Tuple2('C', 2),
          const Tuple2('X', 1),
        ],
      );
    });

    test('additional item filter test', () {
      expect(
        handler.addItems(lst, [
          const Tuple2('C', 2),
          const Tuple2('B', 5),
          const Tuple2('X', 5),
        ]),
        [
          const Tuple2('A', 1),
          const Tuple2('C', 2),
        ],
      );
    });
  });

  group('composite unique key', () {
    final handler =
        ItemsHandler<Tuple2<List<List<String>>, int>, List<List<String>>>(
      (a, b) => a.item1.first.first.compareTo(b.item1.first.first),
      (a) => a.item1,
      itemFilterTest: (a) => a.item2 < 5,
    );

    final lst = [
      const Tuple2([
        ['A']
      ], 1),
      const Tuple2([
        ['B']
      ], 1),
      const Tuple2([
        ['C']
      ], 1),
    ];

    test('add items', () {
      expect(
          handler.addItems(
            lst,
            [
              const Tuple2([
                ['A']
              ], 2)
            ],
          ).map((e) => Tuple2(e.item1.first.first, e.item2)),
          [
            const Tuple2('A', 2),
            const Tuple2('B', 1),
            const Tuple2('C', 1),
          ]);
    });

    test('update items', () {
      expect(
          handler.addItems(
            lst,
            [
              const Tuple2([
                ['A']
              ], 2)
            ],
          ).map((e) => Tuple2(e.item1.first.first, e.item2)),
          [
            const Tuple2('A', 2),
            const Tuple2('B', 1),
            const Tuple2('C', 1),
          ]);
    });

    test('remove items', () {
      expect(
          handler.removeItems(
            lst,
            [
              const Tuple2([
                ['A']
              ], 1)
            ],
          ).map((e) => Tuple2(e.item1.first.first, e.item2)),
          [
            const Tuple2('B', 1),
            const Tuple2('C', 1),
          ]);
    });
  });
}
