import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import '../services/auth_service.dart';
import '../core/app_export.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();

  String _selectedUserType = 'farmer';
  bool _isLoading = false;
  String _currentLanguage = 'hi';

  String _getLocalizedText(String hindiText, String englishText) {
    return _currentLanguage == 'hi' ? hindiText : englishText;
  }

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService.signUpWithPhoneAndPassword(
        phoneNumber: _phoneController.text,
        password: _passwordController.text,
        name: _nameController.text,
        userType: _selectedUserType,
        location: _locationController.text,
      );

      if (result['success']) {
        HapticFeedback.lightImpact();
        _showSuccessMessage(_getLocalizedText(
          'खाता सफलतापूर्वक बनाया गया!',
          'Account created successfully!',
        ));

        // Navigate to appropriate dashboard
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        _showErrorMessage(result['message']);
      }
    } catch (e) {
      _showErrorMessage(_getLocalizedText(
        'पंजीकरण में समस्या हुई',
        'Registration failed',
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getLocalizedText('नया खाता बनाएं', 'Create Account')),
        backgroundColor: AppTheme.lightTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: _getLocalizedText('पूरा नाम', 'Full Name'),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return _getLocalizedText('नाम दर्ज करें', 'Enter name');
                    }
                    return null;
                  },
                ),
                SizedBox(height: 3.h),

                // Phone Field
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: _getLocalizedText('मोबाइल नंबर', 'Mobile Number'),
                    prefixIcon: Icon(Icons.phone),
                    prefixText: '+91 ',
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return _getLocalizedText('मोबाइल नंबर दर्ज करें', 'Enter mobile number');
                    }
                    if (value!.length != 10) {
                      return _getLocalizedText('10 अंक का नंबर दर्ज करें', 'Enter 10 digit number');
                    }
                    return null;
                  },
                ),
                SizedBox(height: 3.h),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: _getLocalizedText('पासवर्ड', 'Password'),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return _getLocalizedText('पासवर्ड दर्ज करें', 'Enter password');
                    }
                    if (value!.length < 6) {
                      return _getLocalizedText('कम से कम 6 अक्षर', 'At least 6 characters');
                    }
                    return null;
                  },
                ),
                SizedBox(height: 3.h),

                // User Type Selection
                DropdownButtonFormField<String>(
                  value: _selectedUserType,
                  decoration: InputDecoration(
                    labelText: _getLocalizedText('उपयोगकर्ता प्रकार', 'User Type'),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'farmer',
                      child: Text(_getLocalizedText('किसान', 'Farmer')),
                    ),
                    DropdownMenuItem(
                      value: 'advisor',
                      child: Text(_getLocalizedText('सलाहकार', 'Advisor')),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedUserType = value!;
                    });
                  },
                ),
                SizedBox(height: 3.h),

                // Location Field
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: _getLocalizedText('स्थान', 'Location'),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                SizedBox(height: 5.h),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  height: 7.h,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegistration,
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(_getLocalizedText('खाता बनाएं', 'Create Account')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
