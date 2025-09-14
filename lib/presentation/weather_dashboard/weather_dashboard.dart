import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

import '../../core/app_export.dart';
import '../../services/weather_service.dart';
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
  bool _isLoading = true;
  String _errorMessage = '';

  final WeatherService _weatherService = WeatherService();

  // Weather data
  Map<String, dynamic> _currentWeather = {};
  List<Map<String, dynamic>> _hourlyForecast = [];
  List<Map<String, dynamic>> _weeklyForecast = [];
  List<Map<String, dynamic>> _agriculturalAlerts = [];
  Map<String, dynamic> _sunData = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadWeatherData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper function to calculate average
  double _calculateAverage(List<double> list) {
    if (list.isEmpty) return 0.0;
    return list.reduce((a, b) => a + b) / list.length;
  }

  Future<void> _loadWeatherData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Get current location
      final position = await _weatherService.getCurrentLocation();

      // Get current weather by coordinates
      final currentWeatherData = await _weatherService.getCurrentWeatherByCoordinates(
          position.latitude,
          position.longitude
      );

      // Get forecast data
      final forecastData = await _weatherService.getForecast(currentWeatherData['name']);

      setState(() {
        _currentWeather = _parseCurrentWeather(currentWeatherData);
        _hourlyForecast = _parseHourlyForecast(forecastData);
        _weeklyForecast = _parseWeeklyForecast(forecastData);
        _sunData = _parseSunData(currentWeatherData);
        _agriculturalAlerts = _generateAgriculturalAlerts(currentWeatherData, forecastData);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      // Load default data if API fails
      _loadDefaultData();
    }
  }

  Map<String, dynamic> _parseCurrentWeather(Map<String, dynamic> data) {
    return {
      "location": "${data['name']}, ${data['sys']['country']}",
      "gpsAccuracy": "High",
      "temperature": data['main']['temp'].round(),
      "feelsLike": data['main']['feels_like'].round(),
      "condition": data['weather'][0]['description'],
      "weatherIcon": "https://openweathermap.org/img/wn/${data['weather'][0]['icon']}@2x.png",
      "humidity": data['main']['humidity'],
      "windSpeed": (data['wind']['speed'] * 3.6).round(), // Convert m/s to km/h
      "rainChance": data['clouds']['all'], // Using cloudiness as rain chance
    };
  }

  List<Map<String, dynamic>> _parseHourlyForecast(Map<String, dynamic> data) {
    List<Map<String, dynamic>> hourlyData = [];

    // Take first 6 hours from forecast
    for (int i = 0; i < 6 && i < data['list'].length; i++) {
      final item = data['list'][i];
      final dateTime = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);

      hourlyData.add({
        "time": i == 0 ? "Now" : DateFormat('HH:mm').format(dateTime),
        "temperature": item['main']['temp'].round(),
        "icon": "https://openweathermap.org/img/wn/${item['weather'][0]['icon']}@2x.png",
        "precipitation": (item['pop'] * 100).round(),
      });
    }

    return hourlyData;
  }

  List<Map<String, dynamic>> _parseWeeklyForecast(Map<String, dynamic> data) {
    List<Map<String, dynamic>> weeklyData = [];
    Map<String, Map<String, dynamic>> dailyData = {};

    // Group forecast data by day
    for (var item in data['list']) {
      final dateTime = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
      final dayKey = DateFormat('yyyy-MM-dd').format(dateTime);

      if (!dailyData.containsKey(dayKey)) {
        dailyData[dayKey] = {
          'date': dateTime,
          'temps': <double>[],
          'weather': item['weather'][0],
          'description': item['weather'][0]['description'],
        };
      }

      dailyData[dayKey]!['temps'].add(item['main']['temp'].toDouble());
    }

    // Convert to weekly forecast format
    final sortedDays = dailyData.keys.toList()..sort();
    for (int i = 0; i < sortedDays.length && i < 5; i++) {
      final dayData = dailyData[sortedDays[i]]!;
      final temps = dayData['temps'] as List<double>;
      final date = dayData['date'] as DateTime;

      String dayName;
      if (i == 0) {
        dayName = "Today";
      } else if (i == 1) {
        dayName = "Tomorrow";
      } else {
        dayName = DateFormat('EEEE').format(date);
      }

      weeklyData.add({
        "day": dayName,
        "highTemp": temps.reduce((a, b) => a > b ? a : b).round(),
        "lowTemp": temps.reduce((a, b) => a < b ? a : b).round(),
        "icon": "https://openweathermap.org/img/wn/${dayData['weather']['icon']}@2x.png",
        "pattern": dayData['description'],
        "farmingRecommendation": _getFarmingRecommendation(dayData['weather']['main'], _calculateAverage(temps)),
      });
    }

    return weeklyData;
  }

  Map<String, dynamic> _parseSunData(Map<String, dynamic> data) {
    final sunrise = DateTime.fromMillisecondsSinceEpoch(data['sys']['sunrise'] * 1000);
    final sunset = DateTime.fromMillisecondsSinceEpoch(data['sys']['sunset'] * 1000);

    return {
      "sunrise": DateFormat('hh:mm a').format(sunrise),
      "sunset": DateFormat('hh:mm a').format(sunset),
      "uvIndex": 7, // Default value, you'd need UV Index API for real data
      "soilTemp": (data['main']['temp'] - 4).round(), // Approximate soil temp
      "farmingActivities": "Best time for outdoor work: ${DateFormat('h:mm a').format(sunrise.add(Duration(hours: 1)))} - ${DateFormat('h:mm a').format(sunrise.add(Duration(hours: 4)))} and ${DateFormat('h:mm a').format(sunset.subtract(Duration(hours: 3)))} - ${DateFormat('h:mm a').format(sunset.subtract(Duration(hours: 1)))}.",
    };
  }

  List<Map<String, dynamic>> _generateAgriculturalAlerts(
      Map<String, dynamic> currentWeather,
      Map<String, dynamic> forecast
      ) {
    List<Map<String, dynamic>> alerts = [];

    // Check for rain in forecast
    bool heavyRainExpected = false;
    for (var item in forecast['list'].take(8)) {
      if (item['weather'][0]['main'] == 'Rain' && (item['pop'] ?? 0) > 0.7) {
        heavyRainExpected = true;
        break;
      }
    }

    if (heavyRainExpected) {
      alerts.add({
        "type": "heavy_rain",
        "severity": "medium",
        "title": "Heavy Rain Warning",
        "timeframe": "Next 24h",
        "description": "Heavy rainfall expected in the coming hours. Accumulated rainfall may be significant.",
        "recommendation": "Ensure proper drainage in fields. Postpone harvesting activities and secure farm equipment.",
      });
    }

    // Check for strong winds
    final windSpeed = currentWeather['windSpeed'] ?? 0;
    if (windSpeed > 20) {
      alerts.add({
        "type": "wind",
        "severity": "low",
        "title": "Strong Wind Advisory",
        "timeframe": "Current",
        "description": "Wind speeds are currently high at $windSpeed km/h.",
        "recommendation": "Secure lightweight farm structures and equipment. Check support systems for tall crops.",
      });
    }

    return alerts;
  }

  String _getFarmingRecommendation(String weatherMain, double avgTemp) {
    switch (weatherMain.toLowerCase()) {
      case 'rain':
        return "Avoid field operations. Good time for greenhouse work and planning activities.";
      case 'clear':
        return "Excellent day for harvesting and field work. Ensure adequate water supply.";
      case 'clouds':
        return "Good conditions for planting and transplanting. Monitor soil moisture levels.";
      default:
        return "Monitor weather conditions closely. Adjust farming activities accordingly.";
    }
  }

  void _loadDefaultData() {
    // Fallback to mock data if API fails
    setState(() {
      _currentWeather = {
        "location": "Location unavailable",
        "gpsAccuracy": "Low",
        "temperature": 25,
        "feelsLike": 28,
        "condition": "Weather data unavailable",
        "weatherIcon": "https://openweathermap.org/img/wn/01d@2x.png",
        "humidity": 60,
        "windSpeed": 10,
        "rainChance": 20,
      };
      _hourlyForecast = [];
      _weeklyForecast = [];
      _agriculturalAlerts = [];
      _sunData = {
        "sunrise": "06:00 AM",
        "sunset": "06:00 PM",
        "uvIndex": 5,
        "soilTemp": 22,
        "farmingActivities": "Weather data temporarily unavailable. Please check back later.",
      };
    });
  }

  Future<void> _refreshWeatherData() async {
    setState(() {
      _isRefreshing = true;
    });

    await _loadWeatherData();

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Weather summary shared successfully'),
        backgroundColor: AppTheme.lightTheme.primaryColor,
      ),
    );
  }

  void _enableVoiceAnnouncements() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Voice announcements enabled'),
        backgroundColor: AppTheme.lightTheme.primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppTheme.lightTheme.primaryColor,
              ),
              SizedBox(height: 2.h),
              Text(
                'Loading weather data...',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage.isNotEmpty && _currentWeather.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 60,
                color: AppTheme.lightTheme.colorScheme.error,
              ),
              SizedBox(height: 2.h),
              Text(
                'Failed to load weather data',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              SizedBox(height: 1.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                ),
              ),
              SizedBox(height: 3.h),
              ElevatedButton(
                onPressed: _loadWeatherData,
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

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
          unselectedLabelColor: Colors.white.withOpacity(0.7),
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
                      if (_hourlyForecast.isNotEmpty)
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
                      if (_weeklyForecast.isNotEmpty)
                        WeeklyForecastWidget(weeklyData: _weeklyForecast)
                      else
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(4.w),
                            child: Text(
                              'Forecast data unavailable',
                              style: AppTheme.lightTheme.textTheme.bodyMedium,
                            ),
                          ),
                        ),
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
                      if (_agriculturalAlerts.isNotEmpty)
                        AgriculturalAlertsWidget(alerts: _agriculturalAlerts)
                      else
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(4.w),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 48,
                                  color: Colors.green,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'No weather alerts',
                                  style: AppTheme.lightTheme.textTheme.titleMedium,
                                ),
                                Text(
                                  'Weather conditions are currently favorable',
                                  style: AppTheme.lightTheme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
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
              color: Colors.black.withOpacity(0.3),
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
        currentIndex: 2,
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
              iconName: 'chat',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'chat',
              color: AppTheme.lightTheme.primaryColor,
              size: 24,
            ),
            label: 'Assistant',
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
              color: AppTheme.lightTheme.primaryColor.withOpacity(0.1),
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
