import 'dart:async';
import 'dart:math';

import 'package:boost/boost.dart';
import 'package:datahub/transfer_object.dart';
import 'package:rxdart/rxdart.dart';
import 'package:datahub/collection.dart';

import 'package:flutter_datahub/bloc.dart';

import 'collection_controller.dart';
import 'sequential_collection_model.dart';

/// Controls collection querying in a lazy sequential manner.
///
/// Queries the whole collection in chunks. Chunks are fetched
/// on demand by calling [continueLoading].
abstract class SequentialCollectionController<Item>
    extends CollectionController<Item> {
  final int chunkSize;

  SequentialCollectionController({this.chunkSize = 25});

  factory SequentialCollectionController.pull(PullCollection<Item> collection,
          {int chunkSize = 25}) =>
      _SequentialPullCollectionController(collection, chunkSize: chunkSize);

  static SequentialCollectionController<Item> reactive<
          Item extends TransferObjectBase<Id>,
          Id>(ReactiveCollection<Item, Id> collection, {int chunkSize = 25}) =>
      _SequentialReactiveCollectionController(collection, chunkSize: chunkSize);

  @override
  Stream<PropertyState<SequentialCollectionModel<Item>>> get stream;

  /// Requests a section of the collection.
  ///
  /// [invalidate] clears cached data and forces the controller
  /// to fetch new data.
  Future<void> continueLoading({bool invalidate = false});

  @override
  Future<void> invalidate() async => await continueLoading(invalidate: true);
}

class _SequentialPullCollectionController<Item>
    extends SequentialCollectionController<Item> {
  final BehaviorSubject<PropertyState<SequentialCollectionModel<Item>>>
      _streamController =
      BehaviorSubject<PropertyState<SequentialCollectionModel<Item>>>();
  final _loadingSemaphore = Semaphore();
  final PullCollection<Item> _collection;

  _SequentialPullCollectionController(this._collection,
      {super.chunkSize = 25}) {
    _streamController.sink.add(const LoadingState());
  }

  @override
  Stream<PropertyState<SequentialCollectionModel<Item>>> get stream =>
      _streamController.stream;

  @override
  Future<void> continueLoading({bool invalidate = false}) async {
    await _loadingSemaphore.throttle(() async {
      try {
        if (invalidate) {
          _streamController.sink.add(const LoadingState());
        }

        if (_streamController.value is LoadingState) {
          final count = await _collection.getLength();
          _streamController.sink
              .add(ValueState(SequentialCollectionModel(count, <Item>[])));
        }

        final current = _streamController.value.valueOrNull!;

        final chunk = await _collection.getItems(current.items.length,
            min(chunkSize, current.size - current.items.length));

        _streamController.sink.add(ValueState(current.addChunk(chunk)));
      } catch (e, stack) {
        _streamController.sink.add(ErrorState(error: e, stack: stack));
      }
    });
  }

  @override
  void dispose() {
    _streamController.close();
  }
}

class _SequentialReactiveCollectionController<
    Item extends TransferObjectBase<Id>,
    Id> extends SequentialCollectionController<Item> {
  final ReactiveCollection<Item, Id> _collection;

  final _continueSemaphore = Semaphore();
  final _controller =
      BehaviorSubject<PropertyState<CollectionWindowState<Item, Id>>>.seeded(
          const LoadingState());

  _SequentialReactiveCollectionController(
    this._collection, {
    super.chunkSize = 25,
  });

  @override
  Stream<PropertyState<SequentialCollectionModel<Item>>> get stream =>
      _controller.stream
          .mapProperty((e) => SequentialCollectionModel(e.length, e.items));

  PropertyState get currentValue => _controller.value;

  StreamSubscription? _sub;

  @override
  Future<void> continueLoading({bool invalidate = false}) async {
    if (_continueSemaphore.isLocked) return;
    _sub?.cancel();
    if (invalidate) {
      _controller.add(const LoadingState());
    }
    await _continueSemaphore.lock();
    if (_controller.value is ValueState && !invalidate) {
      final state = _controller.value.valueOrNull!;
      _sub = _collection
          .getWindow(
            0,
            state.windowLength + chunkSize,
            previous: state,
            query: query,
            params: params,
          )
          .map(ValueState.new)
          .listen(
        (v) {
          _controller.add(v);
          _continueSemaphore.release();
        },
        onError: _controller.addError,
        onDone: _continueSemaphore.release,
      );
    } else {
      _sub = _collection
          .getWindow(
            0,
            chunkSize,
            query: query,
            params: params,
          )
          .map(ValueState.new)
          .listen(
        (v) {
          _controller.add(v);
          _continueSemaphore.release();
        },
        onError: (e, s) => _controller.add(ErrorState(error: e, stack: s)),
        onDone: _continueSemaphore.release,
      );
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _controller.close();
  }
}
