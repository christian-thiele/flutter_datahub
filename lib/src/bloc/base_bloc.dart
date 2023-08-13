import 'dart:async';

import 'package:datahub/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_datahub/collection.dart';
import 'package:rxdart/rxdart.dart';

import 'property_state.dart';

/// Base class for business logic components.
///
/// This is inspired by the BLoC pattern but not quite the same.
/// A bloc provides methods that trigger asynchronous procedures
/// which in turn publish state changes through stream controllers.
///
/// A bloc can provide multiple streams to the UI layer.
abstract class BaseBloc {
  final _streamControllers = <StreamController>[];
  final _collectionControllers = <CollectionController>[];
  final _streamSubscriptions = <StreamSubscription>[];

  BaseBloc();

  void initialize(BuildContext context) {}

  /// Instantiates an auto-disposing [BehaviourSubject]
  ///
  /// Disposal is taken care of in the [dispose] method.
  BehaviorSubject<TState> subject<TState>([TState? initial]) {
    final subject = initial == null
        ? BehaviorSubject<TState>()
        : BehaviorSubject<TState>.seeded(initial);
    _streamControllers.add(subject);
    return subject;
  }

  /// Instantiates an auto-disposing [BehaviourSubject] with
  /// a [PropertyState].
  ///
  /// Disposal is taken care of in the [dispose] method.
  BehaviorSubject<PropertyState<TState>> property<TState>(
      [PropertyState<TState> initial = const LoadingState()]) {
    return subject<PropertyState<TState>>(initial);
  }

  /// Instantiates an auto-disposing [PagedCollectionController].
  ///
  /// Disposal is taken care of in the [dispose] method.
  PagedCollectionController<Item> pagedCollection<Item>(
      PullCollection<Item> collection) {
    final controller = PagedCollectionController<Item>.pull(collection);
    _collectionControllers.add(controller);
    return controller;
  }

  /// Instantiates an auto-disposing [SequentialCollectionController].
  ///
  /// Disposal is taken care of in the [dispose] method.
  SequentialCollectionController<Item> sequentialCollection<Item>(
      PullCollection<Item> collection,
      {int chunkSize = 25}) {
    final controller = SequentialCollectionController<Item>.pull(collection,
        chunkSize: chunkSize);
    _collectionControllers.add(controller);
    return controller;
  }

  /// Instantiates an auto-disposing [StreamController].
  ///
  /// Disposal is taken care of in the [dispose] method.
  StreamController<TState> stream<TState>() {
    final subject = StreamController<TState>();
    _streamControllers.add(subject);
    return subject;
  }

  /// Register a [StreamSubscription] for auto-disposal.
  ///
  /// Disposal is taken care of in the [dispose] method.
  void sub(StreamSubscription subscription) {
    _streamSubscriptions.add(subscription);
  }

  @mustCallSuper
  void dispose() {
    // close all state stream controllers
    for (final s in _streamControllers) {
      s.close();
    }
    // dispose all collection controllers
    for (final s in _collectionControllers) {
      s.dispose();
    }
    // cancel all prerecorded stream subscriptions
    for (final s in _streamSubscriptions) {
      s.cancel();
    }
  }
}
