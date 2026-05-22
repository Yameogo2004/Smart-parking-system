import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/text_styles.dart';

class AppDataTableColumn {
  final String label;
  final int flex;
  final TextAlign textAlign;

  const AppDataTableColumn({
    required this.label,
    this.flex = 1,
    this.textAlign = TextAlign.left,
  });
}

class AppDataTableCell {
  final Widget child;
  final int flex;

  const AppDataTableCell({
    required this.child,
    this.flex = 1,
  });
}

class AppDataTableRowData {
  final List<AppDataTableCell> cells;
  final VoidCallback? onTap;

  const AppDataTableRowData({
    required this.cells,
    this.onTap,
  });
}

class AppDataTable extends StatelessWidget {
  final List<AppDataTableColumn> columns;
  final List<AppDataTableRowData> rows;
  final String? emptyLabel;
  final EdgeInsetsGeometry? padding;

  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.emptyLabel,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return Container(
        width: double.infinity,
        padding: padding ?? const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text(
            emptyLabel ?? 'Aucune donnée disponible.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadius.xxl),
                topRight: Radius.circular(AppRadius.xxl),
              ),
            ),
            child: Row(
              children: columns
                  .map(
                    (column) => Expanded(
                      flex: column.flex,
                      child: Text(
                        column.label,
                        textAlign: column.textAlign,
                        style: AppTextStyles.titleSmall,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          ...rows.map(
            (row) => _AppDataTableRow(row: row),
          ),
        ],
      ),
    );
  }
}

class _AppDataTableRow extends StatelessWidget {
  final AppDataTableRowData row;

  const _AppDataTableRow({
    required this.row,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: row.cells
            .map(
              (cell) => Expanded(
                flex: cell.flex,
                child: cell.child,
              ),
            )
            .toList(),
      ),
    );

    if (row.onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: row.onTap,
        child: content,
      ),
    );
  }
}
