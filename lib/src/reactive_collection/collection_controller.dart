import 'package:datahub/collection.dart';
import 'package:flutter_datahub/bloc.dart';

import 'collection_state_model.dart';

abstract class CollectionController<Item> {
  final Collection<Item> collection;

  Stream<PropertyState<CollectionStateModel<Item>>> get stream;

  CollectionController(this.collection);

  /// Invalidates caches and implies that data should be
  /// re-fetched while trying to keep the current collection state
  /// (f.e. page offset and size in [PagedCollectionController]).
  Future<void> invalidate();

  void dispose();
}
