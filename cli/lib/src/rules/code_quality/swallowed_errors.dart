// cli/lib/src/rules/code_quality/swallowed_errors.dart

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../rule.dart';

/// Flags `catch (...) { }` blocks with no body — errors are silently
/// swallowed, hiding bugs and making debugging impossible.
class SwallowedErrorsRule implements Rule {
  @override
  String get id => 'code-quality/swallowed-errors';

  @override
  RuleCategory get category => RuleCategory.codeQuality;

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
  void visitCatchClause(CatchClause node) {
    final body = node.body;
    if (body.statements.isEmpty) {
      final loc = unit.lineInfo.getLocation(node.offset);
      findings.add(Finding(
        ruleId: 'code-quality/swallowed-errors',
        severity: RuleSeverity.warning,
        message:
            'Empty catch block swallows the error. At least log it with debugPrint().',
        filePath: filePath,
        line: loc.lineNumber,
        column: loc.columnNumber,
      ));
    }
    super.visitCatchClause(node);
  }
}
