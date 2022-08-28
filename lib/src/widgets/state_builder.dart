import 'package:flutter/material.dart';

import 'package:flutter_datahub/utils.dart';

class StateBuilder<TState> extends StatelessWidget {
  final Stream<TState> stream;
  final ValueBuilder<TState?> builder;

  const StateBuilder({Key? key, required this.stream, required this.builder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TState>(stream: stream.distinct(), builder: _builder);
  }

  Widget _builder(BuildContext context, AsyncSnapshot<TState> snapshot) {
    return builder(context, snapshot.data);
  }
}
