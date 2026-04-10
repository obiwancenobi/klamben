// cli/lib/src/rules/code_quality/missing_semantics.dart

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../rule.dart';

/// Flags `IconButton(...)` calls that lack a `tooltip` named argument,
/// which hurts accessibility.
class MissingSemanticsRule implements Rule {
  @override
  String get id => 'code-quality/missing-semantics';

  @override
  RuleCategory get category => RuleCategory.codeQuality;

  @override
  RuleSeverity get severity => RuleSeverity.warning;

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

bool _hasNamedArg(ArgumentList args, String name) {
  return args.arguments.any(
    (a) => a is NamedExpression && a.name.label.name == name,
  );
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
    if (name == 'IconButton' && !_hasNamedArg(args, 'tooltip')) {
      final loc = unit.lineInfo.getLocation(offset);
      findings.add(Finding(
        ruleId: 'code-quality/missing-semantics',
        severity: RuleSeverity.warning,
        message:
            'IconButton is missing a tooltip. Add tooltip for accessibility.',
        filePath: filePath,
        line: loc.lineNumber,
        column: loc.columnNumber,
      ));
    }
  }
}
