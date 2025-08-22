// ignore_for_file: public_member_api_docs, cancel_subscriptions, implementation_imports, prefer_expression_function_bodies, prefer_final_locals, avoid-late-keyword
import 'dart:async';

import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/src/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/src/dart/analysis/byte_store.dart';
import 'package:analyzer/src/dart/analysis/file_content_cache.dart';
import 'package:analyzer_plugin/plugin/plugin.dart';
import 'package:analyzer_plugin/protocol/protocol.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart' as plugin;
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

import '../../cli_runner.dart';
import '../../config.dart';
import '../analyzers/lint_analyzer/lint_analysis_config.dart';
import '../analyzers/lint_analyzer/lint_analysis_options_validator.dart';
import '../analyzers/lint_analyzer/lint_analyzer.dart';
import '../analyzers/lint_analyzer/metrics/metrics_list/number_of_parameters/number_of_parameters_metric.dart';
import '../analyzers/lint_analyzer/metrics/metrics_list/source_lines_of_code/source_lines_of_code_metric.dart';
import '../cli/commands/baseline_command.dart';
import '../providers/baseline_model_reader.dart';
import '../version.dart';
import 'analyzer_plugin_utils.dart';

class AnalyzerPlugin extends ServerPlugin {
  final _configs = <String, LintAnalysisConfig>{};

  AnalysisContextCollectionImpl? _contextCollection;

  @override
  String get contactInfo => 'https://github.com/msxenon/dyzer/issues';

  @override
  List<String> get fileGlobsToAnalyze =>
      const ['*.dart', '*.yaml', BaselineCommand.baselineFileName];

  @override
  String get name => 'Dyzer $packageVersion';

  @override
  String get version => packageVersion;

  late final ByteStore _byteStore = createByteStore();
  String? _sdkPath;

  AnalyzerPlugin({
    required super.resourceProvider,
  }) {
    final location = resourceProvider.getStateLocation('.dyzer-uuid');
    if (location == null) {
      return;
    }

    var uuid = '';

    final file = location.getChildAssumingFile('uuid');
    if (!file.exists) {
      uuid = const Uuid().v4();
      file.writeAsStringSync(uuid);
    } else {
      uuid = file.readAsStringSync();
    }
  }

  @override
  Future<void> afterNewContextCollection({
    required AnalysisContextCollection contextCollection,
  }) {
    _contextCollection = contextCollection as AnalysisContextCollectionImpl;

    contextCollection.contexts.forEach(_createConfig);

    return super
        .afterNewContextCollection(contextCollection: contextCollection);
  }

  void _createConfig(AnalysisContext analysisContext) {
    final rootPath = analysisContext.contextRoot.root.path;
    final file = analysisContext.contextRoot.optionsFile;

    if (file != null && file.exists) {
      final analysisOptions = analysisOptionsFromContext(analysisContext) ??
          analysisOptionsFromFilePath(file.parent.path, analysisContext);
      final config = ConfigBuilder.getLintConfigFromOptions(analysisOptions);

      final lintConfig = ConfigBuilder.getLintAnalysisConfig(
        config,
        analysisOptions.folderPath ?? rootPath,
        classMetrics: const [],
        functionMetrics: [
          NumberOfParametersMetric(config: config.metrics),
          SourceLinesOfCodeMetric(config: config.metrics),
        ],
      );

      _configs[rootPath] = lintConfig;

      _validateAnalysisOptions(lintConfig, rootPath);
    }
  }

  @override
  Future<void> analyzeFile({
    required AnalysisContext analysisContext,
    required String path,
  }) async {
    final isAnalyzed = analysisContext.contextRoot.isAnalyzed(path);
    if (!isAnalyzed) {
      return;
    }

    final rootPath = analysisContext.contextRoot.root.path;

    if (path.endsWith('analysis_options.yaml')) {
      final config = _configs[rootPath];
      if (config != null) {
        _validateAnalysisOptions(config, rootPath);
      }
    }
    try {
      final resolvedUnit =
          await analysisContext.currentSession.getResolvedUnit(path);

      if (resolvedUnit is ResolvedUnitResult) {
        final analysisErrors =
            _getErrorsForResolvedUnit(resolvedUnit, rootPath);

        channel.sendNotification(
          plugin.AnalysisErrorsParams(
            path,
            analysisErrors.map((analysisError) => analysisError.error).toList(),
          ).toNotification(),
        );
      } else {
        channel.sendNotification(
          plugin.AnalysisErrorsParams(path, []).toNotification(),
        );
      }
    } on Exception catch (e, stackTrace) {
      Logger(tag: '$AnalyzerPlugin')
          .e('Error analyzing file $path: $e', stackTrace);
      channel.sendNotification(
        plugin.PluginErrorParams(false, e.toString(), stackTrace.toString())
            .toNotification(),
      );
    }
  }

  @override
  Future<plugin.EditGetFixesResult> handleEditGetFixes(
    plugin.EditGetFixesParams parameters,
  ) async {
    try {
      final path = parameters.file;
      final analysisContext = _contextCollection?.contextFor(path);
      final resolvedUnit =
          await analysisContext?.currentSession.getResolvedUnit(path);

      if (analysisContext != null && resolvedUnit is ResolvedUnitResult) {
        final analysisErrors = _getErrorsForResolvedUnit(
          resolvedUnit,
          analysisContext.contextRoot.root.path,
        ).where((analysisError) {
          final location = analysisError.error.location;

          return location.file == parameters.file &&
              location.offset <= parameters.offset &&
              parameters.offset <= location.offset + location.length &&
              analysisError.fixes.isNotEmpty;
        }).toList();

        return plugin.EditGetFixesResult(analysisErrors);
      }

      // // Cleanup after processing fixes to free memory
      // _monitorMemoryUsage();
    } on Exception catch (e, stackTrace) {
      channel.sendNotification(
        plugin.PluginErrorParams(false, e.toString(), stackTrace.toString())
            .toNotification(),
      );
    }

    return plugin.EditGetFixesResult([]);
  }

  Iterable<plugin.AnalysisErrorFixes> _getErrorsForResolvedUnit(
    ResolvedUnitResult analysisResult,
    String rootPath,
  ) {
    final result = <plugin.AnalysisErrorFixes>[];
    final config = _configs[rootPath];
    if (config != null) {
      final report =
          LintAnalyzer(Logger(tag: 'AnalyzerPlugin'), skipBaseline: false)
              .runPluginAnalysis(analysisResult, config, rootPath);

      if (report != null) {
        result.addAll([
          ...report.issues,
          ...report.antiPatternCases,
        ].map((issue) => codeIssueToAnalysisErrorFixes(issue, analysisResult)));
      }
    }

    return result;
  }

  void _validateAnalysisOptions(LintAnalysisConfig config, String rootPath) {
    if (config.analysisOptionsPath == null) {
      return;
    }

    final result = <plugin.AnalysisErrorFixes>[];

    final report =
        LintAnalysisOptionsValidator.validateOptions(config, rootPath);
    if (report != null) {
      result.addAll(report.issues.map(
        (issue) => codeIssueToAnalysisErrorFixes(issue, null),
      ));
    }

    channel.sendNotification(
      plugin.AnalysisErrorsParams(
        config.analysisOptionsPath!,
        result.map((analysisError) => analysisError.error).toList(),
      ).toNotification(),
    );
  }

  @override
  void onError(Object exception, StackTrace stackTrace) {
    Logger(tag: '$AnalyzerPlugin').e(exception, stackTrace);

    super.onError(exception, stackTrace);
  }

  @override
  Future<AnalysisSetContextRootsResult> handleAnalysisSetContextRoots(
      AnalysisSetContextRootsParams parameters) async {
    var currentContextCollection = _contextCollection;
    if (currentContextCollection != null) {
      _contextCollection = null;
      await beforeContextCollectionDispose(
        contextCollection: currentContextCollection,
      );
      await currentContextCollection.dispose();
    }

    var includedPaths = parameters.roots.map((e) => e.root).toList();
    var contextCollection = AnalysisContextCollectionImpl(
      resourceProvider: resourceProvider,
      includedPaths: includedPaths,
      byteStore: _byteStore,
      sdkPath: _sdkPath,
      fileContentCache: FileContentCache(resourceProvider),
    );
    _contextCollection = contextCollection;
    await afterNewContextCollection(
      contextCollection: contextCollection,
    );
    return AnalysisSetContextRootsResult();
  }

  @override
  Future<void> contentChanged(List<String> paths) async {
    var forceUseFinalPaths = false;
    final contextCollection = _contextCollection;
    if (contextCollection != null) {
      final baselinePath = paths.firstWhereOrNull(
          (e) => e.endsWith(BaselineCommand.baselineFileName));
      if (baselinePath != null && paths.length == 1) {
        final rootFolder = dirname(baselinePath);
        final updatedBaselineFiles = await getUpdatedBaselineFiles(rootFolder);
        if (updatedBaselineFiles == null) {
          return;
        }

        for (final baselineFilePath in updatedBaselineFiles) {
          final fullBaselineFilePath =
              join(rootFolder, relative(baselineFilePath));
          paths.add(fullBaselineFilePath);
        }
        forceUseFinalPaths = true;
      }
      await _forAnalysisContexts(contextCollection, (analysisContext) async {
        if (forceUseFinalPaths) {
          final analyzedFiles = analysisContext.contextRoot.analyzedFiles();
          if (paths.any(analyzedFiles.contains)) {
            paths.forEach(analysisContext.changeFile);
            await analysisContext.applyPendingFileChanges();
            await handleAffectedFiles(
              analysisContext: analysisContext,
              paths: paths,
            );
          }
        } else {
          paths.forEach(analysisContext.changeFile);
          var affected = await analysisContext.applyPendingFileChanges();
          await handleAffectedFiles(
            analysisContext: analysisContext,
            paths: affected,
          );
        }
      });
    }
  }

  @override
  Future<void> flushAnalysisState({
    bool elementModels = true,
  }) async {
    var contextCollection = _contextCollection;
    if (contextCollection != null) {
      for (final analysisContext in contextCollection.contexts) {
        if (elementModels) {
          analysisContext.driver.clearLibraryContext();
        }
      }
    }
  }

  @override
  Future<ResolvedUnitResult> getResolvedUnitResult(String path) async {
    var contextCollection = _contextCollection;
    if (contextCollection != null) {
      var analysisContext = contextCollection.contextFor(path);
      var analysisSession = analysisContext.currentSession;
      var unitResult = await analysisSession.getResolvedUnit(path);
      if (unitResult is ResolvedUnitResult) {
        return unitResult;
      }
    }
    // Return an error from the request.
    throw RequestFailure(
      RequestErrorFactory.pluginError('Failed to analyze $path', null),
    );
  }

  Future<void> _forAnalysisContexts(
    AnalysisContextCollection contextCollection,
    Future<void> Function(AnalysisContext analysisContext) f,
  ) async {
    final nonPriorityAnalysisContexts = <AnalysisContext>[];
    for (final analysisContext in contextCollection.contexts) {
      if (_isPriorityAnalysisContext(analysisContext)) {
        await f(analysisContext);
      } else {
        nonPriorityAnalysisContexts.add(analysisContext);
      }
    }

    for (final analysisContext in nonPriorityAnalysisContexts) {
      await f(analysisContext);
    }
  }

  bool _isPriorityAnalysisContext(AnalysisContext analysisContext) {
    return priorityPaths.any(analysisContext.contextRoot.isAnalyzed);
  }

  @override
  Future<PluginVersionCheckResult> handlePluginVersionCheck(
      PluginVersionCheckParams parameters) async {
    _sdkPath = parameters.sdkPath;

    return super.handlePluginVersionCheck(parameters);
  }

  // After changing the baseline, we need to get the updated files to analyze, doing directly will get the last saved
  // baseline, not the updated one.
  Future<List<String>?> getUpdatedBaselineFiles(
    String rootFolder, {
    int retries = 10,
    Duration interval = const Duration(milliseconds: 300),
  }) async {
    var lastContent = BaselineReaderProvider()(rootFolder);
    final lastContentFiles = lastContent?.files.keys.toList();
    for (var i = 0; i < retries; i++) {
      final content = BaselineReaderProvider()(rootFolder, force: true);
      if (content == null) {
        // Baseline deleted
        return lastContentFiles;
      }
      if (content != lastContent) {
        // Updated baseline found
        BaselineReaderProvider().assignInstance(content, rootFolder);

        return <String>{...content.files.keys, ...lastContentFiles ?? []}
            .nonNulls
            .toList();
      }
      lastContent = content;

      await Future<void>.delayed(interval);
    }

    return null;
  }
}
