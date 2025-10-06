// ignore_for_file: inference_failure_on_collection_literal

import 'dart:collection';

import 'package:dyzer/src/cli/models/baseline_model.dart';
import 'package:dyzer/src/cli/models/ignored_issue_model.dart';
import 'package:dyzer/src/cli/models/lint_file_model.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('BaselineModel', () {
    test('fromMap() should parse correctly', () {
      final baselineV1Data = {
        'files': {
          'lib/second_path.dart': {
            'second_lint': [
              'second_path_second_lint_hash_1',
              'second_path_second_lint_hash_2',
            ],
            'first_lint': ['second_path_first_lint_hash_3'],
          },
          'lib/first_path.dart': {
            'first_lint': [
              'first_path_first_lint_hash_4',
              'first_path_first_lint_hash_5',
            ],
          },
        },
        'createdAt': '2025-08-11T14:51:39.850445Z',
        'version': '1',
        'baselinedIssues': 5,
        'baselinedFiles': 2,
      };

      final baselineModelMapped = BaselineModel.fromMap(baselineV1Data);
      expect(baselineModelMapped.toMap(), baselineV1Data);
      expect(
        baselineModelMapped,
        BaselineModel(
          files: {
            'lib/first_path.dart': LintFileModel(lints: {
              'first_lint': {
                const IgnoredIssueModel('first_path_first_lint_hash_4'),
                const IgnoredIssueModel('first_path_first_lint_hash_5'),
              },
            }),
            'lib/second_path.dart': LintFileModel(lints: {
              'first_lint': {
                const IgnoredIssueModel('second_path_first_lint_hash_3'),
              },
              'second_lint': {
                const IgnoredIssueModel('second_path_second_lint_hash_1'),
                const IgnoredIssueModel('second_path_second_lint_hash_2'),
              },
            }),
          },
          createdAt: DateTime.parse('2025-08-11T14:51:39.850445Z'),
          version: '1',
          baselinedFiles: 2,
          baselinedIssues: 5,
        ),
      );
    });

    test('should not equal', () {
      final model1 = BaselineModel(
        files: SplayTreeMap.from({
          'lib/first_path.dart': LintFileModel(
            lints: SplayTreeMap.from({
              'first_lint': {
                const IgnoredIssueModel('first_path_first_lint_hash_4'),
                const IgnoredIssueModel('first_path_first_lint_hash_5'),
              },
            }),
          ),
          'lib/second_path.dart': LintFileModel(
            lints: {
              'first_lint': {
                const IgnoredIssueModel('second_path_first_lint_hash_3'),
              },
              'second_lint': {
                const IgnoredIssueModel('second_path_second_lint_hash_1'),
                const IgnoredIssueModel('second_path_second_lint_hash_2'),
              },
            },
          ),
        }),
        createdAt: DateTime.parse('2025-08-11T14:51:39.850445Z'),
        version: '1',
        baselinedFiles: 2,
        baselinedIssues: 5,
      );

      final model2 = BaselineModel(
        files: {
          'lib/first_path.dart': LintFileModel(
            lints: {
              'first_lint': {
                const IgnoredIssueModel('first_path_first_lint_hash_4'),
                const IgnoredIssueModel('first_path_first_lint_hash_5'),
              },
            },
          ),
          'lib/second_path.dart': LintFileModel(
            lints: {
              'first_lint': {
                const IgnoredIssueModel('second_path_first_lint_hash_3'),
              },
              'second_lint': {
                const IgnoredIssueModel('second_path_second_lint_hash_1'),
                const IgnoredIssueModel(
                  'second_path_second_lint_hash_22',
                ), // Different hash to ensure inequality
              },
            },
          ),
        },
        createdAt: DateTime.parse('2025-08-11T14:51:39.850445Z'),
        version: '1',
        baselinedFiles: 2,
        baselinedIssues: 5,
      );

      expect(model1, isNot(equals(model2)));
    });
  });

  group('paths', () {
    test('paths should be normalized', () {
      final differentPathTypes = [
        p.Context(style: p.Style.windows)
            .join(r'\directory', 'fileWindows.dart'),
        p.Context(style: p.Style.posix).join('/directory', 'filePosix.dart'),
      ];
      final baselineModel = BaselineModel(
        files: SplayTreeMap<String, LintFileModel>(),
        createdAt: DateTime.parse('2025-08-11T14:51:39.850445Z'),
        version: '1',
        baselinedFiles: 0,
        baselinedIssues: 0,
      );
      for (final path in differentPathTypes) {
        // Normalize it as a Windows path first

        baselineModel.putFileIfAbsent(
          path,
          () => LintFileModel.fromIssues(
            [],
            '',
          ),
        );
      }
      expect(
        baselineModel.toMap(),
        {
          'createdAt': '2025-08-11T14:51:39.850445Z',
          'baselinedIssues': 0,
          'baselinedFiles': 0,
          'version': '1',
          'files': {
            '/directory/filePosix.dart': {},
            '/directory/fileWindows.dart': {},
          },
        },
      );
    });
  });
}
