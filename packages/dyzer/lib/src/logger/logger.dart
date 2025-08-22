import 'dart:convert';
import 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:logger/logger.dart' as logger_package;

import '../utils/environment_utils.dart';
import 'dyzer_pretty_printer.dart';
import 'http_log_output.dart';
import 'io_sink_output.dart';
import 'plain_printer.dart';
import 'progress.dart';

final errorPen = AnsiPen()..rgb(r: 0.88, g: 0.32, b: 0.36);
final warningPen = AnsiPen()..rgb(r: 0.98, g: 0.68, b: 0.4);
final okPen = AnsiPen()..rgb(r: 0.23, g: 0.61, b: 0.16);

class Logger {
  // ignore: avoid-late-keyword
  late final _logger = logger_package.Logger(
    filter: logger_package.ProductionFilter(),
    output: logger_package.MultiOutput(
        [HttpLogOutput(), if (_output != null) IOSinkOutput(_output!)]),
    level: logger_package.Level.all,
    printer: EnvironmentUtils.isTestEnv
        ? PlainPrinter()
        : DyzerPrettyPrinter(
            methodCount: 8,
            errorMethodCount: 8,
            lineLength: 120,
            colors: true,
            printEmojis: true,
            dateTimeFormat: logger_package.DateTimeFormat.onlyTimeAndSinceStart,
            tag: tag,
          ),
  );
  final IOSink? _output;

  final progress = Progress(okPen, warningPen, errorPen);
  static const List<String> pathContains = [];
  bool _isVerbose = false;
  bool get isVerbose => _isVerbose;

  set isVerbose(bool value) {
    _isVerbose = value;

    progress.updateShowProgress = !(_isSilent || _isVerbose);
  }

  bool _isSilent = false;
  bool get isSilent => _isSilent;
  set isSilent(bool value) {
    _isSilent = value;

    progress.updateShowProgress = !(_isSilent || _isVerbose);
  }

  final String tag;
  final _queue = <String>[];

  Logger({
    required this.tag,
    IOSink? output,
  }) : _output = output;
  bool _isAllowedPath(String? path) {
    if (path == null || path.isEmpty || pathContains.isEmpty) {
      return true;
    }
    return pathContains.any((p) => path.contains(p));
  }

  void d(String message, {String? path}) {
    if (_isAllowedPath(path)) {
      _logger.d(message);
    }
  }

  void info(String message, {String? path}) {
    if (_isAllowedPath(path)) {
      _logger.i(message);
    }
  }

  void infoVerbose(String message, {String? path}) {
    if (_isVerbose && _isAllowedPath(path)) {
      _logger.t(message);
    }
  }

  void error(String message) {
    _logger.e(message);
  }

  // ignore: type_annotate_public_apis, inference_failure_on_untyped_parameter
  void e(message, StackTrace stackTrace) {
    _logger.e(message, stackTrace: stackTrace);
  }

  void warn(String message, {String tag = 'WARN', String? path}) {
    if (_isAllowedPath(path)) {
      _logger.w(warningPen('[$tag] $message'));
    }
  }

  void printConfig(Map<String, Object?> config) {
    if (!_isSilent) {
      const encoder = JsonEncoder.withIndent('  ');
      final prettyprint = encoder.convert(config);
      _logger.w('\n${okPen('⚙️ Merged config:')}$prettyprint\n');
    }
  }

  void updateAvailable(
    String version,
    String newVersion,
    String changelogLink,
  ) {
    if (!_isSilent) {
      _logger.d(
          '\n🆕 Update available! ${warningPen('$version -> $newVersion')}\n🆕 Changelog: ${warningPen(changelogLink)}');
    }
  }

  void success(String message) {
    _logger.i(okPen(message));
  }

  void delayed(String message) => _queue.add(message);

  void flush([void Function(String)? print]) {
    final writeln = print ?? info;

    _queue
      ..forEach(writeln)
      ..clear();
  }

  /// Prompts user with a yes/no question.
  bool confirm(String message, {bool defaultValue = false}) {
    info(message);

    final input = stdin.readLineSync()?.trim();
    final response = input == null || input.isEmpty
        ? defaultValue
        : input.toBoolean() ?? defaultValue;

    stdout.writeln('$message: ${response ? 'Yes' : 'No'}');

    return response;
  }
}

extension on String {
  bool? toBoolean() {
    switch (toLowerCase()) {
      case 'y':
      case 'yea':
      case 'yeah':
      case 'yep':
      case 'yes':
      case 'yup':
        return true;
      case 'n':
      case 'no':
      case 'nope':
        return false;
      default:
        return null;
    }
  }
}
