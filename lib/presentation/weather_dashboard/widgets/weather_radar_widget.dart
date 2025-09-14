import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class WeatherRadarWidget extends StatefulWidget {
  final bool isVisible;
  final VoidCallback onClose;

  const WeatherRadarWidget({
    Key? key,
    required this.isVisible,
    required this.onClose,
  }) : super(key: key);

  @override
  State<WeatherRadarWidget> createState() => _WeatherRadarWidgetState();
}

class _WeatherRadarWidgetState extends State<WeatherRadarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  bool _isPlaying = false;
  double _currentFrame = 0;
  final int _totalFrames = 12;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isVisible) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(WeatherRadarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleAnimation() {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      _startRadarAnimation();
    }
  }

  void _startRadarAnimation() {
    if (!_isPlaying) return;

    Future.delayed(const Duration(milliseconds: 500), () {
      if (_isPlaying && mounted) {
        setState(() {
          _currentFrame = (_currentFrame + 1) % _totalFrames;
        });
        _startRadarAnimation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 100.h),
          child: Container(
            height: 100.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.primaryColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'radar',
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          'Weather Radar',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: widget.onClose,
                        icon: CustomIconWidget(
                          iconName: 'close',
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),

                // Controls
                Container(
                  padding: EdgeInsets.all(4.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _toggleAnimation,
                        icon: CustomIconWidget(
                          iconName: _isPlaying ? 'pause' : 'play_arrow',
                          color: Colors.white,
                          size: 20,
                        ),
                        label: Text(_isPlaying ? 'Pause' : 'Play'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.lightTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.primaryColor
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Frame: ${_currentFrame + 1}/$_totalFrames',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Radar Map
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.lightTheme.dividerColor,
                        width: 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Map placeholder
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: const DecorationImage(
                              image: NetworkImage(
                                  'https://images.pexels.com/photos/87651/earth-blue-planet-globe-planet-87651.jpeg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        // Precipitation overlay
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: RadialGradient(
                              center: Alignment.center,
                              radius: 0.8,
                              colors: [
                                Colors.blue
                                    .withValues(alpha: _isPlaying ? 0.3 : 0.1),
                                Colors.green
                                    .withValues(alpha: _isPlaying ? 0.2 : 0.05),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),

                        // Location marker
                        Positioned(
                          top: 45.h,
                          left: 45.w,
                          child: Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.primaryColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.lightTheme.primaryColor
                                      .withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: CustomIconWidget(
                              iconName: 'location_on',
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),

                        // Legend
                        Positioned(
                          bottom: 2.h,
                          left: 4.w,
                          child: Container(
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Precipitation',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleSmall
                                      ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                _buildLegendItem('Light', Colors.green),
                                _buildLegendItem('Moderate', Colors.yellow),
                                _buildLegendItem('Heavy', Colors.orange),
                                _buildLegendItem('Severe', Colors.red),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Time slider
                Container(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    children: [
                      Text(
                        'Time: ${_getTimeLabel(_currentFrame.toInt())}',
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Slider(
                        value: _currentFrame.toDouble(),
                        min: 0,
                        max: (_totalFrames - 1).toDouble(),
                        divisions: _totalFrames - 1,
                        onChanged: (value) {
                          setState(() {
                            _currentFrame = value;
                          });
                        },
                        activeColor: AppTheme.lightTheme.primaryColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.5.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4.w,
            height: 2.h,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 2.w),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  String _getTimeLabel(int frame) {
    final now = DateTime.now();
    final time = now.subtract(Duration(hours: (_totalFrames - 1 - frame)));
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}