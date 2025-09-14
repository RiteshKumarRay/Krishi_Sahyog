import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../services/auth_service.dart';
import '../../services/firebase_auth_service.dart';
import '../dashboard_home/dashboard_home.dart';
import '../../core/app_export.dart';
import './widgets/biometric_login_dialog.dart';
import './widgets/language_toggle_button.dart';
import './widgets/social_login_section.dart';
import './widgets/voice_input_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _mobileFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Google Sign-In variables
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'https://www.googleapis.com/auth/userinfo.profile'],
  );
  GoogleSignInAccount? _currentUser;

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isSocialLoading = false;
  String _currentLanguage = 'hi';
  bool _showBiometricOption = false;

  // Mock credentials for different user types
  final Map<String, Map<String, String>> _mockCredentials = {
    'farmer': {
      'mobile': '9876543210',
      'password': 'farmer123',
      'name': 'रितेश कुमार',
    },
    'advisor': {
      'mobile': '9876543211',
      'password': 'advisor123',
      'name': 'डॉ. सुनीता शर्मा',
    },
    'admin': {
      'mobile': '1234567890',
      'password': '123456',
      'name': 'प्रशासक',
    },
  };

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    // Simulate checking biometric availability
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _showBiometricOption = !kIsWeb; // Biometric only available on mobile
    });
  }

  String _getLocalizedText(String hindiText, String englishText) {
    return _currentLanguage == 'hi' ? hindiText : englishText;
  }

  void _onLanguageChanged(String language) {
    setState(() {
      _currentLanguage = language;
    });
  }

  void _onVoiceInput(String voiceText) {
    // Extract mobile number and password from voice input
    final mobileRegex = RegExp(r'\b\d{10}\b');
    final passwordRegex =
    RegExp(r'पासवर्ड\s+(\w+)|password\s+(\w+)', caseSensitive: false);

    final mobileMatch = mobileRegex.firstMatch(voiceText);
    final passwordMatch = passwordRegex.firstMatch(voiceText);

    if (mobileMatch != null) {
      setState(() {
        _mobileController.text = mobileMatch.group(0)!;
      });
    }

    if (passwordMatch != null) {
      setState(() {
        _passwordController.text =
            passwordMatch.group(1) ?? passwordMatch.group(2) ?? '';
      });
    }

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _getLocalizedText('आवाज़ इनपुट प्राप्त हुआ', 'Voice input received'),
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String? _validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return _getLocalizedText('मोबाइल नंबर दर्ज करें', 'Enter mobile number');
    }
    if (value.length != 10 || !RegExp(r'^\d{10}$').hasMatch(value)) {
      return _getLocalizedText(
          'वैध मोबाइल नंबर दर्ज करें', 'Enter valid mobile number');
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return _getLocalizedText('पासवर्ड दर्ज करें', 'Enter password');
    }
    if (value.length < 6) {
      return _getLocalizedText('पासवर्ड कम से कम 6 अक्षर का होना चाहिए',
          'Password must be at least 6 characters');
    }
    return null;
  }

  // Updated _handleLogin method to support both mock credentials and real auth
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    String mobile = _mobileController.text.trim();
    String password = _passwordController.text.trim();

    try {
      // First, check mock credentials
      bool mockLoginSuccess = await _tryMockLogin(mobile, password);

      if (mockLoginSuccess) {
        return; // Mock login successful, exit early
      }

      // If mock login fails, try real Firebase auth
      final result = await AuthService.signInWithPhoneAndPassword(
        phoneNumber: mobile,
        password: password,
      );

      if (result['success']) {
        HapticFeedback.lightImpact();
        final userData = result['userData'] as Map?;
        final userType = userData?['userType'] ?? 'farmer';
        final userName = userData?['name'] ?? 'उपयोगकर्ता';

        _showSuccessMessage(_getLocalizedText(
          'स्वागत है, $userName!',
          'Welcome, $userName!',
        ));

        _navigateBasedOnUserType(userType);
      } else {
        _showErrorMessage(result['message'] ?? 'Login failed');
      }
    } catch (e) {
      _showErrorMessage(_getLocalizedText(
        'अमान्य मोबाइल नंबर या पासवर्ड',
        'Invalid mobile number or password',
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper method to try mock login
  Future<bool> _tryMockLogin(String mobile, String password) async {
    // Simulate a small delay for mock authentication
    await Future.delayed(Duration(milliseconds: 500));

    // Check each mock credential
    for (var entry in _mockCredentials.entries) {
      String userType = entry.key;
      Map<String, String> credentials = entry.value;

      if (credentials['mobile'] == mobile && credentials['password'] == password) {
        String userName = credentials['name']!;

        HapticFeedback.lightImpact();
        _showSuccessMessage(_getLocalizedText(
          'स्वागत है, $userName!',
          'Welcome, $userName!',
        ));

        _navigateBasedOnUserType(userType);
        return true; // Mock login successful
      }
    }
    return false; // No mock credentials matched
  }

  // Helper method to navigate based on user type
  void _navigateBasedOnUserType(String userType) {
    // For now, all user types go to dashboard-home
    Navigator.pushReplacementNamed(context, '/dashboard-home');

    /* Uncomment and modify when you have different dashboards:
    switch (userType) {
      case 'admin':
        Navigator.pushReplacementNamed(context, '/admin-dashboard');
        break;
      case 'advisor':
        Navigator.pushReplacementNamed(context, '/advisor-dashboard');
        break;
      case 'farmer':
      default:
        Navigator.pushReplacementNamed(context, '/dashboard-home');
        break;
    }
    */
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Google Login method
  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isSocialLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _showErrorMessage(_getLocalizedText(
          'Google लॉगिन रद्द किया गया',
          'Google login canceled',
        ));
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      setState(() {
        _currentUser = googleUser;
      });

      HapticFeedback.lightImpact();
      final userName = googleUser.displayName ?? _getLocalizedText('उपयोगकर्ता', 'User');

      _showSuccessMessage(_getLocalizedText(
        'स्वागत है, $userName',
        'Welcome, $userName',
      ));

      // Navigate to dashboard
      Navigator.pushReplacementNamed(context, '/dashboard-home');

    } catch (e) {
      _showErrorMessage(_getLocalizedText(
        'Google लॉगिन में समस्या हुई: $e',
        'Google login failed: $e',
      ));
    } finally {
      setState(() {
        _isSocialLoading = false;
      });
    }
  }

  void _showBiometricSetupDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BiometricLoginDialog(
        currentLanguage: _currentLanguage,
        onBiometricSuccess: () {
          Navigator.of(context).pop();
          _navigateToDashboard();
        },
        onBiometricCancel: () {
          Navigator.of(context).pop();
          _navigateToDashboard();
        },
      ),
    );
  }

  void _navigateToDashboard() {
    Navigator.pushReplacementNamed(context, '/dashboard-home');
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

  void _handleForgotPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _getLocalizedText('पासवर्ड रीसेट', 'Password Reset'),
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Text(
          _getLocalizedText(
            'आपके मोबाइल नंबर पर SMS भेजा जाएगा',
            'SMS will be sent to your mobile number',
          ),
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(_getLocalizedText('रद्द करें', 'Cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showErrorMessage(_getLocalizedText(
                'SMS भेजा गया है',
                'SMS has been sent',
              ));
            },
            child: Text(_getLocalizedText('भेजें', 'Send')),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    _mobileFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 2.h),

                // Language Toggle
                Align(
                  alignment: Alignment.topRight,
                  child: LanguageToggleButton(
                    currentLanguage: _currentLanguage,
                    onLanguageChanged: _onLanguageChanged,
                  ),
                ),

                SizedBox(height: 4.h),

                // App Logo
                Container(
                  width: 25.w,
                  height: 25.w,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'agriculture',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 12.w,
                    ),
                  ),
                ),

                SizedBox(height: 3.h),

                // App Title
                Text(
                  _getLocalizedText(
                      'स्मार्ट क्रॉप एडवाइजरी', 'Smart Crop Advisory'),
                  style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 1.h),

                Text(
                  _getLocalizedText('किसानों के लिए बुद्धिमान सलाह',
                      'Intelligent advice for farmers'),
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),

                SizedBox(height: 5.h),

                // Mobile Number Field
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _mobileController,
                        focusNode: _mobileFocusNode,
                        keyboardType: TextInputType.phone,
                        validator: _validateMobile,
                        decoration: InputDecoration(
                          labelText:
                          _getLocalizedText('मोबाइल नंबर', 'Mobile Number'),
                          hintText: _getLocalizedText(
                              '10 अंकों का नंबर दर्ज करें',
                              'Enter 10 digit number'),
                          prefixIcon: Container(
                            padding: EdgeInsets.all(3.w),
                            child: Text(
                              '+91',
                              style: AppTheme.lightTheme.textTheme.bodyLarge
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          prefixIconConstraints: BoxConstraints(
                            minWidth: 12.w,
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                      ),
                    ),
                    SizedBox(width: 2.w),
                    VoiceInputButton(
                      onVoiceInput: _onVoiceInput,
                      hintText: _getLocalizedText(
                          'मोबाइल नंबर बोलें', 'Speak mobile number'),
                    ),
                  ],
                ),

                SizedBox(height: 3.h),

                // Password Field
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        obscureText: !_isPasswordVisible,
                        validator: _validatePassword,
                        decoration: InputDecoration(
                          labelText: _getLocalizedText('पासवर्ड', 'Password'),
                          hintText: _getLocalizedText(
                              'अपना पासवर्ड दर्ज करें', 'Enter your password'),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                            icon: CustomIconWidget(
                              iconName: _isPasswordVisible
                                  ? 'visibility_off'
                                  : 'visibility',
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              size: 6.w,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    VoiceInputButton(
                      onVoiceInput: _onVoiceInput,
                      hintText:
                      _getLocalizedText('पासवर्ड बोलें', 'Speak password'),
                    ),
                  ],
                ),

                SizedBox(height: 2.h),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _handleForgotPassword,
                    child: Text(
                      _getLocalizedText('पासवर्ड भूल गए?', 'Forgot Password?'),
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 4.h),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 7.h,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 5.w,
                          height: 5.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                            AppTheme.lightTheme.colorScheme.onPrimary,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          _getLocalizedText(
                              'लॉगिन हो रहा है...', 'Logging in...'),
                        ),
                      ],
                    )
                        : Text(
                      _getLocalizedText('लॉगिन करें', 'Login'),
                      style: AppTheme.lightTheme.textTheme.labelLarge
                          ?.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 4.h),

                // Social Login Section
                SocialLoginSection(
                  onGoogleLogin: _handleGoogleLogin,
                  currentLanguage: _currentLanguage,
                  isLoading: _isSocialLoading,
                ),

                SizedBox(height: 4.h),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getLocalizedText('नए किसान हैं?', 'New farmer?'),
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to registration screen
                        _showErrorMessage(_getLocalizedText(
                          'पंजीकरण सुविधा जल्द आएगी',
                          'Registration feature coming soon',
                        ));
                      },
                      child: Text(
                        _getLocalizedText('पंजीकरण करें', 'Register'),
                        style:
                        AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 2.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
