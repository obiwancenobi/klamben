import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:klamben/src/rules/platform/missing_adaptive.dart';
import 'package:klamben/src/rules/rule.dart';
import 'package:test/test.dart';

void main() {
  group('MissingAdaptiveRule', () {
    test('flags plain Switch but not Switch.adaptive', () {
      const source = '''
import 'package:flutter/material.dart';

Widget a() => Switch(value: true, onChanged: (v) {});
Widget b() => Switch.adaptive(value: true, onChanged: (v) {});
''';
      final parsed = parseString(
        content: source,
        throwIfDiagnostics: false,
        featureSet: FeatureSet.latestLanguageVersion(),
      );
      final rule = MissingAdaptiveRule();
      final findings = rule
          .check(RuleCheckContext(
            filePath: 'test.dart',
            unit: parsed.unit,
            sourceText: source,
          ))
          .toList();
      expect(findings.length, 1,
          reason: 'expected 1 finding for plain Switch, got $findings');
      expect(findings.first.ruleId, 'platform/missing-adaptive');
    });
  });
}
