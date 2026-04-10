// cli/lib/src/reporter/json_reporter.dart

import 'dart:convert';

import '../rules/rule.dart';

class JsonReporter {
  const JsonReporter();

  String render(List<Finding> findings) {
    final payload = <String, dynamic>{
      'count': findings.length,
      'findings': findings
          .map((f) => {
                'rule_id': f.ruleId,
                'severity': f.severity.name,
                'message': f.message,
                'file': f.filePath,
                'line': f.line,
                'column': f.column,
              })
          .toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }
}
