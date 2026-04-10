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
      stderr.writeln(
          'klamben: explain requires a rule ID (e.g. visual/hardcoded-color)');
      return 2;
    }
    final id = rest.first;
    final catalog = RuleCatalog.fromBundled();
    final meta = catalog.byId[id];
    if (meta == null) {
      stderr.writeln('klamben: unknown rule ID: $id');
      return 2;
    }
    stdout.writeln(
        '${meta.id}  [${meta.category.jsonValue}/${meta.severity.name}]');
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
