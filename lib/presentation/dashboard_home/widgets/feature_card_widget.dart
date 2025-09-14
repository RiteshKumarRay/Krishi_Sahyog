import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';

class FeatureCardWidget extends StatelessWidget {
  final Map feature;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const FeatureCardWidget({
    Key? key,
    required this.feature,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color baseColor =
        feature["color"] as Color? ?? AppTheme.lightTheme.primaryColor;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon + Notification Dot
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: baseColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomIconWidget(
                      iconName: feature["icon"] as String? ?? "agriculture",
                      color: baseColor,
                      size: 6.w,
                    ),
                  ),
                  const Spacer(),
                  if (feature["hasNotification"] == true)
                    Container(
                      width: 2.w,
                      height: 2.w,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),

              SizedBox(height: 3.h),

              // Title
              Text(
                feature["title"] as String? ?? "सुविधा",
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: 1.h),

              // Description
              Text(
                feature["description"] as String? ??
                    "विवरण उपलब्ध नहीं",
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color:
                  AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: 2.h),

              // Quick Action Button
              if (feature["quickAction"] != null)
                Flexible(
                  // Ensures the button text wraps or truncates rather than overflowing
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                        vertical: 1.5.h, horizontal: 3.w),
                    decoration: BoxDecoration(
                      color: baseColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      feature["quickAction"] as String? ??
                          "तुरंत शुरू करें",
                      style:
                      AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        color: baseColor,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

