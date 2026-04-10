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
