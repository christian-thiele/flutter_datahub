import 'dart:async';

import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class FlutterLogBackend extends LogBackend {
  LogLevel _logLevel = LogLevel.debug;

  final FirebaseCrashlytics? crashlytics;

  FlutterLogBackend({this.crashlytics});

  @override
  void publish(LogMessage message) {
    if (message.level.level >= LogLevel.error.level) {
      crashlytics?.recordError(
        message.exception,
        message.trace,
        printDetails: false,
        reason: nullOrWhitespace(message.message) ? null : message.message,
      );
    }

    if (!kDebugMode || message.level.level < _logLevel.level) {
      return;
    }

    final buffer = StringBuffer();

    buffer.write(_severityPrefix(message.level));
    buffer.write(' ');
    buffer.write(message.message);

    if (message.exception != null) {
      buffer.write('\n');
      buffer.write(message.exception);
    }

    if (message.trace != null) {
      buffer.write('\n');
      buffer.write(message.trace.toString());
    }

    buffer.write('\n');
    Zone.root.print(buffer.toString());
  }

  @override
  void setLogLevel(LogLevel level) => _logLevel = level;

  String _severityPrefix(LogLevel severity) {
    switch (severity) {
      case LogLevel.debug:
        return '[DEBUG   ]';
      case LogLevel.verbose:
        return '[VERBOSE ]';
      case LogLevel.info:
        return '[INFO    ]';
      case LogLevel.warning:
        return '[WARNING ]';
      case LogLevel.error:
        return '[ERROR   ]';
      case LogLevel.critical:
        return '[CRITICAL]';
      default:
        return '[UNKNOWN ]';
    }
  }
}
