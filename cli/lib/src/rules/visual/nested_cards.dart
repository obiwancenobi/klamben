// cli/lib/src/rules/visual/nested_cards.dart

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../rule.dart';

/// Flags `Card(child: Card(...))` — a Card nested inside another Card
/// creates confusing visual hierarchy.
class NestedCardsRule implements Rule {
  @override
  String get id => 'visual/nested-cards';

  @override
  RuleCategory get category => RuleCategory.visual;

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
    if (node.target == null && node.methodName.name == 'Card') {
      _checkForNestedCard(node.argumentList, node.offset);
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final typeName = node.constructorName.type.name2.lexeme;
    if (typeName == 'Card') {
      _checkForNestedCard(node.argumentList, node.offset);
    }
    super.visitInstanceCreationExpression(node);
  }

  void _checkForNestedCard(ArgumentList argList, int offset) {
    for (final arg in argList.arguments) {
      if (arg is NamedExpression && arg.name.label.name == 'child') {
        final childExpr = arg.expression;
        if (_isCard(childExpr)) {
          final location = unit.lineInfo.getLocation(offset);
          findings.add(Finding(
            ruleId: 'visual/nested-cards',
            severity: RuleSeverity.warning,
            message:
                'Card nested inside Card creates confusing visual hierarchy.',
            filePath: filePath,
            line: location.lineNumber,
            column: location.columnNumber,
          ));
        }
      }
    }
  }

  bool _isCard(Expression expr) {
    if (expr is MethodInvocation &&
        expr.target == null &&
        expr.methodName.name == 'Card') {
      return true;
    }
    if (expr is InstanceCreationExpression &&
        expr.constructorName.type.name2.lexeme == 'Card') {
      return true;
    }
    return false;
  }
}
