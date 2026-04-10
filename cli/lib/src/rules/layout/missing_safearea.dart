// cli/lib/src/rules/layout/missing_safearea.dart

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../rule.dart';

/// Flags a `Scaffold` whose `body` is not a `SafeArea` and has no
/// `appBar`. Without either, content renders under notches and
/// status bars on modern devices.
class MissingSafeAreaRule implements Rule {
  @override
  String get id => 'layout/missing-safearea';

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
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final typeName = node.constructorName.type.name2.lexeme;
    _checkScaffold(
      typeName,
      node.argumentList,
      node.offset,
    );
    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    // Without resolved types, `Scaffold(...)` parses as a MethodInvocation
    // whose `methodName` is `Scaffold`. Handle both cases.
    if (node.target == null) {
      _checkScaffold(
        node.methodName.name,
        node.argumentList,
        node.offset,
      );
    }
    super.visitMethodInvocation(node);
  }

  void _checkScaffold(String typeName, ArgumentList argList, int offset) {
    if (typeName != 'Scaffold') return;
    Expression? body;
    var hasAppBar = false;
    for (final arg in argList.arguments) {
      if (arg is NamedExpression) {
        final name = arg.name.label.name;
        if (name == 'body') body = arg.expression;
        if (name == 'appBar') hasAppBar = true;
      }
    }
    if (body == null || hasAppBar || _isSafeArea(body)) return;
    final loc = unit.lineInfo.getLocation(offset);
    findings.add(Finding(
      ruleId: 'layout/missing-safearea',
      severity: RuleSeverity.error,
      message:
          'Scaffold body without SafeArea or AppBar — content will collide with status bar / notch.',
      filePath: filePath,
      line: loc.lineNumber,
      column: loc.columnNumber,
    ));
  }

  bool _isSafeArea(Expression body) {
    if (body is InstanceCreationExpression) {
      return body.constructorName.type.name2.lexeme == 'SafeArea';
    }
    if (body is MethodInvocation && body.target == null) {
      return body.methodName.name == 'SafeArea';
    }
    return false;
  }
}
