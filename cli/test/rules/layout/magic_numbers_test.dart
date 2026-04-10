import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:klamben/src/rules/layout/magic_numbers.dart';
import 'package:klamben/src/rules/rule.dart';
import 'package:test/test.dart';

void main() {
  group('MagicNumbersRule', () {
    test('flags EdgeInsets values not on 4/8pt grid', () {
      const source = '''
import 'package:flutter/material.dart';

// BAD: 17 is not on grid
Widget bad1() => Padding(padding: EdgeInsets.all(17));

// BAD: 23 is not on grid
Widget bad2() => Padding(padding: EdgeInsets.symmetric(horizontal: 23));

// BAD: 11 is not on grid
Widget bad3() => Padding(padding: EdgeInsets.only(left: 11));

// GOOD: 16 is on grid
Widget good1() => Padding(padding: EdgeInsets.all(16));

// GOOD: 8 and 24 are on grid
Widget good2() => Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 24));

// GOOD: 0 is on grid
Widget good3() => Padding(padding: EdgeInsets.only(left: 0));
''';
      final parsed = parseString(
        content: source,
        throwIfDiagnostics: false,
        featureSet: FeatureSet.latestLanguageVersion(),
      );
      final rule = MagicNumbersRule();
      final findings = rule
          .check(RuleCheckContext(
            filePath: 'test.dart',
            unit: parsed.unit,
            sourceText: source,
          ))
          .toList();
      expect(findings.length, 3, reason: 'should flag 3 bad values');
      expect(findings.every((f) => f.ruleId == 'layout/magic-numbers'), true);
    });
  });
}
