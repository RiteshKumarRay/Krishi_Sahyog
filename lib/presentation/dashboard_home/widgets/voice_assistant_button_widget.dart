import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class VoiceAssistantButtonWidget extends StatefulWidget {
  final bool isListening;
  final VoidCallback? onTap;

  const VoiceAssistantButtonWidget({
    Key? key,
    this.isListening = false,
    this.onTap,
  }) : super(key: key);

  @override
  State<VoiceAssistantButtonWidget> createState() =>
      _VoiceAssistantButtonWidgetState();
}

class _VoiceAssistantButtonWidgetState extends State<VoiceAssistantButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isListening) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(VoiceAssistantButtonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening != oldWidget.isListening) {
      if (widget.isListening) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Pulse effect when listening
              if (widget.isListening)
                Container(
                  width: 20.w * (1 + _pulseAnimation.value * 0.3),
                  height: 20.w * (1 + _pulseAnimation.value * 0.3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.lightTheme.primaryColor.withValues(
                      alpha: 0.2 * (1 - _pulseAnimation.value),
                    ),
                  ),
                ),
              // Main button
              Transform.scale(
                scale: widget.isListening ? _scaleAnimation.value : 1.0,
                child: GestureDetector(
                  onTap: widget.onTap,
                  child: Container(
                    width: 16.w,
                    height: 16.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.isListening
                            ? [
                                AppTheme.lightTheme.colorScheme.error,
                                AppTheme.lightTheme.colorScheme.error
                                    .withValues(alpha: 0.8),
                              ]
                            : [
                                AppTheme.lightTheme.primaryColor,
                                AppTheme.lightTheme.primaryColor
                                    .withValues(alpha: 0.8),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (widget.isListening
                                  ? AppTheme.lightTheme.colorScheme.error
                                  : AppTheme.lightTheme.primaryColor)
                              .withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CustomIconWidget(
                      iconName: widget.isListening ? 'stop' : 'mic',
                      color: Colors.white,
                      size: 7.w,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
