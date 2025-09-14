import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StatusBarWidget extends StatelessWidget {
  final bool isOnline;
  final String? networkType;
  final String? lastSync;

  const StatusBarWidget({
    Key? key,
    this.isOnline = true,
    this.networkType,
    this.lastSync,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isOnline
            ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1)
            : AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: isOnline ? 'wifi' : 'wifi_off',
            color: isOnline
                ? AppTheme.lightTheme.primaryColor
                : AppTheme.lightTheme.colorScheme.error,
            size: 4.w,
          ),
          SizedBox(width: 2.w),
          Text(
            isOnline ? "ऑनलाइन" : "ऑफलाइन",
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: isOnline
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.error,
              fontWeight: FontWeight.w500,
              fontSize: 10.sp,
            ),
          ),
          if (networkType != null && isOnline) ...[
            SizedBox(width: 1.w),
            Text(
              "($networkType)",
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                fontSize: 9.sp,
              ),
            ),
          ],
          const Spacer(),
          if (lastSync != null) ...[
            CustomIconWidget(
              iconName: 'sync',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 3.5.w,
            ),
            SizedBox(width: 1.w),
            Text(
              "अंतिम सिंक: $lastSync",
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                fontSize: 9.sp,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
