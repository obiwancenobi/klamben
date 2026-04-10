// cli/lib/src/rules/layout/magic_numbers.dart

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../rule.dart';

/// Detects EdgeInsets values that are not on the standard 4/8pt spacing grid.
class MagicNumbersRule implements Rule {
  @override
  String get id => 'layout/magic-numbers';

  @override
  RuleCategory get category => RuleCategory.layout;

  @override
  RuleSeverity get severity => RuleSeverity.info;

  static const _allowedValues = <num>{
    0,
    2,
    4,
    6,
    8,
    12,
    16,
    20,
    24,
    32,
    40,
    48,
    56,
    64,
    80,
    96,
    120,
  };

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
    // Match EdgeInsets.all(...), EdgeInsets.symmetric(...), EdgeInsets.only(...)
    final target = node.target;
    if (target is SimpleIdentifier && target.name == 'EdgeInsets') {
      final method = node.methodName.name;
      if (method == 'all') {
        // Check first positional arg
        for (final arg in node.argumentList.arguments) {
          if (arg is! NamedExpression) {
            _checkLiteral(arg, node.offset);
          }
        }
      } else if (method == 'symmetric' || method == 'only') {
        // Check named args
        for (final arg in node.argumentList.arguments) {
          if (arg is NamedExpression) {
            _checkLiteral(arg.expression, node.offset);
          }
        }
      }
    }
    super.visitMethodInvocation(node);
  }

  void _checkLiteral(Expression expr, int reportOffset) {
    num? value;
    if (expr is IntegerLiteral) {
      value = expr.value;
    } else if (expr is DoubleLiteral) {
      value = expr.value;
    }
    if (value != null && !MagicNumbersRule._allowedValues.contains(value)) {
      final loc = unit.lineInfo.getLocation(reportOffset);
      findings.add(Finding(
        ruleId: 'layout/magic-numbers',
        severity: RuleSeverity.info,
        message:
            'EdgeInsets value $value is not on the 4/8pt grid — use a design-system spacing constant.',
        filePath: filePath,
        line: loc.lineNumber,
        column: loc.columnNumber,
      ));
    }
  }
}
