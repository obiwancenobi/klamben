import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:klamben/src/rules/code_quality/missing_const.dart';
import 'package:klamben/src/rules/rule.dart';
import 'package:test/test.dart';

void main() {
  group('MissingConstRule', () {
    test('flags Text with literal string arg', () {
      const source = '''
void build() {
  Text('Hello');
}
''';
      final findings = _run(source);
      expect(findings.length, 1);
      expect(findings.first.ruleId, 'code-quality/missing-const');
    });

    test('flags SizedBox with literal number arg', () {
      const source = '''
void build() {
  SizedBox(height: 8);
}
''';
      final findings = _run(source);
      expect(findings.length, 1);
    });

    test('does not flag when variable is used as arg', () {
      const source = '''
void build() {
  var h = 8;
  SizedBox(height: h);
}
''';
      final findings = _run(source);
      expect(findings, isEmpty);
    });

    test('does not flag non-eligible widgets', () {
      const source = '''
void build() {
  Container(width: 10);
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
  return MissingConstRule()
      .check(RuleCheckContext(
        filePath: 'test.dart',
        unit: parsed.unit,
        sourceText: source,
      ))
      .toList();
}
