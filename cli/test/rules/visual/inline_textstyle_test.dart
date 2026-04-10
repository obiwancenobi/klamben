import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:klamben/src/rules/rule.dart';
import 'package:klamben/src/rules/visual/inline_textstyle.dart';
import 'package:test/test.dart';

void main() {
  group('InlineTextstyleRule', () {
    final rule = InlineTextstyleRule();

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

    test('flags TextStyle(fontSize: 14)', () {
      final findings = run('''
final s = TextStyle(fontSize: 14);
''');
      expect(findings.length, 1);
      expect(findings.first.ruleId, 'visual/inline-textstyle');
    });

    test('flags TextStyle(fontSize: 16.0)', () {
      final findings = run('''
final s = TextStyle(fontSize: 16.0);
''');
      expect(findings.length, 1);
    });

    test('does not flag TextStyle(fontSize: mySize)', () {
      final findings = run('''
final s = TextStyle(fontSize: mySize);
''');
      expect(findings, isEmpty);
    });

    test('does not flag TextStyle without fontSize', () {
      final findings = run('''
final s = TextStyle(color: Colors.red);
''');
      expect(findings, isEmpty);
    });
  });
}
