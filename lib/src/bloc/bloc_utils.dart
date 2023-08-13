import 'dart:async';

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

  Stream<PropertyState<T>> asyncMapProperty<T>(FutureOr<T> Function(E) mapper) =>
      asyncMap((event) async {
        if (event is ValueState<E>) {
          return ValueState(await mapper(event.value));
        } else if (event is ErrorState<E>) {
          return ErrorState(error: event.error, stack: event.stack);
        }
        return const LoadingState();
      });
}
