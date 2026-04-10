// cli/lib/src/reporter/text_reporter.dart

import '../rules/rule.dart';

class TextReporter {
  final bool useColor;
  const TextReporter({this.useColor = true});

  String render(List<Finding> findings) {
    if (findings.isEmpty) {
      return 'No issues found.\n';
    }

    final buf = StringBuffer();
    final byFile = <String, List<Finding>>{};
    for (final f in findings) {
      byFile.putIfAbsent(f.filePath, () => []).add(f);
    }

    final sortedFiles = byFile.keys.toList()..sort();
    for (final file in sortedFiles) {
      buf.writeln(file);
      for (final f in byFile[file]!) {
        final sev = _severityLabel(f.severity);
        buf.writeln(
          '  ${f.line}:${f.column}  $sev  ${f.ruleId}  ${f.message}',
        );
      }
      buf.writeln();
    }

    final errors =
        findings.where((f) => f.severity == RuleSeverity.error).length;
    final warnings =
        findings.where((f) => f.severity == RuleSeverity.warning).length;
    final infos =
        findings.where((f) => f.severity == RuleSeverity.info).length;

    buf.write('${findings.length} issues (');
    final parts = <String>[];
    if (errors > 0) parts.add('$errors error${errors == 1 ? '' : 's'}');
    if (warnings > 0) {
      parts.add('$warnings warning${warnings == 1 ? '' : 's'}');
    }
    if (infos > 0) parts.add('$infos info');
    buf.write(parts.join(', '));
    buf.writeln(
        ') in ${byFile.length} file${byFile.length == 1 ? '' : 's'}.');

    return buf.toString();
  }

  String _severityLabel(RuleSeverity s) {
    final label = switch (s) {
      RuleSeverity.error => 'error  ',
      RuleSeverity.warning => 'warning',
      RuleSeverity.info => 'info   ',
    };
    if (!useColor) return label;
    final color = switch (s) {
      RuleSeverity.error => '\x1B[31m',
      RuleSeverity.warning => '\x1B[33m',
      RuleSeverity.info => '\x1B[36m',
    };
    return '$color$label\x1B[0m';
  }
}
