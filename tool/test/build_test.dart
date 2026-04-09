import 'dart:io';
import 'package:test/test.dart';

void main() {
  group('build.dart', () {
    test('claude harness writes SKILL.md', () async {
      final result = await Process.run('dart', ['run', 'tool/build.dart'],
          workingDirectory: _repoRoot());
      expect(result.exitCode, 0, reason: 'build failed: ${result.stderr}');

      final skillFile = File(
          '${_repoRoot()}/build/.claude/skills/flutter-design/SKILL.md');
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
  });
}

String _repoRoot() {
  final cwd = Directory.current.path;
  return cwd.endsWith('/tool') ? '$cwd/..' : cwd;
}
