// cli/lib/src/rules/rule_registry.dart

import 'code_quality/hardcoded_strings.dart';
import 'code_quality/missing_const.dart';
import 'code_quality/missing_dispose.dart';
import 'code_quality/missing_key.dart';
import 'code_quality/missing_semantics.dart';
import 'code_quality/setstate_after_async.dart';
import 'code_quality/swallowed_errors.dart';
import 'layout/fixed_row_overflow.dart';
import 'layout/hardcoded_width.dart';
import 'layout/magic_numbers.dart';
import 'layout/missing_safearea.dart';
import 'layout/nested_padding.dart';
import 'layout/no_flexible.dart';
import 'platform/cupertino_on_android.dart';
import 'platform/material_on_ios.dart';
import 'platform/missing_adaptive.dart';
import 'platform/wrong_nav_pattern.dart';
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
      NestedPaddingRule(),
      MagicNumbersRule(),
      HardcodedWidthRule(),
      NoFlexibleRule(),
      FixedRowOverflowRule(),
      MissingAdaptiveRule(),
      MaterialOnIosRule(),
      CupertinoOnAndroidRule(),
      WrongNavPatternRule(),
      SwallowedErrorsRule(),
      MissingConstRule(),
      MissingSemanticsRule(),
      MissingDisposeRule(),
      HardcodedStringsRule(),
      SetStateAfterAsyncRule(),
      MissingKeyRule(),
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
