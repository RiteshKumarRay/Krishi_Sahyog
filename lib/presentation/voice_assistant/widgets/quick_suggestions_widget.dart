import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickSuggestionsWidget extends StatelessWidget {
  final Function(String) onSuggestionTap;

  const QuickSuggestionsWidget({
    super.key,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      {
        'text': 'Weather Information',
        'icon': 'wb_sunny',
        'query': 'how is the weather today?'
      },
      {
        'text': 'price of crop',
        'icon': 'trending_up',
        'query': 'what is the price of wheat today?'
      },
      {
        'text': 'Pest Identification',
        'icon': 'bug_report',
        'query': 'My crop is infested with insects'
      },
      {'text': 'Seed Advice', 'icon': 'eco', 'query': 'Which seeds should be sown?'},
      {
        'text': 'Fertilizer Information',
        'icon': 'grass',
        'query': 'Which fertilizer should I put in the crop??'
      },
      {
        'text': 'Irrigation advice',
        'icon': 'water_drop',
        'query': 'When should irrigation be done?'
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'quick advice',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: suggestions
                .map((suggestion) => _buildSuggestionChip(
                      suggestion['text']!,
                      suggestion['icon']!,
                      suggestion['query']!,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text, String icon, String query) {
    return GestureDetector(
      onTap: () => onSuggestionTap(query),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: AppTheme.lightTheme.primaryColor,
              size: 4.w,
            ),
            SizedBox(width: 2.w),
            Text(
              text,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
