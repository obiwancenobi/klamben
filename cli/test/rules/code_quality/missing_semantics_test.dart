import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:klamben/src/rules/code_quality/missing_semantics.dart';
import 'package:klamben/src/rules/rule.dart';
import 'package:test/test.dart';

void main() {
  group('MissingSemanticsRule', () {
    test('flags IconButton without tooltip', () {
      const source = '''
void build() {
  IconButton(
    icon: myIcon,
    onPressed: () {},
  );
}
''';
      final findings = _run(source);
      expect(findings.length, 1);
      expect(findings.first.ruleId, 'code-quality/missing-semantics');
    });

    test('does not flag IconButton with tooltip', () {
      const source = '''
void build() {
  IconButton(
    icon: myIcon,
    onPressed: () {},
    tooltip: 'Delete',
  );
}
''';
      final findings = _run(source);
      expect(findings, isEmpty);
    });

    test('does not flag other widgets', () {
      const source = '''
void build() {
  TextButton(onPressed: () {}, child: text);
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
  return MissingSemanticsRule()
      .check(RuleCheckContext(
        filePath: 'test.dart',
        unit: parsed.unit,
        sourceText: source,
      ))
      .toList();
}
