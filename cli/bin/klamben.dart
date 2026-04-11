// cli/bin/klamben.dart

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:klamben/src/commands/detect_command.dart';
import 'package:klamben/src/commands/explain_command.dart';
import 'package:klamben/src/commands/list_rules_command.dart';
import 'package:klamben/src/commands/report_command.dart';

class KlambenRunner extends CommandRunner<int> {
  KlambenRunner()
      : super('klamben', 'Flutter design anti-pattern detector.') {
    addCommand(DetectCommand());
    addCommand(ListRulesCommand());
    addCommand(ExplainCommand());
    addCommand(ReportCommand());
  }

  @override
  void printUsage() {
    // ignore: avoid_print
    print('''
  ╔═══════════════════════════════════════════╗
  ║  ┌─┐   ┌─┐                                ║
  ║ ┌┘ └───┘ └┐  klamben                      ║
  ║ │         │  flutter design skill         ║
  ║ └─────────┘  for AI code assistants       ║
  ╚═══════════════════════════════════════════╝
''');
    super.printUsage();
  }
}

Future<void> main(List<String> args) async {
  final runner = KlambenRunner();

  try {
    final code = await runner.run(args) ?? 0;
    exit(code);
  } on UsageException catch (e) {
    stderr.writeln(e);
    exit(64);
  }
}
