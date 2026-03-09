import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/presentation/providers/auth_provider.dart';
import 'package:expense_tracker/shared/widgets/pin_pad.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool _showPinPad = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      // Auto-trigger biometric on first load if PIN is not the only option
      if (!_showPinPad) {
        auth.authenticate();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _showPinPad
            ? _buildPinView(authProvider)
            : _buildBiometricView(authProvider),
      ),
    );
  }

  Widget _buildBiometricView(AuthProvider authProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            size: 80,
            color: AppColors.primary,
          ),
          const SizedBox(height: 24),
          const Text(
            'App Locked',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Authenticate to continue',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 48),
          if (authProvider.isChecking || authProvider.isAuthenticating)
            const CircularProgressIndicator(color: AppColors.primary)
          else ...[
            ElevatedButton.icon(
              onPressed: () => authProvider.authenticate(),
              icon: const Icon(Icons.fingerprint),
              label: const Text('Verify Identity'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (authProvider.hasPinSet) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => _showPinPad = true),
                child: const Text(
                  'Use PIN instead',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildPinView(AuthProvider authProvider) {
    return Column(
      children: [
        // Back to biometric button
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TextButton.icon(
              onPressed: () => setState(() => _showPinPad = false),
              icon: const Icon(Icons.fingerprint, size: 18),
              label: const Text('Use biometric'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ),
        ),
        Expanded(
          child: PinPad(
            title: 'Enter PIN',
            subtitle: 'Enter your 4-digit PIN to unlock',
            onComplete: (pin) async {
              final matched = await authProvider.verifyPin(pin);
              return matched ? PinResult.success : PinResult.error;
            },
          ),
        ),
      ],
    );
  }
}
