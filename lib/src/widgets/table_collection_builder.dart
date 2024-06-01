import 'package:boost/boost.dart';
import 'package:flutter/material.dart';

import 'package:flutter_datahub/collection.dart';
import 'package:flutter_datahub/utils.dart';
import 'package:flutter_datahub/widgets.dart';

class TableCollectionBuilder<Item> extends StatefulWidget {
  final PagedCollectionController<Item> collection;
  final List<DataColumn> columns;
  final TableRowBuilder<Item> rowBuilder;
  final WidgetBuilder? loadingBuilder;
  final ErrorBuilder? errorBuilder;
  final List<int> pageSizeOptions;
  final double? columnSpacing;
  final int? sortColumnIndex;
  final bool sortAscending;
  final ValueSetter<bool?>? onSelectAll;
  final Decoration? decoration;
  final WidgetStateProperty<Color?>? dataRowColor;
  final double? dataRowMinHeight;
  final double? dataRowMaxHeight;
  final TextStyle? dataTextStyle;
  final WidgetStateProperty<Color?>? headingRowColor;
  final double? headingRowHeight;
  final TextStyle? headingTextStyle;
  final double? horizontalMargin;
  final bool showCheckboxColumn;
  final double? dividerThickness;
  final bool showBottomBorder;
  final double? checkboxHorizontalMargin;

  TableCollectionBuilder({
    super.key,
    required this.collection,
    required this.columns,
    required this.rowBuilder,
    this.pageSizeOptions = const [10, 20, 50, 100],
    this.loadingBuilder,
    this.errorBuilder,
    this.columnSpacing,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSelectAll,
    this.decoration,
    this.dataRowColor,
    this.dataRowMinHeight,
    this.dataRowMaxHeight,
    this.dataTextStyle,
    this.headingRowColor,
    this.headingRowHeight,
    this.headingTextStyle,
    this.horizontalMargin,
    this.showCheckboxColumn = true,
    this.dividerThickness,
    this.showBottomBorder = false,
    this.checkboxHorizontalMargin,
  })  : assert(pageSizeOptions.isNotEmpty);

  @override
  State<TableCollectionBuilder<Item>> createState() =>
      _TableCollectionBuilderState<Item>();
}

class _TableCollectionBuilderState<Item>
    extends State<TableCollectionBuilder<Item>> {
  final _continueSemaphore = Semaphore();
  int _page = 0;
  late int _pageSize;

  @override
  void initState() {
    super.initState();
    _pageSize = widget.pageSizeOptions.first;
    _loadPage(_page);
  }

  @override
  Widget build(BuildContext context) {
    return PropertyBuilder<PagedCollectionModel<Item>>(
      stream: widget.collection.stream,
      error: _buildError,
      value: _build,
      loading: _buildLoading,
    );
  }

  Widget _build(BuildContext context, PagedCollectionModel<Item> model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTable(context, model.items),
        PageNavigation(
          pageSize: _pageSize,
          pageSizeOptions: widget.pageSizeOptions,
          totalCount: model.size,
          currentPage: _page,
          onNextPagePressed: () => _loadPage(_page + 1),
          onPreviousPagePressed: () => _loadPage(_page - 1),
          onFirstPagePressed: () => _loadPage(0),
          onLastPagePressed: () =>
              _loadPage((model.size / _pageSize).ceil() - 1),
          onRowsPerPageChanged: (size) => _setPageSize(size, model.size),
        )
      ],
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTable(context, []),
        if (widget.loadingBuilder != null) widget.loadingBuilder!(context),
        if (widget.loadingBuilder == null) const LoadingSpinner()
      ],
    );
  }

  Widget _buildTable(BuildContext context, Iterable<Item> items) {
    return DataTable(
      checkboxHorizontalMargin: widget.checkboxHorizontalMargin,
      columnSpacing: widget.columnSpacing,
      columns: widget.columns,
      dataTextStyle: widget.dataTextStyle,
      decoration: widget.decoration,
      dividerThickness: widget.dividerThickness,
      headingTextStyle: widget.headingTextStyle,
      onSelectAll: widget.onSelectAll,
      showCheckboxColumn: widget.showCheckboxColumn,
      dataRowMinHeight: widget.dataRowMinHeight,
      dataRowMaxHeight: widget.dataRowMaxHeight,
      headingRowHeight: widget.headingRowHeight,
      horizontalMargin: widget.horizontalMargin,
      dataRowColor: widget.dataRowColor,
      headingRowColor: widget.headingRowColor,
      showBottomBorder: widget.showBottomBorder,
      sortAscending: widget.sortAscending,
      sortColumnIndex: widget.sortColumnIndex,
      rows: items
          .map((item) => widget.rowBuilder(context, item))
          .toList(growable: false),
    );
  }

  Widget _buildError(BuildContext context, dynamic error) {
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(context, error);
    } else {
      // fallback loading indicator
      return ErrorText(error.toString());
    }
  }

  Future<void> _loadPage(int page, {bool refresh = false}) async {
    await _continueSemaphore.throttle(() async {
      _page = page;
      await widget.collection.setPage(page, _pageSize, invalidate: refresh);
    });
  }

  void _setPageSize(int rows, int size) {
    setState(() {
      final pages = (size / rows).ceil();
      _pageSize = rows;
      _loadPage((_page >= pages) ? pages - 1 : _page);
    });
  }
}
