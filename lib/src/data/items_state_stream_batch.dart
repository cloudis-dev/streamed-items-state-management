import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuple/tuple.dart';

/// Representation of a batch received via a stream.
class ItemsStateStreamBatch<T> {
  final List<Tuple2<DocumentChangeType, T>> batch;

  ItemsStateStreamBatch(this.batch);
}
