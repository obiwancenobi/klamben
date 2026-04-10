// cli/lib/src/rules/code_quality/setstate_after_async.dart

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../rule.dart';

/// Flags `setState(...)` called after an `await` without an intervening
/// `mounted` guard — a common source of "setState() called after dispose()"
/// crashes.
class SetStateAfterAsyncRule implements Rule {
  @override
  String get id => 'code-quality/setstate-after-async';

  @override
  RuleCategory get category => RuleCategory.codeQuality;

  @override
  RuleSeverity get severity => RuleSeverity.error;

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
  void visitMethodDeclaration(MethodDeclaration node) {
    // Only check async methods.
    if (node.body is! BlockFunctionBody) {
      super.visitMethodDeclaration(node);
      return;
    }
    final body = node.body as BlockFunctionBody;
    if (!(body.keyword?.lexeme.contains('async') ?? false)) {
      super.visitMethodDeclaration(node);
      return;
    }

    // Simple text-based approach: get the method body source and check
    // for `await` followed by `setState` without `mounted` between them.
    final bodySource = sourceText.substring(body.offset, body.end);

    final awaitPattern = RegExp(r'\bawait\b');
    final setStatePattern = RegExp(r'\bsetState\b');
    final mountedPattern = RegExp(r'\bmounted\b');

    final awaitMatch = awaitPattern.firstMatch(bodySource);
    if (awaitMatch == null) {
      super.visitMethodDeclaration(node);
      return;
    }

    // Look for setState after the first await.
    final afterAwait = bodySource.substring(awaitMatch.end);
    final setStateMatch = setStatePattern.firstMatch(afterAwait);
    if (setStateMatch == null) {
      super.visitMethodDeclaration(node);
      return;
    }

    // Check if "mounted" appears between await and setState.
    final between = afterAwait.substring(0, setStateMatch.start);
    if (mountedPattern.hasMatch(between)) {
      super.visitMethodDeclaration(node);
      return;
    }

    // Flag at the setState location.
    final setStateOffset = body.offset + awaitMatch.end + setStateMatch.start;
    final loc = unit.lineInfo.getLocation(setStateOffset);
    findings.add(Finding(
      ruleId: 'code-quality/setstate-after-async',
      severity: RuleSeverity.error,
      message: 'setState() called after await without a mounted check. '
          'Add `if (!mounted) return;` before setState.',
      filePath: filePath,
      line: loc.lineNumber,
      column: loc.columnNumber,
    ));

    super.visitMethodDeclaration(node);
  }
}
