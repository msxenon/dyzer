import 'lint_file_model.dart';

class BaselineModel {
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
}
