import 'dart:io';

import 'package:dyzer/lint_analyzer.dart';
import 'package:dyzer/src/analyzers/lint_analyzer/rules/rules_list/prefer_first_or_null/prefer_first_or_null_rule.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../../../stubs_builders.dart';

void main() {
  group(
    'LintAnalyzer',
    () {
      const analyzer = LintAnalyzer(null, skipBaseline: false);
      const rootDirectory = '';
      final folders = [
        p.normalize(File('test/resources/lint_analyzer').absolute.path),
      ];

      test('should analyze files', () async {
        final config = _createConfig();

        final result = await analyzer.runCliAnalysis(
          folders,
          rootDirectory,
          config,
        );

        expect(result, hasLength(4));
      });

      test('should analyze only one file', () async {
        final config = _createConfig(
          excludePatterns: ['test/resources/**/*_exclude_example.dart'],
        );

        final result = await analyzer.runCliAnalysis(
          folders,
          rootDirectory,
          config,
        );

        expect(result, hasLength(3));
      });

      test('should report default code metrics', () async {
        final config = _createConfig();

        final result = await analyzer.runCliAnalysis(
          folders,
          rootDirectory,
          config,
        );

        final report =
            reportForFile(result, 'lint_analyzer_exclude_example.dart')
                .functions
                .values
                .first;
        final metrics = {for (final m in report.metrics) m.metricsId: m.level};

        expect(metrics, {
          'cyclomatic-complexity': MetricValueLevel.none,
          'halstead-volume': MetricValueLevel.none,
          'lines-of-code': MetricValueLevel.none,
          'maximum-nesting-level': MetricValueLevel.none,
          'number-of-parameters': MetricValueLevel.none,
          'source-lines-of-code': MetricValueLevel.none,
          'maintainability-index': MetricValueLevel.none,
        });
      });

      test('should exceed lines-of-code metric', () async {
        final config = _createConfig(metrics: {'lines-of-code': 8});

        final result = await analyzer.runCliAnalysis(
          folders,
          rootDirectory,
          config,
        );

        final report =
            reportForFile(result, 'lint_analyzer_exclude_example.dart')
                .functions
                .values
                .first;
        final metrics = {for (final m in report.metrics) m.metricsId: m.level};

        expect(metrics, {
          'cyclomatic-complexity': MetricValueLevel.none,
          'halstead-volume': MetricValueLevel.none,
          'lines-of-code': MetricValueLevel.warning,
          'maximum-nesting-level': MetricValueLevel.none,
          'number-of-parameters': MetricValueLevel.none,
          'source-lines-of-code': MetricValueLevel.none,
          'maintainability-index': MetricValueLevel.none,
        });
      });

      test('should not report metrics', () async {
        final config = _createConfig(
          excludeForMetricsPatterns: ['test/**'],
        );

        final result = await analyzer.runCliAnalysis(
          folders,
          rootDirectory,
          config,
        );

        final report =
            reportForFile(result, 'lint_analyzer_exclude_example.dart')
                .functions
                .values;

        expect(report, isEmpty);
      });

      test('should report no-magic-number rule', () async {
        final config = _createConfig(rules: {'no-magic-number': {}});

        final result = await analyzer.runCliAnalysis(
          folders,
          rootDirectory,
          config,
        );

        final issues =
            reportForFile(result, 'lint_analyzer_exclude_example.dart').issues;

        expect(
          issues.map((issue) => issue.ruleId),
          equals(['no-magic-number', 'no-magic-number']),
        );
      });

      test('should not report rules', () async {
        final config = _createConfig(
          rules: {'avoid-late-keyword': {}},
          excludeForRulesPatterns: ['test/**'],
        );

        final result = await analyzer.runCliAnalysis(
          folders,
          rootDirectory,
          config,
        );

        final report =
            reportForFile(result, 'lint_analyzer_exclude_example.dart').issues;
        expect(report, isEmpty);
      });

      test('collect summary for passed empty report', () {
        final result = analyzer.getSummary([]);

        expect(
          result.firstWhere((r) => r.title == 'Scanned folders').value,
          isEmpty,
        );

        expect(
          result.firstWhere((r) => r.title == 'Total scanned files').value,
          isZero,
        );

        expect(
          result.firstWhere((r) => r.title == 'Total tech debt').value,
          equals('not found'),
        );
      });

      test('collect summary for passed report', () {
        final result = analyzer.getSummary([
          LintFileReport(
            path: '/home/dev/project/bin/example.dart',
            relativePath: 'bin/example.dart',
            file: buildReportStub(metrics: [
              buildMetricValueStub(
                id: 'technical-debt',
                value: 10,
                unitType: 'USD',
              ),
            ]),
            classes: Map.unmodifiable(<String, Report>{}),
            functions: Map.unmodifiable(<String, Report>{}),
            issues: const [],
            antiPatternCases: const [],
          ),
          LintFileReport(
            path: '/home/dev/project/lib/example.dart',
            relativePath: 'lib/example.dart',
            file: buildReportStub(),
            classes: Map.unmodifiable(<String, Report>{}),
            functions: Map.unmodifiable(<String, Report>{}),
            issues: const [],
            antiPatternCases: const [],
          ),
        ]);

        expect(
          result.firstWhere((r) => r.title == 'Scanned folders').value,
          containsAll(<String>['bin', 'lib']),
        );
        expect(
          result.firstWhere((r) => r.title == 'Total scanned files').value,
          equals(2),
        );
        expect(
          result.firstWhere((r) => r.title == 'Total tech debt').value,
          equals('10 USD'),
        );
      });

      test('should not fix files', () async {
        final basePath =
            '${Directory.current.path}/test/resources/lint_analyzer';
        final fixedExamplePath = '$basePath/lint_fix_fixed_example.dart';

        final originalFixedExampleContent =
            await File(fixedExamplePath).readAsString();

        final config = _createConfig(
          excludePatterns: [
            'test/resources/lint_analyzer/lint_analyzer_example.dart',
            'test/resources/lint_analyzer/lint_analyzer_exclude_example.dart',
            'test/resources/lint_analyzer/lint_fix_original_example.dart',
          ],
          rules: {
            PreferFirstOrNullRule.ruleId: {},
          },
        );

        await analyzer.runCliFix(
          folders,
          rootDirectory,
          config,
        );

        final fixedExampleContent = await File(fixedExamplePath).readAsString();

        expect(
          originalFixedExampleContent,
          equals(fixedExampleContent),
        );
      });

      test('should fix files', () async {
        final basePath =
            '${Directory.current.path}/test/resources/lint_analyzer';
        final originalExamplePath = '$basePath/lint_fix_original_example.dart';
        final fixedExamplePath = '$basePath/lint_fix_fixed_example.dart';

        final originalExampleContent =
            await File(originalExamplePath).readAsString();

        final config = _createConfig(
          rules: {
            PreferFirstOrNullRule.ruleId: {},
          },
        );

        await analyzer.runCliFix(
          folders,
          rootDirectory,
          config,
        );

        final modifiedExampleContent =
            await File(originalExamplePath).readAsString();
        final fixedExampleContent = await File(fixedExamplePath).readAsString();

        expect(
          modifiedExampleContent,
          equals(fixedExampleContent),
        );

        await File(originalExamplePath).writeAsString(originalExampleContent);
      });
    },
    testOn: 'posix',
  );
}

LintConfig _createConfig({
  Map<String, Map<String, Object>> antiPatterns = const {},
  Iterable<String> excludePatterns = const [],
  Map<String, Object> metrics = const {},
  Iterable<String> excludeForMetricsPatterns = const [],
  Map<String, Map<String, Object>> rules = const {},
  Iterable<String> excludeForRulesPatterns = const [],
  bool shouldPrintConfig = false,
  String analysisOptionsPath = '',
}) =>
    LintConfig(
      antiPatterns: antiPatterns,
      excludePatterns: excludePatterns,
      metrics: metrics,
      excludeForMetricsPatterns: excludeForMetricsPatterns,
      rules: rules,
      excludeForRulesPatterns: excludeForRulesPatterns,
      shouldPrintConfig: shouldPrintConfig,
      analysisOptionsPath: analysisOptionsPath,
    );

LintFileReport reportForFile(
  Iterable<LintFileReport> reports,
  String fileName,
) =>
    reports.firstWhere((report) => report.relativePath.endsWith(fileName));
