import 'package:klamben/src/rules/rule_metadata.dart';
import 'package:klamben/src/rules/rule_registry.dart';
import 'package:test/test.dart';

void main() {
  group('catalog sync', () {
    final catalog = RuleCatalog.fromBundled();
    final registry = RuleRegistry.defaults();
    final jsonIds = catalog.byId.keys.toSet();
    final dartIds = registry.rules.map((r) => r.id).toSet();

    test('no orphan Dart rule (Dart rule without JSON entry)', () {
      final orphans = dartIds.difference(jsonIds);
      expect(orphans, isEmpty,
          reason: 'Dart rules missing from rules.json: $orphans');
    });

    test('seed rules are present', () {
      const seeds = {
        'visual/hardcoded-color',
        'layout/missing-safearea',
        'platform/missing-adaptive',
        'code-quality/swallowed-errors',
      };
      expect(dartIds.containsAll(seeds), isTrue,
          reason: 'missing seed rules. Got: $dartIds');
    });

    test('rule category enum matches JSON', () {
      for (final id in dartIds) {
        final dart = registry.rules.firstWhere((r) => r.id == id);
        final jsonMeta = catalog.byId[id]!;
        expect(dart.category, jsonMeta.category,
            reason: 'category mismatch for $id');
      }
    });

    test('placeholder: report missing rules (informational only)', () {
      final missing = jsonIds.difference(dartIds).toList()..sort();
      if (missing.isNotEmpty) {
        // ignore: avoid_print
        print(
            'INFO: ${missing.length} rules in rules.json lack Dart impl: $missing');
      }
    });
  });
}
