import 'dart:io';
import 'package:test/test.dart';

void main() {
  group('build.dart', () {
    test('claude harness writes SKILL.md', () async {
      final result = await Process.run('dart', ['run', 'tool/build.dart'],
          workingDirectory: _repoRoot());
      expect(result.exitCode, 0, reason: 'build failed: ${result.stderr}');

      final skillFile =
          File('${_repoRoot()}/build/.claude/skills/flutter-design/SKILL.md');
      expect(skillFile.existsSync(), isTrue,
          reason: 'expected SKILL.md to be generated');
      expect(skillFile.readAsStringSync(), contains('name: flutter-design'));
    });

    test('claude harness writes 7 reference files', () async {
      await Process.run('dart', ['run', 'tool/build.dart'],
          workingDirectory: _repoRoot());

      final refDir = Directory(
          '${_repoRoot()}/build/.claude/skills/flutter-design/references');
      expect(refDir.existsSync(), isTrue);
      final files = refDir.listSync().whereType<File>().toList();
      expect(files.length, 7,
          reason: 'expected 7 reference modules, got ${files.length}');
    });

    test('claude harness writes 21 command files', () async {
      await Process.run('dart', ['run', 'tool/build.dart'],
          workingDirectory: _repoRoot());

      final cmdDir = Directory('${_repoRoot()}/build/.claude/commands');
      expect(cmdDir.existsSync(), isTrue);
      final files = cmdDir.listSync().whereType<File>().toList();
      expect(files.length, 21,
          reason: 'expected 21 commands, got ${files.length}');
    });

    test('--verify exits 0 when build is fresh', () async {
      // Ensure build is current
      await Process.run('dart', ['run', 'tool/build.dart'],
          workingDirectory: _repoRoot());

      final result = await Process.run(
        'dart',
        ['run', 'tool/build.dart', '--verify'],
        workingDirectory: _repoRoot(),
      );
      expect(result.exitCode, 0,
          reason: 'verify should succeed after fresh build: ${result.stderr}');
    });

    test('build generates cli/lib/src/rules_data.dart', () async {
      await Process.run('dart', ['run', 'tool/build.dart'],
          workingDirectory: _repoRoot());

      final generated = File('${_repoRoot()}/cli/lib/src/rules_data.dart');
      expect(generated.existsSync(), isTrue,
          reason: 'expected rules_data.dart to be generated');
      final content = generated.readAsStringSync();
      expect(content, contains('const rulesJson'),
          reason: 'expected const rulesJson declaration');
      expect(content, contains('visual/hardcoded-color'),
          reason: 'expected rule ID from rules.json in generated data');
    });

    test('--verify exits nonzero when build is stale', () async {
      // Fresh build
      await Process.run('dart', ['run', 'tool/build.dart'],
          workingDirectory: _repoRoot());

      // Tamper: overwrite generated SKILL.md with different content
      final skill =
          File('${_repoRoot()}/build/.claude/skills/flutter-design/SKILL.md');
      final original = await skill.readAsString();
      await skill.writeAsString('tampered');

      try {
        final result = await Process.run(
          'dart',
          ['run', 'tool/build.dart', '--verify'],
          workingDirectory: _repoRoot(),
        );
        expect(result.exitCode, isNot(0),
            reason: 'verify should fail when build is stale');
      } finally {
        // Restore
        await skill.writeAsString(original);
      }
    });
  });
}

String _repoRoot() {
  final cwd = Directory.current.path;
  return cwd.endsWith('/tool') ? '$cwd/..' : cwd;
}
