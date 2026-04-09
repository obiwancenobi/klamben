// tool/build.dart
//
// Fans out canonical src/ files to harness-specific build/<harness>/
// layouts. Sub-plan 1 ships claude-only; later sub-plans add the other
// harnesses.

import 'dart:io';
import 'package:path/path.dart' as p;

const repoRoot = '.';
const srcSkillDir = 'src/skill';
const srcCommandsDir = 'src/commands';
const srcRulesFile = 'src/rules/rules.json';

/// A harness is an AI tool with its own layout conventions (file paths,
/// frontmatter keys, invocation style). One instance per supported tool.
class HarnessSpec {
  final String name;
  final String rootDir; // e.g. '.claude'
  final String skillPath; // e.g. 'skills/flutter-design/SKILL.md'
  final String referencesDir; // e.g. 'skills/flutter-design/references'
  final String commandsDir; // e.g. 'commands'

  const HarnessSpec({
    required this.name,
    required this.rootDir,
    required this.skillPath,
    required this.referencesDir,
    required this.commandsDir,
  });
}

const harnesses = <HarnessSpec>[
  HarnessSpec(
    name: 'claude',
    rootDir: '.claude',
    skillPath: 'skills/flutter-design/SKILL.md',
    referencesDir: 'skills/flutter-design/references',
    commandsDir: 'commands',
  ),
];

Future<void> main(List<String> args) async {
  final verify = args.contains('--verify');

  stdout.writeln(verify ? 'Verifying build/...' : 'Building build/...');

  for (final h in harnesses) {
    await _buildHarness(h, verify: verify);
  }

  stdout.writeln('OK');
}

Future<void> _buildHarness(HarnessSpec h, {required bool verify}) async {
  final outRoot = p.join(repoRoot, 'build', h.rootDir);
  final files = await _computeFiles(h);

  if (verify) {
    for (final entry in files.entries) {
      final path = p.join(outRoot, entry.key);
      final file = File(path);
      if (!file.existsSync()) {
        stderr.writeln('MISSING: $path');
        exit(2);
      }
      final onDisk = await file.readAsString();
      if (onDisk != entry.value) {
        stderr.writeln('STALE: $path');
        exit(2);
      }
    }
    return;
  }

  // Write mode: clear and regenerate
  final dir = Directory(outRoot);
  if (dir.existsSync()) dir.deleteSync(recursive: true);
  dir.createSync(recursive: true);

  for (final entry in files.entries) {
    final path = p.join(outRoot, entry.key);
    File(path).parent.createSync(recursive: true);
    await File(path).writeAsString(entry.value);
  }

  stdout.writeln('  ${h.name}: ${files.length} files -> $outRoot');
}

Future<Map<String, String>> _computeFiles(HarnessSpec h) async {
  final files = <String, String>{};

  // Main SKILL.md
  final skillSrc = File(p.join(repoRoot, srcSkillDir, 'SKILL.md'));
  files[h.skillPath] = await skillSrc.readAsString();

  // Reference modules
  final refSrcDir = Directory(p.join(repoRoot, srcSkillDir, 'references'));
  final refEntries = refSrcDir.listSync().whereType<File>().toList();
  refEntries.sort((a, b) => a.path.compareTo(b.path));
  for (final entity in refEntries) {
    if (!entity.path.endsWith('.md')) continue;
    final basename = p.basename(entity.path);
    final outPath = p.join(h.referencesDir, basename);
    files[outPath] = await entity.readAsString();
  }

  // Commands
  final cmdSrcDir = Directory(p.join(repoRoot, srcCommandsDir));
  final cmdEntries = cmdSrcDir.listSync().whereType<File>().toList();
  cmdEntries.sort((a, b) => a.path.compareTo(b.path));
  for (final entity in cmdEntries) {
    if (!entity.path.endsWith('.md')) continue;
    final basename = p.basename(entity.path);
    final outPath = p.join(h.commandsDir, basename);
    files[outPath] = await entity.readAsString();
  }

  return files;
}
