import 'package:flutter/material.dart';

import 'package:flutter_datahub/bloc.dart';
import 'package:flutter_datahub/utils.dart';

/// Provides an easy wrapper for a builder presenting the value of
/// a [PropertyState] stream.
class PropertyBuilder<TValue> extends StatelessWidget {
  final Stream<PropertyState<TValue>> stream;
  final ValueBuilder<TValue> value;
  final WidgetBuilder loading;
  final ErrorBuilder error;

  const PropertyBuilder({
    Key? key,
    required this.stream,
    required this.value,
    required this.loading,
    required this.error,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PropertyState<TValue>>(
        stream: stream.distinct(), builder: _builder);
  }

  Widget _builder(
      BuildContext context, AsyncSnapshot<PropertyState<TValue>> snapshot) {
    if (snapshot.hasError) {
      return error(context, snapshot.error);
    } else if (snapshot.hasData) {
      final state = snapshot.requireData;
      if (state is ValueState<TValue>) {
        return value(context, state.value);
      } else if (state is LoadingState) {
        return loading(context);
      } else if (state is ErrorState<TValue>) {
        return error(context, state.error);
      } else {
        return error(context, 'Invalid state: ${state.runtimeType}');
      }
    } else {
      return loading(context);
    }
  }
}
