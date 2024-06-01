import 'dart:async';

import 'package:rxdart/rxdart.dart';

import 'property_state.dart';

T? orNull<T>(dynamic obj) => obj is T ? obj : null;

extension PropertyStateMapper<E> on Stream<PropertyState<E>> {
  Stream<PropertyState<T>> mapProperty<T>(T Function(E) mapper) => map((event) {
        if (event is ValueState<E>) {
          return ValueState(mapper(event.value));
        } else if (event is ErrorState<E>) {
          return ErrorState(error: event.error, stack: event.stack);
        }
        return const LoadingState();
      });

  Stream<PropertyState<T>> asyncMapProperty<T>(
          FutureOr<T> Function(E) mapper) =>
      asyncMap((event) async {
        if (event is ValueState<E>) {
          return ValueState(await mapper(event.value));
        } else if (event is ErrorState<E>) {
          return ErrorState(error: event.error, stack: event.stack);
        }
        return const LoadingState();
      });
}

extension StreamUtils<T> on Stream<T> {
  Stream<PropertyState<T>> asProperty() => transform(_PropertyTransformer());
}

extension PropertyStreamUtils<T> on Stream<PropertyState<T>> {
  Future<T> get firstValue async {
    final event = (await firstWhere(
      (state) => state is ValueState<T> || state is ErrorState<T>,
    ));

    if (event is ValueState<T>) {
      return event.value;
    } else {
      throw (event as ErrorState<T>).error;
    }
  }

  Future<ValueState<T>> get firstValueState async {
    final event = (await firstWhere(
      (state) => state is ValueState<T> || state is ErrorState<T>,
    ));

    if (event is ValueState<T>) {
      return event;
    } else {
      throw (event as ErrorState<T>).error;
    }
  }

  Stream<ValueState<T>> whereValue() => whereType<ValueState<T>>();

  Stream<PropertyState<R>> mapValue<R>(R Function(T) mapper) {
    return map(
      (event) => switch (event) {
        (ValueState<T> state) => ValueState<R>(mapper(state.value)),
        (ErrorState state) =>
          ErrorState<R>(error: state.error, stack: state.stack),
        _ => const LoadingState()
      },
    );
  }

  Stream<PropertyState<R>> mapValueState<R>(
    ValueState<R> Function(ValueState<T>) mapper,
  ) {
    return map(
      (event) => switch (event) {
        (ValueState<T> state) => mapper(state),
        (ErrorState state) =>
          ErrorState<R>(error: state.error, stack: state.stack),
        _ => const LoadingState()
      },
    );
  }

  Stream<PropertyState<T>> untilFirstValue() =>
      transform(_UntilFirstValueTransformer<T>());
}

class _UntilFirstValueTransformer<T>
    extends StreamTransformerBase<PropertyState<T>, PropertyState<T>> {
  @override
  Stream<PropertyState<T>> bind(Stream<PropertyState<T>> stream) =>
      Stream.eventTransformed(stream, (sink) => _UntilFirstValueSink(sink));
}

class _UntilFirstValueSink<T> implements EventSink<PropertyState<T>> {
  final EventSink<PropertyState<T>> _out;

  _UntilFirstValueSink(this._out);

  @override
  void add(PropertyState<T> event) {
    _out.add(event);
    if (event is ValueState<T>) {
      close();
    }
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      _out.addError(error, stackTrace);

  @override
  void close() => _out.close();
}

class _PropertyTransformer<T>
    extends StreamTransformerBase<T, PropertyState<T>> {
  @override
  Stream<PropertyState<T>> bind(Stream<T> stream) =>
      Stream.eventTransformed(stream, (sink) => _PropertySink<T>(sink));
}

class _PropertySink<T> implements EventSink<T> {
  final EventSink<PropertyState<T>> _out;

  _PropertySink(this._out) {
    _out.add(const LoadingState());
  }

  @override
  void add(T event) => _out.add(ValueState<T>(event));

  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      _out.add(ErrorState<T>(error: error, stack: stackTrace));

  @override
  void close() => _out.close();
}
