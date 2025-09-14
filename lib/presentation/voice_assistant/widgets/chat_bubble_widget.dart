import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ChatBubbleWidget extends StatelessWidget {
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final VoidCallback? onPlayAudio;
  final bool isPlaying;

  const ChatBubbleWidget({
    super.key,
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.onPlayAudio,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _buildAvatar(),
            SizedBox(width: 2.w),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: 75.w),
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: isUser
                        ? AppTheme.lightTheme.primaryColor
                        : AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message,
                        style:
                            AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                          color: isUser
                              ? Colors.white
                              : AppTheme.lightTheme.colorScheme.onSurface,
                          height: 1.4,
                        ),
                      ),
                      if (!isUser && onPlayAudio != null) ...[
                        SizedBox(height: 1.h),
                        GestureDetector(
                          onTap: onPlayAudio,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.primaryColor
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomIconWidget(
                                  iconName: isPlaying ? 'pause' : 'play_arrow',
                                  color: AppTheme.lightTheme.primaryColor,
                                  size: 3.w,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  isPlaying ? 'रुकें' : 'सुनें',
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: AppTheme.lightTheme.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  _formatTime(timestamp),
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            SizedBox(width: 2.w),
            _buildAvatar(),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 8.w,
      height: 8.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isUser
            ? AppTheme.lightTheme.primaryColor
            : AppTheme.lightTheme.colorScheme.secondary,
      ),
      child: Center(
        child: CustomIconWidget(
          iconName: isUser ? 'person' : 'agriculture',
          color: Colors.white,
          size: 4.w,
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'अभी';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} मिनट पहले';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} घंटे पहले';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}
