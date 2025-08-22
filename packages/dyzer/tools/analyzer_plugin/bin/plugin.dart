import 'dart:isolate';

import 'package:dyzer/analyzer_plugin.dart';

void main(List<String> args, SendPort sendPort) {
  start(args, sendPort);
}
