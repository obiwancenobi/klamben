// cli/lib/src/reporter/html_reporter.dart

import 'dart:convert';
import 'dart:io';

import 'report_data.dart';
import 'templates/dashboard_template.dart';
import 'templates/report_template.dart';

class HtmlReporter {
  const HtmlReporter();

  String renderDetectReport(ReportData data) {
    return _inject(reportTemplate, data);
  }

  String renderDashboard(ReportData data) {
    return _inject(dashboardTemplate, data);
  }

  static void writeToFile(String html, String outputPath) {
    final file = File(outputPath);
    final parent = file.parent;
    if (!parent.existsSync()) {
      parent.createSync(recursive: true);
    }
    file.writeAsStringSync(html);
  }

  String _inject(String template, ReportData data) {
    final jsonStr = const JsonEncoder.withIndent('  ').convert(data.toJson());
    return template.replaceFirst('/* INJECT_DATA */{}', jsonStr);
  }
}
