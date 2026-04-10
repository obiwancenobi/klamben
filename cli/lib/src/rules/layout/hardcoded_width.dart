// cli/lib/src/rules/layout/hardcoded_width.dart

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../rule.dart';

/// Detects `Container(width: N)` or `SizedBox(width: N)` where N > 120,
/// signalling a fixed-width container that won't adapt to screen sizes.
class HardcodedWidthRule implements Rule {
  @override
  String get id => 'layout/hardcoded-width';

  @override
  RuleCategory get category => RuleCategory.layout;

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

class _Visitor extends RecursiveAstVisitor<void> {
  final String filePath;
  final CompilationUnit unit;
  final List<Finding> findings = [];

  _Visitor({required this.filePath, required this.unit});

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.target == null) {
      _check(node.methodName.name, node.argumentList, node.offset);
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final typeName = node.constructorName.type.name2.lexeme;
    _check(typeName, node.argumentList, node.offset);
    super.visitInstanceCreationExpression(node);
  }

  void _check(String name, ArgumentList argList, int offset) {
    if (name != 'Container' && name != 'SizedBox') return;

    for (final arg in argList.arguments) {
      if (arg is NamedExpression && arg.name.label.name == 'width') {
        final expr = arg.expression;
        num? value;
        if (expr is IntegerLiteral) value = expr.value;
        if (expr is DoubleLiteral) value = expr.value;
        if (value != null && value > 120) {
          final loc = unit.lineInfo.getLocation(offset);
          findings.add(Finding(
            ruleId: 'layout/hardcoded-width',
            severity: RuleSeverity.warning,
            message:
                'Hardcoded width $value — fixed-width containers break on different screen sizes.',
            filePath: filePath,
            line: loc.lineNumber,
            column: loc.columnNumber,
          ));
        }
      }
    }
  }
}
