// cli/lib/src/rules/layout/fixed_row_overflow.dart

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../rule.dart';

/// Detects `SizedBox(width: double.infinity)` inside a `Row`'s `children:`,
/// which causes an immediate overflow error.
class FixedRowOverflowRule implements Rule {
  @override
  String get id => 'layout/fixed-row-overflow';

  @override
  RuleCategory get category => RuleCategory.layout;

  @override
  RuleSeverity get severity => RuleSeverity.error;

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
      _checkRow(node.methodName.name, node.argumentList, node.offset);
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final typeName = node.constructorName.type.name2.lexeme;
    _checkRow(typeName, node.argumentList, node.offset);
    super.visitInstanceCreationExpression(node);
  }

  void _checkRow(String name, ArgumentList argList, int offset) {
    if (name != 'Row') return;

    for (final arg in argList.arguments) {
      if (arg is NamedExpression && arg.name.label.name == 'children') {
        final expr = arg.expression;
        if (expr is ListLiteral) {
          for (final element in expr.elements) {
            if (element is Expression && _isSizedBoxDoubleInfinity(element)) {
              final loc = unit.lineInfo.getLocation(offset);
              findings.add(Finding(
                ruleId: 'layout/fixed-row-overflow',
                severity: RuleSeverity.error,
                message:
                    'SizedBox(width: double.infinity) inside Row causes overflow — use Expanded instead.',
                filePath: filePath,
                line: loc.lineNumber,
                column: loc.columnNumber,
              ));
            }
          }
        }
      }
    }
  }

  bool _isSizedBoxDoubleInfinity(Expression expr) {
    String? name;
    ArgumentList? argList;

    if (expr is MethodInvocation && expr.target == null) {
      name = expr.methodName.name;
      argList = expr.argumentList;
    } else if (expr is InstanceCreationExpression) {
      name = expr.constructorName.type.name2.lexeme;
      argList = expr.argumentList;
    }

    if (name != 'SizedBox' || argList == null) return false;

    for (final arg in argList.arguments) {
      if (arg is NamedExpression && arg.name.label.name == 'width') {
        final widthExpr = arg.expression;
        // double.infinity parses as PrefixedIdentifier
        if (widthExpr is PrefixedIdentifier) {
          return widthExpr.prefix.name == 'double' &&
              widthExpr.identifier.name == 'infinity';
        }
      }
    }
    return false;
  }
}
