// cli/lib/src/rules/visual/shadow_overuse.dart

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../rule.dart';

/// Flags `Card(elevation: N)` or `Material(elevation: N)` where N > 8.
/// Excessive elevation creates unrealistic shadows.
class ShadowOveruseRule implements Rule {
  @override
  String get id => 'visual/shadow-overuse';

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

  static const _targets = {'Card', 'Material'};

  _Visitor({required this.filePath, required this.unit});

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.target == null && _targets.contains(node.methodName.name)) {
      _checkElevation(node.argumentList, node.offset);
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final typeName = node.constructorName.type.name2.lexeme;
    if (_targets.contains(typeName)) {
      _checkElevation(node.argumentList, node.offset);
    }
    super.visitInstanceCreationExpression(node);
  }

  void _checkElevation(ArgumentList argList, int offset) {
    for (final arg in argList.arguments) {
      if (arg is NamedExpression && arg.name.label.name == 'elevation') {
        final expr = arg.expression;
        double? value;
        if (expr is IntegerLiteral) {
          value = expr.value?.toDouble();
        } else if (expr is DoubleLiteral) {
          value = expr.value;
        }
        if (value != null && value > 8) {
          final location = unit.lineInfo.getLocation(offset);
          findings.add(Finding(
            ruleId: 'visual/shadow-overuse',
            severity: RuleSeverity.info,
            message:
                'Elevation $value is excessive (> 8). High elevation creates unrealistic shadows.',
            filePath: filePath,
            line: location.lineNumber,
            column: location.columnNumber,
          ));
        }
      }
    }
  }
}
