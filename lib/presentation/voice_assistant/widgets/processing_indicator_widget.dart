import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProcessingIndicatorWidget extends StatefulWidget {
  final bool isVisible;
  final String message;

  const ProcessingIndicatorWidget({
    super.key,
    required this.isVisible,
    this.message = 'Analyzing...',
  });

  @override
  State<ProcessingIndicatorWidget> createState() =>
      _ProcessingIndicatorWidgetState();
}

class _ProcessingIndicatorWidgetState extends State<ProcessingIndicatorWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(ProcessingIndicatorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _startAnimations();
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _stopAnimations();
    }
  }

  void _startAnimations() {
    _rotationController.repeat();
    _scaleController.repeat(reverse: true);
  }

  void _stopAnimations() {
    _rotationController.stop();
    _scaleController.stop();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated agricultural icon
          AnimatedBuilder(
            animation: Listenable.merge([_rotationAnimation, _scaleAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.rotate(
                  angle: _rotationAnimation.value * 2 * 3.14159,
                  child: Container(
                    width: 16.w,
                    height: 16.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.lightTheme.primaryColor
                          .withValues(alpha: 0.1),
                      border: Border.all(
                        color: AppTheme.lightTheme.primaryColor,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: 'agriculture',
                        color: AppTheme.lightTheme.primaryColor,
                        size: 8.w,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 3.h),

          // Processing message
          Text(
            widget.message,
            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 2.h),

          // Animated dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return AnimatedBuilder(
                animation: _scaleController,
                builder: (context, child) {
                  final delay = index * 0.3;
                  final animationValue = (_scaleController.value + delay) % 1.0;
                  final opacity = (animationValue < 0.5)
                      ? animationValue * 2
                      : (1.0 - animationValue) * 2;

                  return Container(
                    width: 2.w,
                    height: 2.w,
                    margin: EdgeInsets.symmetric(horizontal: 1.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.lightTheme.primaryColor
                          .withValues(alpha: opacity),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
