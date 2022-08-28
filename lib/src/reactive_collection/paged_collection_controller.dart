import 'dart:math';

import 'package:boost/boost.dart';
import 'package:rxdart/rxdart.dart';
import 'package:datahub/collection.dart';

import 'package:flutter_datahub/bloc.dart';

import 'collection_controller.dart';
import 'paged_collection_model.dart';

/// Queries collection in a paged manner.
///
/// Items are fetched on demand in non-sequential chunks.
/// Useful for huge datasets in conjunction with paged views
/// (like [TableCollectionTable]).
class PagedCollectionController<Item> extends CollectionController<Item> {
  final BehaviorSubject<PropertyState<PagedCollectionModel<Item>>>
      _streamController =
      BehaviorSubject<PropertyState<PagedCollectionModel<Item>>>();
  final _loadingSemaphore = Semaphore();

  PagedCollectionController(Collection<Item> collection) : super(collection) {
    _streamController.sink.add(const LoadingState());
  }

  @override
  Stream<PropertyState<PagedCollectionModel<Item>>> get stream =>
      _streamController.stream;

  Future<void> loadPage(int page, int pageSize,
      {bool invalidate = false}) async {
    await _loadingSemaphore.throttle(() async {
      try {
        final current = _streamController.value;
        if (current is! LoadingState) {
          _streamController.sink.add(const LoadingState());
        }

        if (invalidate) {
          //TODO clear cache here
        }

        final count = (current is ValueState && !invalidate)
            ? current.valueOrNull!.size
            : await collection.getSize();

        //TODO introduce caching

        final chunk = await collection.getItems(
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
    final value = _streamController.valueOrNull?.valueOrNull;
    if (value == null) {
      return;
    }

    await loadPage(value.page, value.pageSize, invalidate: true);
  }

  @override
  void dispose() {
    _streamController.close();
  }
}
