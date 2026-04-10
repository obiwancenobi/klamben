// cli/lib/src/rules/code_quality/hardcoded_strings.dart

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../rule.dart';

/// Flags `Text('some literal')` — hardcoded user-facing strings that should
/// be extracted for internationalization.
class HardcodedStringsRule implements Rule {
  @override
  String get id => 'code-quality/hardcoded-strings';

  @override
  RuleCategory get category => RuleCategory.codeQuality;

  @override
  RuleSeverity get severity => RuleSeverity.info;

  @override
  Iterable<Finding> check(RuleCheckContext context) {
    final visitor = _Visitor(
      filePath: context.filePath,
      unit: context.unit,
    );
    context.unit.visitChildren(visitor);
    return visitor.findings;
  }
}

bool _isNonTrivialString(SimpleStringLiteral lit) {
  final value = lit.value;
  if (value.isEmpty) return false;
  if (value.trim().isEmpty) return false;
  if (value.length == 1) return false;
  if (value.startsWith('_')) return false;
  return true;
}

class _Visitor extends RecursiveAstVisitor<void> {
  final String filePath;
  final CompilationUnit unit;
  final List<Finding> findings = [];

  _Visitor({required this.filePath, required this.unit});

  @override
  void visitMethodInvocation(MethodInvocation node) {
    _check(node.methodName.name, node.argumentList, node.offset);
    super.visitMethodInvocation(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    _check(
      node.constructorName.type.name2.lexeme,
      node.argumentList,
      node.offset,
    );
    super.visitInstanceCreationExpression(node);
  }

  void _check(String name, ArgumentList args, int offset) {
    if (name != 'Text') return;

    // First positional argument.
    final positional =
        args.arguments.where((a) => a is! NamedExpression).toList();
    if (positional.isEmpty) return;

    final first = positional.first;
    if (first is SimpleStringLiteral && _isNonTrivialString(first)) {
      final loc = unit.lineInfo.getLocation(offset);
      findings.add(Finding(
        ruleId: 'code-quality/hardcoded-strings',
        severity: RuleSeverity.info,
        message: "Text widget has a hardcoded string '${first.value}'. "
            'Consider extracting for i18n.',
        filePath: filePath,
        line: loc.lineNumber,
        column: loc.columnNumber,
      ));
    }
  }
}
