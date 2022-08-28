import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PageNavigation extends StatelessWidget {
  final List<int> pageSizeOptions;
  final int pageSize;
  final int totalCount;
  final int currentPage;
  final VoidCallback? onNextPagePressed;
  final VoidCallback? onPreviousPagePressed;
  final VoidCallback? onFirstPagePressed;
  final VoidCallback? onLastPagePressed;
  final Function(int rows) onRowsPerPageChanged;

  PageNavigation(
      {Key? key,
      this.pageSizeOptions = const [10, 20, 50, 100],
      required this.pageSize,
      required this.totalCount,
      required this.currentPage,
      required this.onNextPagePressed,
      required this.onPreviousPagePressed,
      required this.onFirstPagePressed,
      required this.onLastPagePressed,
      required this.onRowsPerPageChanged})
      : assert(pageSizeOptions.isNotEmpty),
        super(key: key);

  bool get hasNextPage => currentPage < (totalCount / pageSize).ceil() - 1;

  bool get hasPreviousPage => currentPage > 0;

  bool get isFirstPage => currentPage == 0;

  bool get isLastPage => currentPage == (totalCount / pageSize).ceil() - 1;

  List<DropdownMenuItem<int>> get dropdownMenuItem =>
      pageSizeOptions.map<DropdownMenuItem<int>>((int value) {
        return DropdownMenuItem<int>(
          value: value,
          child: Text('$value'),
        );
      }).toList();

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(width: 14.0),
        Text(localizations.rowsPerPageTitle),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 64.0),
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                items: dropdownMenuItem.cast<DropdownMenuItem<int>>(),
                value: pageSize,
                onChanged: (value) =>
                    onRowsPerPageChanged(value ?? pageSizeOptions.first),
                iconSize: 24.0,
              ),
            ),
          ),
        ),
        Container(width: 32.0),
        Text(
          localizations.pageRowsInfoTitle(
            (pageSize * currentPage) + 1,
            min((pageSize * currentPage) + pageSize, totalCount),
            totalCount,
            false,
          ),
        ),
        Container(width: 32.0),
        if (onFirstPagePressed != null)
          IconButton(
            icon: const Icon(Icons.skip_previous),
            padding: EdgeInsets.zero,
            tooltip: localizations.firstPageTooltip,
            onPressed: isFirstPage ? null : onFirstPagePressed,
          ),
        IconButton(
          icon: const Icon(
            Icons.chevron_left,
          ),
          padding: EdgeInsets.zero,
          tooltip: localizations.previousPageTooltip,
          onPressed: hasPreviousPage ? onPreviousPagePressed : null,
        ),
        Container(width: 24.0),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          padding: EdgeInsets.zero,
          tooltip: localizations.nextPageTooltip,
          onPressed: hasNextPage ? onNextPagePressed : null,
        ),
        if (onLastPagePressed != null)
          IconButton(
            icon: const Icon(Icons.skip_next),
            padding: EdgeInsets.zero,
            tooltip: localizations.lastPageTooltip,
            onPressed: (isLastPage || totalCount <= pageSize)
                ? null
                : onLastPagePressed,
          ),
        Container(width: 14.0),
      ],
    );
  }
}
