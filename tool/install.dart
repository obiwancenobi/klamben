// tool/install.dart
//
// Safe installer that merges klamben skill + commands into an existing
// AI harness directory without overwriting user content.
//
// Usage:
//   dart run tool/install.dart <project-path> [options]
//
// Options:
//   --harness <name>   Harness to install (claude|cursor|gemini|...)
//   --force            Overwrite conflicting files
//   --uninstall        Remove klamben files from target
//   --dry-run          Show what would be done

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

// Harness name → rootDir mapping. Mirrors build.dart harnesses list.
const _harnesses = <String, String>{
  'claude': '.claude',
  'cursor': '.cursor',
  'gemini': '.gemini',
  'codex': '.codex',
  'opencode': '.opencode',
  'kiro': '.kiro',
  'trae': '.trae',
  'rovo': '.rovo',
  'copilot': '.copilot',
  'pi': '.pi',
};

const _manifestName = '.klamben-manifest.json';

Future<void> main(List<String> args) async {
  if (args.isEmpty || args.first == '--help' || args.first == '-h') {
    _printUsage();
    exit(0);
  }

  final projectPath = args.first;
  final flags = args.sublist(1);

  final force = flags.contains('--force');
  final dryRun = flags.contains('--dry-run');
  final uninstall = flags.contains('--uninstall');

  String? harness;
  final harnessIdx = flags.indexOf('--harness');
  if (harnessIdx != -1 && harnessIdx + 1 < flags.length) {
    harness = flags[harnessIdx + 1];
    if (!_harnesses.containsKey(harness)) {
      stderr.writeln('Unknown harness: $harness');
      stderr.writeln('Available: ${_harnesses.keys.join(', ')}');
      exit(2);
    }
  }

  if (!Directory(projectPath).existsSync()) {
    stderr.writeln('Project path not found: $projectPath');
    exit(2);
  }

  // Auto-detect harness if not specified.
  harness ??= _autoDetect(projectPath);

  final rootDir = _harnesses[harness]!;
  final repoRoot = _findRepoRoot();
  final buildDir = p.join(repoRoot, 'build', rootDir);

  if (!Directory(buildDir).existsSync()) {
    stderr.writeln(
        'Build directory not found: $buildDir\nRun `dart run tool/build.dart` first.');
    exit(2);
  }

  if (uninstall) {
    await _uninstall(projectPath, rootDir, dryRun: dryRun);
  } else {
    await _install(projectPath, buildDir, rootDir,
        force: force, dryRun: dryRun);
  }
}

/// Auto-detect which harness to install based on existing directories.
String _autoDetect(String projectPath) {
  for (final entry in _harnesses.entries) {
    if (Directory(p.join(projectPath, entry.value)).existsSync()) {
      stdout.writeln('Auto-detected harness: ${entry.key} '
          '(found ${entry.value}/)');
      return entry.key;
    }
  }
  stdout.writeln('No existing harness detected. Defaulting to claude.');
  return 'claude';
}

/// Install klamben files into target project.
Future<void> _install(
  String projectPath,
  String buildDir,
  String rootDir, {
  required bool force,
  required bool dryRun,
}) async {
  final destRoot = p.join(projectPath, rootDir);
  final manifestPath = p.join(destRoot, _manifestName);

  // Load existing manifest (if updating).
  final existingManifest = _loadManifest(manifestPath);
  final installedFiles = <String>[];
  var conflicts = 0;
  var copied = 0;
  var skipped = 0;
  var updated = 0;

  // Walk build directory and merge files.
  final buildEntity = Directory(buildDir);
  for (final entity in buildEntity.listSync(recursive: true)) {
    if (entity is! File) continue;
    final relPath = p.relative(entity.path, from: buildDir);
    final destPath = p.join(destRoot, relPath);
    final destFile = File(destPath);

    if (destFile.existsSync()) {
      // File exists at destination — is it ours?
      if (existingManifest.contains(relPath)) {
        // Klamben-managed file — safe to update.
        if (dryRun) {
          stdout.writeln('  UPDATE $relPath');
        } else {
          destFile.parent.createSync(recursive: true);
          entity.copySync(destPath);
        }
        updated++;
      } else if (force) {
        // Not ours, but --force specified.
        if (dryRun) {
          stdout.writeln('  FORCE  $relPath (overwriting existing)');
        } else {
          entity.copySync(destPath);
        }
        copied++;
      } else {
        // Conflict — skip and warn.
        stderr.writeln('  SKIP   $relPath (already exists, use --force)');
        conflicts++;
        skipped++;
        continue;
      }
    } else {
      // No conflict — copy.
      if (dryRun) {
        stdout.writeln('  COPY   $relPath');
      } else {
        destFile.parent.createSync(recursive: true);
        entity.copySync(destPath);
      }
      copied++;
    }
    installedFiles.add(relPath);
  }

  // Write manifest.
  if (!dryRun) {
    _writeManifest(manifestPath, installedFiles);
  }

  // Summary.
  final action = dryRun ? 'Would install' : 'Installed';
  stdout.writeln('');
  stdout.writeln('$action klamben into $destRoot');
  stdout.writeln(
      '  $copied new, $updated updated, $skipped skipped, $conflicts conflicts');
  if (conflicts > 0 && !force) {
    stdout.writeln('  Re-run with --force to overwrite conflicting files.');
  }
  if (dryRun) {
    stdout.writeln('  (dry run — no files were written)');
  }
}

/// Remove klamben files from target project using the manifest.
Future<void> _uninstall(
  String projectPath,
  String rootDir, {
  required bool dryRun,
}) async {
  final destRoot = p.join(projectPath, rootDir);
  final manifestPath = p.join(destRoot, _manifestName);
  final manifest = _loadManifest(manifestPath);

  if (manifest.isEmpty) {
    stderr.writeln('No klamben manifest found at $manifestPath');
    stderr.writeln('Nothing to uninstall.');
    exit(1);
  }

  var removed = 0;
  for (final relPath in manifest) {
    final filePath = p.join(destRoot, relPath);
    final file = File(filePath);
    if (file.existsSync()) {
      if (dryRun) {
        stdout.writeln('  REMOVE $relPath');
      } else {
        file.deleteSync();
      }
      removed++;
    }
  }

  // Remove empty directories left behind.
  if (!dryRun) {
    _cleanEmptyDirs(destRoot);
    File(manifestPath).deleteSync();
  }

  final action = dryRun ? 'Would remove' : 'Removed';
  stdout.writeln('');
  stdout.writeln('$action $removed klamben files from $destRoot');
  if (dryRun) {
    stdout.writeln('  (dry run — no files were deleted)');
  }
}

/// Load manifest file, return set of relative paths.
Set<String> _loadManifest(String path) {
  final file = File(path);
  if (!file.existsSync()) return {};
  try {
    final data = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
    final files = (data['files'] as List<dynamic>).cast<String>();
    return files.toSet();
  } on Object {
    return {};
  }
}

/// Write manifest file.
void _writeManifest(String path, List<String> files) {
  final data = {
    'version': '0.1.0',
    'installed_at': DateTime.now().toUtc().toIso8601String(),
    'files': files..sort(),
  };
  File(path)
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(const JsonEncoder.withIndent('  ').convert(data));
}

/// Remove empty directories recursively (bottom-up).
void _cleanEmptyDirs(String root) {
  final dir = Directory(root);
  if (!dir.existsSync()) return;
  for (final entity in dir.listSync(recursive: true).reversed) {
    if (entity is Directory) {
      try {
        final contents = entity.listSync();
        if (contents.isEmpty) entity.deleteSync();
      } on Object {
        // ignore
      }
    }
  }
}

/// Find the klamben repo root (directory containing tool/build.dart).
String _findRepoRoot() {
  // Script runs via `dart run tool/install.dart` from repo root.
  final cwd = Directory.current.path;
  if (File(p.join(cwd, 'tool', 'build.dart')).existsSync()) return cwd;
  // Maybe running from tool/ directly.
  final parent = p.dirname(cwd);
  if (File(p.join(parent, 'tool', 'build.dart')).existsSync()) return parent;
  stderr.writeln('Cannot find klamben repo root. '
      'Run from the repo root directory.');
  exit(2);
}

void _printUsage() {
  stdout.writeln('''
klamben install — safely merge skill + commands into your Flutter project

Usage:
  dart run tool/install.dart <project-path> [options]

Options:
  --harness <name>   Harness to install (claude|cursor|gemini|codex|
                     opencode|kiro|trae|rovo|copilot|pi)
                     Default: auto-detect from existing directories
  --force            Overwrite conflicting files
  --uninstall        Remove klamben files from the target project
  --dry-run          Show what would be done without writing files

Examples:
  dart run tool/install.dart ~/my-flutter-app
  dart run tool/install.dart ~/my-flutter-app --harness cursor
  dart run tool/install.dart ~/my-flutter-app --dry-run
  dart run tool/install.dart ~/my-flutter-app --uninstall
''');
}
