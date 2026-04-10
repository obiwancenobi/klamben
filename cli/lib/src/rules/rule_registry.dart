// cli/lib/src/rules/rule_registry.dart

import 'code_quality/swallowed_errors.dart';
import 'layout/missing_safearea.dart';
import 'platform/missing_adaptive.dart';
import 'rule.dart';
import 'visual/gradient_abuse.dart';
import 'visual/hardcoded_color.dart';
import 'visual/inline_textstyle.dart';
import 'visual/nested_cards.dart';
import 'visual/pure_black_text.dart';
import 'visual/roboto_default.dart';
import 'visual/shadow_overuse.dart';

/// Holds all registered Dart Rule instances. Rules are added by
/// constructor in this class to keep registration explicit and
/// visible from one location.
class RuleRegistry {
  final List<Rule> rules;
  const RuleRegistry._(this.rules);

  factory RuleRegistry.defaults() {
    return RuleRegistry._([
      HardcodedColorRule(),
      GradientAbuseRule(),
      InlineTextstyleRule(),
      NestedCardsRule(),
      PureBlackTextRule(),
      RobotoDefaultRule(),
      ShadowOveruseRule(),
      MissingSafeAreaRule(),
      MissingAdaptiveRule(),
      SwallowedErrorsRule(),
    ]);
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
