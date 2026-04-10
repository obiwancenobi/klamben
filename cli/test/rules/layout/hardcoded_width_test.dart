import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:klamben/src/rules/layout/hardcoded_width.dart';
import 'package:klamben/src/rules/rule.dart';
import 'package:test/test.dart';

void main() {
  group('HardcodedWidthRule', () {
    test('flags Container/SizedBox with width > 120', () {
      const source = '''
import 'package:flutter/material.dart';

// BAD: width 300 > 120
Widget bad1() => Container(width: 300, child: Text('hello'));

// BAD: SizedBox with width 400
Widget bad2() => SizedBox(width: 400, child: Text('hello'));

// GOOD: width 100 <= 120
Widget good1() => Container(width: 100, child: Text('hello'));

// GOOD: width 120 is exactly the threshold (not >)
Widget good2() => SizedBox(width: 120, child: Text('hello'));

// GOOD: no width arg
Widget good3() => Container(height: 300, child: Text('hello'));
''';
      final parsed = parseString(
        content: source,
        throwIfDiagnostics: false,
        featureSet: FeatureSet.latestLanguageVersion(),
      );
      final rule = HardcodedWidthRule();
      final findings = rule
          .check(RuleCheckContext(
            filePath: 'test.dart',
            unit: parsed.unit,
            sourceText: source,
          ))
          .toList();
      expect(findings.length, 2, reason: 'should flag 2 bad cases');
      expect(findings.every((f) => f.ruleId == 'layout/hardcoded-width'), true);
    });
  });
}
