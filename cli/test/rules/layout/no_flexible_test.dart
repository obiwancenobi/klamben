import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:klamben/src/rules/layout/no_flexible.dart';
import 'package:klamben/src/rules/rule.dart';
import 'package:test/test.dart';

void main() {
  group('NoFlexibleRule', () {
    test('flags bare Text in Row/Column children', () {
      const source = '''
import 'package:flutter/material.dart';

// BAD: Text not wrapped in Flexible/Expanded inside Row
Widget bad1() => Row(children: [Text('hello'), Icon(Icons.add)]);

// BAD: Text not wrapped in Flexible/Expanded inside Column
Widget bad2() => Column(children: [Text('hello')]);

// GOOD: Text wrapped in Flexible
Widget good1() => Row(children: [Flexible(child: Text('hello'))]);

// GOOD: Text wrapped in Expanded
Widget good2() => Row(children: [Expanded(child: Text('hello'))]);

// GOOD: no Text in children
Widget good3() => Row(children: [Icon(Icons.add)]);
''';
      final parsed = parseString(
        content: source,
        throwIfDiagnostics: false,
        featureSet: FeatureSet.latestLanguageVersion(),
      );
      final rule = NoFlexibleRule();
      final findings = rule
          .check(RuleCheckContext(
            filePath: 'test.dart',
            unit: parsed.unit,
            sourceText: source,
          ))
          .toList();
      expect(findings.length, 2, reason: 'should flag 2 bad cases');
      expect(findings.every((f) => f.ruleId == 'layout/no-flexible'), true);
    });
  });
}
