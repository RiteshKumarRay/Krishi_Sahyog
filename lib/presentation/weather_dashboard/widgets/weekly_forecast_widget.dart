import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class WeeklyForecastWidget extends StatefulWidget {
  final List<Map<String, dynamic>> weeklyData;

  const WeeklyForecastWidget({
    Key? key,
    required this.weeklyData,
  }) : super(key: key);

  @override
  State<WeeklyForecastWidget> createState() => _WeeklyForecastWidgetState();
}

class _WeeklyForecastWidgetState extends State<WeeklyForecastWidget> {
  int? expandedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Text(
              '7-Day Forecast',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.weeklyData.length,
            itemBuilder: (context, index) {
              final dayData = widget.weeklyData[index];
              final isExpanded = expandedIndex == index;

              return Container(
                margin: EdgeInsets.only(bottom: 2.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.lightTheme.dividerColor,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          expandedIndex = isExpanded ? null : index;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                dayData['day'] ?? 'Monday',
                                style: AppTheme.lightTheme.textTheme.titleSmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: CustomImageWidget(
                                imageUrl: dayData['icon'] ??
                                    'https://openweathermap.org/img/wn/02d@2x.png',
                                width: 10.w,
                                height: 10.w,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    '${dayData['highTemp'] ?? '28'}°',
                                    style: AppTheme
                                        .lightTheme.textTheme.titleSmall
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    '${dayData['lowTemp'] ?? '18'}°',
                                    style: AppTheme
                                        .lightTheme.textTheme.titleSmall
                                        ?.copyWith(
                                      color: AppTheme.lightTheme.colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 2.w),
                            CustomIconWidget(
                              iconName:
                                  isExpanded ? 'expand_less' : 'expand_more',
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isExpanded) ...[
                      Divider(
                        color: AppTheme.lightTheme.dividerColor,
                        height: 1,
                      ),
                      Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Weather Pattern: ${dayData['pattern'] ?? 'Partly cloudy with occasional sunshine'}',
                              style: AppTheme.lightTheme.textTheme.bodyMedium,
                            ),
                            SizedBox(height: 2.h),
                            Container(
                              padding: EdgeInsets.all(3.w),
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.primaryColor
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CustomIconWidget(
                                        iconName: 'agriculture',
                                        color: AppTheme.lightTheme.primaryColor,
                                        size: 20,
                                      ),
                                      SizedBox(width: 2.w),
                                      Text(
                                        'Farming Recommendations',
                                        style: AppTheme
                                            .lightTheme.textTheme.titleSmall
                                            ?.copyWith(
                                          color:
                                              AppTheme.lightTheme.primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 1.h),
                                  Text(
                                    dayData['farmingRecommendation'] ??
                                        'Good day for irrigation and field inspection. Avoid heavy machinery work during peak heat hours.',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: AppTheme.lightTheme.primaryColor,
                                    ),
                                  ),
                                ],
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
}
