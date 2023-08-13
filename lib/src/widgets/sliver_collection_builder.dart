import 'package:boost/boost.dart';
import 'package:flutter/material.dart';

import 'package:flutter_datahub/collection.dart';
import 'package:flutter_datahub/utils.dart';

import 'error_text.dart';
import 'loading_spinner.dart';
import 'property_builder.dart';

class SliverCollectionBuilder<Item> extends StatefulWidget {
  final bool pullToRefresh;
  final ScrollPhysics? physics;
  final Axis scrollDirection;
  final ScrollBehavior? scrollBehavior;
  final bool shrinkWrap;
  final bool reverse;

  final SequentialCollectionController<Item> collection;
  final List<Widget>? leading;
  final ValueBuilder<Item> itemBuilder;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? emptyBuilder;
  final ErrorBuilder? errorBuilder;

  const SliverCollectionBuilder({
    Key? key,
    required this.collection,
    required this.itemBuilder,
    this.leading,
    this.errorBuilder,
    this.emptyBuilder,
    this.loadingBuilder,
    this.physics,
    this.reverse = false,
    this.scrollDirection = Axis.vertical,
    this.scrollBehavior,
    this.pullToRefresh = false,
    this.shrinkWrap = true,
  }) : super(key: key);

  @override
  State<SliverCollectionBuilder<Item>> createState() =>
      _SliverCollectionBuilderState<Item>();
}

class _SliverCollectionBuilderState<Item>
    extends State<SliverCollectionBuilder<Item>> {
  final _continueSemaphore = Semaphore();
  bool _done = false;
  final key = GlobalKey();

  @override
  void initState() {
    super.initState();
    _continueLoading();
  }

  @override
  Widget build(BuildContext context) {
    return PropertyBuilder(
      key: key,
      stream: widget.collection.stream,
      error: widget.errorBuilder ?? _fallbackError,
      loading: widget.loadingBuilder ?? _fallbackLoading,
      value: _build,
    );
  }

  Widget _build(BuildContext context, SequentialCollectionModel<Item> model) {
    _done = model.isComplete;
    if (model.size == 0) {
      return _buildEmpty(context);
    } else if (widget.pullToRefresh) {
      return RefreshIndicator(
        onRefresh: _refresh,
        child: _buildScrollView(context, model.items, !model.isComplete),
      );
    } else {
      return _buildScrollView(context, model.items, !model.isComplete);
    }
  }

  Widget _buildEmpty(BuildContext context) {
    if (widget.pullToRefresh) {
      return RefreshIndicator(
        onRefresh: _refresh,
        child: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: CustomScrollView(
            reverse: widget.reverse,
            physics: widget.physics,
            scrollDirection: widget.scrollDirection,
            scrollBehavior: widget.scrollBehavior,
            shrinkWrap: widget.shrinkWrap,
            slivers: [
              if (widget.leading != null) ...widget.leading!,
              SliverFillRemaining(
                child: widget.emptyBuilder?.call(context) ??
                    const SizedBox.shrink(),
              )
            ],
          ),
        ),
      );
    } else {
      return widget.emptyBuilder?.call(context) ?? const SizedBox.shrink();
    }
  }

  Widget _buildScrollView(
      BuildContext context, Iterable<Item> items, bool loading) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: CustomScrollView(
        reverse: widget.reverse,
        physics: widget.physics,
        scrollDirection: widget.scrollDirection,
        scrollBehavior: widget.scrollBehavior,
        shrinkWrap: widget.shrinkWrap,
        slivers: [
          if (widget.leading != null) ...widget.leading!,
          ...items.map((e) => widget.itemBuilder(context, e)),
          if (loading)
            widget.loadingBuilder?.call(context) ??
                const SliverToBoxAdapter(
                  child: LoadingSpinner(),
                )
        ],
      ),
    );
  }

  bool _onScroll(ScrollNotification notification) {
    if (!_done &&
        notification.metrics.pixels >
            notification.metrics.maxScrollExtent - 300) {
      _continueLoading();
    }
    return false; //don't intercept bubbling
  }

  Future<void> _continueLoading({bool refresh = false}) async {
    await _continueSemaphore.throttle(() async {
      await widget.collection.continueLoading(invalidate: refresh);
    });
  }

  Widget _fallbackError(BuildContext context, dynamic e) =>
      ErrorText(e.toString());

  Widget _fallbackLoading(BuildContext context) => const LoadingSpinner();

  Future<void> _refresh() async {
    await _continueLoading(refresh: true);
  }
}
