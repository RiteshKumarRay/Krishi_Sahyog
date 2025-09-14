import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LanguageToggleButton extends StatefulWidget {
  final Function(String) onLanguageChanged;
  final String currentLanguage;

  const LanguageToggleButton({
    Key? key,
    required this.onLanguageChanged,
    this.currentLanguage = 'hi',
  }) : super(key: key);

  @override
  State<LanguageToggleButton> createState() => _LanguageToggleButtonState();
}

class _LanguageToggleButtonState extends State<LanguageToggleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  String _selectedLanguage = 'hi';

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.currentLanguage;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void _toggleLanguage() {
    _animationController.forward().then((_) {
      setState(() {
        _selectedLanguage = _selectedLanguage == 'hi' ? 'en' : 'hi';
      });
      widget.onLanguageChanged(_selectedLanguage);
      _animationController.reverse();
    });
  }

  String get _languageText {
    return _selectedLanguage == 'hi' ? 'हिं' : 'EN';
  }

  String get _fullLanguageName {
    return _selectedLanguage == 'hi' ? 'हिंदी' : 'English';
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleLanguage,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.outline,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightTheme.colorScheme.shadow,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value * 3.14159,
                  child: CustomIconWidget(
                    iconName: 'language',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 5.w,
                  ),
                );
              },
            ),
            SizedBox(width: 2.w),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _languageText,
                  style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _fullLanguageName,
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    fontSize: 8.sp,
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
