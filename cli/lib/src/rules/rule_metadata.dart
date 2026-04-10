// cli/lib/src/rules/rule_metadata.dart

import 'dart:convert';

import '../rules_data.dart';
import 'rule.dart';

class RuleMetadata {
  final String id;
  final RuleCategory category;
  final RuleSeverity severity;
  final String title;
  final String description;
  final String rationale;
  final String fixHint;
  final List<String> references;
  final String badExample;
  final String goodExample;

  const RuleMetadata({
    required this.id,
    required this.category,
    required this.severity,
    required this.title,
    required this.description,
    required this.rationale,
    required this.fixHint,
    required this.references,
    required this.badExample,
    required this.goodExample,
  });
}

class RuleCatalog {
  final Map<String, RuleMetadata> byId;
  final List<RuleMetadata> all;

  const RuleCatalog._(this.byId, this.all);

  factory RuleCatalog.fromBundled() {
    final data = json.decode(rulesJson) as Map<String, dynamic>;
    final rules = data['rules'] as List<dynamic>;
    final parsed = <RuleMetadata>[];
    for (final entry in rules) {
      final map = entry as Map<String, dynamic>;
      final examples = (map['examples'] as Map<String, dynamic>? ?? const {});
      parsed.add(RuleMetadata(
        id: map['id'] as String,
        category: RuleCategory.fromJson(map['category'] as String),
        severity: RuleSeverity.fromJson(map['severity'] as String),
        title: map['title'] as String,
        description: map['description'] as String? ?? '',
        rationale: map['rationale'] as String? ?? '',
        fixHint: map['fix_hint'] as String? ?? '',
        references:
            ((map['references'] as List<dynamic>?) ?? const []).cast<String>(),
        badExample: examples['bad'] as String? ?? '',
        goodExample: examples['good'] as String? ?? '',
      ));
    }
    final byId = <String, RuleMetadata>{
      for (final r in parsed) r.id: r,
    };
    return RuleCatalog._(byId, List.unmodifiable(parsed));
  }
}
