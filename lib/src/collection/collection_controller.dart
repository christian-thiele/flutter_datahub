import 'package:datahub/collection.dart';
import 'package:flutter_datahub/bloc.dart';

import 'collection_state_model.dart';

//TODO docs
abstract class CollectionController<Item> {
  final params = <String, String>{};
  final query = <String, List<String>>{};

  Stream<PropertyState<CollectionStateModel<Item>>> get stream;

  CollectionController();

  /// Invalidates caches and implies that data should be
  /// re-fetched while trying to keep the current collection state
  /// (f.e. page offset and size in [PagedCollectionController]).
  Future<void> invalidate();

  void dispose();
}
