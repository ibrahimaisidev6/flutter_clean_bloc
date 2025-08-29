import 'package:flutter/material.dart';
import '../../core/utils/responsive_utils.dart';

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;
  final double runSpacing;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveUtils.getResponsiveColumns(
      context,
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
    );

    if (columns == 1) {
      return Column(
        children: children.map((child) => Padding(
          padding: EdgeInsets.only(bottom: runSpacing),
          child: child,
        )).toList(),
      );
    }

    // Create rows with the specified number of columns
    final rows = <Widget>[];
    for (int i = 0; i < children.length; i += columns) {
      final rowChildren = <Widget>[];
      for (int j = 0; j < columns; j++) {
        if (i + j < children.length) {
          rowChildren.add(Expanded(child: children[i + j]));
          if (j < columns - 1 && i + j + 1 < children.length) {
            rowChildren.add(SizedBox(width: spacing));
          }
        } else {
          rowChildren.add(const Spacer());
        }
      }
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rowChildren,
        ),
      );
      if (i + columns < children.length) {
        rows.add(SizedBox(height: runSpacing));
      }
    }

    Widget content = Column(
      children: rows,
    );

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    return content;
  }
}

class ResponsiveStaggeredGrid extends StatelessWidget {
  final List<ResponsiveGridItem> items;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;
  final double runSpacing;
  final EdgeInsets? padding;

  const ResponsiveStaggeredGrid({
    super.key,
    required this.items,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveUtils.getResponsiveColumns(
      context,
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
    );

    // Create column heights tracking
    final columnHeights = List.generate(columns, (index) => 0.0);
    final columnWidgets = List.generate(columns, (index) => <Widget>[]);

    // Distribute items to columns
    for (final item in items) {
      // Find the column with minimum height
      int targetColumn = 0;
      double minHeight = columnHeights[0];
      for (int i = 1; i < columns; i++) {
        if (columnHeights[i] < minHeight) {
          minHeight = columnHeights[i];
          targetColumn = i;
        }
      }

      // Add item to target column
      columnWidgets[targetColumn].add(item.child);
      columnHeights[targetColumn] += item.height ?? 200; // Default estimated height

      // Add spacing except for the first item
      if (columnWidgets[targetColumn].length > 1) {
        columnWidgets[targetColumn].insert(
          columnWidgets[targetColumn].length - 1,
          SizedBox(height: runSpacing),
        );
      }
    }

    // Build the grid
    final columnChildren = <Widget>[];
    for (int i = 0; i < columns; i++) {
      columnChildren.add(
        Expanded(
          child: Column(
            children: columnWidgets[i],
          ),
        ),
      );
      if (i < columns - 1) {
        columnChildren.add(SizedBox(width: spacing));
      }
    }

    Widget content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: columnChildren,
    );

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    return content;
  }
}

class ResponsiveGridItem {
  final Widget child;
  final double? height;
  final int? flex;

  const ResponsiveGridItem({
    required this.child,
    this.height,
    this.flex,
  });
}

class ResponsiveWrap extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final WrapAlignment alignment;
  final WrapCrossAlignment crossAxisAlignment;
  final double? itemWidth;
  final double? minItemWidth;
  final double? maxItemWidth;

  const ResponsiveWrap({
    super.key,
    required this.children,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.alignment = WrapAlignment.start,
    this.crossAxisAlignment = WrapCrossAlignment.start,
    this.itemWidth,
    this.minItemWidth,
    this.maxItemWidth,
  });

  @override
  Widget build(BuildContext context) {
    if (itemWidth != null) {
      return Wrap(
        spacing: spacing,
        runSpacing: runSpacing,
        alignment: alignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children.map((child) => SizedBox(
          width: itemWidth,
          child: child,
        )).toList(),
      );
    }

    if (minItemWidth != null || maxItemWidth != null) {
      final screenWidth = MediaQuery.of(context).size.width;
      final availableWidth = screenWidth - (spacing * 2);
      
      double calculatedWidth = availableWidth / children.length;
      
      if (minItemWidth != null && calculatedWidth < minItemWidth!) {
        calculatedWidth = minItemWidth!;
      }
      
      if (maxItemWidth != null && calculatedWidth > maxItemWidth!) {
        calculatedWidth = maxItemWidth!;
      }

      return Wrap(
        spacing: spacing,
        runSpacing: runSpacing,
        alignment: alignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children.map((child) => SizedBox(
          width: calculatedWidth,
          child: child,
        )).toList(),
      );
    }

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      alignment: alignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
  }
}