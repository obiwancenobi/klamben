import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:klamben/src/rules/rule.dart';
import 'package:klamben/src/rules/visual/shadow_overuse.dart';
import 'package:test/test.dart';

void main() {
  group('ShadowOveruseRule', () {
    final rule = ShadowOveruseRule();

    List<Finding> run(String source) {
      final parsed = parseString(
        content: source,
        throwIfDiagnostics: false,
        featureSet: FeatureSet.latestLanguageVersion(),
      );
      return rule
          .check(RuleCheckContext(
            filePath: 'test.dart',
            unit: parsed.unit,
            sourceText: source,
          ))
          .toList();
    }

    test('flags Card(elevation: 16)', () {
      final findings = run('''
final w = Card(elevation: 16);
''');
      expect(findings.length, 1);
      expect(findings.first.ruleId, 'visual/shadow-overuse');
    });

    test('flags Material(elevation: 12.0)', () {
      final findings = run('''
final w = Material(elevation: 12.0);
''');
      expect(findings.length, 1);
    });

    test('does not flag Card(elevation: 4)', () {
      final findings = run('''
final w = Card(elevation: 4);
''');
      expect(findings, isEmpty);
    });

    test('does not flag Card(elevation: 8)', () {
      final findings = run('''
final w = Card(elevation: 8);
''');
      expect(findings, isEmpty);
    });
  });
}
