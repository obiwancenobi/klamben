import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:klamben/src/rules/layout/fixed_row_overflow.dart';
import 'package:klamben/src/rules/rule.dart';
import 'package:test/test.dart';

void main() {
  group('FixedRowOverflowRule', () {
    test('flags SizedBox(width: double.infinity) inside Row', () {
      const source = '''
import 'package:flutter/material.dart';

// BAD: SizedBox with double.infinity width in Row
Widget bad1() => Row(children: [SizedBox(width: double.infinity)]);

// GOOD: SizedBox with double.infinity but not in Row
Widget good1() => Column(children: [SizedBox(width: double.infinity)]);

// GOOD: SizedBox with numeric width in Row
Widget good2() => Row(children: [SizedBox(width: 100)]);

// GOOD: Expanded in Row (correct pattern)
Widget good3() => Row(children: [Expanded(child: Text('hello'))]);
''';
      final parsed = parseString(
        content: source,
        throwIfDiagnostics: false,
        featureSet: FeatureSet.latestLanguageVersion(),
      );
      final rule = FixedRowOverflowRule();
      final findings = rule
          .check(RuleCheckContext(
            filePath: 'test.dart',
            unit: parsed.unit,
            sourceText: source,
          ))
          .toList();
      expect(findings.length, 1, reason: 'should flag 1 bad case');
      expect(findings.first.ruleId, 'layout/fixed-row-overflow');
    });
  });
}
