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

    final engine = Engine(registry: RuleRegistry.defaults());
    final findings = engine
        .detect(path)
        .where((f) => f.severity.index <= minSeverity.index)
        .toList();

    final reporter = TextReporter(useColor: !noColor);
    stdout.write(reporter.render(findings));

    return findings.isEmpty ? 0 : 1;
  }
}
