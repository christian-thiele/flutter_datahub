import 'dart:io';

import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_datahub/utils.dart';

/// Hosts services and provides dependency injection.
///
/// This class also controls the execution of the application itself,
/// providing a framework for services to live in.
///
/// Use this code in your main function:
///
/// ```
/// await FlutterHost(
///   [
///     () => ServiceA(),
///     () => ServiceB(),
///   ],
/// ).run(const MyApp());
/// ```
/// Note that this replaces the usual call to `runApp(const MyApp())`.
class FlutterHost extends ServiceHost {
  FlutterHost(
    List<BaseService Function()> factories, {
    FirebaseCrashlytics? crashlytics,
  }) : super(
          factories,
          failWithServices: false,
          logBackend: FlutterLogBackend(crashlytics: crashlytics),
        );

  /// Runs the application.
  ///
  /// All services will be initialized in the order they are
  /// supplied.
  ///
  /// If [app] is not null, `runApp(app)` will be called after service
  /// initialization.
  Future<void> run([Widget? app]) async {
    final stopwatch = Stopwatch()..start();
    try {
      await initialize();
    } catch (e, stack) {
      resolveService<LogService?>()?.critical(
        'Initialisation failed.',
        sender: 'FlutterDataHub',
        error: e,
        trace: stack,
      );
      await shutdown();
      exit(0);
    }
    stopwatch.stop();

    resolveService<LogService?>()?.info(
      'Initialisation done in ${stopwatch.elapsed}.',
      sender: 'FlutterDataHub',
    );

    app?.apply(runApp);
  }
}
