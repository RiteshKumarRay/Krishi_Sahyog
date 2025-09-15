import 'dart:io';
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
    Widget? screen;
    switch (route) {
      case "/soil-scan":
        screen = SoilScanScreen();
        break;
      case "/crop-advisory":
        screen = CropAdvisoryScreen();
        break;
      case "/market-prices":
        screen = MarketPricesScreen();
        break;
      case "/pest-identification":
        screen = PestIdentificationScreen();
        break;
    }
    if (screen != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => screen!));
    } else {
      // Fallback for other routes if needed
      Navigator.pushNamed(context, route);
    }
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
        Navigator.push(context, MaterialPageRoute(builder: (context) => SoilScanScreen()));
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

class CropAdvisoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> advisories = [
    {
      "title": "Wheat Crop Advisory",
      "description": "Use balanced fertilizers and monitor for pests. Recommended irrigation every 10 days.",
      "icon": "agriculture",
      "color": Color(0xFF8BC34A),
    },
    {
      "title": "Rice Crop Advisory",
      "description": "Ensure proper water management. Apply nitrogen in split doses.",
      "icon": "agriculture",
      "color": Color(0xFF4CAF50),
    },
    {
      "title": "Corn Crop Advisory",
      "description": "Check for soil moisture. Use hybrid seeds for better yield.",
      "icon": "agriculture",
      "color": Color(0xFFFF9800),
    },
    {
      "title": "Soybean Crop Advisory",
      "description": "Rotate crops to prevent disease. Apply phosphorus at planting.",
      "icon": "agriculture",
      "color": Color(0xFF2196F3),
    },
    {
      "title": "Cotton Crop Advisory",
      "description": "Monitor for bollworms. Use integrated pest management.",
      "icon": "agriculture",
      "color": Color(0xFF9C27B0),
    },
    {
      "title": "Tomato Crop Advisory",
      "description": "Stake plants for support. Water consistently to prevent cracking.",
      "icon": "agriculture",
      "color": Color(0xFFF44336),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crop Advisory"),
        backgroundColor: AppTheme.lightTheme.primaryColor,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(4.w),
        itemCount: advisories.length,
        itemBuilder: (context, index) {
          final advisory = advisories[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: AppTheme.lightTheme.cardColor,
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: (advisory["color"] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomIconWidget(
                      iconName: advisory["icon"] as String,
                      color: advisory["color"] as Color,
                      size: 8.w,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          advisory["title"] as String,
                          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          advisory["description"] as String,
                          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class SoilScanScreen extends StatefulWidget {
  const SoilScanScreen({super.key});

  @override
  State<SoilScanScreen> createState() => _SoilScanScreenState();
}

class _SoilScanScreenState extends State<SoilScanScreen> {
  List<Map<String, dynamic>> reports = [
    {
      "date": "2023-01-01",
      "ph": 6.5,
      "nutrients": "N: High, P: Medium, K: Low",
      "recommendation": "Add potassium fertilizers.",
    },
    {
      "date": "2023-06-15",
      "ph": 7.0,
      "nutrients": "N: Medium, P: High, K: Medium",
      "recommendation": "Balanced, monitor regularly.",
    },
    {
      "date": "2023-09-20",
      "ph": 6.2,
      "nutrients": "N: Low, P: Low, K: High",
      "recommendation": "Apply nitrogen and phosphorus fertilizers.",
    },
    {
      "date": "2024-02-10",
      "ph": 7.5,
      "nutrients": "N: High, P: High, K: Low",
      "recommendation": "Reduce nitrogen, add potassium.",
    },
    {
      "date": "2024-05-05",
      "ph": 6.8,
      "nutrients": "N: Medium, P: Medium, K: Medium",
      "recommendation": "Soil is optimal, continue current practices.",
    },
    {
      "date": "2024-08-30",
      "ph": 6.0,
      "nutrients": "N: Low, P: High, K: Low",
      "recommendation": "Lime to raise pH, add N and K.",
    },
  ];

  Future<void> _captureImage() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        // Mock adding a new report
        setState(() {
          reports.add({
            "date": DateTime.now().toIso8601String().split('T')[0],
            "ph": 6.8, // Mock value
            "nutrients": "N: Low, P: High, K: Medium",
            "recommendation": "Adjust nitrogen levels.",
          });
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("New soil scan added! Image path: ${image.path}")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Scan cancelled")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Camera permission denied")),
      );
      openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Soil Health Scan"),
        backgroundColor: AppTheme.lightTheme.primaryColor,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(4.w),
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: AppTheme.lightTheme.cardColor,
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Report Date: ${report["date"]}",
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    "pH Level: ${report["ph"]}",
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                  Text(
                    "Nutrients: ${report["nutrients"]}",
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    "Recommendation: ${report["recommendation"]}",
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _captureImage,
        backgroundColor: AppTheme.lightTheme.primaryColor,
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
    );
  }
}

class PestIdentificationScreen extends StatefulWidget {
  const PestIdentificationScreen({super.key});

  @override
  State<PestIdentificationScreen> createState() => _PestIdentificationScreenState();
}

class _PestIdentificationScreenState extends State<PestIdentificationScreen> {
  XFile? capturedImage;
  List<Map<String, dynamic>> identifications = [
    {
      "date": "2024-01-15",
      "pest": "Aphid",
      "treatment": "Use insecticide XYZ. Apply every 7 days.",
    },
    {
      "date": "2024-03-22",
      "pest": "Whitefly",
      "treatment": "Introduce natural predators. Use neem oil.",
    },
    {
      "date": "2024-05-10",
      "pest": "Spider Mite",
      "treatment": "Increase humidity. Apply miticide.",
    },
    {
      "date": "2024-07-05",
      "pest": "Caterpillar",
      "treatment": "Hand pick. Use BT spray.",
    },
  ];

  Future<void> _capturePest() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          capturedImage = image;
          // Mock adding new identification
          identifications.add({
            "date": DateTime.now().toIso8601String().split('T')[0],
            "pest": "Aphid", // Mock
            "treatment": "Use insecticide XYZ.",
          });
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pest identified as Aphid. Treatment: Use insecticide XYZ.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Capture cancelled")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Camera permission denied")),
      );
      openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pest Identification"),
        backgroundColor: AppTheme.lightTheme.primaryColor,
      ),
      body: Column(
        children: [
          if (capturedImage != null)
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Image.file(File(capturedImage!.path), height: 30.h, fit: BoxFit.cover),
            ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(4.w),
              itemCount: identifications.length,
              itemBuilder: (context, index) {
                final id = identifications[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: AppTheme.lightTheme.cardColor,
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Date: ${id["date"]}",
                          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          "Pest: ${id["pest"]}",
                          style: AppTheme.lightTheme.textTheme.bodyMedium,
                        ),
                        Text(
                          "Treatment: ${id["treatment"]}",
                          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.lightTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _capturePest,
        backgroundColor: AppTheme.lightTheme.primaryColor,
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
    );
  }
}

class MarketPricesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> prices = [
    {
      "crop": "Wheat",
      "price": 25.50,
      "unit": "per kg",
      "change": "+1.2%",
      "color": Color(0xFF4CAF50),
    },
    {
      "crop": "Rice",
      "price": 40.00,
      "unit": "per kg",
      "change": "-0.5%",
      "color": Color(0xFFF44336),
    },
    {
      "crop": "Corn",
      "price": 18.75,
      "unit": "per kg",
      "change": "+0.8%",
      "color": Color(0xFF4CAF50),
    },
    {
      "crop": "Soybean",
      "price": 35.20,
      "unit": "per kg",
      "change": "+2.1%",
      "color": Color(0xFF4CAF50),
    },
    {
      "crop": "Cotton",
      "price": 150.00,
      "unit": "per quintal",
      "change": "-1.3%",
      "color": Color(0xFFF44336),
    },
    {
      "crop": "Tomato",
      "price": 22.00,
      "unit": "per kg",
      "change": "+0.4%",
      "color": Color(0xFF4CAF50),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Market Prices"),
        backgroundColor: AppTheme.lightTheme.primaryColor,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(4.w),
        itemCount: prices.length,
        itemBuilder: (context, index) {
          final price = prices[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: AppTheme.lightTheme.cardColor,
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        price["crop"] as String,
                        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        "\$${price["price"]} ${price["unit"]}",
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  Text(
                    price["change"] as String,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: price["color"] as Color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}