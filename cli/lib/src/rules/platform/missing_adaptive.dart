// cli/lib/src/rules/platform/missing_adaptive.dart

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../rule.dart';

/// Flags usage of non-adaptive widgets where `.adaptive` variants exist.
class MissingAdaptiveRule implements Rule {
  static const _widgetsWithAdaptive = {
    'Switch',
    'Slider',
    'CircularProgressIndicator',
  };

  @override
  String get id => 'platform/missing-adaptive';

  @override
  RuleCategory get category => RuleCategory.platform;

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
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final typeName = node.constructorName.type.name2.lexeme;
    final ctorName = node.constructorName.name?.name;
    if (MissingAdaptiveRule._widgetsWithAdaptive.contains(typeName) &&
        ctorName != 'adaptive') {
      _report(typeName, node.offset);
    }
    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    // Without resolved types, `Switch(...)` parses as a MethodInvocation
    // whose `methodName` is `Switch`. Distinguish from `Switch.adaptive(...)`
    // which parses as a MethodInvocation with target `Switch` and
    // methodName `adaptive`.
    if (node.target == null) {
      final name = node.methodName.name;
      if (MissingAdaptiveRule._widgetsWithAdaptive.contains(name)) {
        _report(name, node.offset);
      }
    }
    super.visitMethodInvocation(node);
  }

  void _report(String typeName, int offset) {
    final loc = unit.lineInfo.getLocation(offset);
    findings.add(Finding(
      ruleId: 'platform/missing-adaptive',
      severity: RuleSeverity.info,
      message: 'Use $typeName.adaptive for platform-correct rendering on iOS.',
      filePath: filePath,
      line: loc.lineNumber,
      column: loc.columnNumber,
    ));
  }
}
