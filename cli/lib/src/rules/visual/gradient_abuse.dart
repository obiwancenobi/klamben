// cli/lib/src/rules/visual/gradient_abuse.dart

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../rule.dart';

/// Flags `LinearGradient(colors: [...Colors.purple..., ...Colors.pink...])`
/// — the overused purple/pink gradient pattern.
class GradientAbuseRule implements Rule {
  @override
  String get id => 'visual/gradient-abuse';

  @override
  RuleCategory get category => RuleCategory.visual;

  @override
  RuleSeverity get severity => RuleSeverity.info;

  @override
  Iterable<Finding> check(RuleCheckContext context) {
    final visitor = _Visitor(
      filePath: context.filePath,
      unit: context.unit,
      sourceText: context.sourceText,
    );
    context.unit.visitChildren(visitor);
    return visitor.findings;
  }
}

class _Visitor extends RecursiveAstVisitor<void> {
  final String filePath;
  final CompilationUnit unit;
  final String sourceText;
  final List<Finding> findings = [];

  _Visitor({
    required this.filePath,
    required this.unit,
    required this.sourceText,
  });

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.target == null && node.methodName.name == 'LinearGradient') {
      _checkGradient(node.argumentList, node.offset);
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final typeName = node.constructorName.type.name2.lexeme;
    if (typeName == 'LinearGradient') {
      _checkGradient(node.argumentList, node.offset);
    }
    super.visitInstanceCreationExpression(node);
  }

  void _checkGradient(ArgumentList argList, int offset) {
    for (final arg in argList.arguments) {
      if (arg is NamedExpression && arg.name.label.name == 'colors') {
        final argSource = sourceText.substring(arg.offset, arg.end);
        final hasPurple = argSource.contains('Colors.purple');
        final hasPink = argSource.contains('Colors.pink');
        if (hasPurple && hasPink) {
          final location = unit.lineInfo.getLocation(offset);
          findings.add(Finding(
            ruleId: 'visual/gradient-abuse',
            severity: RuleSeverity.info,
            message:
                'Purple-to-pink gradient detected. Consider a more distinctive palette.',
            filePath: filePath,
            line: location.lineNumber,
            column: location.columnNumber,
          ));
        }
      }
    }
  }
}
