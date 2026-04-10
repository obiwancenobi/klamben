// cli/lib/src/rules/code_quality/missing_key.dart

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../rule.dart';

/// Flags `.map((...) => Widget(...)).toList()` patterns where the widget
/// constructor inside the map callback is missing a `key:` named argument.
class MissingKeyRule implements Rule {
  @override
  String get id => 'code-quality/missing-key';

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

/// Common widget names to detect in map callbacks.
const _widgetNames = {
  'Text',
  'Container',
  'Card',
  'ListTile',
  'Row',
  'Column',
  'Padding',
  'SizedBox',
  'Icon',
  'IconButton',
  'TextButton',
  'ElevatedButton',
  'GestureDetector',
  'InkWell',
  'Expanded',
  'Flexible',
  'Scaffold',
  'AppBar',
  'Wrap',
  'Stack',
  'Positioned',
  'Center',
  'Align',
  'Opacity',
  'ClipRRect',
  'DecoratedBox',
  'AnimatedContainer',
};

bool _hasKeyArg(ArgumentList args) {
  return args.arguments.any(
    (a) => a is NamedExpression && a.name.label.name == 'key',
  );
}

class _Visitor extends RecursiveAstVisitor<void> {
  final String filePath;
  final CompilationUnit unit;
  final List<Finding> findings = [];

  _Visitor({required this.filePath, required this.unit});

  @override
  void visitMethodInvocation(MethodInvocation node) {
    // Look for .toList() whose target is .map(...)
    if (node.methodName.name == 'toList' && node.target is MethodInvocation) {
      final mapCall = node.target! as MethodInvocation;
      if (mapCall.methodName.name == 'map' &&
          mapCall.argumentList.arguments.isNotEmpty) {
        _checkMapBody(mapCall);
      }
    }
    super.visitMethodInvocation(node);
  }

  void _checkMapBody(MethodInvocation mapCall) {
    final arg = mapCall.argumentList.arguments.first;
    Expression? body;

    if (arg is FunctionExpression) {
      body = _extractReturnExpression(arg.body);
    }

    if (body == null) return;

    // Check if the returned expression is a widget constructor call.
    _checkWidgetCall(body);
  }

  Expression? _extractReturnExpression(FunctionBody body) {
    if (body is ExpressionFunctionBody) {
      return body.expression;
    }
    if (body is BlockFunctionBody) {
      // Check last statement for a return.
      final stmts = body.block.statements;
      if (stmts.isNotEmpty && stmts.last is ReturnStatement) {
        return (stmts.last as ReturnStatement).expression;
      }
    }
    return null;
  }

  void _checkWidgetCall(Expression expr) {
    String? name;
    ArgumentList? args;
    int? offset;

    if (expr is MethodInvocation &&
        _widgetNames.contains(expr.methodName.name)) {
      name = expr.methodName.name;
      args = expr.argumentList;
      offset = expr.offset;
    } else if (expr is InstanceCreationExpression) {
      final typeName = expr.constructorName.type.name2.lexeme;
      if (_widgetNames.contains(typeName)) {
        name = typeName;
        args = expr.argumentList;
        offset = expr.offset;
      }
    }

    if (name != null && args != null && offset != null && !_hasKeyArg(args)) {
      final loc = unit.lineInfo.getLocation(offset);
      findings.add(Finding(
        ruleId: 'code-quality/missing-key',
        severity: RuleSeverity.info,
        message: '$name in .map().toList() is missing a key: argument. '
            'Add a unique key for efficient list reconciliation.',
        filePath: filePath,
        line: loc.lineNumber,
        column: loc.columnNumber,
      ));
    }
  }
}
