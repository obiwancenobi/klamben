// cli/lib/src/reporter/report_data.dart

import 'dart:math';

import '../rules/rule.dart';
import '../rules/rule_metadata.dart';

class RuleHit {
  final String ruleId;
  final String title;
  final String severity;
  final String category;
  final int count;

  const RuleHit({
    required this.ruleId,
    required this.title,
    required this.severity,
    required this.category,
    required this.count,
  });

  Map<String, dynamic> toJson() => {
        'ruleId': ruleId,
        'title': title,
        'severity': severity,
        'category': category,
        'count': count,
      };
}

class Recommendation {
  final String ruleId;
  final String title;
  final String fixHint;
  final int count;
  final String severity;

  const Recommendation({
    required this.ruleId,
    required this.title,
    required this.fixHint,
    required this.count,
    required this.severity,
  });

  Map<String, dynamic> toJson() => {
        'ruleId': ruleId,
        'title': title,
        'fixHint': fixHint,
        'count': count,
        'severity': severity,
      };
}

class ReportData {
  final DateTime generatedAt;
  final String scannedPath;
  final int totalFiles;
  final int totalFindings;
  final Map<String, int> bySeverity;
  final Map<String, int> byCategory;
  final Map<String, List<Map<String, dynamic>>> byFile;
  final List<RuleHit> topRules;
  final int healthScore;
  final int totalRules;
  final int triggeredRules;
  final List<Recommendation> recommendations;

  const ReportData({
    required this.generatedAt,
    required this.scannedPath,
    required this.totalFiles,
    required this.totalFindings,
    required this.bySeverity,
    required this.byCategory,
    required this.byFile,
    required this.topRules,
    required this.healthScore,
    required this.totalRules,
    required this.triggeredRules,
    required this.recommendations,
  });

  factory ReportData.fromFindings(
    List<Finding> findings, {
    required String scannedPath,
    required int totalFiles,
    required int totalRules,
    RuleCatalog? catalog,
  }) {
    final errors =
        findings.where((f) => f.severity == RuleSeverity.error).length;
    final warnings =
        findings.where((f) => f.severity == RuleSeverity.warning).length;
    final infos =
        findings.where((f) => f.severity == RuleSeverity.info).length;

    final bySeverity = <String, int>{
      'error': errors,
      'warning': warnings,
      'info': infos,
    };

    // Group by category using rule ID prefix.
    final byCategory = <String, int>{};
    for (final f in findings) {
      final cat = f.ruleId.split('/').first;
      byCategory[cat] = (byCategory[cat] ?? 0) + 1;
    }

    // Group by file as serializable maps.
    final byFile = <String, List<Map<String, dynamic>>>{};
    for (final f in findings) {
      byFile.putIfAbsent(f.filePath, () => []).add({
        'ruleId': f.ruleId,
        'severity': f.severity.name,
        'message': f.message,
        'line': f.line,
        'column': f.column,
      });
    }

    // Count hits per rule.
    final ruleCounts = <String, int>{};
    for (final f in findings) {
      ruleCounts[f.ruleId] = (ruleCounts[f.ruleId] ?? 0) + 1;
    }

    final topRules = ruleCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topRuleHits = topRules.map((e) {
      final meta = catalog?.byId[e.key];
      final parts = e.key.split('/');
      return RuleHit(
        ruleId: e.key,
        title: meta?.title ?? e.key,
        severity: meta?.severity.name ?? 'info',
        category: parts.isNotEmpty ? parts.first : 'unknown',
        count: e.value,
      );
    }).toList();

    // Build recommendations from top rules (max 5).
    final recommendations = <Recommendation>[];
    if (catalog != null) {
      for (final hit in topRuleHits.take(5)) {
        final meta = catalog.byId[hit.ruleId];
        if (meta != null && meta.fixHint.isNotEmpty) {
          recommendations.add(Recommendation(
            ruleId: hit.ruleId,
            title: meta.title,
            fixHint: meta.fixHint,
            count: hit.count,
            severity: meta.severity.name,
          ));
        }
      }
    }

    final healthScore = max(0, 100 - (errors * 10 + warnings * 3 + infos * 1));

    return ReportData(
      generatedAt: DateTime.now(),
      scannedPath: scannedPath,
      totalFiles: totalFiles,
      totalFindings: findings.length,
      bySeverity: bySeverity,
      byCategory: byCategory,
      byFile: byFile,
      topRules: topRuleHits,
      healthScore: healthScore,
      totalRules: totalRules,
      triggeredRules: ruleCounts.length,
      recommendations: recommendations,
    );
  }

  Map<String, dynamic> toJson() => {
        'generatedAt': generatedAt.toIso8601String(),
        'scannedPath': scannedPath,
        'totalFiles': totalFiles,
        'totalFindings': totalFindings,
        'bySeverity': bySeverity,
        'byCategory': byCategory,
        'byFile': byFile,
        'topRules': topRules.map((r) => r.toJson()).toList(),
        'healthScore': healthScore,
        'totalRules': totalRules,
        'triggeredRules': triggeredRules,
        'recommendations': recommendations.map((r) => r.toJson()).toList(),
      };
}
