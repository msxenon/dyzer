import 'package:source_span/source_span.dart';

import '../cli/models/baseline_model.dart';
import '../cli/models/ignored_issue_model.dart';
import '../providers/baseline_model_reader.dart';

class BaselineSuppression {
  final String _rootFolder;
  final String content;
  BaselineModel? get baselineModel => BaselineReaderProvider()(_rootFolder);
  BaselineSuppression(this._rootFolder, this.content);

  bool isSuppressed(String ruleId, String path) {
    if (baselineModel == null) {
      return false;
    }
    final file = baselineModel!.files[_filePathTrimmer(path)];
    final allRules = file?.lints.keys;
    if (allRules == null) {
      return false;
    }

    return allRules.contains(ruleId);
  }

  String _filePathTrimmer(String filePath) => filePath.split(_rootFolder).elementAtOrNull(1) ?? filePath;

  bool isSuppressedAt(
    SourceLocation start,
    SourceLocation end, {
    required String ruleId,
    required int indexInFile,
  }) {
    if (baselineModel == null) {
      return false;
    }
    final filePath = _filePathTrimmer(start.sourceUrl.toString());

    final fromIssueLintDetails = IgnoredIssueModel.fromIssue(
      start: start,
      end: end,
      content: content,
      indexInFile: indexInFile,
    );

    final files = baselineModel!.files;
    if (files.containsKey(filePath)) {
      final fileSuppression = files[filePath]!;

      if (fileSuppression.lints.keys.contains(ruleId)) {
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
}
