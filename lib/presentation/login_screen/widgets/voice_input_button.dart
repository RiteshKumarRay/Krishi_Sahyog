import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class VoiceInputButton extends StatefulWidget {
  final Function(String) onVoiceInput;
  final String hintText;
  final bool isEnabled;

  const VoiceInputButton({
    Key? key,
    required this.onVoiceInput,
    required this.hintText,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with SingleTickerProviderStateMixin {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isRecording = false;
  bool _isProcessing = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage("hi-IN");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<bool> _requestMicrophonePermission() async {
    if (kIsWeb) return true;

    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> _startRecording() async {
    if (!widget.isEnabled || _isRecording || _isProcessing) return;

    final hasPermission = await _requestMicrophonePermission();
    if (!hasPermission) {
      _showErrorMessage("माइक्रोफ़ोन की अनुमति आवश्यक है");
      return;
    }

    try {
      setState(() {
        _isRecording = true;
      });

      _animationController.repeat(reverse: true);

      if (await _audioRecorder.hasPermission()) {
        if (kIsWeb) {
          await _audioRecorder.start(
            const RecordConfig(encoder: AudioEncoder.wav),
            path: 'recording.wav',
          );
        } else {
          await _audioRecorder.start(
            const RecordConfig(),
            path: 'recording.wav',
          );
        }

        await _flutterTts.speak("बोलना शुरू करें");
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
      });
      _animationController.stop();
      _showErrorMessage("रिकॉर्डिंग शुरू नहीं हो सकी");
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    try {
      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });

      _animationController.stop();
      _animationController.reset();

      final path = await _audioRecorder.stop();

      if (path != null) {
        await _flutterTts.speak("आवाज़ को समझा जा रहा है");

        // Simulate voice processing (in real app, integrate with speech-to-text)
        await Future.delayed(const Duration(seconds: 2));

        // Mock voice input result
        final mockResults = [
          "मेरा मोबाइल नंबर 9876543210 है",
          "पासवर्ड farmer123 है",
          "लॉगिन करना चाहता हूं",
        ];

        final randomResult =
            mockResults[DateTime.now().millisecond % mockResults.length];
        widget.onVoiceInput(randomResult);

        await _flutterTts.speak("आवाज़ समझ गई");
      }
    } catch (e) {
      _showErrorMessage("आवाज़ समझने में समस्या");
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onError,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioRecorder.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _startRecording(),
      onTapUp: (_) => _stopRecording(),
      onTapCancel: () => _stopRecording(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isRecording ? _scaleAnimation.value : 1.0,
            child: Container(
              width: 12.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: _isRecording
                    ? AppTheme.lightTheme.colorScheme.error
                    : _isProcessing
                        ? AppTheme.lightTheme.colorScheme.secondary
                        : AppTheme.lightTheme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.lightTheme.colorScheme.shadow,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: _isProcessing
                    ? SizedBox(
                        width: 5.w,
                        height: 5.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.lightTheme.colorScheme.onSecondary,
                          ),
                        ),
                      )
                    : CustomIconWidget(
                        iconName: _isRecording ? 'stop' : 'mic',
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                        size: 6.w,
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}