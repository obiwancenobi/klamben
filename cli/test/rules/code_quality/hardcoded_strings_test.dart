import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:klamben/src/rules/code_quality/hardcoded_strings.dart';
import 'package:klamben/src/rules/rule.dart';
import 'package:test/test.dart';

void main() {
  group('HardcodedStringsRule', () {
    test('flags Text with hardcoded string literal', () {
      const source = '''
void build() {
  Text('Hello World');
}
''';
      final findings = _run(source);
      expect(findings.length, 1);
      expect(findings.first.ruleId, 'code-quality/hardcoded-strings');
    });

    test('does not flag Text with variable', () {
      const source = '''
void build() {
  var label = 'hi';
  Text(label);
}
''';
      final findings = _run(source);
      expect(findings, isEmpty);
    });

    test('does not flag Text with empty string', () {
      const source = '''
void build() {
  Text('');
}
''';
      final findings = _run(source);
      expect(findings, isEmpty);
    });

    test('does not flag Text with single character', () {
      const source = '''
void build() {
  Text(':');
}
''';
      final findings = _run(source);
      expect(findings, isEmpty);
    });

    test('does not flag non-Text widgets', () {
      const source = '''
void build() {
  Container(child: 'nope');
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
  return HardcodedStringsRule()
      .check(RuleCheckContext(
        filePath: 'test.dart',
        unit: parsed.unit,
        sourceText: source,
      ))
      .toList();
}
