import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';

import '../../cli_runner.dart';
import '../cli/commands/baseline_command.dart';
import '../cli/models/baseline_model.dart';

class BaselineReaderProvider {
  static bool _isInProcess = false;
  static BaselineModel? _instance;
  static String _rootFolder = '';

  BaselineModel? call(String rootFolder, {bool force = false}) {
    try {
      if (_isInProcess) {
        return null;
      }
      if (_instance != null && _rootFolder == rootFolder && !force) {
        return _instance;
      }
      _rootFolder = rootFolder;

      final jsonString = readAsString(rootFolder);
      if (jsonString == null) {
        return null;
      }
      final jsonMap = json.decode(jsonString);

      final baseline = BaselineModel.fromMap(jsonMap as Map<String, dynamic>);

      return _instance = baseline;
      // ignore: avoid_catches_without_on_clauses
    } catch (e, s) {
      Logger(tag: '$BaselineModel').e(e, s);
    }

    return null;
  }

  String? readAsString(String rootFolder) {
    final jsonFile = File(join(rootFolder, BaselineCommand.baselineFileName));
    if (!jsonFile.existsSync()) {
      return null;
    }
    Logger(tag: '$BaselineModel')
        .info('Reading baseline from: ${jsonFile.path}');

    return jsonFile.readAsStringSync();
  }

  void pause() {
    _isInProcess = true;
  }

  // ignore: use_setters_to_change_properties
  void assignInstance(BaselineModel instance, String rootFolder) {
    _instance = instance;
    _rootFolder = rootFolder;
  }

  void resume() {
    _isInProcess = false;
  }

  /// Cleanup method to prevent static memory leaks
  static void cleanup() {
    _instance = null;
    _rootFolder = '';
  }

  /// Switch to a new project and cleanup old data
  void switchProject(String newRootFolder) {
    cleanup();
    _rootFolder = newRootFolder;
  }
}
