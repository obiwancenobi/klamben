// cli/lib/src/walker.dart
//
// Parses .dart files into CompilationUnit using package:analyzer's
// unresolved parser (no Dart SDK resolution, so it's fast and works
// offline without a project pubspec).

import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

class ParsedFile {
  final String filePath;
  final CompilationUnit unit;
  final String sourceText;
  const ParsedFile({
    required this.filePath,
    required this.unit,
    required this.sourceText,
  });
}

/// Walk `rootPath` (file or directory) and yield parsed .dart files.
/// Directories are traversed recursively; generated files (`.g.dart`,
/// `.freezed.dart`, etc.) are skipped.
Iterable<ParsedFile> walkDartFiles(String rootPath) sync* {
  final entity = FileSystemEntity.typeSync(rootPath);
  if (entity == FileSystemEntityType.file) {
    final parsed = _parseOrNull(rootPath);
    if (parsed != null) yield parsed;
    return;
  }
  if (entity == FileSystemEntityType.directory) {
    final dir = Directory(rootPath);
    for (final e in dir.listSync(recursive: true, followLinks: false)) {
      if (e is! File) continue;
      if (!e.path.endsWith('.dart')) continue;
      if (_isGenerated(e.path)) continue;
      final parsed = _parseOrNull(e.path);
      if (parsed != null) yield parsed;
    }
  }
}

bool _isGenerated(String path) {
  final name = p.basename(path);
  return name.endsWith('.g.dart') ||
      name.endsWith('.freezed.dart') ||
      name.endsWith('.gr.dart') ||
      name.endsWith('.config.dart');
}

ParsedFile? _parseOrNull(String path) {
  try {
    final source = File(path).readAsStringSync();
    final result = parseString(
      content: source,
      path: path,
      throwIfDiagnostics: false,
      featureSet: FeatureSet.latestLanguageVersion(),
    );
    return ParsedFile(
      filePath: path,
      unit: result.unit,
      sourceText: source,
    );
  } on Object {
    return null;
  }
}
