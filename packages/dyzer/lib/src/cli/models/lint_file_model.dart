import 'dart:collection';

import '../../../lint_analyzer.dart';
import 'ignored_issue_model.dart';

class LintFileModel {
  // The key is the path to the file being linted.
  final Map<String, Set<IgnoredIssueModel>> lints;
  const LintFileModel({required this.lints});

  factory LintFileModel.fromIssues(Iterable<Issue> issues, String content) {
    final rules = SplayTreeMap<String, Set<IgnoredIssueModel>>();

    for (final issue in issues) {
      final ruleName = issue.ruleId;
      final ignoredIssue = IgnoredIssueModel.fromIssue(
        start: issue.location.start,
        end: issue.location.end,
        content: content,
        indexInFile: issue.codeIndex,
      );

      if (!rules.containsKey(ruleName)) {
        rules[ruleName] = {};
      }

      rules[ruleName]!.add(ignoredIssue);
    }

    return LintFileModel(lints: rules);
  }

  factory LintFileModel.fromMap(Map<String, dynamic> json) {
    final lints = json.map(
      (key, value) => MapEntry(
        key,
        (value as List<dynamic>)
            .map((item) => IgnoredIssueModel.fromMap(item as String))
            .toSet(),
      ),
    );

    return LintFileModel(lints: lints);
  }

  Map<String, dynamic> toMap() => lints.map((key, value) => MapEntry(
        key,
        value.map((item) => item.toJson()).toList(),
      ));
}
