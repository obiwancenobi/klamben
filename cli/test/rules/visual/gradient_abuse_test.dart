import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:klamben/src/rules/rule.dart';
import 'package:klamben/src/rules/visual/gradient_abuse.dart';
import 'package:test/test.dart';

void main() {
  group('GradientAbuseRule', () {
    final rule = GradientAbuseRule();

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

    test('flags LinearGradient with purple and pink', () {
      final findings = run('''
final g = LinearGradient(colors: [Colors.purple, Colors.pink]);
''');
      expect(findings.length, 1);
      expect(findings.first.ruleId, 'visual/gradient-abuse');
    });

    test('does not flag LinearGradient with other colors', () {
      final findings = run('''
final g = LinearGradient(colors: [Colors.red, Colors.blue]);
''');
      expect(findings, isEmpty);
    });

    test('does not flag LinearGradient with only purple', () {
      final findings = run('''
final g = LinearGradient(colors: [Colors.purple, Colors.blue]);
''');
      expect(findings, isEmpty);
    });
  });
}
