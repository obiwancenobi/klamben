import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:klamben/src/rules/platform/material_on_ios.dart';
import 'package:klamben/src/rules/rule.dart';
import 'package:test/test.dart';

void main() {
  group('MaterialOnIosRule', () {
    test('flags Material widget inside Platform.isIOS branch', () {
      const source = '''
import 'dart:io';
import 'package:flutter/material.dart';

Widget build() {
  if (Platform.isIOS) {
    return ElevatedButton(onPressed: () {}, child: Text('Hi'));
  }
  return ElevatedButton(onPressed: () {}, child: Text('Hi'));
}
''';
      final parsed = parseString(
        content: source,
        throwIfDiagnostics: false,
        featureSet: FeatureSet.latestLanguageVersion(),
      );
      final rule = MaterialOnIosRule();
      final findings = rule
          .check(RuleCheckContext(
            filePath: 'test.dart',
            unit: parsed.unit,
            sourceText: source,
          ))
          .toList();
      expect(findings.length, 1,
          reason: 'expected 1 finding for ElevatedButton in iOS branch');
      expect(findings.first.ruleId, 'platform/material-on-ios');
    });

    test('no findings when no Platform.isIOS branch', () {
      const source = '''
import 'package:flutter/material.dart';

Widget build() {
  return ElevatedButton(onPressed: () {}, child: Text('Hi'));
}
''';
      final parsed = parseString(
        content: source,
        throwIfDiagnostics: false,
        featureSet: FeatureSet.latestLanguageVersion(),
      );
      final rule = MaterialOnIosRule();
      final findings = rule
          .check(RuleCheckContext(
            filePath: 'test.dart',
            unit: parsed.unit,
            sourceText: source,
          ))
          .toList();
      expect(findings, isEmpty);
    });

    test('no findings when Cupertino widget is used in iOS branch', () {
      const source = '''
import 'dart:io';
import 'package:flutter/cupertino.dart';

Widget build() {
  if (Platform.isIOS) {
    return CupertinoButton(onPressed: () {}, child: Text('Hi'));
  }
  return ElevatedButton(onPressed: () {}, child: Text('Hi'));
}
''';
      final parsed = parseString(
        content: source,
        throwIfDiagnostics: false,
        featureSet: FeatureSet.latestLanguageVersion(),
      );
      final rule = MaterialOnIosRule();
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
