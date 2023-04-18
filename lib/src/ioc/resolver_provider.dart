import 'package:datahub/ioc.dart';
import 'package:flutter/widgets.dart';

class ResolverProvider extends InheritedWidget {
  final ServiceResolver resolver = ServiceResolver.current;

  ResolverProvider({super.key, required super.child});

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}

extension ContextResolver on BuildContext {
  /// Method for resolving services using a flutter [BuildContext].
  ///
  /// See [ServiceResolver.resolveService].
  TService resolve<TService extends BaseService?>() {
    final provider = dependOnInheritedWidgetOfExactType<ResolverProvider>();
    if (provider == null) {
      throw Exception(
          'No service resolver registered in build context. Start your app with'
          ' FlutterHost.runApp or wrap your widget inside a ResolverProvider.');
    }
    return provider.resolver.resolveService<TService>();
  }
}
