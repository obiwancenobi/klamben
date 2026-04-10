// cli/lib/src/rules/code_quality/missing_dispose.dart

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../rule.dart';

/// Flags State subclasses that declare fields with type names ending in
/// `Controller` but do not override `dispose()`.
class MissingDisposeRule implements Rule {
  @override
  String get id => 'code-quality/missing-dispose';

  @override
  RuleCategory get category => RuleCategory.codeQuality;

  @override
  RuleSeverity get severity => RuleSeverity.error;

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
  void visitClassDeclaration(ClassDeclaration node) {
    // Check if this class extends State (or State<...>).
    final extendsClause = node.extendsClause;
    if (extendsClause == null) {
      super.visitClassDeclaration(node);
      return;
    }

    final superName = extendsClause.superclass.name2.lexeme;
    if (superName != 'State') {
      super.visitClassDeclaration(node);
      return;
    }

    // Collect fields whose type name ends with "Controller".
    final controllerFields = <String>[];
    for (final member in node.members) {
      if (member is FieldDeclaration) {
        final typeName = member.fields.type?.toSource() ?? '';
        if (typeName.endsWith('Controller')) {
          for (final v in member.fields.variables) {
            controllerFields.add(v.name.lexeme);
          }
        }
      }
    }

    if (controllerFields.isEmpty) {
      super.visitClassDeclaration(node);
      return;
    }

    // Check if there is a dispose() method.
    final hasDispose = node.members.any(
      (m) => m is MethodDeclaration && m.name.lexeme == 'dispose',
    );

    if (!hasDispose) {
      final loc = unit.lineInfo.getLocation(node.offset);
      findings.add(Finding(
        ruleId: 'code-quality/missing-dispose',
        severity: RuleSeverity.error,
        message: '${node.name.lexeme} has controller field(s) '
            '(${controllerFields.join(', ')}) but no dispose() override.',
        filePath: filePath,
        line: loc.lineNumber,
        column: loc.columnNumber,
      ));
    }

    super.visitClassDeclaration(node);
  }
}
