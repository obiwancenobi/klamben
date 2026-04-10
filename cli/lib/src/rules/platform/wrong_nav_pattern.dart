// cli/lib/src/rules/platform/wrong_nav_pattern.dart

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../rule.dart';

/// Flags `BottomNavigationBar` usage without a corresponding `CupertinoTabBar`
/// or `CupertinoTabScaffold` anywhere in the same file.
class WrongNavPatternRule implements Rule {
  @override
  String get id => 'platform/wrong-nav-pattern';

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

    // If BottomNavigationBar was found but no CupertinoTabBar/CupertinoTabScaffold
    // exists in the file, flag each occurrence.
    if (visitor.bottomNavFindings.isNotEmpty &&
        !context.sourceText.contains('CupertinoTabBar') &&
        !context.sourceText.contains('CupertinoTabScaffold')) {
      return visitor.bottomNavFindings;
    }
    return const [];
  }
}

class _Visitor extends RecursiveAstVisitor<void> {
  final String filePath;
  final CompilationUnit unit;
  final List<Finding> bottomNavFindings = [];

  _Visitor({required this.filePath, required this.unit});

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final typeName = node.constructorName.type.name2.lexeme;
    if (typeName == 'BottomNavigationBar') {
      _report(node.offset);
    }
    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.target == null && node.methodName.name == 'BottomNavigationBar') {
      _report(node.offset);
    }
    super.visitMethodInvocation(node);
  }

  void _report(int offset) {
    final loc = unit.lineInfo.getLocation(offset);
    bottomNavFindings.add(Finding(
      ruleId: 'platform/wrong-nav-pattern',
      severity: RuleSeverity.info,
      message:
          'BottomNavigationBar without CupertinoTabBar. Consider providing '
          'a platform-adaptive navigation pattern.',
      filePath: filePath,
      line: loc.lineNumber,
      column: loc.columnNumber,
    ));
  }
}
