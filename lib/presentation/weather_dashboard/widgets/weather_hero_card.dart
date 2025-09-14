import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class WeatherHeroCard extends StatelessWidget {
  final Map<String, dynamic> currentWeather;

  const WeatherHeroCard({
    Key? key,
    required this.currentWeather,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.lightTheme.primaryColor,
            AppTheme.lightTheme.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: location and edit
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Location info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentWeather['location'] ?? 'Unknown Location',
                      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.white.withOpacity(0.8),
                          size: 16,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          'GPS Accuracy: ${currentWeather['gpsAccuracy'] ?? 'High'}',
                          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Edit location button
              GestureDetector(
                onTap: () {
                  // Handle manual location change
                },
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.edit_location,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Temperature & icon
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${currentWeather['temperature']?.round() ?? 0}°C',
                      style: AppTheme.lightTheme.textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: 25.sp,
                      ),
                    ),
                    Text(
                      currentWeather['condition'] ?? '',
                      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Feels like ${currentWeather['feelsLike']?.round() ?? 0}°C',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: _buildWeatherIcon(currentWeather['condition'] ?? '', 20.w),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Metrics row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeatherMetric(
                'Humidity',
                '${currentWeather['humidity']?.round() ?? 0}%',
                Icons.water_drop,
              ),
              _buildWeatherMetric(
                'Wind',
                '${currentWeather['windSpeed']?.round() ?? 0} km/h',
                Icons.air,
              ),
              _buildWeatherMetric(
                'Rain',
                '${currentWeather['rainChance']?.round() ?? 0}%',
                Icons.umbrella,
              ),
            ],
          ),
        ],
      ),
    );
  }

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
        size: size * 0.6,
        color: iconColor,
      ),
    );
  }

  Widget _buildWeatherMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.8),
          size: 24,
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
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
      ],
    );
  }
}
