import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/theme_mode_provider.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/wiggle_animation.dart';
import '../providers/rewards_provider.dart';

enum PinMode { create, verify }

class PinScreen extends ConsumerStatefulWidget {
  final PinMode mode;
  final VoidCallback onSuccess;

  const PinScreen({super.key, required this.mode, required this.onSuccess});

  @override
  ConsumerState<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends ConsumerState<PinScreen> {
  String _input = '';
  String? _firstPin; // used in create mode to hold first entry before confirm
  bool _isConfirming = false; // create mode: second entry
  String? _error;
  int _shakeTrigger = 0;

  void _shake() {
    setState(() => _shakeTrigger++);
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
    final l10n = AppLocalizations.of(context)!;
    if (widget.mode == PinMode.verify) {
      final ok = ref.read(rewardsProvider.notifier).verifyPin(_input);
      if (ok) {
        widget.onSuccess();
      } else {
        _shake();
        setState(() {
          _input = '';
          _error = l10n.pinWrong;
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
          _error = l10n.pinMismatch;
        });
      }
    }
  }

  String _title(AppLocalizations l10n) {
    if (widget.mode == PinMode.verify) return l10n.pinTitleVerify;
    return _isConfirming ? l10n.pinTitleConfirm : l10n.pinTitleCreate;
  }

  String _subtitle(AppLocalizations l10n) {
    if (widget.mode == PinMode.verify) return l10n.pinSubtitleVerify;
    return _isConfirming ? l10n.pinSubtitleConfirm : l10n.pinSubtitleCreate;
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(appPaletteProvider);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: colors.bgDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: colors.textSecondary),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            const Text('👨‍👩‍👧',
                style: TextStyle(fontSize: 52), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Text(_title(l10n),
                style: AppTextStyles.headline2(colors),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(_subtitle(l10n),
                style: AppTextStyles.body(colors)
                    .copyWith(color: colors.textMuted),
                textAlign: TextAlign.center),
            const SizedBox(height: 40),
            // Dot indicators with shake animation on a wrong PIN
            WiggleAnimation(
              trigger: _shakeTrigger,
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
                      color: filled ? colors.primaryLight : colors.bgCardLight,
                      border: Border.all(color: colors.bgCardLight),
                    ),
                  );
                }),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: AppTextStyles.label(colors)
                      .copyWith(color: colors.accentCoral)),
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

class _PadKey extends ConsumerWidget {
  final String label;
  final VoidCallback onTap;

  const _PadKey({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appPaletteProvider);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: colors.bgCard,
          shape: BoxShape.circle,
          border: Border.all(color: colors.bgCardLight),
        ),
        child: Center(
          child: Text(
            label,
            style: label == '⌫'
                ? AppTextStyles.headline3(colors)
                    .copyWith(color: colors.textMuted)
                : AppTextStyles.headline2(colors),
          ),
        ),
      ),
    );
  }
}
