/// Implements the most common use case for states.
///
/// Value is available -> [ValueState]
/// Loading the value -> [LoadingState]
/// An error occurred -> [ErrorState]
///
/// See [PropertyBuilder] for more.
abstract class PropertyState<T> {
  T? get valueOrNull => null;

  const PropertyState();
}

class ValueState<T> extends PropertyState<T> {
  final T value;

  @override
  T? get valueOrNull => value;

  const ValueState(this.value);
}

class LoadingState<T> extends PropertyState<T> {
  const LoadingState();
}

class ErrorState<T> extends PropertyState<T> {
  final dynamic error;
  final dynamic stack;

  const ErrorState({this.error, this.stack});
}
