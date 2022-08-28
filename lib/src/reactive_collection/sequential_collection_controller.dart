import 'dart:math';

import 'package:boost/boost.dart';
import 'package:rxdart/rxdart.dart';

import 'package:flutter_datahub/bloc.dart';

import 'collection.dart';
import 'collection_controller.dart';
import 'sequential_collection_model.dart';

/// Controls collection querying in a lazy sequential manner.
///
/// Queries the whole collection in chunks. Chunks are fetched
/// on demand by calling [continueLoading].
class SequentialCollectionController<Item> extends CollectionController<Item> {
  final BehaviorSubject<PropertyState<SequentialCollectionModel<Item>>>
      _streamController =
      BehaviorSubject<PropertyState<SequentialCollectionModel<Item>>>();
  final _loadingSemaphore = Semaphore();

  final int chunkSize;

  SequentialCollectionController(Collection<Item> collection,
      {this.chunkSize = 25})
      : super(collection) {
    _streamController.sink.add(const LoadingState());
  }

  @override
  Stream<PropertyState<SequentialCollectionModel<Item>>> get stream =>
      _streamController.stream;

  /// Requests a section of the collection.
  ///
  /// [invalidate] clears cached data and forces the controller
  /// to fetch new data.
  Future<void> continueLoading({bool invalidate = false}) async {
    await _loadingSemaphore.throttle(() async {
      try {
        if (invalidate) {
          _streamController.sink.add(const LoadingState());
        }

        if (_streamController.value is LoadingState) {
          final count = await collection.getSize();
          _streamController.sink
              .add(ValueState(SequentialCollectionModel(count, <Item>[])));
        }

        final current = _streamController.value.valueOrNull!;

        final chunk = await collection.getItems(current.items.length,
            min(chunkSize, current.size - current.items.length));

        _streamController.sink.add(ValueState(current.addChunk(chunk)));
      } catch (e, stack) {
        _streamController.sink.add(ErrorState(error: e, stack: stack));
      }
    });
  }

  @override
  Future<void> invalidate() async {
    await continueLoading(invalidate: true);
  }

  @override
  void dispose() {
    _streamController.close();
  }
}
