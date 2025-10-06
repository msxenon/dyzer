import 'package:equatable/equatable.dart';
import 'package:path/path.dart' as p;

import 'lint_file_model.dart';

class BaselineModel with EquatableMixin {
  final Map<String, LintFileModel> files;
  final DateTime createdAt;
  final String version;
  final int baselinedIssues;
  final int baselinedFiles;
  const BaselineModel({
    required this.createdAt,
    required this.baselinedIssues,
    required this.baselinedFiles,
    required this.version,
    required this.files,
  });

  factory BaselineModel.fromMap(Map<String, dynamic> json) => BaselineModel(
        createdAt: DateTime.parse(json['createdAt'] as String),
        baselinedIssues: json['baselinedIssues'] as int,
        baselinedFiles: json['baselinedFiles'] as int,
        version: json['version'] as String,
        files: Map<String, LintFileModel>.from(
          (json['files'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(
              key,
              LintFileModel.fromMap(value as Map<String, dynamic>),
            ),
          ),
        ),
      );

  Map<String, dynamic> toMap() => {
        'createdAt': createdAt.toIso8601String(),
        'baselinedIssues': baselinedIssues,
        'baselinedFiles': baselinedFiles,
        'version': version,
        'files': files.map((key, value) => MapEntry(key, value.toMap())),
      };

  BaselineModel copyWith({
    int? baselinedIssues,
    int? baselinedFiles,
  }) =>
      BaselineModel(
        files: files,
        createdAt: createdAt,
        version: version,
        baselinedIssues: baselinedIssues ?? this.baselinedIssues,
        baselinedFiles: baselinedFiles ?? this.baselinedFiles,
      );

  @override
  List<Object?> get props => [
        files,
        createdAt,
        version,
        baselinedIssues,
        baselinedFiles,
      ];

  static String normalizeBaselinePath(String path) {
    // Convert it into a POSIX path
    final normalizedPath = p.Context(style: p.Style.posix).joinAll(
      p.Context(style: p.Style.windows).split(path),
    );

    return normalizedPath;
  }

  void putFileIfAbsent(String path, LintFileModel Function() param1) {
    files.putIfAbsent(normalizeBaselinePath(path), param1);
  }

  bool containsPath(String filePath) =>
      files.containsKey(normalizeBaselinePath(filePath));

  LintFileModel? getLintFileModel(String filePath) =>
      files[normalizeBaselinePath(filePath)];

  void build() {
    files.removeWhere((_, lintFile) => lintFile.lints.isEmpty);
  }
}
