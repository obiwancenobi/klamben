// cli/lib/src/rules/visual/hardcoded_color.dart

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../rule.dart';

/// Flags `Colors.X` (except `transparent`) and `Color(0x...)` literals.
/// Hardcoded colors bypass theming and break dark mode.
class HardcodedColorRule implements Rule {
  @override
  String get id => 'visual/hardcoded-color';

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
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    if (node.prefix.name == 'Colors' &&
        node.identifier.name != 'transparent') {
      _add(node.offset,
          'Use ColorScheme semantic token instead of Colors.${node.identifier.name}');
    }
    super.visitPrefixedIdentifier(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final typeName = node.constructorName.type.name2.lexeme;
    if (typeName == 'Color') {
      _checkColorArgs(node.argumentList, node.offset);
    }
    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    // Without resolved types, `Color(0x...)` without `const` parses as
    // a MethodInvocation with methodName == 'Color'.
    if (node.target == null && node.methodName.name == 'Color') {
      _checkColorArgs(node.argumentList, node.offset);
    }
    super.visitMethodInvocation(node);
  }

  void _checkColorArgs(ArgumentList argList, int offset) {
    final args = argList.arguments;
    if (args.length == 1 && args.first is IntegerLiteral) {
      _add(offset, 'Use ColorScheme semantic token instead of Color(0x...)');
    }
  }

  void _add(int offset, String message) {
    final location = unit.lineInfo.getLocation(offset);
    findings.add(Finding(
      ruleId: 'visual/hardcoded-color',
      severity: RuleSeverity.warning,
      message: message,
      filePath: filePath,
      line: location.lineNumber,
      column: location.columnNumber,
    ));
  }
}
