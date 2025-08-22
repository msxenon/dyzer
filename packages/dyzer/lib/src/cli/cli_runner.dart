import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:pub_updater/pub_updater.dart';

import '../logger/logger.dart';
import '../utils/analyzer_utils.dart';
import '../version.dart';
import 'commands/analyze_command.dart';
import 'commands/baseline_command.dart';
import 'commands/check_unnecessary_nullable_command.dart';
import 'commands/check_unused_code_command.dart';
import 'commands/check_unused_files_command.dart';
import 'commands/check_unused_l10n_command.dart';
import 'commands/fix_lints_command.dart';
import 'models/flag_names.dart';

/// Represents a cli runner responsible
/// for running a command based on raw cli call data.
class CliRunner extends CommandRunner<void> {
  final Logger _logger;

  final PubUpdater? _pubUpdater;

  CliRunner([IOSink? output, PubUpdater? pubUpdater])
      : _logger = Logger(output: output, tag: 'CliRunner'),
        _pubUpdater = pubUpdater ?? PubUpdater(),
        super('metrics', 'Analyze and improve your code quality.') {
    const analyzerUtils = AnalyzerUtils();
    [
      AnalyzeCommand(analyzerUtils, _logger),
      CheckUnusedFilesCommand(analyzerUtils, _logger),
      CheckUnusedL10nCommand(analyzerUtils, _logger),
      CheckUnusedCodeCommand(analyzerUtils, _logger),
      CheckUnnecessaryNullableCommand(analyzerUtils, _logger),
      FixLintsCommand(analyzerUtils, _logger),
      BaselineCommand(
          analyzerUtils, Logger(output: output, tag: '$BaselineCommand')),
    ].forEach(addCommand);

    _usesVersionOption();
  }

  /// Represents the invocation string message.
  @override
  String get invocation => '${super.invocation} <directories>';

  /// Main entry point for running a command.
  @override
  Future<void> run(Iterable<String> args) async {
    try {
      final argsWithDefaultCommand = _addDefaultCommand(args);

      final results = parse(argsWithDefaultCommand);
      final showVersion = results[FlagNames.version] as bool;

      if (showVersion) {
        _logger.info('Dyzer version: $packageVersion');

        return;
      }

      await super.run(argsWithDefaultCommand);
    } on UsageException catch (e, s) {
      _logger.e(e.message, s);

      exit(64);
    } on Exception catch (e, s) {
      _logger.e('Oops; metrics has exited unexpectedly: "$e"', s);

      exit(1);
    }

    await _checkForUpdates();

    exit(0);
  }

  Iterable<String> _addDefaultCommand(Iterable<String> args) => args.isEmpty
      ? args
      : !commands.keys.contains(args.first)
          ? ['analyze', ...args]
          : args;

  void _usesVersionOption() {
    argParser
      ..addSeparator('')
      ..addFlag(
        FlagNames.version,
        help: 'Reports the version of this tool.',
        negatable: false,
      );
  }

  Future<void> _checkForUpdates() async {
    try {
      final latestVersion = await _pubUpdater?.getLatestVersion('dyzer');
      final isUpToDate = packageVersion == latestVersion;
      if (!isUpToDate && latestVersion != null) {
        final changelogLink =
            'https://github.com/msxenon/dyzer/releases/tag/v$latestVersion';
        _logger.updateAvailable(packageVersion, latestVersion, changelogLink);
      }
      // ignore: avoid_catches_without_on_clauses
    } catch (_) {}
  }
}
