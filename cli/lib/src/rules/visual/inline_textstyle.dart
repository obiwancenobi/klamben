// cli/lib/src/rules/visual/inline_textstyle.dart

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../rule.dart';

/// Flags `TextStyle(fontSize: LITERAL)` — inline TextStyle with a literal
/// fontSize instead of using a theme text style.
class InlineTextstyleRule implements Rule {
  @override
  String get id => 'visual/inline-textstyle';

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
    if (node.target == null && node.methodName.name == 'TextStyle') {
      _checkTextStyle(node.argumentList, node.offset);
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final typeName = node.constructorName.type.name2.lexeme;
    if (typeName == 'TextStyle') {
      _checkTextStyle(node.argumentList, node.offset);
    }
    super.visitInstanceCreationExpression(node);
  }

  void _checkTextStyle(ArgumentList argList, int offset) {
    for (final arg in argList.arguments) {
      if (arg is NamedExpression && arg.name.label.name == 'fontSize') {
        final expr = arg.expression;
        if (expr is IntegerLiteral || expr is DoubleLiteral) {
          final location = unit.lineInfo.getLocation(offset);
          findings.add(Finding(
            ruleId: 'visual/inline-textstyle',
            severity: RuleSeverity.warning,
            message:
                'Inline TextStyle with literal fontSize. Use Theme.of(context).textTheme instead.',
            filePath: filePath,
            line: location.lineNumber,
            column: location.columnNumber,
          ));
        }
      }
    }
  }
}
