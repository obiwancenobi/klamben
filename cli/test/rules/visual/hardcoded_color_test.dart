import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:klamben/src/rules/rule.dart';
import 'package:klamben/src/rules/visual/hardcoded_color.dart';
import 'package:test/test.dart';

void main() {
  group('HardcodedColorRule', () {
    test('flags Colors.purple and Color(0xFF...)', () {
      const source = '''
import 'package:flutter/material.dart';

Widget a() => Container(color: Colors.purple);
Widget b() => Container(color: const Color(0xFFAABBCC));
Widget c() => Container(color: Colors.transparent);
''';
      final parsed = parseString(
        content: source,
        throwIfDiagnostics: false,
        featureSet: FeatureSet.latestLanguageVersion(),
      );
      final rule = HardcodedColorRule();
      final findings = rule
          .check(RuleCheckContext(
            filePath: 'test.dart',
            unit: parsed.unit,
            sourceText: source,
          ))
          .toList();
      expect(findings.length, 2,
          reason:
              'expected findings for Colors.purple and Color(0xFF...), got $findings');
      expect(
          findings.every((f) => f.ruleId == 'visual/hardcoded-color'), isTrue);
    });
  });
}
