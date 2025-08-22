import 'dart:io';

import 'package:logger/logger.dart';

class HttpLogOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    event.lines.forEach(_postSilently);
  }

  Future<void> _postSilently(String line) async {
    try {
      final request =
          await HttpClient().postUrl(Uri.parse('http://localhost:8080/log'));
      request.headers.contentType = ContentType.text;
      request.write(line);
      await request.close();
    // ignore: avoid_catches_without_on_clauses
    } catch (_) {}
  }
}
