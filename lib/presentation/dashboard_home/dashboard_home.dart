import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';
import '../login_screen/login_screen.dart';
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
  // Tabs & connectivity
  late TabController _tabController;
  bool _isOnline = true;

  // Voice recorder
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isListening = false;

  // Camera
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isFlashOn = false;

  // Sample data
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
    _initializeCamera();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _audioRecorder.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  // Connectivity check stub
  void _checkConnectivity() {
    setState(() => _isOnline = true);
  }

  // Initialize camera with permission
  Future<void> _initializeCamera() async {
    if (await Permission.camera.request().isGranted) {
      _cameras = await availableCameras();
      final backCam = _cameras!
          .firstWhere((cam) => cam.lensDirection == CameraLensDirection.back);
      _cameraController = CameraController(
        backCam,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _cameraController!.initialize();
      if (mounted) setState(() {});
    } else {
      _showErrorSnackBar("कैमरा अनुमति चाहिए");
    }
  }

  // Navigate to camera capture
  void _quickScan() {
    if (_cameraController?.value.isInitialized == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _CameraCaptureScreen(controller: _cameraController!),
        ),
      );
    } else {
      _showErrorSnackBar("कैमरा तैयार नहीं");
    }
  }

  // Voice assistant handlers (unchanged)
  Future<void> _handleVoiceAssistant() async { /* ... */ }
  Future<void> _startListening() async { /* ... */ }
  Future<void> _stopListening() async { /* ... */ }
  void _showPermissionDialog() { /* ... */ }

  // SnackBars
  void _showSuccessSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.lightTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  void _showErrorSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Pull-to-refresh
  Future<void> _refreshDashboard() async {
    await Future.delayed(const Duration(seconds: 2));
    _checkConnectivity();
    _showSuccessSnackBar("डैशबोर्ड अपडेट हो गया");
  }

  // Feature navigation & options
  void _navigateToFeature(String route) => Navigator.pushNamed(context, route);
  void _showFeatureOptions(Map<String, dynamic> feature) { /* ... */ }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Status bar
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
                      // Greeting
                      GreetingHeaderWidget(
                        farmerName: "रितेश कुमार",
                        location: "लांडरां, पंजाब",
                      ),
                      SizedBox(height: 2.h),

                      // Weather card
                      WeatherCardWidget(
                        weatherData: _weatherData,
                        onTap: () =>
                            Navigator.pushNamed(context, '/weather-dashboard'),
                      ),
                      SizedBox(height: 3.h),

                      // Features grid
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "कृषि सेवाएं",
                              style: AppTheme
                                  .lightTheme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 2.h),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
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
                                  onTap: () =>
                                      _navigateToFeature(feature["route"]),
                                  onLongPress: () =>
                                      _showFeatureOptions(feature),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4.h),

                      // Recent activity
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

      // Bottom tabs
      bottomNavigationBar: TabBar(
        controller: _tabController,
        onTap: (index) {
          switch (index) {
            case 1:
              Navigator.pushNamed(context, '/community-forum');
              break;
            case 2:
              Navigator.pushNamed(context, '/voice-assistant');
              break;
            case 3:
              Navigator.pushNamed(context, '/profile-settings');
              break;
          }
          setState(() => _tabController.index = index);
        },
        tabs: [
          Tab(
            icon: CustomIconWidget(
              iconName: 'home',
              color: _tabController.index == 0
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 6.w,
            ),
            text: "होम",
          ),
          Tab(
            icon: CustomIconWidget(
              iconName: 'groups',
              color: _tabController.index == 1
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 6.w,
            ),
            text: "समुदाय",
          ),
          Tab(
            icon: CustomIconWidget(
              iconName: 'speaker_notes',
              color: _tabController.index == 2
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 6.w,
            ),
            text: "सहायक",
          ),
          Tab(
            icon: CustomIconWidget(
              iconName: 'person',
              color: _tabController.index == 3
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 6.w,
            ),
            text: "प्रोफाइल",
          ),
        ],
      ),

      // Floating camera button
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

// Full-screen camera capture with flash toggle
class _CameraCaptureScreen extends StatefulWidget {
  final CameraController controller;
  const _CameraCaptureScreen({Key? key, required this.controller})
      : super(key: key);

  @override
  State<_CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<_CameraCaptureScreen> {
  bool _isFlashOn = false;

  Future<void> _toggleFlash() async {
    _isFlashOn = !_isFlashOn;
    await widget.controller.setFlashMode(
      _isFlashOn ? FlashMode.torch : FlashMode.off,
    );
    setState(() {});
  }

  Future<void> _capturePhoto() async {
    try {
      final XFile file = await widget.controller.takePicture();
      Navigator.pop(context, file);
      if (_isFlashOn=true){
        _isFlashOn=false;
      }
      else{
        _isFlashOn=false;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("फ़ोटो सेव हो गई")),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("फ़ोटो लेने में त्रुटि")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(widget.controller),
          Positioned(
            bottom: 24,
            left: 24,
            child: IconButton(
              icon: Icon(
                _isFlashOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
                size: 32,
              ),
              onPressed: _toggleFlash,
            ),
          ),
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton(
              onPressed: _capturePhoto,
              child: const Icon(Icons.camera),
            ),
          ),
        ],
      ),
    );
  }
}
