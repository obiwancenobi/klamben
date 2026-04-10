import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:klamben/src/rules/code_quality/swallowed_errors.dart';
import 'package:klamben/src/rules/rule.dart';
import 'package:test/test.dart';

void main() {
  group('SwallowedErrorsRule', () {
    test('flags empty catch block only', () {
      const source = '''
void a() {
  try { throw 1; } catch (_) {}
}
void b() {
  try { throw 1; } catch (e) { print(e); }
}
''';
      final parsed = parseString(
        content: source,
        throwIfDiagnostics: false,
        featureSet: FeatureSet.latestLanguageVersion(),
      );
      final rule = SwallowedErrorsRule();
      final findings = rule
          .check(RuleCheckContext(
            filePath: 'test.dart',
            unit: parsed.unit,
            sourceText: source,
          ))
          .toList();
      expect(findings.length, 1,
          reason: 'expected exactly 1 finding, got $findings');
      expect(findings.first.ruleId, 'code-quality/swallowed-errors');
    });
  });
}
