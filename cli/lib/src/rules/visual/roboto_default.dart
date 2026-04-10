// cli/lib/src/rules/visual/roboto_default.dart

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../rule.dart';

/// Flags `ThemeData()` calls that lack a `textTheme` argument,
/// meaning the app uses the default Roboto font.
class RobotoDefaultRule implements Rule {
  @override
  String get id => 'visual/roboto-default';

  @override
  RuleCategory get category => RuleCategory.visual;

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

class _Visitor extends RecursiveAstVisitor<void> {
  final String filePath;
  final CompilationUnit unit;
  final List<Finding> findings = [];

  _Visitor({required this.filePath, required this.unit});

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.target == null && node.methodName.name == 'ThemeData') {
      _checkThemeData(node.argumentList, node.offset);
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final typeName = node.constructorName.type.name2.lexeme;
    if (typeName == 'ThemeData') {
      _checkThemeData(node.argumentList, node.offset);
    }
    super.visitInstanceCreationExpression(node);
  }

  void _checkThemeData(ArgumentList argList, int offset) {
    final hasTextTheme = argList.arguments.any(
      (arg) => arg is NamedExpression && arg.name.label.name == 'textTheme',
    );
    if (!hasTextTheme) {
      final location = unit.lineInfo.getLocation(offset);
      findings.add(Finding(
        ruleId: 'visual/roboto-default',
        severity: RuleSeverity.info,
        message:
            'ThemeData without textTheme uses default Roboto. Consider setting a custom textTheme.',
        filePath: filePath,
        line: location.lineNumber,
        column: location.columnNumber,
      ));
    }
  }
}
