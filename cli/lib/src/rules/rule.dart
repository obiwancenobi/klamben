// cli/lib/src/rules/rule.dart
//
// Common types for rule definitions and their findings.

import 'package:analyzer/dart/ast/ast.dart';

/// Category a rule belongs to. Mirrors the `category` field in rules.json.
enum RuleCategory {
  visual,
  layout,
  platform,
  codeQuality;

  String get jsonValue => switch (this) {
        RuleCategory.visual => 'visual',
        RuleCategory.layout => 'layout',
        RuleCategory.platform => 'platform',
        RuleCategory.codeQuality => 'code-quality',
      };

  static RuleCategory fromJson(String value) => switch (value) {
        'visual' => RuleCategory.visual,
        'layout' => RuleCategory.layout,
        'platform' => RuleCategory.platform,
        'code-quality' => RuleCategory.codeQuality,
        _ => throw ArgumentError('Unknown rule category: $value'),
      };
}

/// Severity of a finding. Mirrors the `severity` field in rules.json.
enum RuleSeverity {
  error,
  warning,
  info;

  static RuleSeverity fromJson(String value) => switch (value) {
        'error' => RuleSeverity.error,
        'warning' => RuleSeverity.warning,
        'info' => RuleSeverity.info,
        _ => throw ArgumentError('Unknown severity: $value'),
      };
}

/// One rule violation found in source code.
class Finding {
  final String ruleId;
  final RuleSeverity severity;
  final String message;
  final String filePath;
  final int line;
  final int column;

  const Finding({
    required this.ruleId,
    required this.severity,
    required this.message,
    required this.filePath,
    required this.line,
    required this.column,
  });
}

/// Context passed to rule checks. Keeps the interface stable as we add
/// more information (e.g. resolved library, project config) later.
class RuleCheckContext {
  final String filePath;
  final CompilationUnit unit;
  final String sourceText;

  const RuleCheckContext({
    required this.filePath,
    required this.unit,
    required this.sourceText,
  });
}

/// A rule that inspects parsed Dart code and emits findings.
abstract class Rule {
  /// Stable identifier matching an entry in `src/rules/rules.json`
  /// (e.g. `visual/hardcoded-color`).
  String get id;

  /// Category this rule belongs to.
  RuleCategory get category;

  /// Default severity — can be overridden via config later.
  RuleSeverity get severity;

  /// Return all findings for a single compilation unit.
  Iterable<Finding> check(RuleCheckContext context);
}
