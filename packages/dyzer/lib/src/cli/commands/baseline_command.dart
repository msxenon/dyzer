// ignore_for_file: public_member_api_docs, unused_local_variable
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import '../../../config.dart';
import '../../../lint_analyzer.dart';
import '../../analyzers/lint_analyzer/metrics/metrics_factory.dart';
import '../../logger/logger.dart';
import '../../providers/baseline_model_reader.dart';
import '../../version.dart';
import '../models/baseline_model.dart';
import '../models/flag_names.dart';
import '../models/lint_file_model.dart';
import 'base_command.dart';

class BaselineCommand extends BaseCommand {
  final Logger _logger;
  static const String baselineFileName = '.dyzer_baseline.json';
  @override
  String get name => 'baseline';

  @override
  String get description =>
      'Automatically fix code issues based on lint rules and metrics.';

  @override
  String get invocation =>
      '${runner?.executableName} $name [arguments] <directories>';

  BaselineCommand(super.analyzerUtils, this._logger) {
    _addFlags();
  }

  @override
  Future<void> runCommand() async {
    final baselineModelReader = BaselineReaderProvider();
    try {
      _logger
        ..isSilent = isNoCongratulate
        ..isVerbose = isVerbose
        ..progress.start('Analyzing')
        ..info('Running baseline command with args: $argResults');
      final parsedArgs = ParsedArguments.fromArgs(argResults);

      final config = ConfigBuilder.getLintConfigFromArgs(parsedArgs);

      final jsonReportPath = parsedArgs.jsonReportPath;
      final rootFolder = parsedArgs.rootFolder;

      baselineModelReader.pause();

      final lintAnalyzerResult =
          await LintAnalyzer(_logger, skipBaseline: true).runCliAnalysis(
        argResults.rest,
        rootFolder,
        config,
        sdkPath: findSdkPath(),
      );

      _logger.progress
          .complete('Analysis is completed. Writing $baselineFileName');

      final baselineModel = BaselineModel(
        files: SplayTreeMap<String, LintFileModel>(),
        createdAt: DateTime.now(),
        version: packageVersion,
        baselinedFiles: 0,
        baselinedIssues: 0,
      );
      for (final fileReport in lintAnalyzerResult) {
        final content = File(fileReport.path).readAsStringSync();
        final path = fileReport.path.replaceFirst(rootFolder, '');
        baselineModel.files
          ..putIfAbsent(
            path,
            () => LintFileModel.fromIssues([
              ...fileReport.issues,
              ...fileReport.antiPatternCases,
            ], content),
          )
          ..removeWhere((_, lintFile) => lintFile.lints.isEmpty);
      }
      final baselinedFiles = baselineModel.files.length;
      final baselinedIssues = baselineModel.files.values.fold<int>(
        0,
        (previousValue, element) =>
            previousValue +
            element.lints.values.fold<int>(
              0,
              (prev, ignoredIssues) => prev + ignoredIssues.length,
            ),
      );
      final baselineNewContent = const JsonEncoder.withIndent('  ').convert(
        baselineModel
            .copyWith(
                baselinedFiles: baselinedFiles,
                baselinedIssues: baselinedIssues)
            .toMap(),
      );
      final baselineFile = File('$rootFolder/$baselineFileName');
      if (baselineFile.existsSync()) {
        baselineFile.deleteSync();
      }
      baselineFile
        ..createSync()
        ..writeAsStringSync(
          baselineNewContent,
          mode: FileMode.write,
        );
      _logger.info('Baseline file $baselineFileName created successfully.');
      // ignore: avoid_catches_without_on_clauses
    } catch (e, s) {
      _logger
        ..error('An error occurred while running the baseline command: $e')
        ..infoVerbose('Stack trace: $s');

      exit(1);
    } finally {
      baselineModelReader.resume();
    }
  }

  void _addFlags() {
    _usesReporterOption();
    _usesMetricsThresholdOptions();
    addCommonFlags();
    _usesExitOption();
  }

  void _usesReporterOption() {
    argParser
      ..addSeparator('')
      ..addOption(
        FlagNames.reporter,
        abbr: 'r',
        help: 'The format of the output of the analysis.',
        valueHelp: FlagNames.consoleReporter,
        allowed: [
          FlagNames.consoleReporter,
          FlagNames.consoleVerboseReporter,
          FlagNames.checkstyleReporter,
          FlagNames.codeClimateReporter,
          FlagNames.githubReporter,
          FlagNames.gitlabCodeClimateReporter,
          FlagNames.htmlReporter,
          FlagNames.jsonReporter,
        ],
        defaultsTo: FlagNames.consoleReporter,
      )
      ..addOption(
        FlagNames.reportFolder,
        abbr: 'o',
        help: 'Write HTML output to OUTPUT.',
        valueHelp: 'OUTPUT',
        defaultsTo: 'metrics',
      )
      ..addOption(
        FlagNames.jsonReportPath,
        help: 'Path to the JSON file with the output of the analysis.',
        valueHelp: 'path/to/file.json',
        defaultsTo: null,
      );
  }

  void _usesMetricsThresholdOptions() {
    argParser.addSeparator('');

    for (final metric in getMetrics(config: {})) {
      argParser.addOption(
        metric.id,
        help: '${metric.documentation.name} threshold.',
        valueHelp: '${metric.documentation.recommendedThreshold}',
        callback: (i) {
          if (i != null && int.tryParse(i) == null) {
            _logger.warn(
              "'$i' invalid value for argument ${metric.documentation.name}",
            );
          }
        },
      );
    }
  }

  void _usesExitOption() {
    argParser
      ..addSeparator('')
      ..addOption(
        FlagNames.setExitOnViolationLevel,
        allowed: ['noted', 'warning', 'alarm'],
        valueHelp: 'warning',
        help:
            'Set exit code 2 if code violations same or higher level than selected are detected.',
      )
      ..addFlag(
        FlagNames.fatalStyle,
        help: 'Treat style level issues as fatal.',
      )
      ..addFlag(
        FlagNames.fatalPerformance,
        help: 'Treat performance level issues as fatal.',
      )
      ..addFlag(
        FlagNames.fatalWarnings,
        help: 'Treat warning level issues as fatal.',
        defaultsTo: true,
      )
      ..addOption(
        FlagNames.fatalWarningsThreshold,
        help: 'Number of warnings to treat as fatal.',
        valueHelp: 'all',
        defaultsTo: null,
      )
      ..addOption(
        FlagNames.fatalPerformanceThreshold,
        help: 'Number of performance issues to treat as fatal.',
        valueHelp: 'all',
        defaultsTo: null,
      )
      ..addOption(
        FlagNames.fatalStyleThreshold,
        help: 'Number of style issues to treat as fatal.',
        valueHelp: 'all',
        defaultsTo: null,
      );
  }
}
