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
        'text': 'मौसम की जानकारी',
        'icon': 'wb_sunny',
        'query': 'आज का मौसम कैसा है?'
      },
      {
        'text': 'फसल की कीमत',
        'icon': 'trending_up',
        'query': 'गेहूं की आज की कीमत क्या है?'
      },
      {
        'text': 'कीट पहचान',
        'icon': 'bug_report',
        'query': 'मेरी फसल में कीड़े लग गए हैं'
      },
      {'text': 'बीज की सलाह', 'icon': 'eco', 'query': 'कौन सा बीज बोना चाहिए?'},
      {
        'text': 'खाद की जानकारी',
        'icon': 'grass',
        'query': 'फसल में कौन सी खाद डालूं?'
      },
      {
        'text': 'सिंचाई की सलाह',
        'icon': 'water_drop',
        'query': 'कब सिंचाई करनी चाहिए?'
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'त्वरित सुझाव',
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
