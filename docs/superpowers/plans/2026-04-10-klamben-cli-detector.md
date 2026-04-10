# klamben CLI Detector Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a working Dart CLI tool `klamben` that scans `.dart` files and reports anti-patterns. This sub-plan covers 4 seed rules (one per category) with full test coverage. Later sub-plans expand to all 24 rules.

**Architecture:** Standalone Dart package in `cli/` with its own `pubspec.yaml`. Uses `package:analyzer` for AST parsing. Rule definitions live in one place (`src/rules/rules.json` from sub-plan 1) and are bundled into the CLI at build time via a generated `cli/lib/src/rules_data.dart`. Each rule is a Dart class implementing a common `Rule` interface; JSON provides metadata (title, severity, examples) while Dart provides detection logic. A `catalog_sync_test` enforces JSON ↔ Dart class parity.

**Tech Stack:** Dart SDK 3.3+, `analyzer ^6.0.0`, `args ^2.4.0`, `path ^1.9.0`, `glob ^2.1.0`, `test ^1.25.0`.

---

## File Structure

**CLI package (new):**
- `cli/pubspec.yaml` — package manifest, name `klamben`
- `cli/README.md` — short package-level readme
- `cli/analysis_options.yaml` — strict lints
- `cli/.gitignore` — `.dart_tool/`, `pubspec.lock`
- `cli/bin/klamben.dart` — CLI entry, argparse + subcommand routing
- `cli/lib/klamben.dart` — public API barrel file
- `cli/lib/src/rules/rule.dart` — `Rule` abstract class + `Finding`, `RuleCategory`, `RuleSeverity` types
- `cli/lib/src/rules/rule_metadata.dart` — JSON-backed metadata (title, rationale, examples)
- `cli/lib/src/rules/rule_registry.dart` — singleton that owns all Dart `Rule` instances
- `cli/lib/src/rules/visual/hardcoded_color.dart` — seed rule #1
- `cli/lib/src/rules/layout/missing_safearea.dart` — seed rule #2
- `cli/lib/src/rules/platform/missing_adaptive.dart` — seed rule #3
- `cli/lib/src/rules/code_quality/swallowed_errors.dart` — seed rule #4
- `cli/lib/src/rules_data.dart` — **GENERATED** from `src/rules/rules.json` by `tool/build.dart`
- `cli/lib/src/engine.dart` — orchestrator: load files, parse, run rules, collect findings
- `cli/lib/src/walker.dart` — analyzer `parseFile` helper
- `cli/lib/src/reporter/text_reporter.dart` — ANSI-colored terminal output
- `cli/lib/src/reporter/json_reporter.dart` — JSON output

**Tests (new):**
- `cli/test/rules/visual/hardcoded_color_test.dart`
- `cli/test/rules/layout/missing_safearea_test.dart`
- `cli/test/rules/platform/missing_adaptive_test.dart`
- `cli/test/rules/code_quality/swallowed_errors_test.dart`
- `cli/test/catalog_sync_test.dart` — enforces JSON ↔ Dart parity
- `cli/test/engine_test.dart` — integration test across all 4 rules on a multi-violation fixture
- `cli/test/fixtures/bad/hardcoded_color.dart`
- `cli/test/fixtures/bad/missing_safearea.dart`
- `cli/test/fixtures/bad/missing_adaptive.dart`
- `cli/test/fixtures/bad/swallowed_errors.dart`
- `cli/test/fixtures/bad/all_violations.dart`
- `cli/test/fixtures/good/clean.dart` — negative control, zero findings

**Modifications:**
- `tool/build.dart` — add `_generateRulesData()` step that writes `cli/lib/src/rules_data.dart`
- `tool/test/build_test.dart` — add test for rules_data generation
- `.github/workflows/ci.yaml` — NEW: run `dart analyze`, `dart test` for both `tool/` and `cli/`
- `README.md` — add CLI install + usage section

---

## Task 1: Scaffold `cli/` package

**Files:**
- Create: `cli/pubspec.yaml`
- Create: `cli/analysis_options.yaml`
- Create: `cli/.gitignore`
- Create: `cli/README.md`
- Create: `cli/bin/klamben.dart` (stub)
- Create: `cli/lib/klamben.dart` (stub)

- [ ] **Step 1: Create directories**

```bash
mkdir -p cli/bin cli/lib/src/rules/visual cli/lib/src/rules/layout cli/lib/src/rules/platform cli/lib/src/rules/code_quality cli/lib/src/reporter cli/test/rules/visual cli/test/rules/layout cli/test/rules/platform cli/test/rules/code_quality cli/test/fixtures/bad cli/test/fixtures/good
```

- [ ] **Step 2: Write `cli/pubspec.yaml`**

```yaml
name: klamben
description: Flutter design anti-pattern detector. Scans .dart files for AI-slop patterns across visual, layout, platform, and code-quality categories.
version: 0.1.0
repository: https://github.com/obiwancenobi/klamben
publish_to: none

environment:
  sdk: ^3.3.0

executables:
  klamben: klamben

dependencies:
  analyzer: ^6.0.0
  args: ^2.4.0
  path: ^1.9.0
  glob: ^2.1.0
  io: ^1.0.0

dev_dependencies:
  test: ^1.25.0
  lints: ^4.0.0
```

- [ ] **Step 3: Write `cli/analysis_options.yaml`**

```yaml
include: package:lints/recommended.yaml

analyzer:
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true
  errors:
    unused_import: error
    unused_local_variable: warning

linter:
  rules:
    - prefer_const_constructors
    - prefer_final_locals
    - avoid_print
    - unnecessary_this
```

- [ ] **Step 4: Write `cli/.gitignore`**

```
.dart_tool/
pubspec.lock
```

- [ ] **Step 5: Write `cli/README.md`**

```markdown
# klamben CLI

Dart CLI for scanning Flutter projects for design anti-patterns.

## Install

From source during development:

    dart pub global activate --source path cli/

## Usage

    klamben detect lib/
    klamben list-rules
    klamben explain visual/hardcoded-color
    klamben version

See the root [README](../README.md) for the full project overview.
```

- [ ] **Step 6: Write `cli/bin/klamben.dart` stub**

```dart
// cli/bin/klamben.dart
//
// klamben CLI entry point. Argument parsing and subcommand dispatch
// are filled in by Task 10.
void main(List<String> args) {
  print('klamben CLI — not yet implemented');
}
```

- [ ] **Step 7: Write `cli/lib/klamben.dart` stub**

```dart
// cli/lib/klamben.dart
//
// Public API barrel. Re-exports will be filled in by later tasks.
library;
```

- [ ] **Step 8: Install and verify**

```bash
cd cli && dart pub get && cd ..
dart run cli/bin/klamben.dart
```

Expected output: `klamben CLI — not yet implemented`

- [ ] **Step 9: Commit**

```bash
git add cli/ && git commit -m "feat(cli): scaffold klamben Dart package"
```

---

## Task 2: Rule abstraction — types and interface

**Files:**
- Create: `cli/lib/src/rules/rule.dart`

- [ ] **Step 1: Write `cli/lib/src/rules/rule.dart`**

```dart
// cli/lib/src/rules/rule.dart
//
// Common types for rule definitions and their findings.

import 'package:analyzer/dart/ast/ast.dart';

/// Category a rule belongs to. Mirrors the `category` field in rules.json.
enum RuleCategory {
  visual,
  layout,
  platform,
  codeQuality;

  String get jsonValue => switch (this) {
        RuleCategory.visual => 'visual',
        RuleCategory.layout => 'layout',
        RuleCategory.platform => 'platform',
        RuleCategory.codeQuality => 'code-quality',
      };

  static RuleCategory fromJson(String value) => switch (value) {
        'visual' => RuleCategory.visual,
        'layout' => RuleCategory.layout,
        'platform' => RuleCategory.platform,
        'code-quality' => RuleCategory.codeQuality,
        _ => throw ArgumentError('Unknown rule category: $value'),
      };
}

/// Severity of a finding. Mirrors the `severity` field in rules.json.
enum RuleSeverity {
  error,
  warning,
  info;

  static RuleSeverity fromJson(String value) => switch (value) {
        'error' => RuleSeverity.error,
        'warning' => RuleSeverity.warning,
        'info' => RuleSeverity.info,
        _ => throw ArgumentError('Unknown severity: $value'),
      };
}

/// One rule violation found in source code.
class Finding {
  final String ruleId;
  final RuleSeverity severity;
  final String message;
  final String filePath;
  final int line;
  final int column;

  const Finding({
    required this.ruleId,
    required this.severity,
    required this.message,
    required this.filePath,
    required this.line,
    required this.column,
  });
}

/// Context passed to rule checks. Keeps the interface stable as we add
/// more information (e.g. resolved library, project config) later.
class RuleCheckContext {
  final String filePath;
  final CompilationUnit unit;
  final String sourceText;

  const RuleCheckContext({
    required this.filePath,
    required this.unit,
    required this.sourceText,
  });
}

/// A rule that inspects parsed Dart code and emits findings.
abstract class Rule {
  /// Stable identifier matching an entry in `src/rules/rules.json`
  /// (e.g. `visual/hardcoded-color`).
  String get id;

  /// Category this rule belongs to.
  RuleCategory get category;

  /// Default severity — can be overridden via config later.
  RuleSeverity get severity;

  /// Return all findings for a single compilation unit.
  Iterable<Finding> check(RuleCheckContext context);
}
```

- [ ] **Step 2: Verify compiles**

```bash
cd cli && dart analyze lib/src/rules/rule.dart
```

Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add cli/lib/src/rules/rule.dart && git commit -m "feat(cli): add Rule interface, Finding, RuleCategory, RuleSeverity"
```

---

## Task 3: Generate `rules_data.dart` from `rules.json`

**Files:**
- Modify: `tool/build.dart` — add `_generateRulesData()` step
- Create: `cli/lib/src/rules/rule_metadata.dart`
- Modify: `tool/test/build_test.dart` — add generation test

`cli/lib/src/rules_data.dart` is a generated file containing the contents of `src/rules/rules.json` as a Dart string constant. This keeps the CLI self-contained while maintaining one source of truth for rule metadata.

- [ ] **Step 1: Write failing test in `tool/test/build_test.dart`**

Append inside the existing `group('build.dart', ...)`:

```dart
    test('build generates cli/lib/src/rules_data.dart', () async {
      await Process.run('dart', ['run', 'tool/build.dart'],
          workingDirectory: _repoRoot());

      final generated =
          File('${_repoRoot()}/cli/lib/src/rules_data.dart');
      expect(generated.existsSync(), isTrue,
          reason: 'expected rules_data.dart to be generated');
      final content = generated.readAsStringSync();
      expect(content, contains('const rulesJson'),
          reason: 'expected const rulesJson declaration');
      expect(content, contains('visual/hardcoded-color'),
          reason: 'expected rule ID from rules.json in generated data');
    });
```

- [ ] **Step 2: Run the test — expect FAIL**

```bash
cd tool && dart test test/build_test.dart -r expanded
```

Expected: new test fails (file does not exist yet).

- [ ] **Step 3: Add generation step in `tool/build.dart`**

After the `main` function, add a helper and call it from `main`:

```dart
Future<void> _generateRulesData() async {
  final rulesFile = File(p.join(repoRoot, srcRulesFile));
  final rulesJson = await rulesFile.readAsString();

  // Sanity: raw string literal only breaks on the triple-single-quote
  // terminator. rules.json uses double quotes everywhere, so this should
  // never trigger — but fail loudly if it ever does.
  if (rulesJson.contains("'''")) {
    stderr.writeln('rules.json contains triple-single-quote; cannot embed as raw string');
    exit(2);
  }

  final outPath = p.join(repoRoot, 'cli', 'lib', 'src', 'rules_data.dart');
  final out = '// GENERATED FILE — DO NOT EDIT.\n'
      '// Source: src/rules/rules.json\n'
      '// Regenerate: dart run tool/build.dart\n'
      '\n'
      "const rulesJson = r'''\n"
      '$rulesJson'
      "''';\n";

  final file = File(outPath);
  file.parent.createSync(recursive: true);
  await file.writeAsString(out);
  stdout.writeln('  generated: $outPath');
}
```

Wire it into `main` after the harness loop:

```dart
Future<void> main(List<String> args) async {
  final verify = args.contains('--verify');

  stdout.writeln(verify ? 'Verifying build/...' : 'Building build/...');

  for (final h in harnesses) {
    await _buildHarness(h, verify: verify);
  }

  if (!verify) {
    await _generateRulesData();
  }

  stdout.writeln('OK');
}
```

Note: `_generateRulesData` only runs in write mode. For `--verify`, we also need to verify the generated file matches. Add verification:

```dart
Future<void> _verifyRulesData() async {
  final rulesFile = File(p.join(repoRoot, srcRulesFile));
  final rulesJson = await rulesFile.readAsString();

  final expected = '// GENERATED FILE — DO NOT EDIT.\n'
      '// Source: src/rules/rules.json\n'
      '// Regenerate: dart run tool/build.dart\n'
      '\n'
      "const rulesJson = r'''\n"
      '$rulesJson'
      "''';\n";

  final outPath = p.join(repoRoot, 'cli', 'lib', 'src', 'rules_data.dart');
  final file = File(outPath);
  if (!file.existsSync()) {
    stderr.writeln('MISSING: $outPath');
    exit(2);
  }
  final actual = await file.readAsString();
  if (actual != expected) {
    stderr.writeln('STALE: $outPath');
    exit(2);
  }
}
```

And call it in the verify branch of `main`:

```dart
  if (verify) {
    await _verifyRulesData();
  } else {
    await _generateRulesData();
  }
```

- [ ] **Step 4: Run the test — expect PASS**

```bash
cd tool && dart test test/build_test.dart -r expanded
```

Expected: all 6 tests pass.

- [ ] **Step 5: Write `cli/lib/src/rules/rule_metadata.dart`**

This parses the generated `rulesJson` string at startup and exposes metadata by ID.

```dart
// cli/lib/src/rules/rule_metadata.dart

import 'dart:convert';

import 'rule.dart';
import '../rules_data.dart';

class RuleMetadata {
  final String id;
  final RuleCategory category;
  final RuleSeverity severity;
  final String title;
  final String description;
  final String rationale;
  final String fixHint;
  final List<String> references;
  final String badExample;
  final String goodExample;

  const RuleMetadata({
    required this.id,
    required this.category,
    required this.severity,
    required this.title,
    required this.description,
    required this.rationale,
    required this.fixHint,
    required this.references,
    required this.badExample,
    required this.goodExample,
  });
}

class RuleCatalog {
  final Map<String, RuleMetadata> byId;
  final List<RuleMetadata> all;

  const RuleCatalog._(this.byId, this.all);

  factory RuleCatalog.fromBundled() {
    final data = json.decode(rulesJson) as Map<String, dynamic>;
    final rules = data['rules'] as List<dynamic>;
    final parsed = <RuleMetadata>[];
    for (final entry in rules) {
      final map = entry as Map<String, dynamic>;
      final examples = (map['examples'] as Map<String, dynamic>? ?? const {});
      parsed.add(RuleMetadata(
        id: map['id'] as String,
        category: RuleCategory.fromJson(map['category'] as String),
        severity: RuleSeverity.fromJson(map['severity'] as String),
        title: map['title'] as String,
        description: map['description'] as String? ?? '',
        rationale: map['rationale'] as String? ?? '',
        fixHint: map['fix_hint'] as String? ?? '',
        references: ((map['references'] as List<dynamic>?) ?? const [])
            .cast<String>(),
        badExample: examples['bad'] as String? ?? '',
        goodExample: examples['good'] as String? ?? '',
      ));
    }
    final byId = <String, RuleMetadata>{
      for (final r in parsed) r.id: r,
    };
    return RuleCatalog._(byId, List.unmodifiable(parsed));
  }
}
```

- [ ] **Step 6: Verify**

```bash
dart run tool/build.dart
cd cli && dart analyze lib/src/
```

Expected: generation prints `generated: .../cli/lib/src/rules_data.dart` and analyze clean.

- [ ] **Step 7: Commit**

```bash
git add tool/build.dart tool/test/build_test.dart cli/lib/src/rules_data.dart cli/lib/src/rules/rule_metadata.dart
git commit -m "feat(cli): generate rules_data.dart from rules.json, add RuleCatalog"
```

---

## Task 4: File walker via `package:analyzer`

**Files:**
- Create: `cli/lib/src/walker.dart`

- [ ] **Step 1: Write `cli/lib/src/walker.dart`**

```dart
// cli/lib/src/walker.dart
//
// Parses .dart files into CompilationUnit using package:analyzer's
// unresolved parser (no Dart SDK resolution, so it's fast and works
// offline without a project pubspec).

import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

class ParsedFile {
  final String filePath;
  final CompilationUnit unit;
  final String sourceText;
  const ParsedFile({
    required this.filePath,
    required this.unit,
    required this.sourceText,
  });
}

/// Walk `rootPath` (file or directory) and yield parsed .dart files.
/// Directories are traversed recursively; generated files (`.g.dart`,
/// `.freezed.dart`) are skipped.
Iterable<ParsedFile> walkDartFiles(String rootPath) sync* {
  final entity = FileSystemEntity.typeSync(rootPath);
  if (entity == FileSystemEntityType.file) {
    final parsed = _parseOrNull(rootPath);
    if (parsed != null) yield parsed;
    return;
  }
  if (entity == FileSystemEntityType.directory) {
    final dir = Directory(rootPath);
    for (final e in dir.listSync(recursive: true, followLinks: false)) {
      if (e is! File) continue;
      if (!e.path.endsWith('.dart')) continue;
      if (_isGenerated(e.path)) continue;
      final parsed = _parseOrNull(e.path);
      if (parsed != null) yield parsed;
    }
  }
}

bool _isGenerated(String path) {
  final name = p.basename(path);
  return name.endsWith('.g.dart') ||
      name.endsWith('.freezed.dart') ||
      name.endsWith('.gr.dart') ||
      name.endsWith('.config.dart');
}

ParsedFile? _parseOrNull(String path) {
  try {
    final source = File(path).readAsStringSync();
    final result = parseString(
      content: source,
      path: path,
      throwIfDiagnostics: false,
      featureSet: FeatureSet.latestLanguageVersion(),
    );
    return ParsedFile(
      filePath: path,
      unit: result.unit,
      sourceText: source,
    );
  } on Object {
    return null;
  }
}

/// Helper used by tests to glob fixture paths.
List<String> expandGlob(String pattern, {required String cwd}) {
  final glob = Glob(pattern);
  return glob
      .listSync(root: cwd)
      .whereType<File>()
      .map((f) => f.path)
      .toList();
}
```

- [ ] **Step 2: Verify compiles**

```bash
cd cli && dart analyze lib/src/walker.dart
```

Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add cli/lib/src/walker.dart && git commit -m "feat(cli): add walker for parsing .dart files via analyzer"
```

---

## Task 5: Engine — orchestrator that runs rules over parsed files

**Files:**
- Create: `cli/lib/src/engine.dart`
- Create: `cli/lib/src/rules/rule_registry.dart`

- [ ] **Step 1: Write `cli/lib/src/rules/rule_registry.dart`**

```dart
// cli/lib/src/rules/rule_registry.dart

import 'rule.dart';

/// Holds all registered Dart Rule instances. Rules register themselves
/// by constructor in this class to keep registration explicit and
/// visible from one location.
class RuleRegistry {
  final List<Rule> rules;
  const RuleRegistry._(this.rules);

  factory RuleRegistry.defaults() {
    // Seed rules — populated in Tasks 6-9.
    return const RuleRegistry._([]);
  }

  Iterable<Rule> byCategory(RuleCategory c) =>
      rules.where((r) => r.category == c);

  Rule? byId(String id) =>
      rules.cast<Rule?>().firstWhere((r) => r!.id == id, orElse: () => null);
}
```

- [ ] **Step 2: Write `cli/lib/src/engine.dart`**

```dart
// cli/lib/src/engine.dart
//
// The detection engine: given a root path, parse all .dart files,
// run every rule against each, collect findings, and return them.

import 'rules/rule.dart';
import 'rules/rule_registry.dart';
import 'walker.dart';

class Engine {
  final RuleRegistry registry;

  const Engine({required this.registry});

  List<Finding> detect(String rootPath) {
    final findings = <Finding>[];
    for (final parsed in walkDartFiles(rootPath)) {
      final ctx = RuleCheckContext(
        filePath: parsed.filePath,
        unit: parsed.unit,
        sourceText: parsed.sourceText,
      );
      for (final rule in registry.rules) {
        findings.addAll(rule.check(ctx));
      }
    }
    // Stable order: by file, line, column, rule.
    findings.sort((a, b) {
      final fc = a.filePath.compareTo(b.filePath);
      if (fc != 0) return fc;
      if (a.line != b.line) return a.line.compareTo(b.line);
      if (a.column != b.column) return a.column.compareTo(b.column);
      return a.ruleId.compareTo(b.ruleId);
    });
    return findings;
  }
}
```

- [ ] **Step 3: Verify compiles**

```bash
cd cli && dart analyze lib/src/
```

Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add cli/lib/src/engine.dart cli/lib/src/rules/rule_registry.dart
git commit -m "feat(cli): add Engine and RuleRegistry"
```

---

## Task 6: Seed rule — `visual/hardcoded-color` (TDD)

**Files:**
- Create: `cli/test/fixtures/bad/hardcoded_color.dart`
- Create: `cli/test/rules/visual/hardcoded_color_test.dart`
- Create: `cli/lib/src/rules/visual/hardcoded_color.dart`

- [ ] **Step 1: Write fixture `cli/test/fixtures/bad/hardcoded_color.dart`**

```dart
// Fixture: should trigger visual/hardcoded-color rule.
// ignore_for_file: unused_element, unused_import

import 'package:flutter/material.dart';

Widget badPurple() {
  return Container(color: Colors.purple);
}

Widget badHex() {
  return Container(color: const Color(0xFFAABBCC));
}

Widget okTransparent() {
  return Container(color: Colors.transparent);
}
```

- [ ] **Step 2: Write failing test `cli/test/rules/visual/hardcoded_color_test.dart`**

```dart
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/analysis/features.dart';
import 'package:klamben/src/rules/rule.dart';
import 'package:klamben/src/rules/visual/hardcoded_color.dart';
import 'package:test/test.dart';

void main() {
  group('HardcodedColorRule', () {
    test('flags Colors.purple and Color(0xFF...)', () {
      const source = '''
import 'package:flutter/material.dart';

Widget a() => Container(color: Colors.purple);
Widget b() => Container(color: const Color(0xFFAABBCC));
Widget c() => Container(color: Colors.transparent);
''';
      final parsed = parseString(
        content: source,
        throwIfDiagnostics: false,
        featureSet: FeatureSet.latestLanguageVersion(),
      );
      final rule = HardcodedColorRule();
      final findings = rule
          .check(RuleCheckContext(
            filePath: 'test.dart',
            unit: parsed.unit,
            sourceText: source,
          ))
          .toList();
      expect(findings.length, 2,
          reason: 'expected findings for Colors.purple and Color(0xFF...)');
      expect(findings.every((f) => f.ruleId == 'visual/hardcoded-color'),
          isTrue);
    });
  });
}
```

- [ ] **Step 3: Run test — expect FAIL (class does not exist)**

```bash
cd cli && dart test test/rules/visual/hardcoded_color_test.dart -r expanded
```

Expected: compile error `HardcodedColorRule` undefined.

- [ ] **Step 4: Implement `cli/lib/src/rules/visual/hardcoded_color.dart`**

```dart
// cli/lib/src/rules/visual/hardcoded_color.dart

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../rule.dart';

class HardcodedColorRule implements Rule {
  @override
  String get id => 'visual/hardcoded-color';

  @override
  RuleCategory get category => RuleCategory.visual;

  @override
  RuleSeverity get severity => RuleSeverity.warning;

  @override
  Iterable<Finding> check(RuleCheckContext context) {
    final visitor = _Visitor(
      filePath: context.filePath,
      sourceText: context.sourceText,
      unit: context.unit,
    );
    context.unit.visitChildren(visitor);
    return visitor.findings;
  }
}

class _Visitor extends RecursiveAstVisitor<void> {
  final String filePath;
  final String sourceText;
  final CompilationUnit unit;
  final List<Finding> findings = [];

  _Visitor({
    required this.filePath,
    required this.sourceText,
    required this.unit,
  });

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    // Colors.purple, Colors.red, Colors.white, etc.
    if (node.prefix.name == 'Colors' && node.identifier.name != 'transparent') {
      _add(node.offset, 'Use ColorScheme semantic token instead of Colors.${node.identifier.name}');
    }
    super.visitPrefixedIdentifier(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    // Color(0xFF...)
    final typeName = node.constructorName.type.name2.lexeme;
    if (typeName == 'Color') {
      final args = node.argumentList.arguments;
      if (args.length == 1 && args.first is IntegerLiteral) {
        _add(node.offset, 'Use ColorScheme semantic token instead of Color(0x...)');
      }
    }
    super.visitInstanceCreationExpression(node);
  }

  void _add(int offset, String message) {
    final lineInfo = unit.lineInfo;
    final location = lineInfo.getLocation(offset);
    findings.add(Finding(
      ruleId: 'visual/hardcoded-color',
      severity: RuleSeverity.warning,
      message: message,
      filePath: filePath,
      line: location.lineNumber,
      column: location.columnNumber,
    ));
  }
}
```

- [ ] **Step 5: Run test — expect PASS**

```bash
cd cli && dart test test/rules/visual/hardcoded_color_test.dart -r expanded
```

Expected: 1 test passes.

- [ ] **Step 6: Register rule in `rule_registry.dart`**

Replace the `RuleRegistry.defaults` factory:

```dart
  factory RuleRegistry.defaults() {
    return RuleRegistry._([
      HardcodedColorRule(),
    ]);
  }
```

And add the import at the top:

```dart
import 'visual/hardcoded_color.dart';
```

- [ ] **Step 7: Analyze and commit**

```bash
cd cli && dart analyze lib/ test/
git add cli/lib/src/rules/visual/ cli/lib/src/rules/rule_registry.dart cli/test/fixtures/bad/hardcoded_color.dart cli/test/rules/visual/
git commit -m "feat(cli): add visual/hardcoded-color rule with tests"
```

---

## Task 7: Seed rule — `layout/missing-safearea` (TDD)

**Files:**
- Create: `cli/test/fixtures/bad/missing_safearea.dart`
- Create: `cli/test/rules/layout/missing_safearea_test.dart`
- Create: `cli/lib/src/rules/layout/missing_safearea.dart`

- [ ] **Step 1: Write fixture `cli/test/fixtures/bad/missing_safearea.dart`**

```dart
// Fixture: should trigger layout/missing-safearea rule.
// ignore_for_file: unused_element

import 'package:flutter/material.dart';

class BadNoSafeArea extends StatelessWidget {
  const BadNoSafeArea({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: const [Text('hello')]),
    );
  }
}

class OkWithAppBar extends StatelessWidget {
  const OkWithAppBar({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('t')),
      body: Column(children: const [Text('hello')]),
    );
  }
}

class OkWithSafeArea extends StatelessWidget {
  const OkWithSafeArea({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: const [Text('hello')]),
      ),
    );
  }
}
```

- [ ] **Step 2: Write failing test `cli/test/rules/layout/missing_safearea_test.dart`**

```dart
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/analysis/features.dart';
import 'package:klamben/src/rules/layout/missing_safearea.dart';
import 'package:klamben/src/rules/rule.dart';
import 'package:test/test.dart';

void main() {
  group('MissingSafeAreaRule', () {
    test('flags Scaffold body without SafeArea and without AppBar', () {
      const source = '''
import 'package:flutter/material.dart';

Widget a() => Scaffold(body: Column(children: const [Text('x')]));
Widget b() => Scaffold(appBar: AppBar(), body: Column(children: const [Text('x')]));
Widget c() => Scaffold(body: SafeArea(child: Column(children: const [Text('x')])));
''';
      final parsed = parseString(
        content: source,
        throwIfDiagnostics: false,
        featureSet: FeatureSet.latestLanguageVersion(),
      );
      final rule = MissingSafeAreaRule();
      final findings = rule
          .check(RuleCheckContext(
            filePath: 'test.dart',
            unit: parsed.unit,
            sourceText: source,
          ))
          .toList();
      expect(findings.length, 1,
          reason: 'only the naked Scaffold should be flagged');
      expect(findings.first.ruleId, 'layout/missing-safearea');
    });
  });
}
```

- [ ] **Step 3: Run test — expect FAIL (class undefined)**

```bash
cd cli && dart test test/rules/layout/missing_safearea_test.dart -r expanded
```

- [ ] **Step 4: Implement `cli/lib/src/rules/layout/missing_safearea.dart`**

```dart
// cli/lib/src/rules/layout/missing_safearea.dart

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../rule.dart';

class MissingSafeAreaRule implements Rule {
  @override
  String get id => 'layout/missing-safearea';

  @override
  RuleCategory get category => RuleCategory.layout;

  @override
  RuleSeverity get severity => RuleSeverity.error;

  @override
  Iterable<Finding> check(RuleCheckContext context) {
    final visitor = _Visitor(
      filePath: context.filePath,
      unit: context.unit,
    );
    context.unit.visitChildren(visitor);
    return visitor.findings;
  }
}

class _Visitor extends RecursiveAstVisitor<void> {
  final String filePath;
  final CompilationUnit unit;
  final List<Finding> findings = [];

  _Visitor({required this.filePath, required this.unit});

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final typeName = node.constructorName.type.name2.lexeme;
    if (typeName == 'Scaffold') {
      final args = node.argumentList.arguments;
      Expression? body;
      var hasAppBar = false;
      for (final a in args) {
        if (a is NamedExpression) {
          final name = a.name.label.name;
          if (name == 'body') body = a.expression;
          if (name == 'appBar') hasAppBar = true;
        }
      }
      if (body != null && !hasAppBar && !_descendsFromSafeArea(body)) {
        final loc = unit.lineInfo.getLocation(node.offset);
        findings.add(Finding(
          ruleId: 'layout/missing-safearea',
          severity: RuleSeverity.error,
          message:
              'Scaffold body without SafeArea or AppBar — content will collide with status bar / notch.',
          filePath: filePath,
          line: loc.lineNumber,
          column: loc.columnNumber,
        ));
      }
    }
    super.visitInstanceCreationExpression(node);
  }

  bool _descendsFromSafeArea(Expression body) {
    if (body is InstanceCreationExpression) {
      return body.constructorName.type.name2.lexeme == 'SafeArea';
    }
    return false;
  }
}
```

- [ ] **Step 5: Run test — expect PASS**

```bash
cd cli && dart test test/rules/layout/missing_safearea_test.dart -r expanded
```

- [ ] **Step 6: Register rule in `rule_registry.dart`**

Add to imports and registration list:

```dart
import 'layout/missing_safearea.dart';

// ...

  factory RuleRegistry.defaults() {
    return RuleRegistry._([
      HardcodedColorRule(),
      MissingSafeAreaRule(),
    ]);
  }
```

- [ ] **Step 7: Analyze and commit**

```bash
cd cli && dart analyze lib/ test/
git add cli/lib/src/rules/layout/ cli/lib/src/rules/rule_registry.dart cli/test/fixtures/bad/missing_safearea.dart cli/test/rules/layout/
git commit -m "feat(cli): add layout/missing-safearea rule with tests"
```

---

## Task 8: Seed rule — `platform/missing-adaptive` (TDD)

**Files:**
- Create: `cli/test/fixtures/bad/missing_adaptive.dart`
- Create: `cli/test/rules/platform/missing_adaptive_test.dart`
- Create: `cli/lib/src/rules/platform/missing_adaptive.dart`

- [ ] **Step 1: Write fixture `cli/test/fixtures/bad/missing_adaptive.dart`**

```dart
// Fixture: should trigger platform/missing-adaptive rule.
// ignore_for_file: unused_element

import 'package:flutter/material.dart';

Widget bad(bool on, void Function(bool) f) {
  return Switch(value: on, onChanged: f);
}

Widget good(bool on, void Function(bool) f) {
  return Switch.adaptive(value: on, onChanged: f);
}
```

- [ ] **Step 2: Write failing test `cli/test/rules/platform/missing_adaptive_test.dart`**

```dart
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/analysis/features.dart';
import 'package:klamben/src/rules/platform/missing_adaptive.dart';
import 'package:klamben/src/rules/rule.dart';
import 'package:test/test.dart';

void main() {
  group('MissingAdaptiveRule', () {
    test('flags plain Switch but not Switch.adaptive', () {
      const source = '''
import 'package:flutter/material.dart';

Widget a() => Switch(value: true, onChanged: (v) {});
Widget b() => Switch.adaptive(value: true, onChanged: (v) {});
''';
      final parsed = parseString(
        content: source,
        throwIfDiagnostics: false,
        featureSet: FeatureSet.latestLanguageVersion(),
      );
      final rule = MissingAdaptiveRule();
      final findings = rule
          .check(RuleCheckContext(
            filePath: 'test.dart',
            unit: parsed.unit,
            sourceText: source,
          ))
          .toList();
      expect(findings.length, 1);
      expect(findings.first.ruleId, 'platform/missing-adaptive');
    });
  });
}
```

- [ ] **Step 3: Run — expect FAIL**

```bash
cd cli && dart test test/rules/platform/missing_adaptive_test.dart -r expanded
```

- [ ] **Step 4: Implement `cli/lib/src/rules/platform/missing_adaptive.dart`**

```dart
// cli/lib/src/rules/platform/missing_adaptive.dart

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../rule.dart';

/// Flags usage of non-adaptive widgets where `.adaptive` variants exist.
class MissingAdaptiveRule implements Rule {
  static const _widgetsWithAdaptive = {'Switch', 'Slider', 'CircularProgressIndicator'};

  @override
  String get id => 'platform/missing-adaptive';

  @override
  RuleCategory get category => RuleCategory.platform;

  @override
  RuleSeverity get severity => RuleSeverity.info;

  @override
  Iterable<Finding> check(RuleCheckContext context) {
    final visitor = _Visitor(
      filePath: context.filePath,
      unit: context.unit,
    );
    context.unit.visitChildren(visitor);
    return visitor.findings;
  }
}

class _Visitor extends RecursiveAstVisitor<void> {
  final String filePath;
  final CompilationUnit unit;
  final List<Finding> findings = [];

  _Visitor({required this.filePath, required this.unit});

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final typeName = node.constructorName.type.name2.lexeme;
    final ctorName = node.constructorName.name?.name;
    if (MissingAdaptiveRule._widgetsWithAdaptive.contains(typeName) &&
        ctorName != 'adaptive') {
      final loc = unit.lineInfo.getLocation(node.offset);
      findings.add(Finding(
        ruleId: 'platform/missing-adaptive',
        severity: RuleSeverity.info,
        message: 'Use $typeName.adaptive for platform-correct rendering on iOS.',
        filePath: filePath,
        line: loc.lineNumber,
        column: loc.columnNumber,
      ));
    }
    super.visitInstanceCreationExpression(node);
  }
}
```

- [ ] **Step 5: Run — expect PASS**

```bash
cd cli && dart test test/rules/platform/missing_adaptive_test.dart -r expanded
```

- [ ] **Step 6: Register rule**

```dart
import 'platform/missing_adaptive.dart';

// ...

  factory RuleRegistry.defaults() {
    return RuleRegistry._([
      HardcodedColorRule(),
      MissingSafeAreaRule(),
      MissingAdaptiveRule(),
    ]);
  }
```

- [ ] **Step 7: Commit**

```bash
cd cli && dart analyze lib/ test/
git add cli/lib/src/rules/platform/ cli/lib/src/rules/rule_registry.dart cli/test/fixtures/bad/missing_adaptive.dart cli/test/rules/platform/
git commit -m "feat(cli): add platform/missing-adaptive rule with tests"
```

---

## Task 9: Seed rule — `code-quality/swallowed-errors` (TDD)

**Files:**
- Create: `cli/test/fixtures/bad/swallowed_errors.dart`
- Create: `cli/test/rules/code_quality/swallowed_errors_test.dart`
- Create: `cli/lib/src/rules/code_quality/swallowed_errors.dart`

- [ ] **Step 1: Write fixture `cli/test/fixtures/bad/swallowed_errors.dart`**

```dart
// Fixture: should trigger code-quality/swallowed-errors rule.
// ignore_for_file: unused_element, empty_catches

void bad() {
  try {
    throw Exception('boom');
  } catch (_) {}
}

void ok() {
  try {
    throw Exception('boom');
  } catch (e) {
    print('caught: $e');
  }
}
```

- [ ] **Step 2: Write failing test `cli/test/rules/code_quality/swallowed_errors_test.dart`**

```dart
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/analysis/features.dart';
import 'package:klamben/src/rules/code_quality/swallowed_errors.dart';
import 'package:klamben/src/rules/rule.dart';
import 'package:test/test.dart';

void main() {
  group('SwallowedErrorsRule', () {
    test('flags empty catch block only', () {
      const source = '''
void a() {
  try { throw 1; } catch (_) {}
}
void b() {
  try { throw 1; } catch (e) { print(e); }
}
''';
      final parsed = parseString(
        content: source,
        throwIfDiagnostics: false,
        featureSet: FeatureSet.latestLanguageVersion(),
      );
      final rule = SwallowedErrorsRule();
      final findings = rule
          .check(RuleCheckContext(
            filePath: 'test.dart',
            unit: parsed.unit,
            sourceText: source,
          ))
          .toList();
      expect(findings.length, 1);
      expect(findings.first.ruleId, 'code-quality/swallowed-errors');
    });
  });
}
```

- [ ] **Step 3: Run — expect FAIL**

```bash
cd cli && dart test test/rules/code_quality/swallowed_errors_test.dart -r expanded
```

- [ ] **Step 4: Implement `cli/lib/src/rules/code_quality/swallowed_errors.dart`**

```dart
// cli/lib/src/rules/code_quality/swallowed_errors.dart

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../rule.dart';

class SwallowedErrorsRule implements Rule {
  @override
  String get id => 'code-quality/swallowed-errors';

  @override
  RuleCategory get category => RuleCategory.codeQuality;

  @override
  RuleSeverity get severity => RuleSeverity.warning;

  @override
  Iterable<Finding> check(RuleCheckContext context) {
    final visitor = _Visitor(
      filePath: context.filePath,
      unit: context.unit,
    );
    context.unit.visitChildren(visitor);
    return visitor.findings;
  }
}

class _Visitor extends RecursiveAstVisitor<void> {
  final String filePath;
  final CompilationUnit unit;
  final List<Finding> findings = [];

  _Visitor({required this.filePath, required this.unit});

  @override
  void visitCatchClause(CatchClause node) {
    final body = node.body;
    if (body.statements.isEmpty) {
      final loc = unit.lineInfo.getLocation(node.offset);
      findings.add(Finding(
        ruleId: 'code-quality/swallowed-errors',
        severity: RuleSeverity.warning,
        message:
            'Empty catch block swallows the error. At least log it with debugPrint().',
        filePath: filePath,
        line: loc.lineNumber,
        column: loc.columnNumber,
      ));
    }
    super.visitCatchClause(node);
  }
}
```

- [ ] **Step 5: Run — expect PASS**

```bash
cd cli && dart test test/rules/code_quality/swallowed_errors_test.dart -r expanded
```

- [ ] **Step 6: Register rule**

```dart
import 'code_quality/swallowed_errors.dart';

// ...

  factory RuleRegistry.defaults() {
    return RuleRegistry._([
      HardcodedColorRule(),
      MissingSafeAreaRule(),
      MissingAdaptiveRule(),
      SwallowedErrorsRule(),
    ]);
  }
```

- [ ] **Step 7: Commit**

```bash
cd cli && dart analyze lib/ test/
git add cli/lib/src/rules/code_quality/ cli/lib/src/rules/rule_registry.dart cli/test/fixtures/bad/swallowed_errors.dart cli/test/rules/code_quality/
git commit -m "feat(cli): add code-quality/swallowed-errors rule with tests"
```

---

## Task 10: Text reporter

**Files:**
- Create: `cli/lib/src/reporter/text_reporter.dart`
- Create: `cli/test/reporter/text_reporter_test.dart`

- [ ] **Step 1: Write failing test `cli/test/reporter/text_reporter_test.dart`**

```dart
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
```

- [ ] **Step 2: Run — expect compile FAIL**

```bash
cd cli && dart test test/reporter/text_reporter_test.dart -r expanded
```

- [ ] **Step 3: Implement `cli/lib/src/reporter/text_reporter.dart`**

```dart
// cli/lib/src/reporter/text_reporter.dart

import '../rules/rule.dart';

class TextReporter {
  final bool useColor;
  const TextReporter({this.useColor = true});

  String render(List<Finding> findings) {
    if (findings.isEmpty) {
      return 'No issues found.\n';
    }

    final buf = StringBuffer();
    final byFile = <String, List<Finding>>{};
    for (final f in findings) {
      byFile.putIfAbsent(f.filePath, () => []).add(f);
    }

    final sortedFiles = byFile.keys.toList()..sort();
    for (final file in sortedFiles) {
      buf.writeln(file);
      for (final f in byFile[file]!) {
        final sev = _severityLabel(f.severity);
        buf.writeln(
          '  ${f.line}:${f.column}  $sev  ${f.ruleId}  ${f.message}',
        );
      }
      buf.writeln();
    }

    final errors = findings.where((f) => f.severity == RuleSeverity.error).length;
    final warnings = findings.where((f) => f.severity == RuleSeverity.warning).length;
    final infos = findings.where((f) => f.severity == RuleSeverity.info).length;

    buf.write('${findings.length} issues (');
    final parts = <String>[];
    if (errors > 0) parts.add('$errors error${errors == 1 ? '' : 's'}');
    if (warnings > 0) parts.add('$warnings warning${warnings == 1 ? '' : 's'}');
    if (infos > 0) parts.add('$infos info');
    buf.write(parts.join(', '));
    buf.writeln(') in ${byFile.length} file${byFile.length == 1 ? '' : 's'}.');

    return buf.toString();
  }

  String _severityLabel(RuleSeverity s) {
    final label = switch (s) {
      RuleSeverity.error => 'error  ',
      RuleSeverity.warning => 'warning',
      RuleSeverity.info => 'info   ',
    };
    if (!useColor) return label;
    final color = switch (s) {
      RuleSeverity.error => '\x1B[31m', // red
      RuleSeverity.warning => '\x1B[33m', // yellow
      RuleSeverity.info => '\x1B[36m', // cyan
    };
    return '$color$label\x1B[0m';
  }
}
```

- [ ] **Step 4: Run — expect PASS**

```bash
cd cli && dart test test/reporter/text_reporter_test.dart -r expanded
```

- [ ] **Step 5: Commit**

```bash
git add cli/lib/src/reporter/text_reporter.dart cli/test/reporter/
git commit -m "feat(cli): add text reporter with per-file grouping and severity counts"
```

---

## Task 11: CLI entry point — `bin/klamben.dart`

**Files:**
- Modify: `cli/bin/klamben.dart`
- Create: `cli/lib/src/commands/detect_command.dart`
- Create: `cli/lib/src/commands/list_rules_command.dart`
- Create: `cli/lib/src/commands/explain_command.dart`

- [ ] **Step 1: Write `cli/lib/src/commands/detect_command.dart`**

```dart
// cli/lib/src/commands/detect_command.dart

import 'dart:io';
import 'package:args/command_runner.dart';

import '../engine.dart';
import '../reporter/text_reporter.dart';
import '../rules/rule.dart';
import '../rules/rule_registry.dart';

class DetectCommand extends Command<int> {
  @override
  String get name => 'detect';
  @override
  String get description => 'Scan .dart files for anti-patterns.';

  DetectCommand() {
    argParser
      ..addOption('severity',
          abbr: 's',
          help: 'Minimum severity to report (error|warning|info)',
          defaultsTo: 'info')
      ..addFlag('no-color', help: 'Disable ANSI colors', negatable: false);
  }

  @override
  Future<int> run() async {
    final rest = argResults!.rest;
    final path = rest.isEmpty ? 'lib' : rest.first;
    if (!FileSystemEntity.isDirectorySync(path) &&
        !FileSystemEntity.isFileSync(path)) {
      stderr.writeln('klamben: path not found: $path');
      return 2;
    }

    final severityStr = argResults!['severity'] as String;
    final minSeverity = RuleSeverity.fromJson(severityStr);
    final noColor = argResults!['no-color'] as bool;

    final engine = Engine(registry: RuleRegistry.defaults());
    final findings = engine
        .detect(path)
        .where((f) => f.severity.index <= minSeverity.index)
        .toList();

    final reporter = TextReporter(useColor: !noColor);
    stdout.write(reporter.render(findings));

    // Exit code: 1 if any findings, 0 otherwise.
    return findings.isEmpty ? 0 : 1;
  }
}
```

- [ ] **Step 2: Write `cli/lib/src/commands/list_rules_command.dart`**

```dart
// cli/lib/src/commands/list_rules_command.dart

import 'dart:io';
import 'package:args/command_runner.dart';

import '../rules/rule_metadata.dart';

class ListRulesCommand extends Command<int> {
  @override
  String get name => 'list-rules';
  @override
  String get description => 'Print the full rule catalog.';

  @override
  Future<int> run() async {
    final catalog = RuleCatalog.fromBundled();
    for (final r in catalog.all) {
      stdout.writeln('${r.id}  [${r.category.jsonValue}/${r.severity.name}]');
      stdout.writeln('  ${r.title}');
    }
    stdout.writeln();
    stdout.writeln('${catalog.all.length} rules.');
    return 0;
  }
}
```

- [ ] **Step 3: Write `cli/lib/src/commands/explain_command.dart`**

```dart
// cli/lib/src/commands/explain_command.dart

import 'dart:io';
import 'package:args/command_runner.dart';

import '../rules/rule_metadata.dart';

class ExplainCommand extends Command<int> {
  @override
  String get name => 'explain';
  @override
  String get description => 'Show the full description of a rule by ID.';

  @override
  Future<int> run() async {
    final rest = argResults!.rest;
    if (rest.isEmpty) {
      stderr.writeln('klamben: explain requires a rule ID (e.g. visual/hardcoded-color)');
      return 2;
    }
    final id = rest.first;
    final catalog = RuleCatalog.fromBundled();
    final meta = catalog.byId[id];
    if (meta == null) {
      stderr.writeln('klamben: unknown rule ID: $id');
      return 2;
    }
    stdout.writeln('${meta.id}  [${meta.category.jsonValue}/${meta.severity.name}]');
    stdout.writeln();
    stdout.writeln(meta.title);
    stdout.writeln();
    stdout.writeln('Description:');
    stdout.writeln('  ${meta.description}');
    stdout.writeln();
    stdout.writeln('Rationale:');
    stdout.writeln('  ${meta.rationale}');
    stdout.writeln();
    stdout.writeln('Fix:');
    stdout.writeln('  ${meta.fixHint}');
    stdout.writeln();
    if (meta.badExample.isNotEmpty) {
      stdout.writeln('Bad:');
      stdout.writeln('  ${meta.badExample}');
      stdout.writeln();
    }
    if (meta.goodExample.isNotEmpty) {
      stdout.writeln('Good:');
      stdout.writeln('  ${meta.goodExample}');
    }
    return 0;
  }
}
```

- [ ] **Step 4: Rewrite `cli/bin/klamben.dart`**

```dart
// cli/bin/klamben.dart

import 'dart:io';
import 'package:args/command_runner.dart';

import 'package:klamben/src/commands/detect_command.dart';
import 'package:klamben/src/commands/explain_command.dart';
import 'package:klamben/src/commands/list_rules_command.dart';

Future<void> main(List<String> args) async {
  final runner = CommandRunner<int>(
    'klamben',
    'Flutter design anti-pattern detector.',
  )
    ..addCommand(DetectCommand())
    ..addCommand(ListRulesCommand())
    ..addCommand(ExplainCommand());

  try {
    final code = await runner.run(args) ?? 0;
    exit(code);
  } on UsageException catch (e) {
    stderr.writeln(e);
    exit(64);
  }
}
```

- [ ] **Step 5: Smoke test the CLI**

```bash
cd cli && dart pub get
dart run bin/klamben.dart list-rules | head -5
dart run bin/klamben.dart explain visual/hardcoded-color
dart run bin/klamben.dart detect test/fixtures/bad/
```

Expected: `list-rules` prints 24 entries, `explain` prints the rule details, `detect` flags all 4 seed-rule violations across the fixtures.

- [ ] **Step 6: Verify exit code semantics**

```bash
cd cli && dart run bin/klamben.dart detect test/fixtures/bad/ ; echo "exit=$?"
```

Expected: `exit=1` (findings present).

```bash
mkdir -p /tmp/klamben_empty && cd cli && dart run bin/klamben.dart detect /tmp/klamben_empty ; echo "exit=$?"
```

Expected: `exit=0` (no .dart files, no findings).

- [ ] **Step 7: Commit**

```bash
cd /Users/arif.ariyan/Documents/Development/ai/klamben
git add cli/bin/klamben.dart cli/lib/src/commands/
git commit -m "feat(cli): add detect, list-rules, explain subcommands"
```

---

## Task 12: Catalog sync test

**Files:**
- Create: `cli/test/catalog_sync_test.dart`

Enforces that every ID in `rules.json` has a Dart `Rule` implementation, and vice versa. Prevents drift as rules are added in later sub-plans.

**Note:** Sub-plan 2 only implements 4 of 24 rules. This test asserts the seed rules exist and that there are no ORPHAN Dart rule classes (Dart rule with no JSON entry). The inverse check (JSON rule with no Dart class) is relaxed: this test lists MISSING rule IDs as a warning via `print` but does not fail — sub-plan 3 will tighten it to a hard assertion when all 24 are implemented.

- [ ] **Step 1: Write `cli/test/catalog_sync_test.dart`**

```dart
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
        print('INFO: ${missing.length} rules in rules.json lack Dart impl: $missing');
      }
    });
  });
}
```

- [ ] **Step 2: Run — expect PASS**

```bash
cd cli && dart test test/catalog_sync_test.dart -r expanded
```

Expected: 4 tests pass (the 4th prints an info line about the 20 missing rules but does not fail).

- [ ] **Step 3: Commit**

```bash
git add cli/test/catalog_sync_test.dart
git commit -m "test(cli): add catalog sync test for Dart/JSON rule parity"
```

---

## Task 13: Integration test — all seeds on a single multi-violation fixture

**Files:**
- Create: `cli/test/fixtures/bad/all_violations.dart`
- Create: `cli/test/fixtures/good/clean.dart`
- Create: `cli/test/engine_test.dart`

- [ ] **Step 1: Write `cli/test/fixtures/bad/all_violations.dart`**

```dart
// Fixture: triggers all 4 seed rules in one file.
// ignore_for_file: unused_element, empty_catches

import 'package:flutter/material.dart';

class BadScreen extends StatelessWidget {
  const BadScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(color: Colors.purple),
          Switch(value: true, onChanged: (v) {}),
        ],
      ),
    );
  }
}

void bad() {
  try {
    throw Exception('x');
  } catch (_) {}
}
```

- [ ] **Step 2: Write `cli/test/fixtures/good/clean.dart`**

```dart
// Fixture: triggers zero findings — negative control.
// ignore_for_file: unused_element

import 'package:flutter/material.dart';

class CleanScreen extends StatelessWidget {
  const CleanScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(color: Theme.of(context).colorScheme.primary),
            Switch.adaptive(value: true, onChanged: (v) {}),
          ],
        ),
      ),
    );
  }
}

void ok() {
  try {
    throw Exception('x');
  } catch (e) {
    print('caught: $e');
  }
}
```

- [ ] **Step 3: Write `cli/test/engine_test.dart`**

```dart
import 'package:klamben/src/engine.dart';
import 'package:klamben/src/rules/rule_registry.dart';
import 'package:test/test.dart';

void main() {
  group('Engine', () {
    final engine = Engine(registry: RuleRegistry.defaults());

    test('bad fixture triggers one finding per seed rule', () {
      final findings = engine.detect('test/fixtures/bad/all_violations.dart');
      final ids = findings.map((f) => f.ruleId).toSet();
      expect(ids, containsAll(const {
        'visual/hardcoded-color',
        'layout/missing-safearea',
        'platform/missing-adaptive',
        'code-quality/swallowed-errors',
      }));
    });

    test('good fixture triggers no findings', () {
      final findings = engine.detect('test/fixtures/good/clean.dart');
      expect(findings, isEmpty,
          reason: 'clean fixture should not trigger any rule. Got: $findings');
    });
  });
}
```

- [ ] **Step 4: Run — expect PASS**

```bash
cd cli && dart test test/engine_test.dart -r expanded
```

If the good fixture triggers a finding, the rule logic is over-matching. Fix the rule (not the fixture) until the test passes.

- [ ] **Step 5: Commit**

```bash
git add cli/test/fixtures/ cli/test/engine_test.dart
git commit -m "test(cli): integration test for all seed rules on bad/good fixtures"
```

---

## Task 14: JSON reporter

**Files:**
- Create: `cli/lib/src/reporter/json_reporter.dart`
- Create: `cli/test/reporter/json_reporter_test.dart`
- Modify: `cli/lib/src/commands/detect_command.dart` — add `--format` flag

- [ ] **Step 1: Write failing test `cli/test/reporter/json_reporter_test.dart`**

```dart
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
```

- [ ] **Step 2: Run — expect FAIL (class undefined)**

```bash
cd cli && dart test test/reporter/json_reporter_test.dart -r expanded
```

- [ ] **Step 3: Implement `cli/lib/src/reporter/json_reporter.dart`**

```dart
// cli/lib/src/reporter/json_reporter.dart

import 'dart:convert';

import '../rules/rule.dart';

class JsonReporter {
  const JsonReporter();

  String render(List<Finding> findings) {
    final payload = <String, dynamic>{
      'count': findings.length,
      'findings': findings
          .map((f) => {
                'rule_id': f.ruleId,
                'severity': f.severity.name,
                'message': f.message,
                'file': f.filePath,
                'line': f.line,
                'column': f.column,
              })
          .toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }
}
```

- [ ] **Step 4: Run — expect PASS**

```bash
cd cli && dart test test/reporter/json_reporter_test.dart -r expanded
```

- [ ] **Step 5: Wire `--format` into `detect_command.dart`**

Add the option in the constructor:

```dart
    argParser
      ..addOption('severity',
          abbr: 's',
          help: 'Minimum severity to report (error|warning|info)',
          defaultsTo: 'info')
      ..addOption('format',
          abbr: 'f',
          allowed: ['text', 'json'],
          help: 'Output format',
          defaultsTo: 'text')
      ..addFlag('no-color', help: 'Disable ANSI colors', negatable: false);
```

Add import:

```dart
import '../reporter/json_reporter.dart';
```

Replace the reporter call:

```dart
    final format = argResults!['format'] as String;
    final output = switch (format) {
      'json' => const JsonReporter().render(findings),
      _ => TextReporter(useColor: !noColor).render(findings),
    };
    stdout.write(output);
    if (format == 'text' && !output.endsWith('\n')) stdout.writeln();
```

- [ ] **Step 6: Smoke test**

```bash
cd cli && dart run bin/klamben.dart detect --format=json test/fixtures/bad/all_violations.dart | head -20
```

Expected: valid JSON with a `findings` array.

- [ ] **Step 7: Commit**

```bash
cd /Users/arif.ariyan/Documents/Development/ai/klamben
git add cli/lib/src/reporter/json_reporter.dart cli/lib/src/commands/detect_command.dart cli/test/reporter/json_reporter_test.dart
git commit -m "feat(cli): add JSON reporter and --format flag"
```

---

## Task 15: CI workflow

**Files:**
- Create: `.github/workflows/ci.yaml`

- [ ] **Step 1: Write `.github/workflows/ci.yaml`**

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: dart-lang/setup-dart@v1
        with:
          sdk: '3.3'

      - name: Install tool deps
        working-directory: tool
        run: dart pub get

      - name: Install cli deps
        working-directory: cli
        run: dart pub get

      - name: Verify build is current
        run: dart run tool/build.dart --verify

      - name: Analyze tool
        run: dart analyze tool/

      - name: Analyze cli
        working-directory: cli
        run: dart analyze lib/ test/ bin/

      - name: Format check tool
        run: dart format --set-exit-if-changed tool/

      - name: Format check cli
        working-directory: cli
        run: dart format --set-exit-if-changed lib/ test/ bin/

      - name: Test tool
        working-directory: tool
        run: dart test

      - name: Test cli
        working-directory: cli
        run: dart test
```

- [ ] **Step 2: Commit**

```bash
git add .github/workflows/ci.yaml
git commit -m "ci: add GitHub Actions workflow for tool and cli packages"
```

---

## Task 16: README CLI section

**Files:**
- Modify: `README.md` — add "CLI detector" section

- [ ] **Step 1: Insert new section into `README.md` between "What's inside" and "Install (Claude Code)"**

```markdown
## CLI detector (`klamben`)

Scan any Flutter project for anti-patterns without an AI harness:

```bash
# From the klamben repo
cd cli && dart pub global activate --source path .

# In your Flutter project
klamben detect lib/
klamben list-rules
klamben explain visual/hardcoded-color
klamben detect --format=json lib/ > findings.json
```

Exit codes:
- `0` — no findings
- `1` — one or more findings
- `2` — tool error (bad path, invalid rule ID)

**Note:** The CLI currently ships with 4 seed rules (one per category).
The full 24-rule coverage will be added in a later sub-plan.
```

(Use fenced code blocks correctly — the outer block needs to be 4 backticks or use a different syntax so the inner code block can use 3 backticks. When writing this to the file, use four backticks for the outer wrapper and three inside.)

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs: add CLI detector section to README"
```

---

## Task 17: End-to-end verification

**Files:** none modified

- [ ] **Step 1: Clean build + full verify**

```bash
cd /Users/arif.ariyan/Documents/Development/ai/klamben
rm -rf build/.claude cli/lib/src/rules_data.dart
dart run tool/build.dart
dart run tool/build.dart --verify
```

Expected: `OK` for both runs.

- [ ] **Step 2: Full tool test suite**

```bash
cd tool && dart test -r expanded
```

Expected: 6 tests pass (5 from sub-plan 1 + 1 new for rules_data generation).

- [ ] **Step 3: Full cli test suite**

```bash
cd ../cli && dart test -r expanded
```

Expected: all tests pass (4 per-rule + 2 reporter + 4 catalog + 2 engine = 12 tests).

- [ ] **Step 4: Analyze + format clean**

```bash
cd /Users/arif.ariyan/Documents/Development/ai/klamben
dart analyze tool/
cd cli && dart analyze lib/ test/ bin/
cd ..
dart format --set-exit-if-changed tool/
cd cli && dart format --set-exit-if-changed lib/ test/ bin/
```

Expected: all clean.

- [ ] **Step 5: Smoke test against a real Flutter project**

```bash
cd /tmp && flutter create klamben_smoke
cd cli && dart pub global activate --source path .
cd /tmp/klamben_smoke && klamben detect lib/
```

Expected: runs without crashing. The default `flutter create` template may trigger a couple of findings (e.g. inline color in `main.dart`).

```bash
rm -rf /tmp/klamben_smoke
```

- [ ] **Step 6: Commit any fallout**

```bash
cd /Users/arif.ariyan/Documents/Development/ai/klamben
git status
# If clean, move on; if not, commit with an explanatory message
```

- [ ] **Step 7: Final summary report**

Report:

```
Sub-plan 2 complete.

✓ cli/ Dart package scaffolded (pubspec, analysis_options, entry)
✓ Rule abstraction: Rule, Finding, RuleCategory, RuleSeverity
✓ rules_data.dart generated from src/rules/rules.json by tool/build.dart
✓ RuleCatalog parses bundled JSON at runtime
✓ Walker + Engine orchestrate parsing + rule execution
✓ 4 seed rules (one per category) with per-rule tests:
    - visual/hardcoded-color
    - layout/missing-safearea
    - platform/missing-adaptive
    - code-quality/swallowed-errors
✓ Text + JSON reporters
✓ CLI entry: detect, list-rules, explain subcommands
✓ Catalog sync test (no orphan Dart rules)
✓ Integration test on multi-violation fixture + clean negative control
✓ GitHub Actions CI workflow
✓ README updated with CLI install + usage
✓ Smoke tested against a fresh flutter create project

Ready for sub-plan 3 (expand from 4 to 24 rules).
```

---

## Sub-plan 2 acceptance criteria

- [ ] `cli/` package compiles clean: `dart analyze lib/ test/ bin/`
- [ ] `dart format --set-exit-if-changed cli/{lib,test,bin}` clean
- [ ] `cd cli && dart test` → 12+ tests pass
- [ ] `dart run tool/build.dart` generates `cli/lib/src/rules_data.dart`
- [ ] `dart run tool/build.dart --verify` exits 0 on clean checkout
- [ ] `klamben list-rules` prints 24 entries
- [ ] `klamben explain visual/hardcoded-color` prints the full metadata
- [ ] `klamben detect cli/test/fixtures/bad/` flags all 4 seed rules
- [ ] `klamben detect cli/test/fixtures/good/` prints "No issues found."
- [ ] Exit code 1 when findings exist, 0 otherwise, 2 on tool error
- [ ] CI workflow exists and runs analyze + format + test for both packages

## Out of scope (deferred)

- Remaining 20 rules → sub-plan 3
- SARIF / GitHub annotation reporters → sub-plan 3 or later
- `--fix` codemods → sub-plan 3
- Multi-harness fan-out (cursor, gemini, codex, ...) → sub-plan 4
- pub.dev publication → after 24-rule coverage is ready
