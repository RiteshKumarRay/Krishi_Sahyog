import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/data_export_widget.dart';
import './widgets/editable_field_widget.dart';
import './widgets/language_selector_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/settings_tile_widget.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({Key? key}) : super(key: key);

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  // Mock profile data
  Map<String, dynamic> profileData = {
    "name": "Ritesh Kumar",
    "mobile": "+91 70155 03726",
    "email": "ritesh.kumar123@gmail.com",
    "location": "Landran, Punjab",
    "farmSize": "5.2 hectares",
    "profileImage":
        "https://akm-img-a-in.tosshub.com/indiatoday/images/story/202405/pm-modi-smiling-064650291-16x9_0.jpeg?VersionId=jB9Lbi.Ok_FF1q5NWLNuMtK9MVa7EfRp&size=690:388",
    "memberSince": "2022",
    "farmCoordinates": "30.9010° N, 75.8573° E",
    "primaryCrops": "Wheat, Rice, Sugarcane",
    "farmingExperience": "15 years",
    "farmingMethod": "Mixed (Organic & Conventional)",
    "cropPreferences": "Seasonal rotation crops",
  };

  // App preferences
  String selectedLanguage = 'hi';
  bool notificationsEnabled = true;
  bool weatherAlertsEnabled = true;
  bool marketUpdatesEnabled = true;
  bool voiceNavigationEnabled = true;
  bool largeTextEnabled = false;
  bool highContrastEnabled = false;
  bool offlineDataEnabled = true;
  double speechRate = 1.0;
  String accentPreference = 'indian';

  void _updateProfileData(String key, String value) {
    setState(() {
      profileData[key] = value;
    });
  }

  void _updateProfileImage(String imagePath) {
    setState(() {
      profileData['profileImage'] = imagePath;
    });
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Text(
          'Are you sure you want to logout? You will need to login again to access your account.',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login-screen',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showVoiceSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Voice Settings',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Speech Rate',
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                  Text(
                    '${speechRate.toStringAsFixed(1)}x',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Slider(
                value: speechRate,
                min: 0.5,
                max: 2.0,
                divisions: 6,
                onChanged: (value) {
                  setDialogState(() {
                    speechRate = value;
                  });
                  setState(() {
                    speechRate = value;
                  });
                },
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Accent Preference',
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                  DropdownButton<String>(
                    value: accentPreference,
                    items: [
                      DropdownMenuItem(value: 'indian', child: Text('Indian')),
                      DropdownMenuItem(
                          value: 'british', child: Text('British')),
                      DropdownMenuItem(
                          value: 'american', child: Text('American')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          accentPreference = value;
                        });
                        setState(() {
                          accentPreference = value;
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Notification Settings',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: Text('Weather Alerts'),
                subtitle: Text('Get notified about weather changes'),
                value: weatherAlertsEnabled,
                onChanged: (value) {
                  setDialogState(() {
                    weatherAlertsEnabled = value;
                  });
                  setState(() {
                    weatherAlertsEnabled = value;
                  });
                },
              ),
              SwitchListTile(
                title: Text('Market Updates'),
                subtitle: Text('Receive crop price notifications'),
                value: marketUpdatesEnabled,
                onChanged: (value) {
                  setDialogState(() {
                    marketUpdatesEnabled = value;
                  });
                  setState(() {
                    marketUpdatesEnabled = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Profile Settings'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: Colors.white,
            size: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/dashboard-home'),
            icon: CustomIconWidget(
              iconName: 'home',
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            ProfileHeaderWidget(
              profileData: profileData,
              onImageChanged: _updateProfileImage,
            ),

            SizedBox(height: 2.h),

            // Personal Information Section
            SettingsSectionWidget(
              title: 'Personal Information',
              children: [
                EditableFieldWidget(
                  label: 'Full Name',
                  value: profileData['name'] ?? '',
                  iconName: 'person',
                  onChanged: (value) => _updateProfileData('name', value),
                ),
                EditableFieldWidget(
                  label: 'Mobile Number',
                  value: profileData['mobile'] ?? '',
                  iconName: 'phone',
                  keyboardType: TextInputType.phone,
                  onChanged: (value) => _updateProfileData('mobile', value),
                ),
                EditableFieldWidget(
                  label: 'Email Address',
                  value: profileData['email'] ?? '',
                  iconName: 'email',
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) => _updateProfileData('email', value),
                ),
                EditableFieldWidget(
                  label: 'Farm Location',
                  value: profileData['location'] ?? '',
                  iconName: 'location_on',
                  onChanged: (value) => _updateProfileData('location', value),
                ),
                EditableFieldWidget(
                  label: 'Farm Size',
                  value: profileData['farmSize'] ?? '',
                  iconName: 'landscape',
                  onChanged: (value) => _updateProfileData('farmSize', value),
                ),
              ],
            ),

            // Agricultural Profile Section
            SettingsSectionWidget(
              title: 'Agricultural Profile',
              children: [
                EditableFieldWidget(
                  label: 'Primary Crops',
                  value: profileData['primaryCrops'] ?? '',
                  iconName: 'grass',
                  maxLines: 2,
                  onChanged: (value) =>
                      _updateProfileData('primaryCrops', value),
                ),
                EditableFieldWidget(
                  label: 'Farming Experience',
                  value: profileData['farmingExperience'] ?? '',
                  iconName: 'timeline',
                  onChanged: (value) =>
                      _updateProfileData('farmingExperience', value),
                ),
                EditableFieldWidget(
                  label: 'Farming Method',
                  value: profileData['farmingMethod'] ?? '',
                  iconName: 'eco',
                  onChanged: (value) =>
                      _updateProfileData('farmingMethod', value),
                ),
                EditableFieldWidget(
                  label: 'Crop Preferences',
                  value: profileData['cropPreferences'] ?? '',
                  iconName: 'favorite',
                  maxLines: 2,
                  onChanged: (value) =>
                      _updateProfileData('cropPreferences', value),
                ),
              ],
            ),

            // App Preferences Section
            SettingsSectionWidget(
              title: 'App Preferences',
              children: [
                LanguageSelectorWidget(
                  selectedLanguage: selectedLanguage,
                  onLanguageChanged: (language) {
                    setState(() {
                      selectedLanguage = language;
                    });
                  },
                ),
                SettingsTileWidget(
                  iconName: 'record_voice_over',
                  title: 'Voice Settings',
                  subtitle: 'Speech rate and accent preferences',
                  onTap: _showVoiceSettingsDialog,
                ),
                SettingsTileWidget(
                  iconName: 'notifications',
                  title: 'Notifications',
                  subtitle: notificationsEnabled ? 'Enabled' : 'Disabled',
                  trailing: Switch(
                    value: notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        notificationsEnabled = value;
                      });
                    },
                  ),
                  showArrow: false,
                  onTap: _showNotificationSettings,
                ),
                SettingsTileWidget(
                  iconName: 'cloud_off',
                  title: 'Offline Data',
                  subtitle: 'Cache data for offline use',
                  trailing: Switch(
                    value: offlineDataEnabled,
                    onChanged: (value) {
                      setState(() {
                        offlineDataEnabled = value;
                      });
                    },
                  ),
                  showArrow: false,
                ),
              ],
            ),

            // Accessibility Section
            SettingsSectionWidget(
              title: 'Accessibility',
              children: [
                SettingsTileWidget(
                  iconName: 'text_fields',
                  title: 'Large Text',
                  subtitle: 'Increase text size for better readability',
                  trailing: Switch(
                    value: largeTextEnabled,
                    onChanged: (value) {
                      setState(() {
                        largeTextEnabled = value;
                      });
                    },
                  ),
                  showArrow: false,
                ),
                SettingsTileWidget(
                  iconName: 'contrast',
                  title: 'High Contrast',
                  subtitle: 'Improve visibility in bright sunlight',
                  trailing: Switch(
                    value: highContrastEnabled,
                    onChanged: (value) {
                      setState(() {
                        highContrastEnabled = value;
                      });
                    },
                  ),
                  showArrow: false,
                ),
                SettingsTileWidget(
                  iconName: 'voice_over_off',
                  title: 'Voice Navigation',
                  subtitle: 'Navigate using voice commands',
                  trailing: Switch(
                    value: voiceNavigationEnabled,
                    onChanged: (value) {
                      setState(() {
                        voiceNavigationEnabled = value;
                      });
                    },
                  ),
                  showArrow: false,
                ),
              ],
            ),

            // Data Management Section
            SettingsSectionWidget(
              title: 'Data Management',
              children: [
                DataExportWidget(profileData: profileData),
                SettingsTileWidget(
                  iconName: 'privacy_tip',
                  title: 'Privacy Settings',
                  subtitle: 'Control data sharing and visibility',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Privacy settings will be available soon'),
                        backgroundColor:
                            AppTheme.lightTheme.colorScheme.primary,
                      ),
                    );
                  },
                ),
              ],
            ),

            // Help & Support Section
            SettingsSectionWidget(
              title: 'Help & Support',
              children: [
                SettingsTileWidget(
                  iconName: 'help',
                  title: 'Tutorial',
                  subtitle: 'Replay app introduction and tutorials',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Tutorial will be available soon'),
                        backgroundColor:
                            AppTheme.lightTheme.colorScheme.primary,
                      ),
                    );
                  },
                ),
                SettingsTileWidget(
                  iconName: 'question_answer',
                  title: 'FAQ',
                  subtitle: 'Frequently asked questions',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('FAQ section will be available soon'),
                        backgroundColor:
                            AppTheme.lightTheme.colorScheme.primary,
                      ),
                    );
                  },
                ),
                SettingsTileWidget(
                  iconName: 'support_agent',
                  title: 'Contact Support',
                  subtitle: 'Get help from agricultural extension services',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Support contact: +91 1800-XXX-XXXX'),
                        backgroundColor:
                            AppTheme.lightTheme.colorScheme.primary,
                      ),
                    );
                  },
                ),
                SettingsTileWidget(
                  iconName: 'feedback',
                  title: 'Send Feedback',
                  subtitle: 'Help us improve the app',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Feedback form will open soon'),
                        backgroundColor:
                            AppTheme.lightTheme.colorScheme.primary,
                      ),
                    );
                  },
                ),
              ],
            ),

            // Logout Section
            Container(
              margin: EdgeInsets.all(4.w),
              child: ElevatedButton(
                onPressed: _showLogoutDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 7.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'logout',
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Logout',
                      style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }
}
