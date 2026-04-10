import 'package:klamben/src/reporter/text_reporter.dart';
import 'package:klamben/src/rules/rule.dart';
import 'package:test/test.dart';

void main() {
  group('TextReporter', () {
    test('renders findings grouped by file with counts', () {
      const findings = [
        Finding(
          ruleId: 'visual/hardcoded-color',
          severity: RuleSeverity.warning,
          message: 'Use ColorScheme.primary',
          filePath: 'lib/a.dart',
          line: 11,
          column: 15,
        ),
        Finding(
          ruleId: 'layout/missing-safearea',
          severity: RuleSeverity.error,
          message: 'Wrap body in SafeArea',
          filePath: 'lib/a.dart',
          line: 24,
          column: 7,
        ),
      ];
      final output = const TextReporter(useColor: false).render(findings);
      expect(output, contains('lib/a.dart'));
      expect(output, contains('visual/hardcoded-color'));
      expect(output, contains('layout/missing-safearea'));
      expect(output, contains('2 issues'));
      expect(output, contains('1 error'));
      expect(output, contains('1 warning'));
    });

    test('empty findings list renders zero-issue summary', () {
      final output = const TextReporter(useColor: false).render(const []);
      expect(output, contains('No issues'));
    });
  });
}
