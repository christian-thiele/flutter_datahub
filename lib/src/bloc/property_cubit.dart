import 'package:bloc/bloc.dart';

import 'bloc_utils.dart';
import 'property_state.dart';

class PropertyCubit<Property> extends Cubit<PropertyState<Property>> {
  PropertyCubit([PropertyState<Property>? initialValue])
      : super(initialValue ?? LoadingState<Property>());

  Property? get valueOrNull => orNull<ValueState<Property>>(state)?.value;

  void emitLoading() => emit(LoadingState<Property>());

  void emitValue(Property value) => emit(ValueState<Property>(value));

  void emitError(dynamic error, [StackTrace? stack]) =>
      emit(ErrorState(error: error, stack: stack));
}
