// cli/lib/src/rules/layout/no_flexible.dart

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../rule.dart';

/// Detects `Row` or `Column` whose `children:` list contains a bare `Text`
/// widget not wrapped in `Flexible` or `Expanded`.
class NoFlexibleRule implements Rule {
  @override
  String get id => 'layout/no-flexible';

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
    if (name != 'Row' && name != 'Column') return;

    for (final arg in argList.arguments) {
      if (arg is NamedExpression && arg.name.label.name == 'children') {
        final expr = arg.expression;
        if (expr is ListLiteral) {
          for (final element in expr.elements) {
            if (_isBareText(element)) {
              final loc = unit.lineInfo.getLocation(offset);
              findings.add(Finding(
                ruleId: 'layout/no-flexible',
                severity: RuleSeverity.warning,
                message:
                    'Text widget in $name without Flexible/Expanded — may overflow on narrow screens.',
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

  /// Returns true if [expr] is a `Text(...)` call that is NOT wrapped in
  /// `Flexible(...)` or `Expanded(...)`.
  bool _isBareText(CollectionElement element) {
    if (element is! Expression) return false;
    final expr = element;
    final name = _widgetName(expr);
    return name == 'Text';
  }

  String? _widgetName(Expression expr) {
    if (expr is MethodInvocation && expr.target == null) {
      return expr.methodName.name;
    }
    if (expr is InstanceCreationExpression) {
      return expr.constructorName.type.name2.lexeme;
    }
    return null;
  }
}
