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
      setState(() {
        _weather = {
          'location': '${data['name']}, ${data['sys']['country']}',
          'temperature': data['main']['temp'].round(),
          'condition': data['weather'][0]['main'],
          'weatherIcon':
          'https://openweathermap.org/img/wn/${data['weather'][0]['icon']}@2x.png',
          'humidity': data['main']['humidity'],
          'windSpeed': (data['wind']['speed'] * 3.6).round(),
          'rainChance': data['clouds']['all'].round(),
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
        height: 18.h, // Reduced height to avoid overflow
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
                              ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 2.w),
                        Image.network(
                          w['weatherIcon'],
                          width: 6.w,
                          height: 6.w,
                          fit: BoxFit.contain,
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
              // Right: metrics
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  // Allows vertical scroll if needed
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _metric('नमी', '${w['humidity']}%', Icons.water_drop),
                      SizedBox(height: 1.h),
                      _metric('हवा', '${w['windSpeed']} km/h', Icons.air),
                      SizedBox(height: 1.h),
                      _metric('बारिश', '${w['rainChance']}%', Icons.umbrella),
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
}
