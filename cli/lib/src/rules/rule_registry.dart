// cli/lib/src/rules/rule_registry.dart

import 'rule.dart';

/// Holds all registered Dart Rule instances. Rules are added by
/// constructor in this class to keep registration explicit and
/// visible from one location.
class RuleRegistry {
  final List<Rule> rules;
  const RuleRegistry._(this.rules);

  factory RuleRegistry.defaults() {
    // Seed rules — populated in Tasks 6-9.
    return const RuleRegistry._([]);
  }

  Iterable<Rule> byCategory(RuleCategory c) =>
      rules.where((r) => r.category == c);

  Rule? byId(String id) {
    for (final r in rules) {
      if (r.id == id) return r;
    }
    return null;
  }
}
