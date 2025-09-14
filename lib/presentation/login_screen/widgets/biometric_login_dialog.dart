import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BiometricLoginDialog extends StatefulWidget {
  final VoidCallback onBiometricSuccess;
  final VoidCallback onBiometricCancel;
  final String currentLanguage;

  const BiometricLoginDialog({
    Key? key,
    required this.onBiometricSuccess,
    required this.onBiometricCancel,
    this.currentLanguage = 'hi',
  }) : super(key: key);

  @override
  State<BiometricLoginDialog> createState() => _BiometricLoginDialogState();
}

class _BiometricLoginDialogState extends State<BiometricLoginDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat(reverse: true);
  }

  Future<void> _authenticateWithBiometric() async {
    setState(() {
      _isAuthenticating = true;
    });

    try {
      // Simulate biometric authentication
      await Future.delayed(const Duration(seconds: 2));

      // Mock successful authentication
      HapticFeedback.lightImpact();
      widget.onBiometricSuccess();
    } catch (e) {
      setState(() {
        _isAuthenticating = false;
      });
      _showErrorMessage();
    }
  }

  void _showErrorMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.currentLanguage == 'hi'
              ? 'बायोमेट्रिक प्रमाणीकरण असफल'
              : 'Biometric authentication failed',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onError,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.currentLanguage == 'hi'
                  ? 'बायोमेट्रिक लॉगिन'
                  : 'Biometric Login',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isAuthenticating
                          ? CircularProgressIndicator(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              strokeWidth: 3,
                            )
                          : CustomIconWidget(
                              iconName: 'fingerprint',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 10.w,
                            ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 3.h),
            Text(
              widget.currentLanguage == 'hi'
                  ? 'अपनी उंगली को सेंसर पर रखें या फेस आईडी का उपयोग करें'
                  : 'Place your finger on the sensor or use Face ID',
              textAlign: TextAlign.center,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _isAuthenticating ? null : widget.onBiometricCancel,
                    child: Text(
                      widget.currentLanguage == 'hi' ? 'रद्द करें' : 'Cancel',
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        _isAuthenticating ? null : _authenticateWithBiometric,
                    child: Text(
                      widget.currentLanguage == 'hi'
                          ? 'प्रमाणित करें'
                          : 'Authenticate',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
