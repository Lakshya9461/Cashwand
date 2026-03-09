import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/presentation/providers/auth_provider.dart';
import 'package:expense_tracker/shared/widgets/pin_pad.dart';

class SetPinScreen extends StatefulWidget {
  const SetPinScreen({super.key});

  @override
  State<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  String? _firstPin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Set PIN')),
      body: SafeArea(
        child: PinPad(
          title: _firstPin == null ? 'Create PIN' : 'Confirm PIN',
          subtitle: _firstPin == null
              ? 'Choose a 4-digit PIN'
              : 'Re-enter your PIN to confirm',
          onComplete: (pin) async {
            if (_firstPin == null) {
              // First entry — store and ask for confirmation
              setState(() => _firstPin = pin);
              return PinResult.reset; // Silently clear dots, no error
            } else {
              // Confirmation step
              if (pin == _firstPin) {
                final auth = context.read<AuthProvider>();
                final messenger = ScaffoldMessenger.of(context);
                final router = GoRouter.of(context);
                await auth.setPin(pin);
                if (mounted) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('PIN set successfully!')),
                  );
                  router.pop();
                }
                return PinResult.success;
              } else {
                // Mismatch — restart
                final messenger = ScaffoldMessenger.of(context);
                setState(() => _firstPin = null);
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('PINs didn\'t match. Try again.'),
                  ),
                );
                return PinResult.error;
              }
            }
          },
        ),
      ),
    );
  }
}
