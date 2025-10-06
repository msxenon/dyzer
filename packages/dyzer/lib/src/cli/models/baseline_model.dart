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
    final windowsContext = p.Context(style: p.Style.windows);
    final posixContext = p.Context(style: p.Style.posix);

    // 1. Split the Windows path into components.
    final pathComponents = windowsContext.split(path);

    // 2. Remove the first component if it's an empty string.
    // This handles the initial '\' which Windows treats as a root/separator,
    // but which results in an empty string at the beginning of the split list.
    if (pathComponents.isNotEmpty &&
        pathComponents.first == windowsContext.separator) {
      pathComponents.first = posixContext.separator;
    }

    // 3. Join the remaining components using the POSIX style.
    final normalizedPath = posixContext.joinAll(pathComponents);

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
