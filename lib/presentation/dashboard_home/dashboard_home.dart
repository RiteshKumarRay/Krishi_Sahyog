import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:sizer/sizer.dart';
import 'package:image_picker/image_picker.dart';
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
    "location": "Delhi, India",
    "temperature": 28,
    "condition": "Sunny",
    "humidity": 65,
    "windSpeed": 12,
    "rainfall": 5,
  };

  final List<Map<String, dynamic>> _features = [
    {
      "id": "soil_scan",
      "title": "Soil Health Scan",
      "description": "Scan your soil health card and get instant analysis",
      "icon": "document_scanner",
      "color": Color(0xFF4CAF50),
      "quickAction": "Start Scan",
      "hasNotification": false,
      "route": "/soil-scan",
    },
    {
      "id": "crop_advisory",
      "title": "Crop Advisory",
      "description": "Personalized suggestions for your crop and better production information",
      "icon": "agriculture",
      "color": Color(0xFF8BC34A),
      "quickAction": "Get Advice",
      "hasNotification": true,
      "route": "/crop-advisory",
    },
    {
      "id": "market_prices",
      "title": "Market Prices",
      "description": "Get today's fresh market prices and information",
      "icon": "trending_up",
      "color": Color(0xFF2196F3),
      "quickAction": "View Prices",
      "hasNotification": false,
      "route": "/market-prices",
    },
    {
      "id": "pest_identification",
      "title": "Pest Identification",
      "description": "Identify pests and diseases in crops and get treatment information",
      "icon": "bug_report",
      "color": Color(0xFFFF9800),
      "quickAction": "Take Photo",
      "hasNotification": false,
      "route": "/pest-identification",
    },
  ];

  final List<Map<String, dynamic>> _recentActivities = [
    {
      "id": "1",
      "type": "scan",
      "title": "Soil Health Scan",
      "description": "Analysis of soil in field #1 complete",
      "timestamp": DateTime.now().subtract(Duration(hours: 2)),
    },
    {
      "id": "2",
      "type": "voice",
      "title": "Voice Query",
      "description": "Asked about wheat sowing",
      "timestamp": DateTime.now().subtract(Duration(hours: 5)),
    },
    {
      "id": "3",
      "type": "weather",
      "title": "Weather Update",
      "description": "Possibility of rain in next 3 days",
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
      _showErrorSnackBar("Problem in voice recording");
    }
  }

  Future<void> _stopListening() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isListening = false;
      });
      if (path != null) {
        _showSuccessSnackBar("Voice recorded, processing...");
        Navigator.pushNamed(context, '/voice-assistant');
      }
    } catch (e) {
      setState(() {
        _isListening = false;
      });
      _showErrorSnackBar("Problem stopping recording");
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Microphone Permission Required"),
        content: const Text("Allow microphone permission to use voice assistant."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text("Open Settings"),
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
    _showSuccessSnackBar("Dashboard updated");
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
              title: const Text("Pin to Top"),
              onTap: () {
                Navigator.pop(context);
                _showSuccessSnackBar("${feature["title"]} pinned to top");
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'visibility_off',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 6.w,
              ),
              title: const Text("Hide"),
              onTap: () {
                Navigator.pop(context);
                _showSuccessSnackBar("${feature["title"]} hidden");
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'settings',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 6.w,
              ),
              title: const Text("Settings"),
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

  Future<void> _quickScan() async {
    // Request camera permission
    final status = await Permission.camera.request();
    if (status.isGranted) {
      // Open the camera scanner
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        // For demo purposes, show a success message after "scanning"
        _showSuccessSnackBar("Scan complete! Image path: ${image.path}");
        // Optionally navigate to the soil-scan route after scanning
        Navigator.pushNamed(context, '/soil-scan');
      } else {
        _showErrorSnackBar("Scan cancelled");
      }
    } else {
      _showErrorSnackBar("Camera permission denied");
      openAppSettings();
    }
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
              lastSync: _isOnline ? "Now" : "2 hours ago",
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
                        farmerName: "Ritesh Kumar",
                        location: "Landran, Punjab",
                      ),
                      SizedBox(height: 2.h),

                      // Mic floating button removed here.

                      WeatherCardWidget(
                        onTap: () => Navigator.pushNamed(context, '/weather-dashboard'),
                      ),
                      SizedBox(height: 3.h),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Agriculture Services",
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
            text: "Home",
          ),
          Tab(
            icon: CustomIconWidget(
              iconName: 'groups',
              color: _currentTabIndex == 1
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 6.w,
            ),
            text: "Community",
          ),
          Tab(
            icon: CustomIconWidget(
              iconName: 'speaker_notes',
              color: _currentTabIndex == 2
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 6.w,
            ),
            text: "Assistant",
          ),
          Tab(
            icon: CustomIconWidget(
              iconName: 'person',
              color: _currentTabIndex == 3
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 6.w,
            ),
            text: "Profile",
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