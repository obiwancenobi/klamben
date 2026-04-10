// cli/lib/src/rules/platform/cupertino_on_android.dart

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../rule.dart';

/// Flags Cupertino widgets used inside `Platform.isAndroid` conditional branches.
class CupertinoOnAndroidRule implements Rule {
  static const _cupertinoWidgets = {
    'CupertinoButton',
    'CupertinoAlertDialog',
    'CupertinoNavigationBar',
    'CupertinoTextField',
  };

  @override
  String get id => 'platform/cupertino-on-android';

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
    return visitor.findings;
  }
}

class _Visitor extends RecursiveAstVisitor<void> {
  final String filePath;
  final CompilationUnit unit;
  final List<Finding> findings = [];

  _Visitor({required this.filePath, required this.unit});

  @override
  void visitIfStatement(IfStatement node) {
    final conditionSource = node.expression.toSource();
    if (conditionSource.contains('Platform.isAndroid')) {
      final thenSource = node.thenStatement.toSource();
      for (final widget in CupertinoOnAndroidRule._cupertinoWidgets) {
        if (thenSource.contains(widget)) {
          final loc = unit.lineInfo.getLocation(node.offset);
          findings.add(Finding(
            ruleId: 'platform/cupertino-on-android',
            severity: RuleSeverity.info,
            message:
                'Cupertino widget "$widget" used inside Platform.isAndroid '
                'branch. Consider using a Material or adaptive alternative.',
            filePath: filePath,
            line: loc.lineNumber,
            column: loc.columnNumber,
          ));
        }
      }
    }
    super.visitIfStatement(node);
  }
}
