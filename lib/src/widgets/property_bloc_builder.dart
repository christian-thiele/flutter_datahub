import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datahub/flutter_datahub.dart';

class PropertyBlocBuilder<B extends StateStreamable<PropertyState<S>>, S>
    extends StatelessWidget {
  final Widget Function(BuildContext, S) builder;
  final Widget Function(BuildContext)? loadingBuilder;
  final Widget Function(BuildContext, dynamic)? errorBuilder;

  const PropertyBlocBuilder({
    super.key,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<B, PropertyState<S>>(builder: (context, state) {
      return switch (state) {
        ValueState(value: final value) => builder(context, value),
        ErrorState(error: final error) =>
          errorBuilder?.call(context, error) ?? ErrorText(error.toString()),
        LoadingState() =>
          loadingBuilder?.call(context) ?? const LoadingSpinner(),
      };
    });
  }
}
