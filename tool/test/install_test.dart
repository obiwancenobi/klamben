import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  late Directory tmpDir;

  setUp(() {
    tmpDir = Directory.systemTemp.createTempSync('klamben_install_test_');
  });

  tearDown(() {
    if (tmpDir.existsSync()) tmpDir.deleteSync(recursive: true);
  });

  group('install', () {
    test('installs into empty project', () async {
      final result = await _runInstall([
        tmpDir.path,
        '--harness',
        'claude',
      ]);
      expect(result.exitCode, 0, reason: 'install failed: ${result.stderr}');

      final skill = File(p.join(
          tmpDir.path, '.claude', 'skills', 'flutter-design', 'SKILL.md'));
      expect(skill.existsSync(), isTrue);

      final cmds = Directory(p.join(tmpDir.path, '.claude', 'commands'));
      expect(cmds.listSync().whereType<File>().length, 28);

      final manifest =
          File(p.join(tmpDir.path, '.claude', '.klamben-manifest.json'));
      expect(manifest.existsSync(), isTrue);

      final data =
          json.decode(manifest.readAsStringSync()) as Map<String, dynamic>;
      expect(data['files'], hasLength(36));
    });

    test('preserves existing non-klamben files', () async {
      // Create existing content.
      final cmdsDir = Directory(p.join(tmpDir.path, '.claude', 'commands'));
      cmdsDir.createSync(recursive: true);
      File(p.join(cmdsDir.path, 'my-custom.md'))
          .writeAsStringSync('user content');

      await _runInstall([tmpDir.path, '--harness', 'claude']);

      // User file preserved.
      final custom = File(p.join(cmdsDir.path, 'my-custom.md'));
      expect(custom.readAsStringSync(), 'user content');

      // Klamben files installed.
      final skill = File(p.join(
          tmpDir.path, '.claude', 'skills', 'flutter-design', 'SKILL.md'));
      expect(skill.existsSync(), isTrue);
    });

    test('skips conflicting files without --force', () async {
      // Create a conflicting audit.md.
      final cmdsDir = Directory(p.join(tmpDir.path, '.claude', 'commands'));
      cmdsDir.createSync(recursive: true);
      File(p.join(cmdsDir.path, 'audit.md'))
          .writeAsStringSync('user audit command');

      final result = await _runInstall([tmpDir.path, '--harness', 'claude']);
      expect(result.exitCode, 0);
      expect(result.stderr, contains('SKIP'));
      expect(result.stderr, contains('audit.md'));

      // Conflict preserved.
      expect(
        File(p.join(cmdsDir.path, 'audit.md')).readAsStringSync(),
        'user audit command',
      );
    });

    test('--force overwrites conflicting files', () async {
      final cmdsDir = Directory(p.join(tmpDir.path, '.claude', 'commands'));
      cmdsDir.createSync(recursive: true);
      File(p.join(cmdsDir.path, 'audit.md'))
          .writeAsStringSync('user audit command');

      await _runInstall([tmpDir.path, '--harness', 'claude', '--force']);

      // Overwritten with klamben content.
      final content = File(p.join(cmdsDir.path, 'audit.md')).readAsStringSync();
      expect(content, contains('name: audit'));
    });

    test('--dry-run does not write files', () async {
      final result =
          await _runInstall([tmpDir.path, '--harness', 'claude', '--dry-run']);
      expect(result.exitCode, 0);
      expect(result.stdout, contains('dry run'));

      // No files written.
      final claudeDir = Directory(p.join(tmpDir.path, '.claude'));
      expect(claudeDir.existsSync(), isFalse);
    });

    test('update re-installs klamben-managed files', () async {
      // First install.
      await _runInstall([tmpDir.path, '--harness', 'claude']);

      // Tamper a klamben file.
      final skill = File(p.join(
          tmpDir.path, '.claude', 'skills', 'flutter-design', 'SKILL.md'));
      skill.writeAsStringSync('tampered');

      // Re-install (update).
      final result = await _runInstall([tmpDir.path, '--harness', 'claude']);
      expect(result.exitCode, 0);

      // File restored.
      expect(skill.readAsStringSync(), contains('name: flutter-design'));
    });
  });

  group('uninstall', () {
    test('removes only klamben files', () async {
      // Create existing content + install.
      final cmdsDir = Directory(p.join(tmpDir.path, '.claude', 'commands'));
      cmdsDir.createSync(recursive: true);
      File(p.join(cmdsDir.path, 'my-custom.md'))
          .writeAsStringSync('user content');

      await _runInstall([tmpDir.path, '--harness', 'claude', '--force']);

      // Uninstall.
      await _runInstall([tmpDir.path, '--harness', 'claude', '--uninstall']);

      // User file preserved.
      expect(
        File(p.join(cmdsDir.path, 'my-custom.md')).readAsStringSync(),
        'user content',
      );

      // Klamben files gone.
      final skill = File(p.join(
          tmpDir.path, '.claude', 'skills', 'flutter-design', 'SKILL.md'));
      expect(skill.existsSync(), isFalse);

      // Manifest gone.
      final manifest =
          File(p.join(tmpDir.path, '.claude', '.klamben-manifest.json'));
      expect(manifest.existsSync(), isFalse);
    });
  });
}

Future<ProcessResult> _runInstall(List<String> args) async {
  return Process.run(
    'dart',
    ['run', 'tool/install.dart', ...args],
    workingDirectory: _repoRoot(),
  );
}

String _repoRoot() {
  final cwd = Directory.current.path;
  if (cwd.endsWith('/tool')) return p.dirname(cwd);
  return cwd;
}
