// cli/lib/src/rules/code_quality/missing_const.dart

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../rule.dart';

/// Best-effort detection of widget constructors like `Text('literal')` that
/// could be `const` but aren't. Only flags calls where all arguments are
/// simple literals and the call is not already in a const context.
class MissingConstRule implements Rule {
  @override
  String get id => 'code-quality/missing-const';

  @override
  RuleCategory get category => RuleCategory.codeQuality;

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

/// Widget names we check for const-eligibility.
const _constEligibleWidgets = {'Text', 'SizedBox', 'Icon', 'Padding'};

bool _isInConstContext(AstNode node) {
  AstNode? current = node.parent;
  while (current != null) {
    if (current is InstanceCreationExpression && current.isConst) return true;
    if (current is ListLiteral && current.constKeyword != null) return true;
    if (current is SetOrMapLiteral && current.constKeyword != null) return true;
    current = current.parent;
  }
  return false;
}

bool _allArgsAreLiterals(ArgumentList args) {
  for (final arg in args.arguments) {
    final expr = arg is NamedExpression ? arg.expression : arg;
    if (expr is! IntegerLiteral &&
        expr is! DoubleLiteral &&
        expr is! SimpleStringLiteral &&
        expr is! BooleanLiteral &&
        expr is! NullLiteral) {
      return false;
    }
  }
  return true;
}

class _Visitor extends RecursiveAstVisitor<void> {
  final String filePath;
  final CompilationUnit unit;
  final List<Finding> findings = [];

  _Visitor({required this.filePath, required this.unit});

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final name = node.methodName.name;
    if (_constEligibleWidgets.contains(name) &&
        !_isInConstContext(node) &&
        node.argumentList.arguments.isNotEmpty &&
        _allArgsAreLiterals(node.argumentList)) {
      _flag(node.offset, name);
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final name = node.constructorName.type.name2.lexeme;
    if (_constEligibleWidgets.contains(name) &&
        !node.isConst &&
        !_isInConstContext(node) &&
        node.argumentList.arguments.isNotEmpty &&
        _allArgsAreLiterals(node.argumentList)) {
      _flag(node.offset, name);
    }
    super.visitInstanceCreationExpression(node);
  }

  void _flag(int offset, String widgetName) {
    final loc = unit.lineInfo.getLocation(offset);
    findings.add(Finding(
      ruleId: 'code-quality/missing-const',
      severity: RuleSeverity.info,
      message: '$widgetName with all-literal args could be const.',
      filePath: filePath,
      line: loc.lineNumber,
      column: loc.columnNumber,
    ));
  }
}
