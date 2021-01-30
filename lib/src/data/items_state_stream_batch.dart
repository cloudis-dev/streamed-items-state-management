import 'package:streamed_items_state_management/src/data/change_status.dart';
import 'package:tuple/tuple.dart';

/// Representation of a batch received via a stream.
class ItemsStateStreamBatch<T> {
  final List<Tuple2<ChangeStatus, T>> batch;

  ItemsStateStreamBatch(this.batch);
}
