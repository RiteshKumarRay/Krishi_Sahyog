import 'dart:convert';
import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:universal_html/html.dart' as html;

import '../../../core/app_export.dart';

class DataExportWidget extends StatefulWidget {
  final Map<String, dynamic> profileData;

  const DataExportWidget({
    Key? key,
    required this.profileData,
  }) : super(key: key);

  @override
  State<DataExportWidget> createState() => _DataExportWidgetState();
}

class _DataExportWidgetState extends State<DataExportWidget> {
  bool _isExporting = false;

  Future<void> _exportData(String format) async {
    setState(() {
      _isExporting = true;
    });

    try {
      String content = '';
      String filename = '';

      switch (format) {
        case 'json':
          content = _generateJsonData();
          filename =
              'profile_data_${DateTime.now().millisecondsSinceEpoch}.json';
          break;
        case 'csv':
          content = _generateCsvData();
          filename =
              'profile_data_${DateTime.now().millisecondsSinceEpoch}.csv';
          break;
        case 'txt':
          content = _generateTextData();
          filename =
              'profile_data_${DateTime.now().millisecondsSinceEpoch}.txt';
          break;
      }

      await _downloadFile(content, filename);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data exported successfully as $format'),
            backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _downloadFile(String content, String filename) async {
    if (kIsWeb) {
      final bytes = utf8.encode(content);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", filename)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsString(content);
    }
  }

  String _generateJsonData() {
    final exportData = {
      'profile': widget.profileData,
      'soilHealthRecords': _getMockSoilHealthData(),
      'advisoryHistory': _getMockAdvisoryData(),
      'exportDate': DateTime.now().toIso8601String(),
    };
    return JsonEncoder.withIndent('  ').convert(exportData);
  }

  String _generateCsvData() {
    final buffer = StringBuffer();
    buffer.writeln('Field,Value');

    widget.profileData.forEach((key, value) {
      buffer.writeln('$key,"$value"');
    });

    buffer.writeln('\nSoil Health Records');
    buffer.writeln('Date,pH,Nitrogen,Phosphorus,Potassium');

    final soilData = _getMockSoilHealthData();
    for (var record in soilData) {
      buffer.writeln(
          '${record['date']},${record['ph']},${record['nitrogen']},${record['phosphorus']},${record['potassium']}');
    }

    return buffer.toString();
  }

  String _generateTextData() {
    final buffer = StringBuffer();
    buffer.writeln('FARMER PROFILE DATA');
    buffer.writeln('=' * 50);
    buffer.writeln('Export Date: ${DateTime.now().toString()}');
    buffer.writeln();

    buffer.writeln('PERSONAL INFORMATION:');
    buffer.writeln('-' * 30);
    widget.profileData.forEach((key, value) {
      buffer.writeln('$key: $value');
    });

    buffer.writeln('\nSOIL HEALTH RECORDS:');
    buffer.writeln('-' * 30);
    final soilData = _getMockSoilHealthData();
    for (var record in soilData) {
      buffer.writeln('Date: ${record['date']}');
      buffer.writeln('pH: ${record['ph']}');
      buffer.writeln('Nitrogen: ${record['nitrogen']}');
      buffer.writeln('Phosphorus: ${record['phosphorus']}');
      buffer.writeln('Potassium: ${record['potassium']}');
      buffer.writeln();
    }

    return buffer.toString();
  }

  List<Map<String, dynamic>> _getMockSoilHealthData() {
    return [
      {
        'date': '2024-01-15',
        'ph': '6.8',
        'nitrogen': 'Medium',
        'phosphorus': 'High',
        'potassium': 'Low',
      },
      {
        'date': '2024-06-20',
        'ph': '7.2',
        'nitrogen': 'High',
        'phosphorus': 'Medium',
        'potassium': 'Medium',
      },
    ];
  }

  List<Map<String, dynamic>> _getMockAdvisoryData() {
    return [
      {
        'date': '2024-08-15',
        'query': 'Best fertilizer for wheat crop',
        'response': 'Use NPK 12:32:16 at 150kg per hectare',
      },
      {
        'date': '2024-09-01',
        'query': 'Weather forecast for next week',
        'response': 'Moderate rainfall expected, delay harvesting',
      },
    ];
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Export Data',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose export format:',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            _buildExportOption('JSON', 'json', 'Complete data in JSON format'),
            _buildExportOption('CSV', 'csv', 'Spreadsheet compatible format'),
            _buildExportOption('Text', 'txt', 'Human readable text format'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportOption(String title, String format, String description) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: format == 'json'
            ? 'code'
            : format == 'csv'
                ? 'table_chart'
                : 'description',
        color: AppTheme.lightTheme.colorScheme.primary,
        size: 24,
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        description,
        style: AppTheme.lightTheme.textTheme.bodySmall,
      ),
      onTap: () {
        Navigator.pop(context);
        _exportData(format);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _isExporting ? null : _showExportDialog,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Row(
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: _isExporting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.lightTheme.colorScheme.primary,
                          ),
                        ),
                      )
                    : CustomIconWidget(
                        iconName: 'download',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 20,
                      ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Export Data',
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    _isExporting
                        ? 'Exporting...'
                        : 'Download your profile and agricultural data',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (!_isExporting)
              CustomIconWidget(
                iconName: 'chevron_right',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
