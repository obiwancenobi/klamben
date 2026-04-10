// cli/lib/src/rules/layout/nested_padding.dart

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../rule.dart';

/// Detects redundant padding nesting: `Padding(child: Container(padding: ...))`
/// or `Container(child: Padding(...))`.
class NestedPaddingRule implements Rule {
  @override
  String get id => 'layout/nested-padding';

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
    if (name == 'Padding') {
      // Check if child is Container with padding
      final child = _getNamedArg(argList, 'child');
      if (child != null && _isWidgetWithName(child, 'Container')) {
        final containerArgs = _getArgList(child);
        if (containerArgs != null && _hasNamedArg(containerArgs, 'padding')) {
          _report(offset);
        }
      }
    } else if (name == 'Container') {
      // Check if child is Padding
      final child = _getNamedArg(argList, 'child');
      if (child != null && _isWidgetWithName(child, 'Padding')) {
        _report(offset);
      }
    }
  }

  Expression? _getNamedArg(ArgumentList argList, String name) {
    for (final arg in argList.arguments) {
      if (arg is NamedExpression && arg.name.label.name == name) {
        return arg.expression;
      }
    }
    return null;
  }

  bool _hasNamedArg(ArgumentList argList, String name) {
    return _getNamedArg(argList, name) != null;
  }

  bool _isWidgetWithName(Expression expr, String name) {
    if (expr is MethodInvocation && expr.target == null) {
      return expr.methodName.name == name;
    }
    if (expr is InstanceCreationExpression) {
      return expr.constructorName.type.name2.lexeme == name;
    }
    return false;
  }

  ArgumentList? _getArgList(Expression expr) {
    if (expr is MethodInvocation) return expr.argumentList;
    if (expr is InstanceCreationExpression) return expr.argumentList;
    return null;
  }

  void _report(int offset) {
    final loc = unit.lineInfo.getLocation(offset);
    findings.add(Finding(
      ruleId: 'layout/nested-padding',
      severity: RuleSeverity.warning,
      message:
          'Redundant padding nesting — combine into a single padding widget.',
      filePath: filePath,
      line: loc.lineNumber,
      column: loc.columnNumber,
    ));
  }
}
