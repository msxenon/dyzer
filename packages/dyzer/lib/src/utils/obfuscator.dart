import 'dart:convert';

class Obfuscator {
  /// Encodes a Map into a short, non-human-readable string
  String encode(Map<String, dynamic> data) {
    final jsonStr = jsonEncode(data);
    final encoded = base64Url.encode(utf8.encode(jsonStr));

    return encoded;
  }

  /// Decodes a string back to the original Map
  Map<String, dynamic>? decode(String encoded) {
    try {
      final jsonStr = utf8.decode(base64Url.decode(encoded));

      return jsonDecode(jsonStr) as Map<String, dynamic>;
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      // Handle decoding errors gracefully
      return null;
    }
  }
}
