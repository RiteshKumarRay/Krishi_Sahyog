import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecentActivityWidget extends StatelessWidget {
  final List<Map<String, dynamic>> activities;

  const RecentActivityWidget({
    Key? key,
    required this.activities,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: 'history',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 12.w,
            ),
            SizedBox(height: 2.h),
            Text(
              "कोई हाल की गतिविधि नहीं",
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Row(
            children: [
              Text(
                "हाल की गतिविधि",
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // Navigate to full activity history
                },
                child: Text(
                  "सभी देखें",
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.lightTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          itemCount: activities.length > 3 ? 3 : activities.length,
          separatorBuilder: (context, index) => SizedBox(height: 1.h),
          itemBuilder: (context, index) {
            final activity = activities[index];
            return _buildActivityItem(activity);
          },
        ),
      ],
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: _getActivityColor(activity["type"] as String? ?? "scan")
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: _getActivityIcon(activity["type"] as String? ?? "scan"),
              color: _getActivityColor(activity["type"] as String? ?? "scan"),
              size: 5.w,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity["title"] as String? ?? "गतिविधि",
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  activity["description"] as String? ?? "विवरण उपलब्ध नहीं",
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            _formatTimestamp(
                activity["timestamp"] as DateTime? ?? DateTime.now()),
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }

  String _getActivityIcon(String type) {
    switch (type) {
      case 'scan':
        return 'document_scanner';
      case 'voice':
        return 'mic';
      case 'weather':
        return 'wb_sunny';
      case 'market':
        return 'trending_up';
      case 'crop':
        return 'agriculture';
      default:
        return 'history';
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'scan':
        return AppTheme.lightTheme.primaryColor;
      case 'voice':
        return const Color(0xFF2196F3);
      case 'weather':
        return const Color(0xFFFF9800);
      case 'market':
        return const Color(0xFF4CAF50);
      case 'crop':
        return const Color(0xFF8BC34A);
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return "अभी";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes}मि पहले";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}घं पहले";
    } else {
      return "${difference.inDays}दिन पहले";
    }
  }
}
