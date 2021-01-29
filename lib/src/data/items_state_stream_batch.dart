import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuple/tuple.dart';

class ItemsStateStreamBatch<T> {
  final List<Tuple2<DocumentChangeType, T>> batch;

  ItemsStateStreamBatch(this.batch);
}
