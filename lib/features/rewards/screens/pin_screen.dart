import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/rewards_provider.dart';

enum PinMode { create, verify }

class PinScreen extends ConsumerStatefulWidget {
  final PinMode mode;
  final VoidCallback onSuccess;

  const PinScreen({super.key, required this.mode, required this.onSuccess});

  @override
  ConsumerState<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends ConsumerState<PinScreen>
    with SingleTickerProviderStateMixin {
  String _input = '';
  String? _firstPin; // used in create mode to hold first entry before confirm
  bool _isConfirming = false; // create mode: second entry
  String? _error;

  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _shake() {
    _shakeCtrl.forward(from: 0);
  }

  void _onDigit(String d) {
    if (_input.length >= 4) return;
    HapticFeedback.selectionClick();
    setState(() {
      _input += d;
      _error = null;
    });
    if (_input.length == 4) _onComplete();
  }

  void _onBackspace() {
    if (_input.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() => _input = _input.substring(0, _input.length - 1));
  }

  Future<void> _onComplete() async {
    if (widget.mode == PinMode.verify) {
      final ok = ref.read(rewardsProvider.notifier).verifyPin(_input);
      if (ok) {
        widget.onSuccess();
      } else {
        _shake();
        setState(() {
          _input = '';
          _error = 'Wrong PIN — try again';
        });
      }
      return;
    }

    // create mode
    if (!_isConfirming) {
      setState(() {
        _firstPin = _input;
        _input = '';
        _isConfirming = true;
      });
    } else {
      if (_input == _firstPin) {
        await ref.read(rewardsProvider.notifier).setPin(_input);
        widget.onSuccess();
      } else {
        _shake();
        setState(() {
          _input = '';
          _firstPin = null;
          _isConfirming = false;
          _error = "PINs didn't match — start again";
        });
      }
    }
  }

  String get _title {
    if (widget.mode == PinMode.verify) return 'Parent PIN';
    return _isConfirming ? 'Confirm PIN' : 'Create Parent PIN';
  }

  String get _subtitle {
    if (widget.mode == PinMode.verify) return 'Enter your 4-digit PIN';
    return _isConfirming
        ? 'Enter the same PIN again'
        : 'Choose a 4-digit PIN for the Parent Zone';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.textSecondary),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            const Text('👨‍👩‍👧', style: TextStyle(fontSize: 52),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Text(_title, style: AppTextStyles.headline2,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(_subtitle,
                style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center),
            const SizedBox(height: 40),
            // Dot indicators with shake animation
            AnimatedBuilder(
              animation: _shakeAnim,
              builder: (context, child) {
                final offset =
                    Offset(8 * _shakeAnim.value * (_shakeCtrl.value < 0.5 ? 1 : -1), 0);
                return Transform.translate(offset: offset, child: child);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final filled = i < _input.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? AppColors.primaryLight : AppColors.bgCardLight,
                      border: Border.all(color: AppColors.bgCardLight),
                    ),
                  );
                }),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: AppTextStyles.label
                      .copyWith(color: AppColors.accentCoral)),
            ],
            const Spacer(),
            // Number pad
            _NumPad(onDigit: _onDigit, onBackspace: _onBackspace),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _NumPad extends StatelessWidget {
  final void Function(String) onDigit;
  final VoidCallback onBackspace;

  const _NumPad({required this.onDigit, required this.onBackspace});

  @override
  Widget build(BuildContext context) {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: rows.map((row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: row.map((label) {
              if (label.isEmpty) return const SizedBox(width: 72, height: 72);
              return _PadKey(
                label: label,
                onTap: label == '⌫' ? onBackspace : () => onDigit(label),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}

class _PadKey extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PadKey({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.bgCardLight),
        ),
        child: Center(
          child: Text(
            label,
            style: label == '⌫'
                ? AppTextStyles.headline3.copyWith(color: AppColors.textMuted)
                : AppTextStyles.headline2,
          ),
        ),
      ),
    );
  }
}
