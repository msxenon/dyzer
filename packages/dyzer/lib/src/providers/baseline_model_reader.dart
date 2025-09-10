import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:path/path.dart';

import '../../cli_runner.dart';
import '../cli/commands/baseline_command.dart';
import '../cli/models/baseline_model.dart';
import '../utils/analyzer_utils.dart';

class BaselineReaderProvider {
  static bool _isInProcess = false;
  @visibleForTesting
  static final Map<String, BaselineModel> rootFolderAndBaselineMap = {};
  static final Map<String, String> rootFolderAndBaselineHashMap = {};

  String? getBaselineHash(String rootFolder, {bool force = false}) {
    final currentHash = rootFolderAndBaselineHashMap[rootFolder];
    if (currentHash != null && !force) {
      return currentHash;
    }
    final jsonString = _readAsString(rootFolder);
    if (jsonString == null) {
      rootFolderAndBaselineHashMap.remove(rootFolder);

      return null;
    }
    final jsonHash = const AnalyzerUtils().hashString(jsonString);
    rootFolderAndBaselineHashMap[rootFolder] = jsonHash;

    return jsonHash;
  }

  BaselineModel? call(String rootFolder, {bool force = false}) {
    try {
      if (_isInProcess) {
        return null;
      }
      if (!force && rootFolderAndBaselineMap.keys.contains(rootFolder)) {
        return rootFolderAndBaselineMap[rootFolder];
      }

      final jsonString = _readAsString(rootFolder);
      if (jsonString == null) {
        rootFolderAndBaselineMap.remove(rootFolder);
        rootFolderAndBaselineHashMap.remove(rootFolder);

        return null;
      }
      final jsonHash = const AnalyzerUtils().hashString(jsonString);
    
      final jsonMap = json.decode(jsonString);
      Logger(tag: '$BaselineModel').info(
        'Reading baseline from: $rootFolder, $force',
      );
      final baseline = BaselineModel.fromMap(jsonMap as Map<String, dynamic>);

      rootFolderAndBaselineMap[rootFolder] = baseline;
      rootFolderAndBaselineHashMap[rootFolder] = jsonHash;
      Logger(tag: '$BaselineModel').info(
        'Reading baseline from: $rootFolder, $force =>> Completed',
      );

      return baseline;
      // ignore: avoid_catches_without_on_clauses
    } catch (e, s) {
      Logger(tag: '$BaselineModel').e(e, s);
    }

    return null;
  }

  String? _readAsString(String rootFolder) {
    final jsonFile = File(join(rootFolder, BaselineCommand.baselineFileName));
    if (!jsonFile.existsSync()) {
      return null;
    }

    return jsonFile.readAsStringSync();
  }

  void pause() {
    _isInProcess = true;
  }

  @visibleForTesting
  void assignInstance(BaselineModel instance, String rootFolder) {
    rootFolderAndBaselineMap[rootFolder] = instance;
  }

  void resume() {
    _isInProcess = false;
  }

  void clearInstances() {
    rootFolderAndBaselineMap.clear();
  }
}
