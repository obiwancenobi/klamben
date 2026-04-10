import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:klamben/src/rules/rule.dart';
import 'package:klamben/src/rules/visual/pure_black_text.dart';
import 'package:test/test.dart';

void main() {
  group('PureBlackTextRule', () {
    final rule = PureBlackTextRule();

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

    test('flags TextStyle(color: Colors.black)', () {
      final findings = run('''
final s = TextStyle(color: Colors.black);
''');
      expect(findings.length, 1);
      expect(findings.first.ruleId, 'visual/pure-black-text');
    });

    test('does not flag TextStyle(color: Colors.grey)', () {
      final findings = run('''
final s = TextStyle(color: Colors.grey);
''');
      expect(findings, isEmpty);
    });

    test('does not flag Colors.black outside TextStyle', () {
      final findings = run('''
final c = Container(color: Colors.black);
''');
      expect(findings, isEmpty);
    });
  });
}
