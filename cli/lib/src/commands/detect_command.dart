// cli/lib/src/commands/detect_command.dart

import 'dart:io';

import 'package:args/command_runner.dart';

import '../engine.dart';
import '../reporter/json_reporter.dart';
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
      ..addOption('format',
          abbr: 'f',
          allowed: ['text', 'json'],
          help: 'Output format',
          defaultsTo: 'text')
      ..addFlag('no-color',
          help: 'Disable ANSI colors', negatable: false);
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
    final format = argResults!['format'] as String;

    final engine = Engine(registry: RuleRegistry.defaults());
    final findings = engine
        .detect(path)
        .where((f) => f.severity.index <= minSeverity.index)
        .toList();

    final output = switch (format) {
      'json' => const JsonReporter().render(findings),
      _ => TextReporter(useColor: !noColor).render(findings),
    };
    stdout.write(output);
    if (format == 'json' && !output.endsWith('\n')) stdout.writeln();

    return findings.isEmpty ? 0 : 1;
  }
}
