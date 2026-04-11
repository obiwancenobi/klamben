// cli/lib/src/commands/report_command.dart

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../engine.dart';
import '../reporter/html_reporter.dart';
import '../reporter/report_data.dart';
import '../rules/rule.dart';
import '../rules/rule_metadata.dart';
import '../rules/rule_registry.dart';

class ReportCommand extends Command<int> {
  @override
  String get name => 'report';

  @override
  String get description => 'Generate a rich HTML health dashboard.';

  ReportCommand() {
    argParser
      ..addOption('severity',
          abbr: 's',
          help: 'Minimum severity to report (error|warning|info)',
          defaultsTo: 'info')
      ..addOption('output',
          abbr: 'o',
          help: 'Output file path',
          defaultsTo: 'klamben-report.html');
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

    final registry = RuleRegistry.defaults();
    final engine = Engine(registry: registry);
    final findings = engine
        .detect(path)
        .where((f) => f.severity.index <= minSeverity.index)
        .toList();

    final totalFiles = _countDartFiles(path);
    final catalog = RuleCatalog.fromBundled();
    final data = ReportData.fromFindings(
      findings,
      scannedPath: path,
      totalFiles: totalFiles,
      totalRules: registry.rules.length,
      catalog: catalog,
    );

    final html = const HtmlReporter().renderDashboard(data);
    final outputPath = argResults!['output'] as String;
    HtmlReporter.writeToFile(html, outputPath);

    stderr.writeln('Dashboard written to $outputPath');
    stderr.writeln(
      '  ${data.totalFiles} files scanned, '
      '${data.totalFindings} findings, '
      'health score: ${data.healthScore}/100',
    );

    return 0;
  }

  int _countDartFiles(String rootPath) {
    final entity = FileSystemEntity.typeSync(rootPath);
    if (entity == FileSystemEntityType.file) return 1;
    if (entity != FileSystemEntityType.directory) return 0;
    var count = 0;
    for (final e in Directory(rootPath).listSync(recursive: true)) {
      if (e is! File) continue;
      if (!e.path.endsWith('.dart')) continue;
      final name = p.basename(e.path);
      if (name.endsWith('.g.dart') ||
          name.endsWith('.freezed.dart') ||
          name.endsWith('.gr.dart') ||
          name.endsWith('.config.dart')) {
        continue;
      }
      count++;
    }
    return count;
  }
}
