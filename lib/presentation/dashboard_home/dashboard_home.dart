import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';
import './widgets/feature_card_widget.dart';
import './widgets/greeting_header_widget.dart';
import './widgets/recent_activity_widget.dart';
import './widgets/status_bar_widget.dart';
import './widgets/voice_assistant_button_widget.dart';
import './widgets/weather_card_widget.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({Key? key}) : super(key: key);

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> with TickerProviderStateMixin {
  int _currentTabIndex = 0;
  bool _isListening = false;
  bool _isOnline = true;
  final AudioRecorder _audioRecorder = AudioRecorder();
  late TabController _tabController;

  final Map<String, dynamic> _weatherData = {
    "location": "दिल्ली, भारत",
    "temperature": 28,
    "condition": "धूप",
    "humidity": 65,
    "windSpeed": 12,
    "rainfall": 5,
  };

  final List<Map<String, dynamic>> _features = [
    {
      "id": "soil_scan",
      "title": "मिट्टी स्वास्थ्य स्कैन",
      "description": "अपने मिट्टी स्वास्थ्य कार्ड को स्कैन करें और तुरंत विश्लेषण प्राप्त करें",
      "icon": "document_scanner",
      "color": Color(0xFF4CAF50),
      "quickAction": "स्कैन शुरू करें",
      "hasNotification": false,
      "route": "/soil-scan",
    },
    {
      "id": "crop_advisory",
      "title": "फसल सलाह",
      "description": "आपकी फसल के लिए व्यक्तिगत सुझाव और बेहतर उत्पादन की जानकारी",
      "icon": "agriculture",
      "color": Color(0xFF8BC34A),
      "quickAction": "सलाह प्राप्त करें",
      "hasNotification": true,
      "route": "/crop-advisory",
    },
    {
      "id": "market_prices",
      "title": "बाजार भाव",
      "description": "आज के ताजे बाजार भाव और कीमतों की जानकारी प्राप्त करें",
      "icon": "trending_up",
      "color": Color(0xFF2196F3),
      "quickAction": "भाव देखें",
      "hasNotification": false,
      "route": "/market-prices",
    },
    {
      "id": "pest_identification",
      "title": "कीट पहचान",
      "description": "फसल में कीट और रोगों की पहचान करें और उपचार की जानकारी पाएं",
      "icon": "bug_report",
      "color": Color(0xFFFF9800),
      "quickAction": "फोटो लें",
      "hasNotification": false,
      "route": "/pest-identification",
    },
  ];

  final List<Map<String, dynamic>> _recentActivities = [
    {
      "id": "1",
      "type": "scan",
      "title": "मिट्टी स्वास्थ्य स्कैन",
      "description": "खेत #1 की मिट्टी का विश्लेषण पूरा",
      "timestamp": DateTime.now().subtract(Duration(hours: 2)),
    },
    {
      "id": "2",
      "type": "voice",
      "title": "आवाज प्रश्न",
      "description": "गेहूं की बुआई के बारे में पूछा",
      "timestamp": DateTime.now().subtract(Duration(hours: 5)),
    },
    {
      "id": "3",
      "type": "weather",
      "title": "मौसम अपडेट",
      "description": "अगले 3 दिन बारिश की संभावना",
      "timestamp": DateTime.now().subtract(Duration(days: 1)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _checkConnectivity();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _checkConnectivity() {
    setState(() {
      _isOnline = true;
    });
  }

  Future<void> _handleVoiceAssistant() async {
    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        setState(() {
          _isListening = true;
        });
        await _audioRecorder.start(const RecordConfig(), path: 'voice_input.m4a');
        Future.delayed(const Duration(seconds: 10), () {
          if (_isListening) {
            _stopListening();
          }
        });
      } else {
        _showPermissionDialog();
      }
    } catch (e) {
      setState(() {
        _isListening = false;
      });
      _showErrorSnackBar("आवाज रिकॉर्डिंग में समस्या हुई");
    }
  }

  Future<void> _stopListening() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isListening = false;
      });
      if (path != null) {
        _showSuccessSnackBar("आवाज रिकॉर्ड हो गई, प्रोसेसिंग हो रही है...");
        Navigator.pushNamed(context, '/voice-assistant');
      }
    } catch (e) {
      setState(() {
        _isListening = false;
      });
      _showErrorSnackBar("रिकॉर्डिंग बंद करने में समस्या हुई");
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("माइक्रोफोन की अनुमति चाहिए"),
        content: const Text("आवाज सहायक का उपयोग करने के लिए माइक्रोफोन की अनुमति दें।"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("रद्द करें"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text("सेटिंग्स खोलें"),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _refreshDashboard() async {
    await Future.delayed(const Duration(seconds: 2));
    _checkConnectivity();
    _showSuccessSnackBar("डैशबोर्ड अपडेट हो गया");
  }

  void _navigateToFeature(String route) {
    Navigator.pushNamed(context, route);
  }

  void _showFeatureOptions(Map<String, dynamic> feature) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'push_pin',
                color: AppTheme.lightTheme.primaryColor,
                size: 6.w,
              ),
              title: const Text("टॉप पर पिन करें"),
              onTap: () {
                Navigator.pop(context);
                _showSuccessSnackBar("${feature["title"]} को टॉप पर पिन कर दिया");
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'visibility_off',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 6.w,
              ),
              title: const Text("छुपाएं"),
              onTap: () {
                Navigator.pop(context);
                _showSuccessSnackBar("${feature["title"]} को छुपा दिया");
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'settings',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 6.w,
              ),
              title: const Text("सेटिंग्स"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile-settings');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _quickScan() {
    Navigator.pushNamed(context, '/soil-scan');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            StatusBarWidget(
              isOnline: _isOnline,
              networkType: _isOnline ? "4G" : null,
              lastSync: _isOnline ? "अभी" : "2 घंटे पहले",
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshDashboard,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GreetingHeaderWidget(
                        farmerName: "रितेश कुमार",
                        location: "लांडरां, पंजाब",
                      ),
                      SizedBox(height: 2.h),

                      // Mic floating button removed here.

                      WeatherCardWidget(
                        weatherData: _weatherData,
                        onTap: () => Navigator.pushNamed(context, '/weather-dashboard'),
                      ),
                      SizedBox(height: 3.h),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "कृषि सेवाएं",
                              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 3.w,
                                mainAxisSpacing: 2.h,
                                childAspectRatio: 0.85,
                              ),
                              itemCount: _features.length,
                              itemBuilder: (context, index) {
                                final feature = _features[index];
                                return FeatureCardWidget(
                                  feature: feature,
                                  onTap: () => _navigateToFeature(feature["route"] as String),
                                  onLongPress: () => _showFeatureOptions(feature),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4.h),

                      RecentActivityWidget(
                        activities: _recentActivities,
                      ),
                      SizedBox(height: 2.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: TabBar(
        controller: _tabController,
        onTap: (index) {
          setState(() {
            _currentTabIndex = index;
          });
          switch (index) {
            case 0:
            // Home, no extra action needed
              break;
            case 1:
              Navigator.pushNamed(context, '/community-forum'); // Navigate to community forum
              break;
            case 2:
              Navigator.pushNamed(context, '/voice-assistant');
              break;
            case 3:
              Navigator.pushNamed(context, '/profile-settings');
              break;
          }
        },
        tabs: [
          Tab(
            icon: CustomIconWidget(
              iconName: 'home',
              color: _currentTabIndex == 0
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 6.w,
            ),
            text: "होम",
          ),
          Tab(
            icon: CustomIconWidget(
              iconName: 'groups',
              color: _currentTabIndex == 1
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 6.w,
            ),
            text: "समुदाय",
          ),
          Tab(
            icon: CustomIconWidget(
              iconName: 'speaker_notes',
              color: _currentTabIndex == 2
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 6.w,
            ),
            text: "सहायक",
          ),
          Tab(
            icon: CustomIconWidget(
              iconName: 'person',
              color: _currentTabIndex == 3
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 6.w,
            ),
            text: "प्रोफाइल",
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _quickScan,
        child: CustomIconWidget(
          iconName: 'camera_alt',
          color: Colors.white,
          size: 7.w,
        ),
      ),
    );
  }
}
