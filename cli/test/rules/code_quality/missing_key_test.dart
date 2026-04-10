import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:klamben/src/rules/code_quality/missing_key.dart';
import 'package:klamben/src/rules/rule.dart';
import 'package:test/test.dart';

void main() {
  group('MissingKeyRule', () {
    test('flags widget in .map().toList() without key', () {
      const source = '''
void build() {
  items.map((item) => Text(item.name)).toList();
}
''';
      final findings = _run(source);
      expect(findings.length, 1);
      expect(findings.first.ruleId, 'code-quality/missing-key');
    });

    test('does not flag widget in .map().toList() with key', () {
      const source = '''
void build() {
  items.map((item) => Text(item.name, key: ValueKey(item.id))).toList();
}
''';
      final findings = _run(source);
      expect(findings, isEmpty);
    });

    test('does not flag non-widget in .map().toList()', () {
      const source = '''
void build() {
  items.map((item) => item.toString()).toList();
}
''';
      final findings = _run(source);
      expect(findings, isEmpty);
    });

    test('does not flag widget outside of .map().toList()', () {
      const source = '''
void build() {
  Text('hello');
}
''';
      final findings = _run(source);
      expect(findings, isEmpty);
    });
  });
}

List<Finding> _run(String source) {
  final parsed = parseString(
    content: source,
    throwIfDiagnostics: false,
    featureSet: FeatureSet.latestLanguageVersion(),
  );
  return MissingKeyRule()
      .check(RuleCheckContext(
        filePath: 'test.dart',
        unit: parsed.unit,
        sourceText: source,
      ))
      .toList();
}
