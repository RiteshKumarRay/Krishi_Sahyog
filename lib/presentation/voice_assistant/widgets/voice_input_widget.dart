import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class VoiceInputWidget extends StatefulWidget {
  final Function(String) onVoiceInput;
  final bool isListening;
  final VoidCallback onStartListening;
  final VoidCallback onStopListening;

  const VoiceInputWidget({
    super.key,
    required this.onVoiceInput,
    required this.isListening,
    required this.onStartListening,
    required this.onStopListening,
  });

  @override
  State<VoiceInputWidget> createState() => _VoiceInputWidgetState();
}

class _VoiceInputWidgetState extends State<VoiceInputWidget>
    with TickerProviderStateMixin {
  final AudioRecorder _audioRecorder = AudioRecorder();
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;
  String? _recordingPath;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkPermissions();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _checkPermissions() async {
    if (kIsWeb) {
      setState(() => _hasPermission = true);
      return;
    }

    final status = await Permission.microphone.request();
    setState(() => _hasPermission = status.isGranted);
  }

  Future<void> _startRecording() async {
    if (!_hasPermission) {
      await _checkPermissions();
      if (!_hasPermission) return;
    }

    try {
      if (await _audioRecorder.hasPermission()) {
        if (kIsWeb) {
          await _audioRecorder.start(
            const RecordConfig(encoder: AudioEncoder.wav),
            path: 'voice_recording.wav',
          );
        } else {
          final dir = await getTemporaryDirectory();
          _recordingPath =
              '${dir.path}/voice_recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
          await _audioRecorder.start(
            const RecordConfig(encoder: AudioEncoder.aacLc),
            path: _recordingPath!,
          );
        }

        _pulseController.repeat(reverse: true);
        _waveController.repeat(reverse: true);
        widget.onStartListening();
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      _pulseController.stop();
      _waveController.stop();

      if (path != null) {
        // Simulate voice-to-text conversion
        await Future.delayed(const Duration(milliseconds: 500));
        widget.onVoiceInput("मेरी फसल में कीड़े लग गए हैं, क्या करूं?");
      }

      widget.onStopListening();
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      widget.onStopListening();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          // Waveform visualization
          if (widget.isListening) ...[
            SizedBox(
              height: 8.h,
              child: AnimatedBuilder(
                animation: _waveAnimation,
                builder: (context, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(5, (index) {
                      final height =
                          (20 + (index * 10) + (_waveAnimation.value * 30))
                              .clamp(10.0, 60.0);
                      return Container(
                        width: 1.w,
                        height: height,
                        margin: EdgeInsets.symmetric(horizontal: 0.5.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.primaryColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
            SizedBox(height: 2.h),
          ],

          // Main microphone button
          GestureDetector(
            onTap: widget.isListening ? _stopRecording : _startRecording,
            child: AnimatedBuilder(
              animation: widget.isListening
                  ? _pulseAnimation
                  : const AlwaysStoppedAnimation(1.0),
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isListening
                          ? AppTheme.lightTheme.colorScheme.error
                          : AppTheme.lightTheme.primaryColor,
                      boxShadow: [
                        BoxShadow(
                          color: (widget.isListening
                                  ? AppTheme.lightTheme.colorScheme.error
                                  : AppTheme.lightTheme.primaryColor)
                              .withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: widget.isListening ? 10 : 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: widget.isListening ? 'stop' : 'mic',
                        color: Colors.white,
                        size: 8.w,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 3.h),

          // Status text
          Text(
            widget.isListening ? 'I am listening... tell me' : 'press the mic and speak',
            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),

          if (!_hasPermission) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'warning',
                    color: AppTheme.lightTheme.colorScheme.error,
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  Flexible(
                    child: Text(
                      'Allow microphone',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
