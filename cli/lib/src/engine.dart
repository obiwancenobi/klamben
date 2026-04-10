// cli/lib/src/engine.dart
//
// The detection engine: given a root path, parse all .dart files,
// run every rule against each, collect findings, and return them
// sorted by file/line/column/rule for stable output.

import 'rules/rule.dart';
import 'rules/rule_registry.dart';
import 'walker.dart';

class Engine {
  final RuleRegistry registry;

  const Engine({required this.registry});

  List<Finding> detect(String rootPath) {
    final findings = <Finding>[];
    for (final parsed in walkDartFiles(rootPath)) {
      final ctx = RuleCheckContext(
        filePath: parsed.filePath,
        unit: parsed.unit,
        sourceText: parsed.sourceText,
      );
      for (final rule in registry.rules) {
        findings.addAll(rule.check(ctx));
      }
    }
    findings.sort((a, b) {
      final fc = a.filePath.compareTo(b.filePath);
      if (fc != 0) return fc;
      if (a.line != b.line) return a.line.compareTo(b.line);
      if (a.column != b.column) return a.column.compareTo(b.column);
      return a.ruleId.compareTo(b.ruleId);
    });
    return findings;
  }
}
