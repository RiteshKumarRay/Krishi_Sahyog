import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class VoiceTextInputWidget extends StatefulWidget {
  final String text;
  final Function(String) onTextChanged;
  final bool isEditable;
  final VoidCallback? onEditToggle;

  const VoiceTextInputWidget({
    super.key,
    required this.text,
    required this.onTextChanged,
    this.isEditable = false,
    this.onEditToggle,
  });

  @override
  State<VoiceTextInputWidget> createState() => _VoiceTextInputWidgetState();
}

class _VoiceTextInputWidgetState extends State<VoiceTextInputWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(VoiceTextInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text) {
      _controller.text = widget.text;
    }
    if (widget.isEditable && !oldWidget.isEditable) {
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.text.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isEditable
              ? AppTheme.lightTheme.primaryColor
              : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          width: widget.isEditable ? 2 : 1,
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
          // Header with edit button
          Row(
            children: [
              CustomIconWidget(
                iconName: 'record_voice_over',
                color: AppTheme.lightTheme.primaryColor,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  '',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    color: AppTheme.lightTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (widget.onEditToggle != null)
                GestureDetector(
                  onTap: widget.onEditToggle,
                  child: Container(
                    padding: EdgeInsets.all(1.w),
                    decoration: BoxDecoration(
                      color: widget.isEditable
                          ? AppTheme.lightTheme.primaryColor
                              .withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: CustomIconWidget(
                      iconName: widget.isEditable ? 'check' : 'edit',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 4.w,
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: 2.h),

          // Text input/display area
          widget.isEditable
              ? TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: null,
                  onChanged: widget.onTextChanged,
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Write your question here...',
                    hintStyle:
                        AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.6),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                )
              : SelectableText(
                  widget.text,
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
        ],
      ),
    );
  }
}
