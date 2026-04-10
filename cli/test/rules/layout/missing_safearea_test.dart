import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:klamben/src/rules/layout/missing_safearea.dart';
import 'package:klamben/src/rules/rule.dart';
import 'package:test/test.dart';

void main() {
  group('MissingSafeAreaRule', () {
    test('flags Scaffold body without SafeArea and without AppBar', () {
      const source = '''
import 'package:flutter/material.dart';

Widget a() => Scaffold(body: Column(children: const [Text('x')]));
Widget b() => Scaffold(appBar: AppBar(), body: Column(children: const [Text('x')]));
Widget c() => Scaffold(body: SafeArea(child: Column(children: const [Text('x')])));
''';
      final parsed = parseString(
        content: source,
        throwIfDiagnostics: false,
        featureSet: FeatureSet.latestLanguageVersion(),
      );
      final rule = MissingSafeAreaRule();
      final findings = rule
          .check(RuleCheckContext(
            filePath: 'test.dart',
            unit: parsed.unit,
            sourceText: source,
          ))
          .toList();
      expect(findings.length, 1,
          reason:
              'only the naked Scaffold should be flagged, got $findings');
      expect(findings.first.ruleId, 'layout/missing-safearea');
    });
  });
}
