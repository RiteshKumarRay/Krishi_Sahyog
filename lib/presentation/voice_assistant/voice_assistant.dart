import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/chat_bubble_widget.dart';
import './widgets/language_selector_widget.dart';
import './widgets/processing_indicator_widget.dart';
import './widgets/quick_suggestions_widget.dart';
import './widgets/voice_input_widget.dart';
import './widgets/voice_text_input_widget.dart';

class VoiceAssistant extends StatefulWidget {
  const VoiceAssistant({super.key});

  @override
  State<VoiceAssistant> createState() => _VoiceAssistantState();
}

class _VoiceAssistantState extends State<VoiceAssistant> {
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _chatHistory = [];

  String _selectedLanguage = 'Hindi';
  bool _isListening = false;
  bool _isProcessing = false;
  bool _isTextEditable = false;
  String _currentVoiceText = '';
  int? _playingMessageIndex;

  // Mock agricultural responses
  final Map<String, List<String>> _mockResponses = {
    'weather': [
      'आज का मौसम साफ है। तापमान 28°C है। हवा की गति 15 किमी/घंटा है। आज सिंचाई के लिए अच्छा दिन है।',
      'कल बारिश की संभावना है। अपनी फसल को ढक दें और खाद डालने से बचें।',
    ],
    'pest': [
      'आपकी फसल में दिख रहे कीड़े माहू हो सकते हैं। नीम का तेल का छिड़काव करें। 10 लीटर पानी में 50 मिली नीम का तेल मिलाकर शाम को छिड़काव करें।',
      'यह तना छेदक कीट लग सकता है। ट्राइकोग्रामा कार्ड का उपयोग करें या कार्बोफ्यूरान 3G का छिड़काव करें।',
    ],
    'price': [
      'आज गेहूं की कीमत ₹2,150 प्रति क्विंटल है। पिछले सप्ताह से ₹50 की बढ़ोतरी हुई है।',
      'धान की कीमत ₹1,950 प्रति क्विंटल है। मंडी में अच्छी मांग है।',
    ],
    'seed': [
      'इस मौसम में HD-2967 किस्म का गेहूं बोना अच्छा रहेगा। यह 120 दिन में तैयार हो जाता है।',
      'धान के लिए पूसा बासमती 1121 अच्छी किस्म है। पानी की कम आवश्यकता होती है।',
    ],
    'fertilizer': [
      'फसल में यूरिया 50 किग्रा प्रति एकड़ डालें। DAP 25 किग्रा और पोटाश 15 किग्रा मिलाकर डालें।',
      'जैविक खाद का उपयोग करें। गोबर की खाद 5 टन प्रति एकड़ डालें।',
    ],
    'irrigation': [
      'फसल में 15 दिन के अंतराल पर सिंचाई करें। सुबह या शाम के समय सिंचाई करना बेहतर है।',
      'ड्रिप सिंचाई का उपयोग करें। पानी की 40% बचत होगी और फसल भी अच्छी होगी।',
    ],
  };

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    setState(() {
      _chatHistory.add({
        'message':
            'नमस्कार! मैं आपका कृषि सहायक हूं। आप मुझसे फसल, मौसम, कीमत और खेती से जुड़े सवाल पूछ सकते हैं। कैसे मदद कर सकता हूं?',
        'isUser': false,
        'timestamp': DateTime.now(),
      });
    });
  }

  void _onVoiceInput(String text) {
    setState(() {
      _currentVoiceText = text;
      _isListening = false;
    });
  }

  void _onStartListening() {
    setState(() {
      _isListening = true;
      _currentVoiceText = '';
    });
  }

  void _onStopListening() {
    setState(() {
      _isListening = false;
    });
  }

  void _onLanguageChanged(String language) {
    setState(() {
      _selectedLanguage = language;
    });
  }

  void _onSuggestionTap(String query) {
    _processQuery(query);
  }

  void _onTextChanged(String text) {
    setState(() {
      _currentVoiceText = text;
    });
  }

  void _onEditToggle() {
    setState(() {
      _isTextEditable = !_isTextEditable;
    });

    if (!_isTextEditable && _currentVoiceText.isNotEmpty) {
      _processQuery(_currentVoiceText);
    }
  }

  void _processQuery(String query) {
    if (query.trim().isEmpty) return;

    // Add user message
    setState(() {
      _chatHistory.add({
        'message': query,
        'isUser': true,
        'timestamp': DateTime.now(),
      });
      _isProcessing = true;
      _currentVoiceText = '';
      _isTextEditable = false;
    });

    _scrollToBottom();

    // Simulate AI processing
    Future.delayed(const Duration(seconds: 2), () {
      final response = _generateResponse(query);

      setState(() {
        _chatHistory.add({
          'message': response,
          'isUser': false,
          'timestamp': DateTime.now(),
        });
        _isProcessing = false;
      });

      _scrollToBottom();
    });
  }

  String _generateResponse(String query) {
    final lowerQuery = query.toLowerCase();

    if (lowerQuery.contains('मौसम') || lowerQuery.contains('weather')) {
      return _mockResponses['weather']![DateTime.now().millisecond % 2];
    } else if (lowerQuery.contains('कीड़') ||
        lowerQuery.contains('pest') ||
        lowerQuery.contains('कीट')) {
      return _mockResponses['pest']![DateTime.now().millisecond % 2];
    } else if (lowerQuery.contains('कीमत') ||
        lowerQuery.contains('price') ||
        lowerQuery.contains('भाव')) {
      return _mockResponses['price']![DateTime.now().millisecond % 2];
    } else if (lowerQuery.contains('बीज') ||
        lowerQuery.contains('seed') ||
        lowerQuery.contains('किस्म')) {
      return _mockResponses['seed']![DateTime.now().millisecond % 2];
    } else if (lowerQuery.contains('खाद') ||
        lowerQuery.contains('fertilizer') ||
        lowerQuery.contains('उर्वरक')) {
      return _mockResponses['fertilizer']![DateTime.now().millisecond % 2];
    } else if (lowerQuery.contains('सिंचाई') ||
        lowerQuery.contains('irrigation') ||
        lowerQuery.contains('पानी')) {
      return _mockResponses['irrigation']![DateTime.now().millisecond % 2];
    } else {
      return 'मैं आपकी समस्या समझ गया हूं। कृषि विशेषज्ञ से सलाह लेने के लिए हमारे हेल्पलाइन नंबर 1800-180-1551 पर संपर्क करें। या फिर अपने नजदीकी कृषि केंद्र में जाकर सलाह लें।';
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onPlayAudio(int index) {
    setState(() {
      _playingMessageIndex = _playingMessageIndex == index ? null : index;
    });

    // Simulate audio playback
    if (_playingMessageIndex == index) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _playingMessageIndex = null;
          });
        }
      });
    }
  }

  void _showResourcesBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 60.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'संबंधित संसाधन',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                children: [
                  _buildResourceItem('कृषि विशेषज्ञ से संपर्क', 'call', () {}),
                  _buildResourceItem('फसल की तस्वीरें', 'photo_library', () {}),
                  _buildResourceItem('मौसम रिपोर्ट', 'wb_sunny', () {}),
                  _buildResourceItem('मंडी की कीमतें', 'trending_up', () {}),
                  _buildResourceItem('कृषि लेख', 'article', () {}),
                  _buildResourceItem('वीडियो गाइड', 'play_circle', () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceItem(String title, String icon, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        width: 10.w,
        height: 10.w,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: icon,
            color: AppTheme.lightTheme.primaryColor,
            size: 5.w,
          ),
        ),
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: CustomIconWidget(
        iconName: 'arrow_forward_ios',
        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        size: 4.w,
      ),
      onTap: onTap,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'कृषि सहायक',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        foregroundColor: AppTheme.lightTheme.appBarTheme.foregroundColor,
        elevation: AppTheme.lightTheme.appBarTheme.elevation,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.appBarTheme.foregroundColor!,
            size: 6.w,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showResourcesBottomSheet,
            icon: CustomIconWidget(
              iconName: 'help_outline',
              color: AppTheme.lightTheme.appBarTheme.foregroundColor!,
              size: 6.w,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Language selector
          Container(
            padding: EdgeInsets.symmetric(vertical: 2.h),
            child: Center(
              child: LanguageSelectorWidget(
                selectedLanguage: _selectedLanguage,
                onLanguageChanged: _onLanguageChanged,
              ),
            ),
          ),

          // Chat history
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(vertical: 1.h),
              itemCount: _chatHistory.length,
              itemBuilder: (context, index) {
                final message = _chatHistory[index];
                return ChatBubbleWidget(
                  message: message['message'],
                  isUser: message['isUser'],
                  timestamp: message['timestamp'],
                  onPlayAudio:
                      message['isUser'] ? null : () => _onPlayAudio(index),
                  isPlaying: _playingMessageIndex == index,
                );
              },
            ),
          ),

          // Processing indicator
          ProcessingIndicatorWidget(
            isVisible: _isProcessing,
            message: 'आपके सवाल का जवाब तैयार कर रहे हैं...',
          ),

          // Voice text input
          VoiceTextInputWidget(
            text: _currentVoiceText,
            onTextChanged: _onTextChanged,
            isEditable: _isTextEditable,
            onEditToggle: _onEditToggle,
          ),

          // Quick suggestions (show only when no active conversation)
          if (_chatHistory.length <= 1 && !_isListening && !_isProcessing) ...[
            SizedBox(height: 2.h),
            QuickSuggestionsWidget(
              onSuggestionTap: _onSuggestionTap,
            ),
          ],

          // Voice input widget
          VoiceInputWidget(
            onVoiceInput: _onVoiceInput,
            isListening: _isListening,
            onStartListening: _onStartListening,
            onStopListening: _onStopListening,
          ),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}
