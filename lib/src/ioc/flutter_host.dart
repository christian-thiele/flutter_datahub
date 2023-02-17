import 'package:datahub/datahub.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_datahub/utils.dart';

class FlutterHost extends ServiceHost {
  final Widget? app;

  FlutterHost(
    List<BaseService Function()> factories, {
    FirebaseCrashlytics? crashlytics,
    this.app,
  }) : super(
          factories,
          failWithServices: false,
          logBackend: FlutterLogBackend(crashlytics: crashlytics),
        );


}
