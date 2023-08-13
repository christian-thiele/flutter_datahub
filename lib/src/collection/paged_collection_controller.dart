import 'dart:math';

import 'package:boost/boost.dart';
import 'package:rxdart/rxdart.dart';
import 'package:datahub/collection.dart';

import 'package:flutter_datahub/bloc.dart';

import 'collection_controller.dart';
import 'paged_collection_model.dart';

/// Provides collections in a paged manner.
abstract class PagedCollectionController<Item>
    extends CollectionController<Item> {
  PagedCollectionController();

  factory PagedCollectionController.pull(PullCollection<Item> collection) =>
      _PagedPullCollectionController(collection);

  //TODO responsive

  @override
  Stream<PropertyState<PagedCollectionModel<Item>>> get stream;

  Future<void> setPage(int page, int pageSize, {bool invalidate = false});
}

class _PagedPullCollectionController<Item>
    extends PagedCollectionController<Item> {
  final BehaviorSubject<PropertyState<PagedCollectionModel<Item>>>
      _streamController =
      BehaviorSubject<PropertyState<PagedCollectionModel<Item>>>();
  final _loadingSemaphore = Semaphore();
  final PullCollection<Item> _collection;
  int? _lastPage;
  int? _lastPageSize;

  _PagedPullCollectionController(this._collection) {
    _streamController.sink.add(const LoadingState());
  }

  @override
  Stream<PropertyState<PagedCollectionModel<Item>>> get stream =>
      _streamController.stream;

  @override
  Future<void> setPage(int page, int pageSize,
      {bool invalidate = false}) async {
    _lastPage = page;
    _lastPageSize = pageSize;
    await _loadingSemaphore.throttle(() async {
      try {
        final current = _streamController.value;
        if (!invalidate && current is ValueState<PagedCollectionModel<Item>>) {
          if (current.value.page == page &&
              current.value.pageSize == pageSize) {
            return;
          }
        }

        if (current is! LoadingState) {
          _streamController.sink.add(const LoadingState());
        }

        final count = (current is ValueState && !invalidate)
            ? current.valueOrNull!.size
            : await _collection.getLength();

        final chunk = await _collection.getItems(
            page * pageSize, min(pageSize, count - page * pageSize));

        _streamController.sink.add(
            ValueState(PagedCollectionModel(count, page, pageSize, chunk)));
      } catch (e, stack) {
        _streamController.sink.add(ErrorState(error: e, stack: stack));
      }
    });
  }

  @override
  Future<void> invalidate() async {
    if (_lastPage != null && _lastPageSize != null) {
      await setPage(_lastPage!, _lastPageSize!, invalidate: true);
    }
  }

  @override
  void dispose() {
    _streamController.close();
  }
}