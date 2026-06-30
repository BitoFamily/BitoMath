import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum _ButtonVariant { play, primary, secondary }

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final _ButtonVariant _variant;

  const AppButton._({
    required this.label,
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
    required VoidCallback? onTap,
  }) =>
      AppButton._(label: label, onTap: onTap, variant: _ButtonVariant.primary);

  factory AppButton.secondary({
    required String label,
    required VoidCallback? onTap,
  }) =>
      AppButton._(label: label, onTap: onTap, variant: _ButtonVariant.secondary);

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scaleAnim;

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
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  bool get _isOutlined => widget._variant == _ButtonVariant.secondary;

  Gradient? get _gradient => switch (widget._variant) {
        _ButtonVariant.play => AppColors.playGradient,
        _ButtonVariant.primary => AppColors.primaryGradient,
        _ButtonVariant.secondary => null,
      };

  List<BoxShadow> get _shadow => _isOutlined
      ? []
      : [
          BoxShadow(
            color: (widget._variant == _ButtonVariant.play
                    ? const Color(0xFFFF6B35)
                    : AppColors.primary)
                .withOpacity(0.45),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          width: double.infinity,
          height: 64,
          decoration: BoxDecoration(
            gradient: _gradient,
            color: _isOutlined ? Colors.transparent : null,
            borderRadius: BorderRadius.circular(20),
            border: _isOutlined
                ? Border.all(color: AppColors.primaryLight, width: 2)
                : null,
            boxShadow: _shadow,
          ),
          child: Center(
            child: Text(
              widget.label,
              style: AppTextStyles.buttonText.copyWith(
                color: _isOutlined
                    ? AppColors.primaryLight
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
