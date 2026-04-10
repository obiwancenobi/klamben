import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:klamben/src/rules/code_quality/setstate_after_async.dart';
import 'package:klamben/src/rules/rule.dart';
import 'package:test/test.dart';

void main() {
  group('SetStateAfterAsyncRule', () {
    test('flags setState after await without mounted check', () {
      const source = '''
class _MyState {
  Future<void> loadData() async {
    await fetchData();
    setState(() {});
  }
}
''';
      final findings = _run(source);
      expect(findings.length, 1);
      expect(findings.first.ruleId, 'code-quality/setstate-after-async');
    });

    test('does not flag setState after await with mounted check', () {
      const source = '''
class _MyState {
  Future<void> loadData() async {
    await fetchData();
    if (!mounted) return;
    setState(() {});
  }
}
''';
      final findings = _run(source);
      expect(findings, isEmpty);
    });

    test('does not flag setState without await', () {
      const source = '''
class _MyState {
  void doThing() {
    setState(() {});
  }
}
''';
      final findings = _run(source);
      expect(findings, isEmpty);
    });

    test('does not flag async method without setState', () {
      const source = '''
class _MyState {
  Future<void> loadData() async {
    await fetchData();
  }
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
  return SetStateAfterAsyncRule()
      .check(RuleCheckContext(
        filePath: 'test.dart',
        unit: parsed.unit,
        sourceText: source,
      ))
      .toList();
}
