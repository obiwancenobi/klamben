import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:klamben/src/rules/layout/nested_padding.dart';
import 'package:klamben/src/rules/rule.dart';
import 'package:test/test.dart';

void main() {
  group('NestedPaddingRule', () {
    test('flags Padding wrapping Container with padding', () {
      const source = '''
import 'package:flutter/material.dart';

// BAD: Padding -> Container(padding:)
Widget bad1() => Padding(
  padding: EdgeInsets.all(8),
  child: Container(
    padding: EdgeInsets.all(16),
    child: Text('hello'),
  ),
);

// BAD: Container -> Padding
Widget bad2() => Container(
  child: Padding(
    padding: EdgeInsets.all(8),
    child: Text('hello'),
  ),
);

// GOOD: Container without padding inside Padding
Widget good1() => Padding(
  padding: EdgeInsets.all(8),
  child: Container(
    color: Colors.red,
    child: Text('hello'),
  ),
);

// GOOD: standalone Padding
Widget good2() => Padding(
  padding: EdgeInsets.all(8),
  child: Text('hello'),
);
''';
      final parsed = parseString(
        content: source,
        throwIfDiagnostics: false,
        featureSet: FeatureSet.latestLanguageVersion(),
      );
      final rule = NestedPaddingRule();
      final findings = rule
          .check(RuleCheckContext(
            filePath: 'test.dart',
            unit: parsed.unit,
            sourceText: source,
          ))
          .toList();
      expect(findings.length, 2, reason: 'should flag 2 bad cases');
      expect(findings.every((f) => f.ruleId == 'layout/nested-padding'), true);
    });
  });
}
