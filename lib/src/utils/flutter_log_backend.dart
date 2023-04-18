import 'dart:async';

import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class FlutterLogBackend extends LogBackend {
  int _logLevel = 0;

  final FirebaseCrashlytics? crashlytics;

  FlutterLogBackend({this.crashlytics});

  @override
  void publish(LogMessage message) {
    if (message.severity >= LogMessage.error) {
      crashlytics?.recordError(
        message.exception,
        message.trace,
        printDetails: false,
        reason: nullOrWhitespace(message.message) ? null : message.message,
      );
    }

    if (!kDebugMode || message.severity < _logLevel) {
      return;
    }

    final buffer = StringBuffer();

    buffer.write(_severityPrefix(message.severity));
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
  void setLogLevel(int level) => _logLevel = level;

  String _severityPrefix(int severity) {
    switch (severity) {
      case LogMessage.debug:
        return '[DEBUG   ]';
      case LogMessage.verbose:
        return '[VERBOSE ]';
      case LogMessage.info:
        return '[INFO    ]';
      case LogMessage.warning:
        return '[WARNING ]';
      case LogMessage.error:
        return '[ERROR   ]';
      case LogMessage.critical:
        return '[CRITICAL]';
      default:
        return '[UNKNOWN ]';
    }
  }
}
