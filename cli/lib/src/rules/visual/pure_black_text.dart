// cli/lib/src/rules/visual/pure_black_text.dart

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../rule.dart';

/// Flags `TextStyle(color: Colors.black)` — pure black text is harsh
/// on screens and reduces readability. Use a dark grey or theme color.
class PureBlackTextRule implements Rule {
  @override
  String get id => 'visual/pure-black-text';

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
      if (arg is NamedExpression && arg.name.label.name == 'color') {
        final expr = arg.expression;
        if (expr is PrefixedIdentifier &&
            expr.prefix.name == 'Colors' &&
            expr.identifier.name == 'black') {
          final location = unit.lineInfo.getLocation(offset);
          findings.add(Finding(
            ruleId: 'visual/pure-black-text',
            severity: RuleSeverity.warning,
            message:
                'Avoid pure black text (Colors.black). Use a dark grey or theme color for better readability.',
            filePath: filePath,
            line: location.lineNumber,
            column: location.columnNumber,
          ));
        }
      }
    }
  }
}
