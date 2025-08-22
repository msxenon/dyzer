import 'dart:isolate';

import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer_plugin/starter.dart';

import '../../cli_runner.dart';
import 'analyzer_plugin.dart';

void start(Iterable<String> _, SendPort sendPort) {
  Logger(tag: 'analyzer_plugin_starter').info('Starting Dyzer plugin');

  final plugin =
      AnalyzerPlugin(resourceProvider: PhysicalResourceProvider.INSTANCE);

  ServerPluginStarter(plugin).start(sendPort);
}
