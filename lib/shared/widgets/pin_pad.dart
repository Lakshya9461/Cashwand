import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';

/// Result from PIN entry callback.
enum PinResult {
  /// PIN accepted — success
  success,

  /// PIN rejected — show error shake
  error,

  /// PIN noted — clear dots without error (used for "enter again to confirm")
  reset,
}

/// A reusable 4-digit PIN entry pad with visual dot indicators.
class PinPad extends StatefulWidget {
  final String title;
  final String? subtitle;

  /// Called when 4 digits are entered.
  /// Return [PinResult.success] to accept, [PinResult.error] to shake,
  /// or [PinResult.reset] to silently clear.
  final Future<PinResult> Function(String pin) onComplete;

  const PinPad({
    super.key,
    required this.title,
    this.subtitle,
    required this.onComplete,
  });

  @override
  State<PinPad> createState() => _PinPadState();
}

class _PinPadState extends State<PinPad> with SingleTickerProviderStateMixin {
  String _pin = '';
  bool _isError = false;
  bool _isProcessing = false;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onDigit(String digit) {
    if (_pin.length >= 4 || _isProcessing) return;
    HapticFeedback.lightImpact();

    setState(() {
      _pin += digit;
      _isError = false;
    });

    if (_pin.length == 4) {
      _submit();
    }
  }

  void _onDelete() {
    if (_pin.isEmpty || _isProcessing) return;
    HapticFeedback.lightImpact();
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _isError = false;
    });
  }

  Future<void> _submit() async {
    setState(() => _isProcessing = true);
    final result = await widget.onComplete(_pin);

    if (!mounted) return;

    switch (result) {
      case PinResult.success:
        setState(() => _isProcessing = false);
        break;
      case PinResult.error:
        _shakeController.forward(from: 0);
        HapticFeedback.heavyImpact();
        setState(() {
          _isError = true;
          _pin = '';
          _isProcessing = false;
        });
        break;
      case PinResult.reset:
        // Silently clear — no error shake
        setState(() {
          _isError = false;
          _pin = '';
          _isProcessing = false;
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        if (widget.subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.subtitle!,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: 32),

        // Dot indicators
        AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            final offset = _shakeController.isAnimating
                ? 10.0 *
                      (0.5 - _shakeController.value).abs() *
                      (_shakeController.value < 0.25 ||
                              _shakeController.value > 0.75
                          ? 1
                          : -1)
                : 0.0;
            return Transform.translate(offset: Offset(offset, 0), child: child);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              final filled = i < _pin.length;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isError
                      ? AppColors.expense
                      : filled
                      ? AppColors.primary
                      : Colors.transparent,
                  border: Border.all(
                    color: _isError ? AppColors.expense : AppColors.primary,
                    width: 2,
                  ),
                ),
              );
            }),
          ),
        ),
        if (_isError) ...[
          const SizedBox(height: 12),
          const Text(
            'Incorrect PIN. Try again.',
            style: TextStyle(color: AppColors.expense, fontSize: 13),
          ),
        ],
        const SizedBox(height: 40),

        // Number grid
        _buildNumberGrid(),
      ],
    );
  }

  Widget _buildNumberGrid() {
    final rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'del'],
    ];

    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) {
              if (key.isEmpty) {
                return const SizedBox(width: 80, height: 64);
              }
              if (key == 'del') {
                return SizedBox(
                  width: 80,
                  height: 64,
                  child: IconButton(
                    onPressed: _onDelete,
                    icon: const Icon(
                      Icons.backspace_outlined,
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }
              return _buildDigitButton(key);
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDigitButton(String digit) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SizedBox(
        width: 64,
        height: 64,
        child: TextButton(
          onPressed: () => _onDigit(digit),
          style: TextButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: AppColors.surfaceLight,
          ),
          child: Text(
            digit,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
