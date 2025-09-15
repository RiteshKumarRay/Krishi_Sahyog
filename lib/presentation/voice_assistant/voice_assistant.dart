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

  String _selectedLanguage = 'English';

  bool _isListening = false;

  bool _isProcessing = false;

  bool _isTextEditable = false;

  String _currentVoiceText = '';

  int? _playingMessageIndex;

// Mock agricultural responses

  final Map<String, List<String>> _mockResponses = {

    'weather': [

      'Today\'s weather is clear. Temperature is 28°C. Wind speed is 15 km/h. Today is a good day for irrigation.',

      'There is a possibility of rain tomorrow. Cover your crops and avoid applying fertilizer.',

    ],

    'pest': [

      'The insects visible in your crop might be aphids. Spray neem oil. Mix 50ml neem oil in 10 liters of water and spray in the evening.',

      'This could be a stem borer pest. Use Trichogramma cards or spray Carbofuran 3G.',

    ],

    'price': [

      'Today wheat price is ₹2,150 per quintal. There has been an increase of ₹50 from last week.',

      'Rice price is ₹1,950 per quintal. There is good demand in the market.',

    ],

    'seed': [

      'HD-2967 variety wheat will be good to sow this season. It gets ready in 120 days.',

      'For rice, Pusa Basmati 1121 is a good variety. It requires less water.',

    ],

    'fertilizer': [

      'Apply 50 kg urea per acre to the crop. Mix and apply 25 kg DAP and 15 kg potash.',

      'Use organic fertilizer. Apply 5 tons of cow dung manure per acre.',

    ],

    'irrigation': [

      'Irrigate the crop at intervals of 15 days. It is better to irrigate in the morning or evening.',

      'Use drip irrigation. It will save 40% water and the crop will also be good.',

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

        'Hello! I am your agricultural assistant. You can ask me questions about crops, weather, prices, and farming. How can I help you?',

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

    if (lowerQuery.contains('weather') || lowerQuery.contains('climate')) {

      return _mockResponses['weather']![DateTime.now().millisecond % 2];

    } else if (lowerQuery.contains('pest') ||

        lowerQuery.contains('insect') ||

        lowerQuery.contains('bug')) {

      return _mockResponses['pest']![DateTime.now().millisecond % 2];

    } else if (lowerQuery.contains('price') ||

        lowerQuery.contains('rate') ||

        lowerQuery.contains('cost')) {

      return _mockResponses['price']![DateTime.now().millisecond % 2];

    } else if (lowerQuery.contains('seed') ||

        lowerQuery.contains('variety') ||

        lowerQuery.contains('cultivar')) {

      return _mockResponses['seed']![DateTime.now().millisecond % 2];

    } else if (lowerQuery.contains('fertilizer') ||

        lowerQuery.contains('manure') ||

        lowerQuery.contains('nutrient')) {

      return _mockResponses['fertilizer']![DateTime.now().millisecond % 2];

    } else if (lowerQuery.contains('irrigation') ||

        lowerQuery.contains('watering') ||

        lowerQuery.contains('water')) {

      return _mockResponses['irrigation']![DateTime.now().millisecond % 2];

    } else {

      return 'I understand your problem. For advice from agricultural experts, contact our helpline number 1800-180-1551. Or visit your nearest agricultural center for advice.';

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

                'Related Resources',

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

                  _buildResourceItem('Contact Agricultural Expert', 'call', () {}),

                  _buildResourceItem('Crop Photos', 'photo_library', () {}),

                  _buildResourceItem('Weather Report', 'wb_sunny', () {}),

                  _buildResourceItem('Market Prices', 'trending_up', () {}),

                  _buildResourceItem('Agricultural Articles', 'article', () {}),

                  _buildResourceItem('Video Guides', 'play_circle', () {}),

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

          'Agricultural Assistant',

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

            message: 'Preparing answer to your question...',

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