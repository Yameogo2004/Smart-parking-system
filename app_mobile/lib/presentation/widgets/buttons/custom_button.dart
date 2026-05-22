import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/text_styles.dart';

enum CustomButtonVariant {
  primary,
  secondary,
  outlined,
  danger,
  ghost,
}

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final CustomButtonVariant variant;
  final bool isLoading;
  final bool isExpanded;
  final double? width;
  final double height;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = CustomButtonVariant.primary,
    this.isLoading = false,
    this.isExpanded = true,
    this.width,
    this.height = AppSpacing.buttonHeight,
    this.leadingIcon,
    this.trailingIcon,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final _ButtonStyleConfig config = _resolveStyle();

    final bool isDisabled = onPressed == null || isLoading;

    Widget child = Container(
      width: isExpanded ? double.infinity : width,
      height: height,
      padding: padding,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: isDisabled
              ? AppColors.grey700
              : config.backgroundColor,
          foregroundColor: isDisabled
              ? AppColors.grey400
              : config.foregroundColor,
          disabledBackgroundColor: AppColors.grey700,
          disabledForegroundColor: AppColors.grey400,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: BorderSide(
              color: config.borderColor,
              width: config.hasBorder ? 1.1 : 0,
            ),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    config.foregroundColor,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize:
                    isExpanded ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  if (leadingIcon != null) ...[
                    Icon(leadingIcon, size: 18),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: config.foregroundColor,
                      ),
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Icon(trailingIcon, size: 18),
                  ],
                ],
              ),
      ),
    );

    if (variant == CustomButtonVariant.ghost) {
      child = SizedBox(
        width: isExpanded ? double.infinity : width,
        height: height,
        child: TextButton(
          onPressed: isDisabled ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: isDisabled
                ? AppColors.grey400
                : config.foregroundColor,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2.2),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize:
                      isExpanded ? MainAxisSize.max : MainAxisSize.min,
                  children: [
                    if (leadingIcon != null) ...[
                      Icon(leadingIcon, size: 18),
                      const SizedBox(width: AppSpacing.xs),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: config.foregroundColor,
                        ),
                      ),
                    ),
                    if (trailingIcon != null) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Icon(trailingIcon, size: 18),
                    ],
                  ],
                ),
        ),
      );
    }

    return child;
  }

  _ButtonStyleConfig _resolveStyle() {
    switch (variant) {
      case CustomButtonVariant.primary:
        return const _ButtonStyleConfig(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          borderColor: AppColors.primary,
          hasBorder: false,
        );

      case CustomButtonVariant.secondary:
        return const _ButtonStyleConfig(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.textOnPrimary,
          borderColor: AppColors.secondary,
          hasBorder: false,
        );

      case CustomButtonVariant.outlined:
        return const _ButtonStyleConfig(
          backgroundColor: AppColors.card,
          foregroundColor: AppColors.textPrimary,
          borderColor: AppColors.border,
          hasBorder: true,
        );

      case CustomButtonVariant.danger:
        return const _ButtonStyleConfig(
          backgroundColor: AppColors.danger,
          foregroundColor: AppColors.textOnPrimary,
          borderColor: AppColors.danger,
          hasBorder: false,
        );

      case CustomButtonVariant.ghost:
        return const _ButtonStyleConfig(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primary,
          borderColor: Colors.transparent,
          hasBorder: false,
        );
    }
  }
}

class _ButtonStyleConfig {
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final bool hasBorder;

  const _ButtonStyleConfig({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.hasBorder,
  });
}
