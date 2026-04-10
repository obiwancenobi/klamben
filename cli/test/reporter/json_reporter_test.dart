import 'dart:convert';

import 'package:klamben/src/reporter/json_reporter.dart';
import 'package:klamben/src/rules/rule.dart';
import 'package:test/test.dart';

void main() {
  group('JsonReporter', () {
    test('renders findings as JSON array', () {
      const findings = [
        Finding(
          ruleId: 'visual/hardcoded-color',
          severity: RuleSeverity.warning,
          message: 'Use ColorScheme.primary',
          filePath: 'lib/a.dart',
          line: 11,
          column: 15,
        ),
      ];
      final output = const JsonReporter().render(findings);
      final parsed = json.decode(output) as Map<String, dynamic>;
      expect(parsed['count'], 1);
      final list = parsed['findings'] as List<dynamic>;
      expect(list.length, 1);
      final f = list.first as Map<String, dynamic>;
      expect(f['rule_id'], 'visual/hardcoded-color');
      expect(f['severity'], 'warning');
      expect(f['line'], 11);
    });

    test('empty findings renders valid JSON with count 0', () {
      final output = const JsonReporter().render(const []);
      final parsed = json.decode(output) as Map<String, dynamic>;
      expect(parsed['count'], 0);
      expect(parsed['findings'], isEmpty);
    });
  });
}
