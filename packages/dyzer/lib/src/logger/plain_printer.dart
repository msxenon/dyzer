import 'dart:convert';

import 'package:logger/logger.dart';

class PlainPrinter extends LogPrinter {
  PlainPrinter();
  @override
  List<String> log(LogEvent event) {
    final messageStr = _stringifyMessage(event.message);

    return [messageStr];
  }

  // ignore: inference_failure_on_untyped_parameter
  String _stringifyMessage(message) {
    // ignore: avoid_dynamic_calls
    final finalMessage = message is Function ? message() : message;
    if (finalMessage is Map || finalMessage is Iterable) {
      const encoder = JsonEncoder.withIndent(null);

      return encoder.convert(finalMessage);
    } else {
      return finalMessage.toString();
    }
  }
}
