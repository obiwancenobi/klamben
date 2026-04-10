import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:klamben/src/rules/rule.dart';
import 'package:klamben/src/rules/visual/roboto_default.dart';
import 'package:test/test.dart';

void main() {
  group('RobotoDefaultRule', () {
    final rule = RobotoDefaultRule();

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

    test('flags ThemeData() with no args', () {
      final findings = run('''
final t = ThemeData();
''');
      expect(findings.length, 1);
      expect(findings.first.ruleId, 'visual/roboto-default');
    });

    test('flags ThemeData with colorScheme but no textTheme', () {
      final findings = run('''
final t = ThemeData(colorScheme: cs);
''');
      expect(findings.length, 1);
    });

    test('does not flag ThemeData with textTheme', () {
      final findings = run('''
final t = ThemeData(textTheme: myTextTheme);
''');
      expect(findings, isEmpty);
    });
  });
}
