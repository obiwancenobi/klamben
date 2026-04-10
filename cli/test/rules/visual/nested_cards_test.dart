import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:klamben/src/rules/rule.dart';
import 'package:klamben/src/rules/visual/nested_cards.dart';
import 'package:test/test.dart';

void main() {
  group('NestedCardsRule', () {
    final rule = NestedCardsRule();

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

    test('flags Card(child: Card(...))', () {
      final findings = run('''
final w = Card(child: Card(child: Text('nested')));
''');
      expect(findings.length, 1);
      expect(findings.first.ruleId, 'visual/nested-cards');
    });

    test('does not flag Card(child: Container(...))', () {
      final findings = run('''
final w = Card(child: Container(child: Text('ok')));
''');
      expect(findings, isEmpty);
    });
  });
}
