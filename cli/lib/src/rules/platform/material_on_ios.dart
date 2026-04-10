// cli/lib/src/rules/platform/material_on_ios.dart

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../rule.dart';

/// Flags Material widgets used inside `Platform.isIOS` conditional branches.
class MaterialOnIosRule implements Rule {
  static const _materialWidgets = {
    'ElevatedButton',
    'FilledButton',
    'MaterialButton',
    'FloatingActionButton',
  };

  @override
  String get id => 'platform/material-on-ios';

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
    if (conditionSource.contains('Platform.isIOS')) {
      final thenSource = node.thenStatement.toSource();
      for (final widget in MaterialOnIosRule._materialWidgets) {
        if (thenSource.contains(widget)) {
          final loc = unit.lineInfo.getLocation(node.offset);
          findings.add(Finding(
            ruleId: 'platform/material-on-ios',
            severity: RuleSeverity.info,
            message:
                'Material widget "$widget" used inside Platform.isIOS branch. '
                'Consider using a Cupertino or adaptive alternative.',
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
