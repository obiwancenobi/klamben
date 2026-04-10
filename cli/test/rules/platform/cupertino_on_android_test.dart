import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:klamben/src/rules/platform/cupertino_on_android.dart';
import 'package:klamben/src/rules/rule.dart';
import 'package:test/test.dart';

void main() {
  group('CupertinoOnAndroidRule', () {
    test('flags Cupertino widget inside Platform.isAndroid branch', () {
      const source = '''
import 'dart:io';
import 'package:flutter/cupertino.dart';

Widget build() {
  if (Platform.isAndroid) {
    return CupertinoButton(onPressed: () {}, child: Text('Hi'));
  }
  return CupertinoButton(onPressed: () {}, child: Text('Hi'));
}
''';
      final parsed = parseString(
        content: source,
        throwIfDiagnostics: false,
        featureSet: FeatureSet.latestLanguageVersion(),
      );
      final rule = CupertinoOnAndroidRule();
      final findings = rule
          .check(RuleCheckContext(
            filePath: 'test.dart',
            unit: parsed.unit,
            sourceText: source,
          ))
          .toList();
      expect(findings.length, 1,
          reason: 'expected 1 finding for CupertinoButton in Android branch');
      expect(findings.first.ruleId, 'platform/cupertino-on-android');
    });

    test('no findings when no Platform.isAndroid branch', () {
      const source = '''
import 'package:flutter/cupertino.dart';

Widget build() {
  return CupertinoButton(onPressed: () {}, child: Text('Hi'));
}
''';
      final parsed = parseString(
        content: source,
        throwIfDiagnostics: false,
        featureSet: FeatureSet.latestLanguageVersion(),
      );
      final rule = CupertinoOnAndroidRule();
      final findings = rule
          .check(RuleCheckContext(
            filePath: 'test.dart',
            unit: parsed.unit,
            sourceText: source,
          ))
          .toList();
      expect(findings, isEmpty);
    });

    test('no findings when Material widget is used in Android branch', () {
      const source = '''
import 'dart:io';
import 'package:flutter/material.dart';

Widget build() {
  if (Platform.isAndroid) {
    return ElevatedButton(onPressed: () {}, child: Text('Hi'));
  }
  return CupertinoButton(onPressed: () {}, child: Text('Hi'));
}
''';
      final parsed = parseString(
        content: source,
        throwIfDiagnostics: false,
        featureSet: FeatureSet.latestLanguageVersion(),
      );
      final rule = CupertinoOnAndroidRule();
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
