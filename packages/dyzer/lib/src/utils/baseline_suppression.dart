import 'package:path/path.dart' as p;
import 'package:source_span/source_span.dart';

import '../cli/models/baseline_model.dart';
import '../cli/models/ignored_issue_model.dart';
import '../providers/baseline_model_reader.dart';

class BaselineSuppression {
  final String _rootNormalizedRootFolder;
  final String _rootFolder;
  final String content;
  BaselineModel? get baselineModel => BaselineReaderProvider()(_rootFolder);

  BaselineSuppression(String rootFolder, this.content)
      : _rootNormalizedRootFolder =
            BaselineModel.pathContext.joinAll(p.split(rootFolder)),
        _rootFolder = rootFolder;

  bool isSuppressed(String ruleId, String path) {
    if (baselineModel == null) {
      return false;
    }
    final file = baselineModel!
        .getLintFileModel(fullToBaselineFriendlyPath(Uri.parse(path)));
    final allRules = file?.lints.keys;
    if (allRules == null) {
      return false;
    }

    return allRules.contains(ruleId);
  }

  bool isSuppressedAt(
    SourceLocation start,
    SourceLocation end, {
    required String ruleId,
    required int indexInFile,
  }) {
    if (baselineModel == null) {
      return false;
    }
    final pathUri = start.sourceUrl;
    if (pathUri == null) {
      return false;
    }
    final filePath = fullToBaselineFriendlyPath(pathUri);

    final fromIssueLintDetails = IgnoredIssueModel.fromIssue(
      start: start,
      end: end,
      content: content,
      indexInFile: indexInFile,
    );

    if (baselineModel!.containsPath(filePath)) {
      final fileSuppression = baselineModel!.getLintFileModel(filePath);

      if (fileSuppression!.lints.keys.contains(ruleId)) {
        final lintDetails = fileSuppression.lints[ruleId]!;

        var result = false;
        for (final lintDetail in lintDetails) {
          if (fromIssueLintDetails == lintDetail) {
            result = true;
            break;
          }
        }

        return result;
      }
    }

    return false;
  }

  String fullToBaselineFriendlyPath(Uri filePath) {
    // Normalize both paths to handle separators
    final normalizedFilePath = p.normalize(filePath.toFilePath());
    final normalizedRoot = p.normalize(_rootNormalizedRootFolder);

    // Get the relative path
    final relativePath = p.relative(normalizedFilePath, from: normalizedRoot);

    // Ensure POSIX-style slashes
    var expectedTrimmedPath = p.posix.joinAll(p.split(relativePath));
    final posixSeparator = p.posix.separator;
    // Add leading slash if missing
    if (!expectedTrimmedPath.startsWith(posixSeparator)) {
      expectedTrimmedPath = '$posixSeparator$expectedTrimmedPath';
    }

    return expectedTrimmedPath;
  }
}
