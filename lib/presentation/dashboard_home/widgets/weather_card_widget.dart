import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../../services/weather_service.dart';

class WeatherCardWidget extends StatefulWidget {
  final VoidCallback? onTap;

  const WeatherCardWidget({Key? key, this.onTap}) : super(key: key);

  @override
  State<WeatherCardWidget> createState() => _WeatherCardWidgetState();
}

class _WeatherCardWidgetState extends State<WeatherCardWidget> {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? _weather;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final pos = await _weatherService.getCurrentLocation();
      final data = await _weatherService.getCurrentWeatherByCoordinates(
        pos.latitude,
        pos.longitude,
      );

      // Get forecast data for more accurate rain chance
      final forecastData = await _weatherService.getForecast(data['name']);
      int rainChance = _calculateRainChance(data, forecastData);

      setState(() {
        _weather = {
          'location': '${data['name']}, ${data['sys']['country']}',
          'temperature': data['main']['temp'].round(),
          'condition': data['weather'][0]['main'],
          'conditionDescription': data['weather'][0]['description'], // Added for better icon matching
          'weatherIcon': 'https://openweathermap.org/img/wn/${data['weather'][0]['icon']}@2x.png',
          'humidity': data['main']['humidity'],
          'windSpeed': (data['wind']['speed'] * 3.6).round(),
          'rainChance': rainChance,
          'precipitation': _getCurrentPrecipitation(data),
        };
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // Calculate rain chance using forecast data (more accurate)
  int _calculateRainChance(Map<String, dynamic> currentData, Map<String, dynamic>? forecastData) {
    if (forecastData != null && forecastData['list'] != null) {
      // Get rain chance from next few hours forecast
      var nextForecast = forecastData['list'][0];
      if (nextForecast['pop'] != null) {
        return (nextForecast['pop'] * 100).round();
      }
    }

    // Fallback: Use current weather condition to estimate rain chance
    String mainCondition = currentData['weather'][0]['main'].toLowerCase();
    switch (mainCondition) {
      case 'rain':
      case 'drizzle':
        return 80;
      case 'thunderstorm':
        return 90;
      case 'snow':
        return 70;
      case 'clouds':
        int cloudiness = currentData['clouds']['all'] ?? 0;
        return (cloudiness * 0.6).round();
      default:
        return 10;
    }
  }

  // Get current precipitation amount if available
  String _getCurrentPrecipitation(Map<String, dynamic> data) {
    if (data['rain'] != null) {
      double rainAmount = data['rain']['1h']?.toDouble() ?? 0.0;
      return '${rainAmount.toStringAsFixed(1)} mm';
    } else if (data['snow'] != null) {
      double snowAmount = data['snow']['1h']?.toDouble() ?? 0.0;
      return '${snowAmount.toStringAsFixed(1)} mm';
    }
    return '0.0 mm';
  }

  // Updated _buildWeatherIcon method
  Widget _buildWeatherIcon(String condition, double size) {
    IconData iconData;
    Color iconColor = Colors.white;

    // Determine time of day for sun/moon
    final now = DateTime.now();
    final hour = now.hour;
    final isNight = hour < 6 || hour > 18;

    switch (condition.toLowerCase()) {
      case 'clear':
      case 'clear sky':
        iconData = isNight ? Icons.nights_stay : Icons.wb_sunny;
        iconColor = isNight ? Colors.blue.shade100 : Colors.yellow.shade100;
        break;
      case 'clouds':
      case 'few clouds':
      case 'scattered clouds':
      case 'broken clouds':
      case 'overcast clouds':
      case 'partly cloudy':
        iconData = Icons.cloud;
        iconColor = Colors.grey.shade100;
        break;
      case 'rain':
      case 'light rain':
      case 'moderate rain':
      case 'heavy rain':
      case 'shower rain':
        iconData = Icons.grain;
        iconColor = Colors.blue.shade100;
        break;
      case 'drizzle':
      case 'light intensity drizzle':
        iconData = Icons.grain;
        iconColor = Colors.lightBlue.shade100;
        break;
      case 'thunderstorm':
      case 'thunderstorm with light rain':
      case 'thunderstorm with rain':
        iconData = Icons.thunderstorm;
        iconColor = Colors.purple.shade100;
        break;
      case 'snow':
      case 'light snow':
      case 'heavy snow':
        iconData = Icons.ac_unit;
        iconColor = Colors.white;
        break;
      case 'mist':
      case 'fog':
      case 'haze':
      case 'smoke':
        iconData = Icons.blur_on;
        iconColor = Colors.grey.shade200;
        break;
      default:
        iconData = isNight ? Icons.nights_stay : Icons.wb_sunny;
        iconColor = isNight ? Colors.blue.shade100 : Colors.yellow.shade100;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.1),
      ),
      child: Icon(
        iconData,
        size: size * 0.65, // Slightly adjusted proportion for larger container
        color: iconColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SizedBox(
        height: 18.h,
        child: Center(
          child: CircularProgressIndicator(
            color: AppTheme.lightTheme.primaryColor,
          ),
        ),
      );
    }

    if (_error != null) {
      return SizedBox(
        height: 18.h,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red),
              SizedBox(height: 1.h),
              Text('Failed to load weather', style: TextStyle(color: Colors.red)),
              SizedBox(height: 1.h),
              ElevatedButton(onPressed: _fetchWeather, child: Text('Retry')),
            ],
          ),
        ),
      );
    }

    final w = _weather!;
    return GestureDetector(
      onTap: widget.onTap ?? _fetchWeather,
      child: Container(
        width: double.infinity,
        height: 18.h,
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.lightTheme.primaryColor,
              AppTheme.lightTheme.primaryColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightTheme.primaryColor.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Row(
            children: [
              // Left: location & temp
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      w['location'],
                      style: AppTheme.lightTheme.textTheme.titleMedium
                          ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        Text(
                          '${w['temperature']}°C',
                          style: AppTheme.lightTheme.textTheme.headlineMedium
                              ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 23.sp, // Increased from default size
                          ),
                        ),
                        SizedBox(width: 2.w),
                        // Increased weather icon size from 6.w to 8.w
                        _buildWeatherIcon(
                          w['conditionDescription'] ?? w['condition'] ?? '',
                          8.w, // Increased from 6.w
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      w['condition'],
                      style: AppTheme.lightTheme.textTheme.bodyMedium
                          ?.copyWith(color: Colors.white.withOpacity(0.9)),
                    ),
                  ],
                ),
              ),
              // Right: metrics with improved rain chance
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _metric('नमी', '${w['humidity']}%', Icons.water_drop),
                      SizedBox(height: 1.h),
                      _metric('हवा', '${w['windSpeed']} km/h', Icons.air),
                      SizedBox(height: 1.h),
                      // Enhanced rain chance with color coding
                      _rainMetric('बारिश', w['rainChance'], w['precipitation']),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 24),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.bodyMedium
              ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall
              ?.copyWith(color: Colors.white.withOpacity(0.8)),
        ),
      ],
    );
  }

  // Enhanced rain metric with color coding and precipitation info
  Widget _rainMetric(String label, int rainChance, String precipitation) {
    Color rainColor = Colors.white.withOpacity(0.8);
    IconData rainIcon = Icons.umbrella;

    // Color code based on rain chance
    if (rainChance >= 70) {
      rainColor = Colors.blue.shade200;
      rainIcon = Icons.thunderstorm;
    } else if (rainChance >= 40) {
      rainColor = Colors.blue.shade100;
      rainIcon = Icons.grain;
    } else if (rainChance >= 20) {
      rainColor = Colors.grey.shade200;
      rainIcon = Icons.cloud;
    } else {
      rainColor = Colors.white.withOpacity(0.8);
      rainIcon = Icons.wb_sunny; // Clear weather icon for low rain chance
    }

    return Column(
      children: [
        Icon(rainIcon, color: rainColor, size: 24),
        SizedBox(height: 0.5.h),
        Text(
          '${rainChance}%',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        if (precipitation != '0.0 mm')
          Text(
            precipitation,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.7),
              fontSize: 8.sp,
            ),
          ),
      ],
    );
  }
}
