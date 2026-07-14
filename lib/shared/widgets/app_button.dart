import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/theme_mode_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum _ButtonVariant { play, primary, secondary }

class AppButton extends ConsumerStatefulWidget {
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;
  final _ButtonVariant _variant;

  const AppButton._({
    required this.label,
    this.subtitle,
    required this.onTap,
    required _ButtonVariant variant,
  }) : _variant = variant;

  factory AppButton.play({
    required String label,
    required VoidCallback? onTap,
  }) =>
      AppButton._(label: label, onTap: onTap, variant: _ButtonVariant.play);

  factory AppButton.primary({
    required String label,
    String? subtitle,
    required VoidCallback? onTap,
  }) =>
      AppButton._(
        label: label,
        subtitle: subtitle,
        onTap: onTap,
        variant: _ButtonVariant.primary,
      );

  factory AppButton.secondary({
    required String label,
    required VoidCallback? onTap,
  }) =>
      AppButton._(
          label: label, onTap: onTap, variant: _ButtonVariant.secondary);

  @override
  ConsumerState<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends ConsumerState<AppButton>
    with SingleTickerProviderStateMixin {
  static const double _sinkDistance = 4.0;

  late final AnimationController _pressCtrl;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 150),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  bool get _isOutlined => widget._variant == _ButtonVariant.secondary;

  Gradient? _gradient(AppPalette c) => switch (widget._variant) {
        _ButtonVariant.play => c.playGradient,
        _ButtonVariant.primary => c.primaryGradient,
        _ButtonVariant.secondary => null,
      };

  // Flat, non-blurry shadow that fades out as the button sinks on press —
  // mimics a physical button losing its "lift" while held down.
  List<BoxShadow> _shadow(AppPalette c, double pressProgress) => _isOutlined
      ? []
      : [
          BoxShadow(
            color: (widget._variant == _ButtonVariant.play
                    ? c.playGradient.colors.first
                    : c.primary)
                .withValues(alpha: 0.45 * (1 - pressProgress)),
            blurRadius: 20 * (1 - pressProgress),
            offset: Offset(0, 8 * (1 - pressProgress)),
          ),
        ];

  void _onTapDown(_) {
    if (widget.onTap == null) return;
    _pressCtrl.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(_) => _pressCtrl.reverse();

  void _onTapCancel() => _pressCtrl.reverse();

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(appPaletteProvider);
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pressCtrl,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, _sinkDistance * _pressCtrl.value),
          child: Container(
            width: double.infinity,
            height: widget.subtitle == null ? 64 : 72,
            padding: widget.subtitle == null
                ? null
                : const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: _gradient(colors),
              color: _isOutlined ? Colors.transparent : null,
              borderRadius: BorderRadius.circular(20),
              border: _isOutlined
                  ? Border.all(color: colors.primaryLight, width: 2)
                  : null,
              boxShadow: _shadow(colors, _pressCtrl.value),
            ),
            child: child,
          ),
        ),
        child: Center(
          child: widget.subtitle == null
              ? Text(
                  widget.label,
                  style: AppTextStyles.buttonText(colors).copyWith(
                    color:
                        _isOutlined ? colors.primaryLight : colors.textPrimary,
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.label,
                      style: AppTextStyles.buttonText(colors).copyWith(
                        color: _isOutlined
                            ? colors.primaryLight
                            : colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle!,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.label(colors).copyWith(
                        color: _isOutlined
                            ? colors.primaryLight.withValues(alpha: 0.85)
                            : colors.textPrimary.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
