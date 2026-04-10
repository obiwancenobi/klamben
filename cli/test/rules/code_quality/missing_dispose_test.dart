import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:klamben/src/rules/code_quality/missing_dispose.dart';
import 'package:klamben/src/rules/rule.dart';
import 'package:test/test.dart';

void main() {
  group('MissingDisposeRule', () {
    test('flags State subclass with controller but no dispose', () {
      const source = '''
class _MyState extends State {
  TextEditingController _controller = TextEditingController();

  void build() {}
}
''';
      final findings = _run(source);
      expect(findings.length, 1);
      expect(findings.first.ruleId, 'code-quality/missing-dispose');
      expect(findings.first.message, contains('_controller'));
    });

    test('does not flag State subclass with dispose', () {
      const source = '''
class _MyState extends State {
  TextEditingController _controller = TextEditingController();

  void dispose() {
    _controller.dispose();
  }
}
''';
      final findings = _run(source);
      expect(findings, isEmpty);
    });

    test('does not flag State subclass without controller', () {
      const source = '''
class _MyState extends State {
  String name = '';

  void build() {}
}
''';
      final findings = _run(source);
      expect(findings, isEmpty);
    });

    test('does not flag non-State class with controller', () {
      const source = '''
class MyService extends BaseService {
  TextEditingController _controller = TextEditingController();
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
  return MissingDisposeRule()
      .check(RuleCheckContext(
        filePath: 'test.dart',
        unit: parsed.unit,
        sourceText: source,
      ))
      .toList();
}
