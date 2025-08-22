import 'dart:io';

import 'package:logger/logger.dart';

class IOSinkOutput extends LogOutput {
  final IOSink _output;

  IOSinkOutput(this._output);

  @override
  void output(OutputEvent event) {
    event.lines.forEach(_output.writeln);
  }
}
