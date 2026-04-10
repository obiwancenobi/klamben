import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:klamben/src/rules/platform/wrong_nav_pattern.dart';
import 'package:klamben/src/rules/rule.dart';
import 'package:test/test.dart';

void main() {
  group('WrongNavPatternRule', () {
    test('flags BottomNavigationBar without CupertinoTabBar', () {
      const source = '''
import 'package:flutter/material.dart';

Widget build() {
  return Scaffold(
    bottomNavigationBar: BottomNavigationBar(
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      ],
    ),
  );
}
''';
      final parsed = parseString(
        content: source,
        throwIfDiagnostics: false,
        featureSet: FeatureSet.latestLanguageVersion(),
      );
      final rule = WrongNavPatternRule();
      final findings = rule
          .check(RuleCheckContext(
            filePath: 'test.dart',
            unit: parsed.unit,
            sourceText: source,
          ))
          .toList();
      expect(findings.length, 1,
          reason:
              'expected 1 finding for BottomNavigationBar without CupertinoTabBar');
      expect(findings.first.ruleId, 'platform/wrong-nav-pattern');
    });

    test('no findings when CupertinoTabBar is also present', () {
      const source = '''
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

Widget buildMaterial() {
  return Scaffold(
    bottomNavigationBar: BottomNavigationBar(
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      ],
    ),
  );
}

Widget buildCupertino() {
  return CupertinoTabBar(
    items: [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    ],
  );
}
''';
      final parsed = parseString(
        content: source,
        throwIfDiagnostics: false,
        featureSet: FeatureSet.latestLanguageVersion(),
      );
      final rule = WrongNavPatternRule();
      final findings = rule
          .check(RuleCheckContext(
            filePath: 'test.dart',
            unit: parsed.unit,
            sourceText: source,
          ))
          .toList();
      expect(findings, isEmpty);
    });

    test('no findings when no BottomNavigationBar used', () {
      const source = '''
import 'package:flutter/material.dart';

Widget build() {
  return Scaffold(
    body: Center(child: Text('Hello')),
  );
}
''';
      final parsed = parseString(
        content: source,
        throwIfDiagnostics: false,
        featureSet: FeatureSet.latestLanguageVersion(),
      );
      final rule = WrongNavPatternRule();
      final findings = rule
          .check(RuleCheckContext(
            filePath: 'test.dart',
            unit: parsed.unit,
            sourceText: source,
          ))
          .toList();
      expect(findings, isEmpty);
    });
  });
}
