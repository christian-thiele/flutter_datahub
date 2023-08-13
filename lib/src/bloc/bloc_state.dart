import 'package:flutter/widgets.dart';
import 'package:flutter_datahub/bloc.dart';
import 'package:flutter_datahub/ioc.dart';

abstract class BlocState<T extends StatefulWidget, Bloc extends BaseBloc>
    extends State<T> {
  late final Bloc bloc;
  bool _initialized = false;

  Bloc getBloc();

  @override
  void didChangeDependencies() {
    if (!_initialized) {
      initialize();
      _initialized = true;
    }
    super.didChangeDependencies();
  }

  @mustCallSuper
  void initialize() {
    final host = (context.getResolver() as FlutterHost);
    bloc = host.runAsService(getBloc);
    bloc.initialize(context);
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }
}
