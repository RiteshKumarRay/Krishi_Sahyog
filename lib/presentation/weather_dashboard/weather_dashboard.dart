import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/agricultural_alerts_widget.dart';
import './widgets/hourly_forecast_widget.dart';
import './widgets/sun_times_widget.dart';
import './widgets/weather_hero_card.dart';
import './widgets/weather_radar_widget.dart';
import './widgets/weekly_forecast_widget.dart';

class WeatherDashboard extends StatefulWidget {
  const WeatherDashboard({Key? key}) : super(key: key);

  @override
  State<WeatherDashboard> createState() => _WeatherDashboardState();
}

class _WeatherDashboardState extends State<WeatherDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isRadarVisible = false;
  bool _isRefreshing = false;

  // Mock data for weather dashboard
  final Map<String, dynamic> _currentWeather = {
    "location": "Pune, Maharashtra",
    "gpsAccuracy": "High",
    "temperature": 28,
    "feelsLike": 32,
    "condition": "Partly Cloudy",
    "weatherIcon": "https://openweathermap.org/img/wn/02d@2x.png",
    "humidity": 68,
    "windSpeed": 15,
    "rainChance": 25,
  };

  final List<Map<String, dynamic>> _hourlyForecast = [
    {
      "time": "Now",
      "temperature": 28,
      "icon": "https://openweathermap.org/img/wn/02d@2x.png",
      "precipitation": 25,
    },
    {
      "time": "14:00",
      "temperature": 30,
      "icon": "https://openweathermap.org/img/wn/01d@2x.png",
      "precipitation": 10,
    },
    {
      "time": "15:00",
      "temperature": 32,
      "icon": "https://openweathermap.org/img/wn/01d@2x.png",
      "precipitation": 5,
    },
    {
      "time": "16:00",
      "temperature": 31,
      "icon": "https://openweathermap.org/img/wn/02d@2x.png",
      "precipitation": 15,
    },
    {
      "time": "17:00",
      "temperature": 29,
      "icon": "https://openweathermap.org/img/wn/03d@2x.png",
      "precipitation": 30,
    },
    {
      "time": "18:00",
      "temperature": 27,
      "icon": "https://openweathermap.org/img/wn/04d@2x.png",
      "precipitation": 45,
    },
  ];

  final List<Map<String, dynamic>> _weeklyForecast = [
    {
      "day": "Today",
      "highTemp": 32,
      "lowTemp": 22,
      "icon": "https://openweathermap.org/img/wn/02d@2x.png",
      "pattern": "Partly cloudy with afternoon sunshine",
      "farmingRecommendation":
          "Good day for irrigation and field inspection. Avoid heavy machinery work during peak heat hours (12-3 PM).",
    },
    {
      "day": "Tomorrow",
      "highTemp": 29,
      "lowTemp": 20,
      "icon": "https://openweathermap.org/img/wn/10d@2x.png",
      "pattern": "Light rain in the morning, clearing by afternoon",
      "farmingRecommendation":
          "Delay outdoor activities until afternoon. Good time for indoor farm planning and equipment maintenance.",
    },
    {
      "day": "Wednesday",
      "highTemp": 31,
      "lowTemp": 21,
      "icon": "https://openweathermap.org/img/wn/01d@2x.png",
      "pattern": "Clear skies with bright sunshine",
      "farmingRecommendation":
          "Excellent day for harvesting and field work. Ensure adequate water supply for crops and workers.",
    },
    {
      "day": "Thursday",
      "highTemp": 28,
      "lowTemp": 19,
      "icon": "https://openweathermap.org/img/wn/03d@2x.png",
      "pattern": "Mostly cloudy with occasional breaks",
      "farmingRecommendation":
          "Good conditions for planting and transplanting. Monitor soil moisture levels.",
    },
    {
      "day": "Friday",
      "highTemp": 26,
      "lowTemp": 18,
      "icon": "https://openweathermap.org/img/wn/09d@2x.png",
      "pattern": "Moderate rain expected throughout the day",
      "farmingRecommendation":
          "Avoid field operations. Good time for greenhouse work and planning next week's activities.",
    },
  ];

  final List<Map<String, dynamic>> _agriculturalAlerts = [
    {
      "type": "heavy_rain",
      "severity": "medium",
      "title": "Heavy Rain Warning",
      "timeframe": "Next 48h",
      "description":
          "Moderate to heavy rainfall expected over the next two days. Accumulated rainfall may reach 50-75mm.",
      "recommendation":
          "Ensure proper drainage in fields. Postpone harvesting activities and secure farm equipment. Check for waterlogging in low-lying areas.",
    },
    {
      "type": "wind",
      "severity": "low",
      "title": "Strong Wind Advisory",
      "timeframe": "Tonight",
      "description": "Wind speeds may reach 25-30 km/h during evening hours.",
      "recommendation":
          "Secure lightweight farm structures and equipment. Check support systems for tall crops like sugarcane or banana plants.",
    },
  ];

  final Map<String, dynamic> _sunData = {
    "sunrise": "06:15 AM",
    "sunset": "06:45 PM",
    "uvIndex": 7,
    "soilTemp": 24,
    "farmingActivities":
        "Best time for outdoor work: 6:30 AM - 10:00 AM and 4:00 PM - 6:30 PM. Avoid heavy work during peak sun hours (11 AM - 3 PM). High UV index - ensure workers use sun protection.",
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshWeatherData() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
    });
  }

  void _showRadar() {
    setState(() {
      _isRadarVisible = true;
    });
  }

  void _hideRadar() {
    setState(() {
      _isRadarVisible = false;
    });
  }

  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildNotificationSettings(),
    );
  }

  void _shareWeatherSummary() {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Weather summary shared successfully'),
        backgroundColor: AppTheme.lightTheme.primaryColor,
      ),
    );
  }

  void _enableVoiceAnnouncements() {
    // Implement voice announcements
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Voice announcements enabled'),
        backgroundColor: AppTheme.lightTheme.primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Weather Dashboard'),
        backgroundColor: AppTheme.lightTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showNotificationSettings,
            icon: CustomIconWidget(
              iconName: 'notifications',
              color: Colors.white,
              size: 24,
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'share':
                  _shareWeatherSummary();
                  break;
                case 'voice':
                  _enableVoiceAnnouncements();
                  break;
                case 'radar':
                  _showRadar();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'radar',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'radar',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text('Weather Radar'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'voice',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'record_voice_over',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text('Voice Updates'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'share',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text('Share Summary'),
                  ],
                ),
              ),
            ],
            icon: CustomIconWidget(
              iconName: 'more_vert',
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Current'),
            Tab(text: 'Forecast'),
            Tab(text: 'Alerts'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
          indicatorColor: Colors.white,
        ),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refreshWeatherData,
            color: AppTheme.lightTheme.primaryColor,
            child: TabBarView(
              controller: _tabController,
              children: [
                // Current Weather Tab
                SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      WeatherHeroCard(currentWeather: _currentWeather),
                      HourlyForecastWidget(hourlyData: _hourlyForecast),
                      SunTimesWidget(sunData: _sunData),
                      SizedBox(height: 2.h),
                    ],
                  ),
                ),

                // Forecast Tab
                SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(height: 2.h),
                      WeeklyForecastWidget(weeklyData: _weeklyForecast),
                      SizedBox(height: 2.h),
                    ],
                  ),
                ),

                // Alerts Tab
                SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(height: 2.h),
                      AgriculturalAlertsWidget(alerts: _agriculturalAlerts),
                      SizedBox(height: 2.h),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Weather Radar Overlay
          WeatherRadarWidget(
            isVisible: _isRadarVisible,
            onClose: _hideRadar,
          ),

          // Loading overlay
          if (_isRefreshing)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: AppTheme.lightTheme.primaryColor,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Updating weather data...',
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        selectedItemColor: AppTheme.lightTheme.primaryColor,
        unselectedItemColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        currentIndex: 2, // Weather Dashboard is at index 2
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/dashboard-home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/voice-assistant');
              break;
            case 2:
              // Current screen - do nothing
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/market-prices');
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/profile-settings');
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'home',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'home',
              color: AppTheme.lightTheme.primaryColor,
              size: 24,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'mic',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'mic',
              color: AppTheme.lightTheme.primaryColor,
              size: 24,
            ),
            label: 'Voice',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'wb_cloudy',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'wb_cloudy',
              color: AppTheme.lightTheme.primaryColor,
              size: 24,
            ),
            label: 'Weather',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'trending_up',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'trending_up',
              color: AppTheme.lightTheme.primaryColor,
              size: 24,
            ),
            label: 'Market',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'person',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'person',
              color: AppTheme.lightTheme.primaryColor,
              size: 24,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'notifications',
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Notification Settings',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(4.w),
              children: [
                _buildNotificationTile(
                  'Weather Alerts',
                  'Get notified about severe weather conditions',
                  true,
                  'warning',
                ),
                _buildNotificationTile(
                  'Daily Forecast',
                  'Receive daily weather summary every morning',
                  true,
                  'wb_sunny',
                ),
                _buildNotificationTile(
                  'Rain Alerts',
                  'Get alerts before expected rainfall',
                  true,
                  'umbrella',
                ),
                _buildNotificationTile(
                  'Frost Warnings',
                  'Critical alerts for frost conditions',
                  true,
                  'ac_unit',
                ),
                _buildNotificationTile(
                  'UV Index Alerts',
                  'High UV index warnings for outdoor work',
                  false,
                  'wb_sunny',
                ),
                _buildNotificationTile(
                  'Wind Warnings',
                  'Strong wind alerts for farming activities',
                  false,
                  'air',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(
      String title, String subtitle, bool isEnabled, String iconName) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: iconName,
              color: AppTheme.lightTheme.primaryColor,
              size: 24,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (value) {
              // Handle switch toggle
            },
            activeColor: AppTheme.lightTheme.primaryColor,
          ),
        ],
      ),
    );
  }
}
