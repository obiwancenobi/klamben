import 'package:klamben/src/engine.dart';
import 'package:klamben/src/rules/rule_registry.dart';
import 'package:test/test.dart';

void main() {
  group('Engine', () {
    final engine = Engine(registry: RuleRegistry.defaults());

    test('bad fixture triggers one finding per seed rule', () {
      final findings =
          engine.detect('test/fixtures/bad/all_violations.dart');
      final ids = findings.map((f) => f.ruleId).toSet();
      expect(
          ids,
          containsAll(const {
            'visual/hardcoded-color',
            'layout/missing-safearea',
            'platform/missing-adaptive',
            'code-quality/swallowed-errors',
          }),
          reason:
              'expected all 4 seed rules to fire on all_violations.dart, got $ids');
    });

    test('good fixture triggers no findings', () {
      final findings = engine.detect('test/fixtures/good/clean.dart');
      expect(findings, isEmpty,
          reason:
              'clean fixture should not trigger any rule. Got: $findings');
    });
  });
}
