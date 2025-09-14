import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AgriculturalAlertsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> alerts;

  const AgriculturalAlertsWidget({
    Key? key,
    required this.alerts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
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
            CustomIconWidget(
              iconName: 'check_circle',
              color: Colors.green,
              size: 24,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                'No weather alerts at this time. Conditions are favorable for farming activities.',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Text(
              'Agricultural Alerts',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return Container(
                margin: EdgeInsets.only(bottom: 2.h),
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: _getAlertBackgroundColor(alert['severity'] ?? 'low'),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getAlertBorderColor(alert['severity'] ?? 'low'),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: _getAlertIcon(alert['type'] ?? 'general'),
                          color: _getAlertIconColor(alert['severity'] ?? 'low'),
                          size: 24,
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                alert['title'] ?? 'Weather Alert',
                                style: AppTheme.lightTheme.textTheme.titleSmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: _getAlertTextColor(
                                      alert['severity'] ?? 'low'),
                                ),
                              ),
                              Text(
                                _getSeverityLabel(alert['severity'] ?? 'low'),
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: _getAlertIconColor(
                                      alert['severity'] ?? 'low'),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color:
                                _getAlertIconColor(alert['severity'] ?? 'low')
                                    .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            alert['timeframe'] ?? 'Next 24h',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: _getAlertIconColor(
                                  alert['severity'] ?? 'low'),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      alert['description'] ??
                          'Weather conditions may affect farming activities.',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: _getAlertTextColor(alert['severity'] ?? 'low'),
                      ),
                    ),
                    if (alert['recommendation'] != null) ...[
                      SizedBox(height: 2.h),
                      Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomIconWidget(
                              iconName: 'lightbulb',
                              color: _getAlertIconColor(
                                  alert['severity'] ?? 'low'),
                              size: 20,
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Text(
                                alert['recommendation'],
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: _getAlertTextColor(
                                      alert['severity'] ?? 'low'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getAlertBackgroundColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red.withValues(alpha: 0.1);
      case 'medium':
        return Colors.orange.withValues(alpha: 0.1);
      case 'low':
      default:
        return Colors.blue.withValues(alpha: 0.1);
    }
  }

  Color _getAlertBorderColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red.withValues(alpha: 0.3);
      case 'medium':
        return Colors.orange.withValues(alpha: 0.3);
      case 'low':
      default:
        return Colors.blue.withValues(alpha: 0.3);
    }
  }

  Color _getAlertIconColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
      default:
        return Colors.blue;
    }
  }

  Color _getAlertTextColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red.shade800;
      case 'medium':
        return Colors.orange.shade800;
      case 'low':
      default:
        return Colors.blue.shade800;
    }
  }

  String _getAlertIcon(String type) {
    switch (type.toLowerCase()) {
      case 'frost':
        return 'ac_unit';
      case 'rain':
      case 'heavy_rain':
        return 'umbrella';
      case 'drought':
        return 'wb_sunny';
      case 'wind':
        return 'air';
      case 'hail':
        return 'grain';
      default:
        return 'warning';
    }
  }

  String _getSeverityLabel(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return 'Critical Alert';
      case 'medium':
        return 'Moderate Alert';
      case 'low':
      default:
        return 'Advisory';
    }
  }
}
